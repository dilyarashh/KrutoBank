namespace AccountsService.Errors.Exceptions;

public class BadRequestException(string message) : Exception(message);