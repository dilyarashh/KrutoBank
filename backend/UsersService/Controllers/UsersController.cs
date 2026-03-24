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
    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(UserDto), 200)]
    public async Task<ActionResult<UserDto>> Get(Guid id)
    {
        var user = await service.GetById(id);
        return Ok(user);
    }
    
    /// <summary>
    /// Получить информацию о себе
    /// </summary>
    [Authorize]
    [HttpGet("myself")]
    [ProducesResponseType(typeof(UserDto), 200)]
    public async Task<ActionResult<UserDto>> GetMyself()
    {
        var user = await service.GetMyself();
        return Ok(user);
    }

    /// <summary>
    /// Получить информацию о пользователях
    /// </summary>
    [Authorize(Roles = "Employee")]
    [HttpGet("list")]
    [ProducesResponseType(typeof(PagedResponse<UserDto>), 200)]
    public async Task<ActionResult<PagedResponse<UserDto>>> GetAll([FromQuery] PagedRequest request)
    {
        var result = await service.GetAllAsync(request);
        return Ok(result);
    }

    /// <summary>
    /// Получить пользователя по телефону
    /// </summary>
    [Authorize]
    [HttpGet("phone/{phone}")]
    public async Task<ActionResult<UserDto>> GetByPhone([FromQuery] string phone)
    {
        var user = await service.GetByPhoneAsync(phone);

        return Ok(user);
    }

    [HttpGet("internal/{id}")]
    public async Task<ActionResult<UserDto>> GetInternal(Guid id,
    [FromHeader(Name = "X-Internal-Api-Key")] string apiKey)
    {
        if (apiKey != "KRUTOBANK_INTERNAL_KEY_2026")
            return Unauthorized();

        var user = await service.GetById(id);
        return Ok(user);
    }
}
