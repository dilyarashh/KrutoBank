import { HttpHeaders } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { HttpApiClient } from '../../shared/api/http-api-client.service';
import { API_ENDPOINTS } from '../../shared/api/api-endpoints';
import { OAuthTokenResponse, RegisterRequest, RegisterResponse } from './auth.models';

@Injectable({ providedIn: 'root' })
export class AuthApi {
  private readonly api = inject(HttpApiClient);
  private readonly formHeaders = new HttpHeaders({ 'Content-Type': 'application/x-www-form-urlencoded' });

  exchangeCode(body: URLSearchParams): Observable<OAuthTokenResponse> {
    return this.api.post<OAuthTokenResponse, string>(`${API_ENDPOINTS.auth}/connect/token`, body.toString(), {
      headers: this.formHeaders,
    });
  }

  register(payload: RegisterRequest): Observable<RegisterResponse> {
    return this.api.post<RegisterResponse, RegisterRequest>(`${API_ENDPOINTS.auth}/account/register`, payload);
  }
}
