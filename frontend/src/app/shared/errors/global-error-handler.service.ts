import { ErrorHandler, Injectable, inject } from '@angular/core';
import { Router } from '@angular/router';
import { AppError, mapHttpError } from '../api/api-error';
import { FrontendMonitoringService } from '../../core/frontend-monitoring/frontend-monitoring.service';

@Injectable()
export class GlobalErrorHandlerService implements ErrorHandler {
  private readonly router = inject(Router);
  private readonly monitoring = inject(FrontendMonitoringService);

  handleError(error: unknown): void {
    const appError = error instanceof AppError ? error : mapHttpError(error);
    this.monitoring.recordException({
      message: appError.message,
      stack: error instanceof Error ? error.stack : undefined,
      route: this.router.url,
      traceId: this.createTraceId(),
      spanId: this.createSpanId(),
    });

    console.error(error);
    void this.router.navigateByUrl('/error', {
      state: {
        message: appError.message,
      },
    });
  }

  private createTraceId(): string {
    return this.randomHex(32);
  }

  private createSpanId(): string {
    return this.randomHex(16);
  }

  private randomHex(length: number): string {
    const bytes = new Uint8Array(length / 2);
    crypto.getRandomValues(bytes);
    return Array.from(bytes, (byte) => byte.toString(16).padStart(2, '0')).join('');
  }
}
