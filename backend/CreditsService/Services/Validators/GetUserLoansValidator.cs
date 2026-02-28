using FluentValidation;

namespace CreditsService.Services.Validators
{
    /// <summary>
    /// Валидатор для запроса кредитов пользователя (параметры маршрута)
    /// </summary>
    public class GetUserLoansValidator : AbstractValidator<Guid>
    {
        public GetUserLoansValidator()
        {
            RuleFor(x => x)
                .NotEmpty().WithMessage("ID пользователя обязателен");
        }
    }
}
