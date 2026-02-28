using FluentValidation;
using UsersService.DTOs;
using UsersService.Infrastructure.Repositories;

namespace UsersService.Services.Validators;

public class PagedRequestValidator : AbstractValidator<PagedRequest>
{
    public PagedRequestValidator()
    {
        RuleFor(x => x.Page)
            .GreaterThan(0).WithMessage("Страница должна быть больше 0");

        RuleFor(x => x.PageSize)
            .InclusiveBetween(1, 100).WithMessage("Количество элементов на странице от 1 до 100");

        RuleFor(x => x.SortBy)
            .IsInEnum().WithMessage("Доступные значения: ");
    }
}
