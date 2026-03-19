using Microsoft.AspNetCore.Mvc;
using UsersService.Domain.Entities;
using UsersService.DTOs.Internal;
using UsersService.Infrastructure.Repositories;

namespace UsersService.Controllers.Internal;

[ApiController]
[Route("api/internal/users")]
[ApiExplorerSettings(IgnoreApi = true)]
public class InternalUsersController(IUserRepository userRepository, IConfiguration configuration) : ControllerBase
{
    private const string InternalHeader = "X-Internal-Api-Key";

    [HttpGet("by-phone")]
    public async Task<ActionResult<InternalUserAuthDto>> GetByPhone([FromQuery] string phone)
    {
        if (!IsInternalRequest())
        {
            return Unauthorized();
        }

        var user = await userRepository.GetByPhoneAsync(phone);
        if (user is null)
        {
            return NotFound();
        }

        return Ok(ToAuthDto(user));
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<InternalUserAuthDto>> GetById(Guid id)
    {
        if (!IsInternalRequest())
        {
            return Unauthorized();
        }

        var user = await userRepository.GetByIdAsync(id);
        if (user is null)
        {
            return NotFound();
        }

        return Ok(ToAuthDto(user));
    }

    [HttpPost]
    public async Task<ActionResult<Guid>> Create([FromBody] InternalCreateUserRequest request)
    {
        if (!IsInternalRequest())
        {
            return Unauthorized();
        }

        if (request.Birthday > DateOnly.FromDateTime(DateTime.UtcNow))
        {
            return BadRequest("Дата рождения не может быть в будущем");
        }

        if (await userRepository.GetByPhoneAsync(request.Phone) is not null)
        {
            return BadRequest("Телефон уже используется");
        }

        if (await userRepository.GetByEmailAsync(request.Email) is not null)
        {
            return BadRequest("Email уже используется");
        }

        var user = new User
        {
            Id = Guid.NewGuid(),
            FirstName = request.FirstName,
            LastName = request.LastName,
            MiddleName = request.MiddleName,
            Phone = request.Phone,
            Email = request.Email,
            Birthday = request.Birthday,
            HashPassword = request.PasswordHash,
            Role = request.Role,
            IsBlocked = false,
            Created = DateTime.UtcNow
        };

        await userRepository.AddAsync(user);
        return Ok(user.Id);
    }

    [HttpPatch("{id:guid}/password")]
    public async Task<IActionResult> UpdatePassword(Guid id, [FromBody] InternalUpdatePasswordRequest request)
    {
        if (!IsInternalRequest())
        {
            return Unauthorized();
        }

        var user = await userRepository.GetByIdAsync(id);
        if (user is null)
        {
            return NotFound();
        }

        user.HashPassword = request.PasswordHash;
        user.Updated = DateTime.UtcNow;

        await userRepository.UpdateAsync(user);
        return NoContent();
    }

    private bool IsInternalRequest()
    {
        var configuredKey = configuration["InternalApi:Key"];
        if (string.IsNullOrWhiteSpace(configuredKey))
        {
            return false;
        }

        if (!Request.Headers.TryGetValue(InternalHeader, out var key))
        {
            return false;
        }

        return string.Equals(key.ToString(), configuredKey, StringComparison.Ordinal);
    }

    private static InternalUserAuthDto ToAuthDto(User user)
    {
        return new InternalUserAuthDto
        {
            Id = user.Id,
            Phone = user.Phone,
            HashPassword = user.HashPassword,
            Role = user.Role.ToString(),
            IsBlocked = user.IsBlocked
        };
    }
}
