import { ApplicationConfig, ErrorHandler, provideBrowserGlobalErrorListeners } from '@angular/core';
import { provideRouter } from '@angular/router';

import { routes } from './app.routes';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { authTokenInterceptor } from './core/auth/interceptor/auth-token.interceptor';
import { idempotencyInterceptor } from './shared/api/idempotency.interceptor';
import { provideNativeDateAdapter } from '@angular/material/core';
import { GlobalErrorHandlerService } from './shared/errors/global-error-handler.service';
import { resilienceInterceptor } from './shared/api/resilience.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideRouter(routes),
    provideHttpClient(withInterceptors([idempotencyInterceptor, resilienceInterceptor, authTokenInterceptor])),
    provideNativeDateAdapter(),
    { provide: ErrorHandler, useClass: GlobalErrorHandlerService },
  ],
};
