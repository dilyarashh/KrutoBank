import { Injectable, signal, computed, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { tap } from 'rxjs/operators';
import { Observable } from 'rxjs';

export type LoginRequest = {
  phone: string;
  password: string;
};

export type LoginResponse = {
  token: string;
};

const TOKEN_KEY = 'access_token';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly token = signal<string | null>(this.readToken());

  readonly isAuthenticated = computed(() => !!this.token());

  private readonly http = inject(HttpClient); 

  private readonly loginUrl = 'сюда в след раз вставлю бэкенд урл';

  login(payload: LoginRequest): Observable<LoginResponse> {
    return this.http.post<LoginResponse>(this.loginUrl, payload).pipe(
      tap((res) => {
        this.setToken(res.token);
      })
    );
  }

  logout() {
    this.setToken(null);
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
}