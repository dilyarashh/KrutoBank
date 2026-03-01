namespace UsersService.Infrastructure.Errors.Exceptions;

public class UnauthorizedException(string message) : Exception(message);
