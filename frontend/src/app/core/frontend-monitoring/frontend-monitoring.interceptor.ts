import { HttpErrorResponse, HttpInterceptorFn, HttpResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { tap } from 'rxjs';
import { FrontendMonitoringService } from './frontend-monitoring.service';

export const frontendMonitoringInterceptor: HttpInterceptorFn = (req, next) => {
  const monitoring = inject(FrontendMonitoringService);
  const router = inject(Router);

  const startedAt = performance.now();
  const traceId = createTraceId();
  const spanId = createSpanId();

  const tracedReq = req.clone({
    setHeaders: {
      'X-Trace-Id': traceId,
      'X-Span-Id': spanId,
      traceparent: `00-${traceId}-${spanId}-01`,
    },
  });

  return next(tracedReq).pipe(
    tap({
      next: (event) => {
        if (event instanceof HttpResponse) {
          monitoring.recordRequest({
            method: req.method,
            url: req.urlWithParams,
            route: router.url,
            statusCode: event.status,
            durationMs: elapsedMs(startedAt),
            traceId,
            spanId,
            isError: event.status >= 400,
          });
        }
      },
      error: (error: unknown) => {
        const statusCode = error instanceof HttpErrorResponse ? error.status : 0;
        monitoring.recordRequest({
          method: req.method,
          url: req.urlWithParams,
          route: router.url,
          statusCode,
          durationMs: elapsedMs(startedAt),
          traceId,
          spanId,
          isError: true,
          errorMessage: error instanceof Error ? error.message : 'Неизвестная ошибка запроса',
        });
      },
    })
  );
};

function elapsedMs(startedAt: number): number {
  return Math.round(performance.now() - startedAt);
}

function createTraceId(): string {
  return randomHex(32);
}

function createSpanId(): string {
  return randomHex(16);
}

function randomHex(length: number): string {
  const bytes = new Uint8Array(length / 2);
  crypto.getRandomValues(bytes);
  return Array.from(bytes, (byte) => byte.toString(16).padStart(2, '0')).join('');
}
