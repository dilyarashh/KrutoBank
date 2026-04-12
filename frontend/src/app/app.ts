import { Component, computed, effect, inject, signal } from '@angular/core';
import { NavigationEnd, Router, RouterOutlet } from '@angular/router';
import { AppHeaderComponent } from './shared/components/header/header.component';
import { filter, map } from 'rxjs';
import { CommonModule } from '@angular/common';
import { ThemeService } from './core/theme/theme.service';
import { FeedbackStackComponent } from './shared/components/feedback-stack/feedback-stack.component';
import { AuthService } from './core/auth/auth.service';
import { PushNotificationsService } from './core/push/push-notifications.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, AppHeaderComponent, CommonModule, FeedbackStackComponent],
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App {
  protected readonly title = signal('KrutoBank');
  private readonly router = inject(Router);
  private readonly themeService = inject(ThemeService);
  private readonly auth = inject(AuthService);
  private readonly pushNotifications = inject(PushNotificationsService);

  private currentUrl = signal(this.router.url);

  constructor() {
    this.themeService.currentTheme();
    this.themeService.loadUserTheme();

    this.router.events
      .pipe(
        filter((e): e is NavigationEnd => e instanceof NavigationEnd),
        map((e) => e.urlAfterRedirects)
      )
      .subscribe((url) => this.currentUrl.set(url));

    effect(() => {
      if (this.auth.isAuthenticated()) {
        void this.pushNotifications.enable(this.auth.getPushAudience());
      }
    });
  }

  showHeader = computed(() => !this.currentUrl().startsWith('/login') && !this.currentUrl().startsWith('/error'));
}
