using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using CreditsService.Data;
using Microsoft.EntityFrameworkCore;

namespace CreditsService.Idempotency;

public class IdempotencyMiddleware(RequestDelegate next, ILogger<IdempotencyMiddleware> logger)
{
    public async Task InvokeAsync(HttpContext context, CreditsDbContext dbContext)
    {
        if (!ShouldHandle(context.Request))
        {
            await next(context);
            return;
        }

        if (!context.Request.Headers.TryGetValue("Idempotency-Key", out var values) ||
            string.IsNullOrWhiteSpace(values.ToString()))
        {
            await WriteProblemAsync(context, StatusCodes.Status400BadRequest,
                "Idempotency-Key header is required for this request.");
            return;
        }

        var key = values.ToString().Trim();
        var userScope = context.User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "anonymous";
        var method = context.Request.Method;
        var path = context.Request.Path.Value ?? string.Empty;
        var queryString = context.Request.QueryString.Value ?? string.Empty;
        var requestHash = await ComputeRequestHashAsync(context.Request, method, path, queryString);

        var existing = await FindExistingAsync(dbContext, userScope, key);
        if (existing is not null)
        {
            await HandleExistingAsync(context, existing, requestHash, method, path, queryString);
            return;
        }

        var record = new IdempotencyRequest
        {
            Id = Guid.NewGuid(),
            Key = key,
            UserScope = userScope,
            Method = method,
            RequestPath = path,
            QueryString = queryString,
            RequestHash = requestHash,
            State = "InProgress",
            CreatedAt = DateTime.UtcNow
        };

        dbContext.IdempotencyRequests.Add(record);

        try
        {
            await dbContext.SaveChangesAsync();
        }
        catch (DbUpdateException)
        {
            dbContext.Entry(record).State = EntityState.Detached;
            existing = await FindExistingAsync(dbContext, userScope, key);
            if (existing is not null)
            {
                await HandleExistingAsync(context, existing, requestHash, method, path, queryString);
                return;
            }

            throw;
        }

        var originalBodyStream = context.Response.Body;
        await using var responseBuffer = new MemoryStream();
        context.Response.Body = responseBuffer;

        try
        {
            await next(context);

            responseBuffer.Position = 0;
            var responseBody = await new StreamReader(responseBuffer).ReadToEndAsync();
            responseBuffer.Position = 0;

            if (context.Response.StatusCode >= StatusCodes.Status500InternalServerError)
            {
                dbContext.IdempotencyRequests.Remove(record);
                await dbContext.SaveChangesAsync();
            }
            else
            {
                record.State = "Completed";
                record.ResponseStatusCode = context.Response.StatusCode;
                record.ResponseContentType = context.Response.ContentType;
                record.ResponseBody = responseBody;
                record.CompletedAt = DateTime.UtcNow;
                await dbContext.SaveChangesAsync();
            }

            await responseBuffer.CopyToAsync(originalBodyStream);
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "Idempotent request failed, removing in-progress record for {Path}", path);
            dbContext.IdempotencyRequests.Remove(record);
            await dbContext.SaveChangesAsync();
            throw;
        }
        finally
        {
            context.Response.Body = originalBodyStream;
        }
    }

    private static bool ShouldHandle(HttpRequest request)
    {
        if (!HttpMethods.IsPost(request.Method) &&
            !HttpMethods.IsPatch(request.Method) &&
            !HttpMethods.IsPut(request.Method) &&
            !HttpMethods.IsDelete(request.Method))
        {
            return false;
        }

        var path = request.Path.Value ?? string.Empty;
        if (!path.StartsWith("/api/", StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        return !path.StartsWith("/api/internal/", StringComparison.OrdinalIgnoreCase);
    }

    private static async Task<string> ComputeRequestHashAsync(
        HttpRequest request,
        string method,
        string path,
        string queryString)
    {
        request.EnableBuffering();
        request.Body.Position = 0;

        string body;
        using (var reader = new StreamReader(request.Body, Encoding.UTF8, leaveOpen: true))
        {
            body = await reader.ReadToEndAsync();
        }

        request.Body.Position = 0;

        var payload = $"{method}\n{path}\n{queryString}\n{body}";
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(payload));
        return Convert.ToHexString(bytes);
    }

    private static Task<IdempotencyRequest?> FindExistingAsync(
        CreditsDbContext dbContext,
        string userScope,
        string key)
        => dbContext.IdempotencyRequests
            .AsNoTracking()
            .SingleOrDefaultAsync(x => x.UserScope == userScope && x.Key == key);

    private static async Task HandleExistingAsync(
        HttpContext context,
        IdempotencyRequest existing,
        string requestHash,
        string method,
        string path,
        string queryString)
    {
        if (existing.RequestHash != requestHash ||
            !string.Equals(existing.Method, method, StringComparison.Ordinal) ||
            !string.Equals(existing.RequestPath, path, StringComparison.Ordinal) ||
            !string.Equals(existing.QueryString, queryString, StringComparison.Ordinal))
        {
            await WriteProblemAsync(context, StatusCodes.Status409Conflict,
                "The same Idempotency-Key was already used for a different request.");
            return;
        }

        if (!string.Equals(existing.State, "Completed", StringComparison.Ordinal))
        {
            await WriteProblemAsync(context, StatusCodes.Status409Conflict,
                "A request with the same Idempotency-Key is already being processed.");
            return;
        }

        context.Response.StatusCode = existing.ResponseStatusCode ?? StatusCodes.Status200OK;
        context.Response.ContentType = existing.ResponseContentType ?? "application/json";

        if (!string.IsNullOrEmpty(existing.ResponseBody))
        {
            await context.Response.WriteAsync(existing.ResponseBody);
        }
    }

    private static Task WriteProblemAsync(HttpContext context, int statusCode, string title)
    {
        context.Response.StatusCode = statusCode;
        context.Response.ContentType = "application/json";

        return context.Response.WriteAsJsonAsync(new
        {
            title,
            status = statusCode
        });
    }
}
