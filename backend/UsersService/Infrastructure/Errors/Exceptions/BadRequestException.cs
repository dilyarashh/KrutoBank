namespace UsersService.Infrastructure.Errors.Exceptions;

public class BadRequestException(string message) : Exception(message);