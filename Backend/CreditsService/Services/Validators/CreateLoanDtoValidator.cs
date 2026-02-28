using CreditsService.Data;
using CreditsService.DTO;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace CreditsService.Services.Validators
{
    public class CreateLoanDtoValidator : AbstractValidator<CreateLoanDto>
    {
        private readonly CreditsDbContext _dbContext;

        public CreateLoanDtoValidator(CreditsDbContext dbContext)
        {
            _dbContext = dbContext;

            RuleFor(x => x.UserId)
                .NotEmpty().WithMessage("ID пользователя обязателен");

            RuleFor(x => x.TariffName)
                .NotEmpty().WithMessage("Название тарифа обязательно")
                .MaximumLength(100).WithMessage("Название тарифа слишком длинное")
                .MustAsync(BeActiveTariff).WithMessage("Тариф с таким названием не существует или неактивен");

            RuleFor(x => x.Amount)
                .GreaterThanOrEqualTo(100).WithMessage("Минимальная сумма кредита - 100")
                .LessThanOrEqualTo(10000000).WithMessage("Максимальная сумма кредита - 10 000 000");
        }

        private async Task<bool> BeActiveTariff(string tariffName, CancellationToken cancellationToken)
        {
            return await _dbContext.Tariffs.AnyAsync(t => t.Name == tariffName && t.IsActive, cancellationToken);
        }
    }
}
