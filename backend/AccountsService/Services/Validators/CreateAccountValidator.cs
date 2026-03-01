using AccountsService.DTO;
using FluentValidation;

namespace AccountsService.Services.Validators;

public class CreateAccountValidator : AbstractValidator<CreateAccountRequest>
{
    public CreateAccountValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .MaximumLength(50).WithMessage("Размер названия счёта не более 50 символов");
    }
}