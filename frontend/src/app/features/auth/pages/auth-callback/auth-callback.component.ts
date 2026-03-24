import { ChangeDetectionStrategy, Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService } from '../../../../core/auth/auth.service';
import { ThemeService } from '../../../../core/theme/theme.service';
import { toErrorMessage } from '../../../../shared/api/api-error';
import { FeedbackService } from '../../../../shared/feedback/feedback.service';

@Component({
  selector: 'app-auth-callback',
  templateUrl: './auth-callback.component.html',
  standalone: true,
  styleUrl: './auth-callback.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AuthCallbackComponent implements OnInit {
  private readonly auth = inject(AuthService);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly themeService = inject(ThemeService);
  private readonly feedback = inject(FeedbackService);

  readonly message = signal('Завершаем вход...');

  async ngOnInit() {
    const query = this.route.snapshot.queryParamMap;
    const code = query.get('code');
    const state = query.get('state');

    if (!code) {
      this.message.set('Код авторизации отсутствует.');
      return;
    }

    try {
      const redirect = await this.auth.completeAuthorization(code, state ?? undefined);
      await this.themeService.loadUserTheme(true);
      await this.router.navigateByUrl(redirect);
    } catch (error: unknown) {
      const message = toErrorMessage(error, 'Не удалось выполнить авторизацию.');
      this.message.set(`Не удалось выполнить авторизацию: ${message}`);
      this.feedback.error(message);
    }
  }
}
