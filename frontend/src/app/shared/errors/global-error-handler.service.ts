import { ErrorHandler, Injectable, inject } from '@angular/core';
import { Router } from '@angular/router';
import { AppError, mapHttpError } from '../api/api-error';

@Injectable()
export class GlobalErrorHandlerService implements ErrorHandler {
  private readonly router = inject(Router);

  handleError(error: unknown): void {
    const appError = error instanceof AppError ? error : mapHttpError(error);
    console.error(error);
    void this.router.navigateByUrl('/error', {
      state: {
        message: appError.message,
      },
    });
  }
}
