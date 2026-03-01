import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import {
  LoginCredentials,
  LoginFormComponent,
} from '../../components/login-form/login-form.component';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService } from '../../../../core/auth/auth.service';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-login-page',
  imports: [LoginFormComponent, CommonModule],
  templateUrl: './login-page.component.html',
  standalone: true,
  styleUrl: './login-page.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class LoginPageComponent {
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);
  private readonly route = inject(ActivatedRoute);

  readonly pageLoading = signal(false);

 async onLogin(credentials: LoginCredentials) {
  this.pageLoading.set(true);

  try {
    await this.auth.login(credentials).toPromise();

    const returnUrl = this.route.snapshot.queryParamMap.get('returnUrl') || '/users';
    await this.router.navigateByUrl(returnUrl);
  } catch (e: any) {
    console.error(e);
  } finally {
    this.pageLoading.set(false);
  }
}
}
