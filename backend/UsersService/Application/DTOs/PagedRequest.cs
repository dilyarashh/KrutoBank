using UsersService.DTOs.Enums;

namespace UsersService.DTOs;

public class PagedRequest
{
    public int Page { get; set; } = 1; //Номер страницы
    public int PageSize { get; set; } = 10; //Размер элементов на странице

    public UserSortOption SortBy { get; set; } = UserSortOption.Created; //Сортировка
    public bool Ascending { get; set; } = true; //По возрастанию по умолчанию 
}


