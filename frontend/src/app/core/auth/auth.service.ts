import { Injectable, signal, computed, inject } from '@angular/core';
import { firstValueFrom, Observable } from 'rxjs';
import { API_ENDPOINTS } from '../../shared/api/api-endpoints';
import { AuthApi } from './auth.api';
import { RegisterRequest, RegisterResponse } from './auth.models';

const TOKEN_KEY = 'access_token';
const REFRESH_TOKEN_KEY = 'refresh_token';
const CODE_VERIFIER_KEY = 'pkce_code_verifier';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly token = signal<string | null>(this.readToken());

  readonly isAuthenticated = computed(() => !!this.token());

  private readonly authApi = inject(AuthApi);

  private readonly authServer = API_ENDPOINTS.auth;

  private get clientId() {
    return window.location.origin.includes('4200')
      ? 'bank-employee-web'
      : 'bank-client-web';
  }

  private get redirectUri() {
    return `${window.location.origin}/auth/callback`;
  }

  loginRedirect(returnUrl?: string) {
    const codeVerifier = this.generateRandomString(128);

    sessionStorage.setItem(CODE_VERIFIER_KEY, codeVerifier);

    this.generateCodeChallenge(codeVerifier).then((codeChallenge) => {
      const params = new URLSearchParams({
        client_id: this.clientId,
        redirect_uri: this.redirectUri,
        response_type: 'code',
        scope: 'openid profile roles users_api accounts_api credits_api settings_api offline_access',
        code_challenge: codeChallenge,
        code_challenge_method: 'S256',
        state: returnUrl ?? '/users',
      });

      window.location.href = `${this.authServer}/connect/authorize?${params.toString()}`;
    });
  }

  async completeAuthorization(code: string, state?: string) {
    const codeVerifier = sessionStorage.getItem(CODE_VERIFIER_KEY);
    if (!codeVerifier) {
      throw new Error('PKCE code verifier is missing.');
    }

    const redirectUri = `${window.location.origin}/auth/callback`;

    const body = new URLSearchParams({
      grant_type: 'authorization_code',
      client_id: this.clientId,
      code,
      redirect_uri: redirectUri,
      code_verifier: codeVerifier,
    });

    const token = await firstValueFrom(this.authApi.exchangeCode(body));

    this.setToken(token.access_token);

    if (token.refresh_token) {
      localStorage.setItem(REFRESH_TOKEN_KEY, token.refresh_token);
    }

    sessionStorage.removeItem(CODE_VERIFIER_KEY);

    return state ?? '/users';
  }

  async logout() {
    this.setToken(null);
    localStorage.removeItem(REFRESH_TOKEN_KEY);

    const redirectUri = encodeURIComponent(window.location.origin);
    window.location.href = `${this.authServer}/connect/logout?post_logout_redirect_uri=${redirectUri}`;
  }

  register(payload: RegisterRequest): Observable<RegisterResponse> {
    return this.authApi.register(payload);
  }

  getToken(): string | null {
    return this.token();
  }

  private setToken(value: string | null) {
    this.token.set(value);

    if (value) {
      localStorage.setItem(TOKEN_KEY, value);
    } else {
      localStorage.removeItem(TOKEN_KEY);
    }
  }

  private readToken(): string | null {
    return localStorage.getItem(TOKEN_KEY);
  }

  private generateRandomString(length = 64): string {
    const array = new Uint8Array(length);
    crypto.getRandomValues(array);
    return Array.from(array, (b) => ('0' + b.toString(16)).slice(-2)).join('');
  }

  private async generateCodeChallenge(codeVerifier: string): Promise<string> {
    const data = new TextEncoder().encode(codeVerifier);
    const digest = await crypto.subtle.digest('SHA-256', data);
    return this.base64UrlEncode(new Uint8Array(digest));
  }

  private base64UrlEncode(buffer: Uint8Array): string {
    const base64 = btoa(String.fromCharCode(...buffer));
    return base64.replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
  }
}
