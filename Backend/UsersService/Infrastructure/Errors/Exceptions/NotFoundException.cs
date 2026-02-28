namespace UsersService.Infrastructure.Errors.Exceptions;

public class NotFoundException(string message) : Exception(message);