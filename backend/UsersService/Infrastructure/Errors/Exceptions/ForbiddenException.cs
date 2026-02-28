namespace UsersService.Infrastructure.Errors.Exceptions;

public class ForbiddenException(string message) : Exception(message);