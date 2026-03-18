import { Component, ChangeDetectionStrategy, inject, signal, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService } from '../../../../core/auth/auth.service';

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
      await this.router.navigateByUrl(redirect);
    } catch (error: any) {
      this.message.set('Не удалось выполнить авторизацию: ' + (error?.message ?? 'Ошибка'));
    }
  }
}
