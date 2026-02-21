using CreditsService.Data;
using CreditsService.DTO;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace CreditsService.Services.Validators
{
    /// <summary>
    /// Валидатор для погашения кредита
    /// </summary>
    public class RepayLoanDtoValidator : AbstractValidator<RepayLoanDto>
    {
        private readonly CreditsDbContext _dbContext;

        public RepayLoanDtoValidator(CreditsDbContext dbContext)
        {
            _dbContext = dbContext;

            RuleFor(x => x.LoanId)
                .NotEmpty().WithMessage("ID кредита обязателен")
                .MustAsync(BeActiveLoan).WithMessage("Кредит не существует, неактивен или уже погашен");

            RuleFor(x => x.Amount)
                .GreaterThan(0).WithMessage("Сумма погашения должна быть больше 0")
                .MustAsync(async (dto, amount, ct) =>
                {
                    var loan = await _dbContext.Loans
                            .AsNoTracking()
                            .FirstOrDefaultAsync(l => l.Id == dto.LoanId, ct);

                    return loan != null && amount <= loan.RemainingAmount;
                }).WithMessage(dto => $"Сумма погашения превышает остаток по кредиту");
        }

        private async Task<bool> BeActiveLoan(Guid loanId, CancellationToken cancellationToken)
        {
            var loan = await _dbContext.Loans
                    .AsNoTracking()
                    .FirstOrDefaultAsync(l => l.Id == loanId, cancellationToken);

            return loan != null && loan.IsActive;
        }
    }
}
