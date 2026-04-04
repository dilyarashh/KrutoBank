import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { IdempotencyService } from './idempotency.service';

export const idempotencyInterceptor: HttpInterceptorFn = (req, next) => {
  const idempotencyService = inject(IdempotencyService);

  const isWriteOperation = /^(POST|PUT|DELETE|PATCH)$/i.test(req.method);

  if (!isWriteOperation) {
    return next(req);
  }

  if (req.url.includes('/connect/token')) {
    return next(req);
  }

  let body = null;
  if (req.body) {
    try {
      body = typeof req.body === 'string' ? req.body : JSON.parse(JSON.stringify(req.body));
    } catch {
      body = null;
    }
  }

  const idempotencyKey = idempotencyService.getOrCreateKey(req.method, req.url, body);

  const modifiedReq = req.clone({
    setHeaders: {
      'Idempotency-Key': idempotencyKey,
    },
  });

  return next(modifiedReq);
};
