using Microsoft.EntityFrameworkCore;
using OpenIddict.EntityFrameworkCore.Models;

namespace AuthService.Data;

public class OpenIddictDbContext(DbContextOptions<OpenIddictDbContext> options) : DbContext(options)
{
    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.UseOpenIddict<OpenIddictEntityFrameworkCoreApplication,
            OpenIddictEntityFrameworkCoreAuthorization,
            OpenIddictEntityFrameworkCoreScope,
            OpenIddictEntityFrameworkCoreToken,
            string>();
    }
}
