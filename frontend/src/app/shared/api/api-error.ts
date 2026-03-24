import { HttpErrorResponse } from '@angular/common/http';

export type AppErrorCode =
  | 'bad_request'
  | 'unauthorized'
  | 'forbidden'
  | 'not_found'
  | 'conflict'
  | 'validation'
  | 'network'
  | 'server'
  | 'unknown';

export class AppError extends Error {
  constructor(
    message: string,
    public readonly code: AppErrorCode,
    public readonly status?: number,
    public readonly details?: unknown
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export function mapHttpError(error: unknown): AppError {
  if (error instanceof AppError) {
    return error;
  }

  if (error instanceof HttpErrorResponse) {
    if (error.status === 0) {
      return new AppError('Не удалось связаться с сервером.', 'network', error.status, error.error);
    }

    const message = extractErrorMessage(error) ?? defaultMessageByStatus(error.status);
    return new AppError(message, codeByStatus(error.status), error.status, error.error);
  }

  if (error instanceof Error) {
    return new AppError(error.message, 'unknown');
  }

  return new AppError('Произошла непредвиденная ошибка.', 'unknown');
}

export function toErrorMessage(error: unknown, fallback: string): string {
  const appError = mapHttpError(error);
  return appError.message?.trim() ? appError.message : fallback;
}

function extractErrorMessage(error: HttpErrorResponse): string | null {
  const payload = error.error;

  if (typeof payload === 'string' && payload.trim()) {
    return normalizeServerMessage(payload);
  }

  if (isRecord(payload)) {
    const validationMessage = extractValidationMessage(payload);
    if (validationMessage) {
      return validationMessage;
    }

    const candidates = [
      payload['message'],
      payload['error_description'],
      payload['title'],
      payload['detail'],
    ];

    for (const candidate of candidates) {
      if (typeof candidate === 'string' && candidate.trim()) {
        return normalizeServerMessage(candidate);
      }
    }
  }

  return null;
}

function extractValidationMessage(payload: Record<string, unknown>): string | null {
  const errors = payload['errors'];

  if (!isRecord(errors)) {
    return null;
  }

  const messages = Object.values(errors)
    .flatMap((value) => {
      if (Array.isArray(value)) {
        return value.filter((item): item is string => typeof item === 'string' && item.trim().length > 0);
      }

      if (typeof value === 'string' && value.trim()) {
        return [value];
      }

      return [];
    })
    .map((message) => normalizeServerMessage(message))
    .filter(Boolean);

  if (messages.length === 0) {
    return null;
  }

  return joinUniqueMessages(messages);
}

function normalizeServerMessage(message: string): string {
  const trimmed = message.trim();
  if (!trimmed) {
    return '';
  }

  const fluentValidationMessages = extractFluentValidationMessages(trimmed);
  if (fluentValidationMessages.length > 0) {
    return joinUniqueMessages(fluentValidationMessages);
  }

  return trimmed.replace(/\s+/g, ' ');
}

function extractFluentValidationMessages(message: string): string[] {
  const normalized = message.replace(/\r/g, '');
  const matches = [...normalized.matchAll(/--\s*[^:]+:\s*(.+?)(?=(?:\s*Severity:\s*\w+)|(?:\s*--\s*[^:]+:)|$)/g)];

  if (matches.length === 0) {
    return [];
  }

  return matches
    .map((match) => match[1]?.trim() ?? '')
    .map((item) => item.replace(/\s+/g, ' '))
    .filter(Boolean);
}

function joinUniqueMessages(messages: string[]): string {
  const unique = [...new Set(messages.map((message) => message.trim()).filter(Boolean))];
  return unique.join('\n');
}

function codeByStatus(status: number): AppErrorCode {
  switch (status) {
    case 400:
      return 'bad_request';
    case 401:
      return 'unauthorized';
    case 403:
      return 'forbidden';
    case 404:
      return 'not_found';
    case 409:
      return 'conflict';
    case 422:
      return 'validation';
    default:
      return status >= 500 ? 'server' : 'unknown';
  }
}

function defaultMessageByStatus(status: number): string {
  switch (status) {
    case 400:
      return 'Запрос не прошел проверку.';
    case 401:
      return 'Требуется авторизация.';
    case 403:
      return 'Недостаточно прав для выполнения действия.';
    case 404:
      return 'Запрошенные данные не найдены.';
    case 409:
      return 'Данные уже существуют или конфликтуют с текущим состоянием.';
    case 422:
      return 'Сервер не принял введенные данные.';
    default:
      return status >= 500
        ? 'На сервере произошла ошибка. Попробуйте позже.'
        : 'Не удалось выполнить запрос.';
  }
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null;
}
