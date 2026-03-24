import { HttpHeaders } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { HttpApiClient } from '../../shared/api/http-api-client.service';
import { API_ENDPOINTS } from '../../shared/api/api-endpoints';

export type ApiTheme = 'Light' | 'Dark';

export type UserSettingsResponse = {
  theme: ApiTheme;
  hiddenAccountIds: string[];
};

@Injectable({ providedIn: 'root' })
export class ThemeApi {
  private readonly api = inject(HttpApiClient);
  private readonly headers = new HttpHeaders({ 'Content-Type': 'application/json' });

  getUserSettings(): Observable<UserSettingsResponse> {
    return this.api.get<UserSettingsResponse>(`${API_ENDPOINTS.settings}/me`);
  }

  saveTheme(theme: ApiTheme): Observable<void> {
    return this.api.patch<void, string>(`${API_ENDPOINTS.settings}/theme`, JSON.stringify(theme), {
      headers: this.headers,
    });
  }
}
