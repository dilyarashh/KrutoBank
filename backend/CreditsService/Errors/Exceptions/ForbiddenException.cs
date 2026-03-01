namespace AccountsService.Errors.Exceptions;

public class ForbiddenException(string message) : Exception(message);