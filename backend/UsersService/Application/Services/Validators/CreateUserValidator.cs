using FluentValidation;
using UsersService.DTOs;
using UsersService.Infrastructure.Repositories;

namespace UsersService.Services.Validators;

public class CreateUserValidator : AbstractValidator<CreateUserRequest>
{
    public CreateUserValidator(IUserRepository userRepository)
    {
        RuleFor(x => x.FirstName)
            .NotEmpty()
            .MaximumLength(50)
            .Matches(@"^[A-ZА-Я][a-zа-я]*$").WithMessage("Имя должно начинаться с большой буквы и содержать только буквы");

        RuleFor(x => x.LastName)
            .NotEmpty()
            .MaximumLength(50)
            .Matches(@"^[A-ZА-Я][a-zа-я]*$").WithMessage("Фамилия должна начинаться с большой буквы и содержать только буквы");

        RuleFor(x => x.MiddleName)
            .NotEmpty()
            .MaximumLength(50)
            .Matches(@"^[A-ZА-Я][a-zа-я]*$").WithMessage("Отчество должно начинаться с большой буквы и содержать только буквы");

        RuleFor(x => x.Phone)
            .NotEmpty()
            .Matches(@"^\+?\d{10,15}$").WithMessage("Телефон должен быть корректным")
            .MustAsync(async (phone, ct) =>
            {
                var existing = await userRepository.GetByPhoneAsync(phone);
                return existing == null;
            }).WithMessage("Телефон уже используется");

        RuleFor(x => x.Email)
            .EmailAddress()
            .When(x => !string.IsNullOrEmpty(x.Email))
            .MustAsync(async (email, ct) =>
            {
                if (string.IsNullOrEmpty(email)) return true;
                var existing = await userRepository.GetByEmailAsync(email);
                return existing == null;
            }).WithMessage("Email уже используется");

        RuleFor(x => x.Birthday)
            .Must(d => d <= DateOnly.FromDateTime(DateTime.UtcNow))
            .WithMessage("Дата рождения не может быть в будущем");

        RuleFor(x => x.Password)
            .MinimumLength(8);

        RuleFor(x => x.Role)
            .IsInEnum();
    }
}