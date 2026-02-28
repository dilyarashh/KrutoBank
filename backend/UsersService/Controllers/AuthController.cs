using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using UsersService.Domain.Entities;
using UsersService.DTOs;
using UsersService.Infrastructure.Auth;
using UsersService.Infrastructure.Repositories;
using UsersService.Infrastructure.Errors.Exceptions;

namespace UsersService.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController(UsersDbContext db, AuthService authService) : ControllerBase
{
    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginRequest request)
    {
        var user = await db.Users.FirstOrDefaultAsync(x => x.Phone == request.Phone);
        if (user == null)
        {
            throw new BadRequestException("Пользователь с таким номером телефона не зарегистрирован");
        }

        if (!BCrypt.Net.BCrypt.Verify(request.Password, user.HashPassword))
        {
            throw new BadRequestException("Неверный пароль");
        }

        if (user.IsBlocked)
        {
            throw new BadRequestException("Пользователь заблокирован");
        } 

        var token = authService.GenerateToken(user);
        return Ok(new { token });
    }

    [HttpPost("logout")]
    [Authorize]
    public async Task<IActionResult> Logout()
    {
        var token = Request.Headers["Authorization"].ToString().Replace("Bearer ", "");
        if (string.IsNullOrEmpty(token))
        {
            throw new BadRequestException("Пользователь не был авторизован");
        }

        await db.BlackTokens.AddAsync(new BlackToken
        {
            Token = token,
            ExpiredAt = DateTime.UtcNow
        });

        await db.SaveChangesAsync();
        return NoContent();
    }
}