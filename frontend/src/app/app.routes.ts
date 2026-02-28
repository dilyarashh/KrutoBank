import { Routes } from '@angular/router';
import { LoginPageComponent } from './features/auth/pages/login-page/login-page.component';
import { UsersPageComponent } from './features/users/pages/users-page/users-page.component';

export const routes: Routes = [
  { path: 'login', component: LoginPageComponent },
  { path: 'users', component: UsersPageComponent },
];
