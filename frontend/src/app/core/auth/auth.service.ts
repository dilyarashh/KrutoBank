import { Injectable, signal, computed, inject } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { firstValueFrom, Observable } from 'rxjs';

export type RegisterRequest = {
  firstName: string;
  lastName: string;
  middleName?: string;
  phone: string;
  email?: string;
  birthday: string; // ISO date
  password: string;
  role: 'Client' | 'Employee';
};

export type OAuthTokenResponse = {
  access_token: string;
  refresh_token?: string;
  expires_in: number;
  token_type: 'Bearer';
  scope: string;
};

export type RegisterResponse = {
  userId: string;
};

const TOKEN_KEY = 'access_token';
const REFRESH_TOKEN_KEY = 'refresh_token';
const CODE_VERIFIER_KEY = 'pkce_code_verifier';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly token = signal<string | null>(this.readToken());

  readonly isAuthenticated = computed(() => !!this.token());

  private readonly http = inject(HttpClient);

  private readonly authServer = 'http://localhost:5270';

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
        scope: 'openid profile roles users_api accounts_api credits_api offline_access',
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

    const token = await firstValueFrom(
      this.http.post<OAuthTokenResponse>(`${this.authServer}/connect/token`, body.toString(), {
        headers: new HttpHeaders({ 'Content-Type': 'application/x-www-form-urlencoded' }),
      })
    );

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
    return this.http.post<RegisterResponse>(`${this.authServer}/account/register`, payload);
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