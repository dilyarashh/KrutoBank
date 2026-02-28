using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using UsersService.DTOs;
using UsersService.Services;

namespace UsersService.Controllers;

[ApiController]
[Route("api/users")]
public class UsersController(IUserService service) : ControllerBase
{
    /// <summary>
    /// Создать пользователя (доступно только сотруднику)
    /// </summary>
    [Authorize(Roles = "Employee")]
    [HttpPost]
    [ProducesResponseType(typeof(Guid), 200)]
    public async Task<ActionResult<Guid>> Create([FromBody] CreateUserRequest dto)
    {
        var user = await service.CreateUserAsync(dto);
        return Ok(user.Id);
    }
    
    /// <summary>
    /// Заблокировать пользователя (доступно только сотруднику)
    /// </summary>
    [Authorize(Roles = "Employee")]
    [HttpPatch("block/{id}")]
    [ProducesResponseType(204)]
    public async Task<IActionResult> Block(Guid id)
    {
        await service.BlockUserAsync(id);
        return NoContent();
    }

    /// <summary>
    /// Получить информацию о пользователе
    /// </summary>
    [Authorize]
    [HttpGet("{id}")]
    [ProducesResponseType(typeof(UserDto), 200)]
    public async Task<ActionResult<UserDto>> Get(Guid id)
    {
        var user = await service.GetById(id);
        return Ok(user);
    }

    /// <summary>
    /// Получить информацию о пользователях
    /// </summary>
    [Authorize(Roles = "Employee")]
    [HttpGet]
    [ProducesResponseType(typeof(PagedResponse<UserDto>), 200)]
    public async Task<ActionResult<PagedResponse<UserDto>>> GetAll([FromQuery] PagedRequest request)
    {
        var result = await service.GetAllAsync(request);
        return Ok(result);
    }
}