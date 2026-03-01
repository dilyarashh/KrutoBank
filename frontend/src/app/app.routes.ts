import { Routes } from '@angular/router';
import { LoginPageComponent } from './features/auth/pages/login-page/login-page.component';
import { UsersPageComponent } from './features/users/pages/users-page/users-page.component';
import { UserProfilePageComponent } from './features/users/pages/user-profile/user-profile-page.component';
import { guestGuard } from './core/auth/guards/guest.guard';
import { authGuard } from './core/auth/guards/auth.guard';

export const routes: Routes = [
  { path: '', pathMatch: 'full', redirectTo: 'users' },

  { path: 'login', component: LoginPageComponent, canActivate: [guestGuard] },

  { path: 'users', component: UsersPageComponent, canActivate: [authGuard] },
  { path: 'users/:id', component: UserProfilePageComponent, canActivate: [authGuard] },

  { path: '**', redirectTo: 'users' },
];
