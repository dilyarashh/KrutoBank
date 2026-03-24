import { ApplicationConfig, ErrorHandler, provideBrowserGlobalErrorListeners } from '@angular/core';
import { provideRouter } from '@angular/router';

import { routes } from './app.routes';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { authTokenInterceptor } from './core/auth/interceptor/auth-token.interceptor';
import { provideNativeDateAdapter } from '@angular/material/core';
import { GlobalErrorHandlerService } from './shared/errors/global-error-handler.service';

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideRouter(routes),
    provideHttpClient(withInterceptors([authTokenInterceptor])),
    provideNativeDateAdapter(),
    { provide: ErrorHandler, useClass: GlobalErrorHandlerService },
  ],
};
