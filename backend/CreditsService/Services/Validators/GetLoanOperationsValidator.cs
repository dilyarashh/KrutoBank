using FluentValidation;

namespace CreditsService.Services.Validators
{
    /// <summary>
    /// Валидатор для запроса операций по кредиту (параметры маршрута)
    /// </summary>
    public class GetLoanOperationsValidator : AbstractValidator<(Guid userId, Guid loanId)>
    {
        public GetLoanOperationsValidator()
        {
            RuleFor(x => x.userId)
                .NotEmpty().WithMessage("ID пользователя обязателен");

            RuleFor(x => x.loanId)
                .NotEmpty().WithMessage("ID кредита обязателен");
        }
    }
}
