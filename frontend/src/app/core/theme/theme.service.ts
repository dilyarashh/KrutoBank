import { DOCUMENT } from '@angular/common';
import { Injectable, computed, inject, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { AuthService } from '../auth/auth.service';
import { ThemeApi, ApiTheme } from './theme.api';

export type AppTheme = 'light' | 'dark';

const THEME_STORAGE_KEY = 'app_theme';

@Injectable({ providedIn: 'root' })
export class ThemeService {
  private readonly document = inject(DOCUMENT);
  private readonly auth = inject(AuthService);
  private readonly themeApi = inject(ThemeApi);
  private readonly theme = signal<AppTheme>(this.readInitialTheme());
  private loadPromise: Promise<void> | null = null;

  readonly currentTheme = computed(() => this.theme());
  readonly isDark = computed(() => this.theme() === 'dark');

  constructor() {
    this.applyTheme(this.theme());
  }

  async toggleTheme() {
    await this.setTheme(this.theme() === 'dark' ? 'light' : 'dark');
  }

  async setTheme(theme: AppTheme, options?: { persistRemote?: boolean }) {
    this.theme.set(theme);
    localStorage.setItem(THEME_STORAGE_KEY, theme);
    this.applyTheme(theme);

    const shouldPersistRemote = options?.persistRemote ?? this.auth.isAuthenticated();
    if (!shouldPersistRemote) {
      return;
    }

    await this.saveUserTheme(theme);
  }

  loadUserTheme(force = false): Promise<void> {
    if (!this.auth.isAuthenticated()) {
      return Promise.resolve();
    }

    if (!force && this.loadPromise) {
      return this.loadPromise;
    }

    this.loadPromise = this.fetchAndApplyUserTheme()
      .catch(() => undefined)
      .finally(() => {
        this.loadPromise = null;
      });

    return this.loadPromise;
  }

  private readInitialTheme(): AppTheme {
    const savedTheme = localStorage.getItem(THEME_STORAGE_KEY);
    return savedTheme === 'dark' ? 'dark' : 'light';
  }

  private applyTheme(theme: AppTheme) {
    this.document.body.dataset['theme'] = theme;
  }

  private async fetchAndApplyUserTheme() {
    const response = await firstValueFrom(this.themeApi.getUserSettings());

    const theme = this.fromApiTheme(response.theme);
    await this.setTheme(theme, { persistRemote: false });
  }

  private async saveUserTheme(theme: AppTheme) {
    await firstValueFrom(this.themeApi.saveTheme(this.toApiTheme(theme)));
  }

  private toApiTheme(theme: AppTheme): ApiTheme {
    return theme === 'dark' ? 'Dark' : 'Light';
  }

  private fromApiTheme(theme: ApiTheme): AppTheme {
    return theme === 'Dark' ? 'dark' : 'light';
  }
}
