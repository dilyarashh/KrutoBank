import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from '../auth.service';

export const authTokenInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthService);
  const token = auth.getToken?.() ?? null; 

  if (!token) return next(req);

  const authReq = req.clone({
    setHeaders: { Authorization: `Bearer ${token}` },
  });

  return next(authReq);
};