import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';
import {
  CreateUserRequest,
  CreateUserResponse,
  UserDto,
  UsersListRequest,
  UsersListResponse,
} from './users.models';
import { AuthService } from '../auth/auth.service';
import { UsersApi } from './users.api';

@Injectable({ providedIn: 'root' })
export class UsersService {
  private readonly usersApi = inject(UsersApi);
  private readonly auth = inject(AuthService);

  getUsersList(req: UsersListRequest): Observable<UsersListResponse> {
    return this.usersApi.getUsersList(req);
  }

  getById(id: string): Observable<UserDto> {
    return this.usersApi.getById(id);
  }

  blockUser(id: string): Observable<void> {
    return this.usersApi.blockUser(id);
  }

  createUser(payload: CreateUserRequest): Observable<CreateUserResponse> {
    return this.auth.register({
      firstName: payload.firstName,
      lastName: payload.lastName,
      middleName: payload.middleName,
      phone: payload.phone,
      email: payload.email ?? undefined,
      birthday: payload.birthday,
      password: payload.password,
      role: payload.role,
    }).pipe(
      map((res) => ({ id: res.userId }))
    );
  }
}
