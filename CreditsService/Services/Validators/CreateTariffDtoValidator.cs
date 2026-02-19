using CreditsService.DTO;
using FluentValidation;

namespace CreditsService.Services.Validators
{
    /// <summary>
    /// Валидатор для создания тарифа
    /// </summary>
    public class CreateTariffDtoValidator : AbstractValidator<CreateTariffDto>
    {
        public CreateTariffDtoValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("Название тарифа обязательно")
                .Length(3, 100).WithMessage("Название должно быть от 3 до 100 символов")
                .Matches(@"^[a-zA-Zа-яА-Я0-9\s\-]+$").WithMessage("Название может содержать только буквы, цифры, пробелы и дефисы");

            RuleFor(x => x.InterestRate)
                .NotEmpty().WithMessage("Процентная ставка обязательна")
                .InclusiveBetween(0.001m, 0.5m).WithMessage("Ставка должна быть от 0.1% до 50%");
        }
    }
}
