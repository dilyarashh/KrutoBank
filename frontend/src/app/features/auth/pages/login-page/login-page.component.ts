import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { AuthService } from '../../../../core/auth/auth.service';
import { CommonModule } from '@angular/common';
import { MatButtonModule } from '@angular/material/button';

@Component({
  selector: 'app-login-page',
  imports: [CommonModule, MatButtonModule],
  templateUrl: './login-page.component.html',
  standalone: true,
  styleUrl: './login-page.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class LoginPageComponent {
  private readonly auth = inject(AuthService);
  private readonly route = inject(ActivatedRoute);

  onLogin() {
    const returnUrl = this.route.snapshot.queryParamMap.get('returnUrl') ?? '/users';
    this.auth.loginRedirect(returnUrl);
  }
}

