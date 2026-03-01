using CreditsService.DTO;
using CreditsService.Services.Validators;
using FluentValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.DependencyInjection;

namespace CreditsService.Controllers
{
    /// <summary>
    /// Контроллер для управления кредитами, тарифами и операциями
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CreditsController : ControllerBase
    {
        private readonly ICreditService _creditService;
        private readonly ILogger<CreditsController> _logger;
        private readonly IServiceProvider _serviceProvider;

        public CreditsController(ICreditService creditService, ILogger<CreditsController> logger, IServiceProvider serviceProvider)
        {
            _creditService = creditService;
            _logger = logger;
            _serviceProvider = serviceProvider;
        }

        /// <summary>
        /// Создать новый тариф (доступно только сотрудникам)
        /// </summary>
        /// <param name="dto">Данные для создания тарифа (название и процентная ставка)</param>
        /// <returns>Информация о созданном тарифе</returns>
        /// <response code="200">Тариф успешно создан</response>
        /// <response code="400">Ошибка валидации (некорректная ставка или название)</response>
        /// <response code="401">Пользователь не авторизован</response>
        /// <response code="403">Недостаточно прав (только для сотрудников)</response>
        [HttpPost("tariffs")]
        public async Task<ActionResult<TariffResponseDto>> CreateTariff([FromBody] CreateTariffDto dto)
        {
            var validator = _serviceProvider.GetRequiredService<CreateTariffDtoValidator>();
            await validator.ValidateAndThrowAsync(dto);

            var result = await _creditService.CreateTariff(dto);
            return Ok(result);
        }

        /// <summary>
        /// Получить список всех активных тарифов банка
        /// </summary>
        /// <returns>Список тарифов</returns>
        /// <response code="200">Список тарифов успешно получен</response>
        /// <response code="401">Пользователь не авторизован</response>
        [HttpGet("tariffs")]
        public async Task<ActionResult<List<TariffResponseDto>>> GetAllTariffs()
        {
            var result = await _creditService.GetAllTariffs();
            return Ok(result);
        }

        /// <summary>
        /// Оформить новый кредит для клиента
        /// </summary>
        /// <param name="dto">Данные для оформления кредита (ID клиента, название тарифа, сумма)</param>
        /// <returns>Информация о выданном кредите</returns>
        /// <response code="200">Кредит успешно оформлен</response>
        /// <response code="400">Ошибка валидации (некорректная сумма или отсутствие тарифа)</response>
        /// <response code="401">Пользователь не авторизован</response>
        /// <response code="403">Недостаточно прав (только для клиентов)</response>
        /// <response code="404">Тариф с указанным названием не найден</response>
        [HttpPost("loans/take")]
        public async Task<ActionResult<LoanInfoDto>> TakeLoan([FromBody] CreateLoanDto dto)
        {
            var validator = _serviceProvider.GetRequiredService<CreateLoanDtoValidator>();
            await validator.ValidateAndThrowAsync(dto);

            var result = await _creditService.TakeLoan(dto);
            return Ok(result);
        }

        /// <summary>
        /// Произвести частичное или полное погашение кредита
        /// </summary>
        /// <param name="dto">Данные для погашения (ID кредита и сумма)</param>
        /// <returns>Обновленная информация о кредите</returns>
        /// <response code="200">Погашение выполнено успешно</response>
        /// <response code="400">Ошибка валидации (сумма превышает остаток или кредит уже погашен)</response>
        /// <response code="401">Пользователь не авторизован</response>
        /// <response code="403">Недостаточно прав (только владелец кредита)</response>
        /// <response code="404">Кредит с указанным ID не найден</response>
        [HttpPost("loans/repay")]
        public async Task<ActionResult<LoanInfoDto>> RepayLoan([FromBody] RepayLoanDto dto)
        {
            var validator = _serviceProvider.GetRequiredService<RepayLoanDtoValidator>();
            await validator.ValidateAndThrowAsync(dto);

            var result = await _creditService.RepayLoan(dto);
            return Ok(result);
        }

        /// <summary>
        /// Получить список всех кредитов указанного пользователя
        /// </summary>
        /// <param name="userId">ID пользователя</param>
        /// <returns>Список кредитов пользователя с детальной информацией</returns>
        /// <response code="200">Список кредитов успешно получен</response>
        /// <response code="400">Некорректный ID пользователя</response>
        /// <response code="401">Пользователь не авторизован</response>
        /// <response code="403">Недостаточно прав (только сотрудник или сам пользователь)</response>
        [HttpGet("users/{userId}/loans")]
        public async Task<ActionResult<List<LoanInfoDto>>> GetUserLoans(Guid userId)
        {
            if (userId == Guid.Empty)
            {
                throw new ArgumentException("ID пользователя не может быть пустым");
            }

            var result = await _creditService.GetUserLoans(userId);
            return Ok(result);
        }

        /// <summary>
        /// Получить историю операций по конкретному кредиту
        /// </summary>
        /// <param name="userId">ID пользователя-владельца кредита</param>
        /// <param name="loanId">ID кредита</param>
        /// <returns>Список операций (начисления процентов и погашения) с датами и суммами</returns>
        /// <response code="200">Список операций успешно получен</response>
        /// <response code="400">Некорректные ID пользователя или кредита</response>
        /// <response code="401">Пользователь не авторизован</response>
        /// <response code="403">Недостаточно прав (только сотрудник или владелец кредита)</response>
        /// <response code="404">Кредит не найден или не принадлежит указанному пользователю</response>
        [HttpGet("users/{userId}/loans/{loanId}/operations")]
        public async Task<ActionResult<List<LoanOperationDto>>> GetLoanOperations(Guid userId, Guid loanId)
        {
            if (userId == Guid.Empty)
            {
                throw new ArgumentException("ID пользователя не может быть пустым");
            }

            if (loanId == Guid.Empty)
            {
                throw new ArgumentException("ID кредита не может быть пустым");
            }

            var result = await _creditService.GetLoanOperations(userId, loanId);
            return Ok(result);
        }
    }
}
