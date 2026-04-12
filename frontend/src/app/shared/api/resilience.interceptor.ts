import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { Observable, tap, throwError, timer } from 'rxjs';
import { retry } from 'rxjs/operators';
import { AppError } from './api-error';
import { ResilienceCircuitBreakerService } from './resilience-circuit-breaker.service';

const RETRY_COUNT = 7;
const RETRY_DELAY_MS = 200;

export const resilienceInterceptor: HttpInterceptorFn = (req, next) => {
  const circuitBreaker = inject(ResilienceCircuitBreakerService);
  const circuitKey = getCircuitKey(req.url);

  if (circuitBreaker.isOpen(circuitKey)) {
    return throwCircuitOpen(circuitBreaker, circuitKey);
  }

  return next(req).pipe(
    retry({
      count: RETRY_COUNT,
      delay: (error: unknown, retryAttempt: number) => {
        if (!isTransientError(error)) {
          return throwError(() => error);
        }

        circuitBreaker.recordFailure(circuitKey);

        if (circuitBreaker.isOpen(circuitKey)) {
          return throwCircuitOpen(circuitBreaker, circuitKey);
        }

        return timer(RETRY_DELAY_MS * retryAttempt);
      },
    }),
    tap({
      next: () => circuitBreaker.recordSuccess(circuitKey),
      error: (error: unknown) => {
        if (isTransientError(error)) {
          circuitBreaker.recordFailure(circuitKey);
        }
      },
    })
  );
};

function isTransientError(error: unknown): boolean {
  if (!(error instanceof HttpErrorResponse)) {
    return false;
  }

  return error.status === 0 || error.status === 408 || error.status === 429 || error.status >= 500;
}

function getCircuitKey(url: string): string {
  try {
    return new URL(url, window.location.origin).origin;
  } catch {
    return url;
  }
}

function throwCircuitOpen(
  circuitBreaker: ResilienceCircuitBreakerService,
  circuitKey: string
): Observable<never> {
  const retryAfter = circuitBreaker.retryAfterSeconds(circuitKey);
  const message = retryAfter > 0
    ? `Service is temporarily unavailable. Try again in ${retryAfter} seconds.`
    : 'Service is temporarily unavailable. Try again later.';

  return throwError(() => new AppError(message, 'server', 503));
}
