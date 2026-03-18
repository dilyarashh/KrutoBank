import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import {
  CreateUserRequest,
  CreateUserResponse,
  UserDto,
  UsersListRequest,
  UsersListResponse,
} from './users.models';
import { AuthService } from '../auth/auth.service';

@Injectable({ providedIn: 'root' })
export class UsersService {
  private readonly http = inject(HttpClient);
  private readonly auth = inject(AuthService);
  private readonly baseUrl = 'http://localhost:5260/api/users';

  getUsersList(req: UsersListRequest): Observable<UsersListResponse> {
    const params = this.buildListParams(req);
    return this.http.get<UsersListResponse>(`${this.baseUrl}/list`, { params });
  }

   getById(id: string) {
    return this.http.get<UserDto>(`${this.baseUrl}/${id}`);
  }

  private buildListParams(req: UsersListRequest): HttpParams {
    let params = new HttpParams()
      .set('Page', String(req.page))
      .set('PageSize', String(req.pageSize));

    if (req.sortBy && req.sortBy.trim().length > 0) {
      params = params.set('SortBy', req.sortBy.trim());
    }

    if (req.ascending !== undefined) {
      params = params.set('Ascending', String(req.ascending));
    }

    return params;
  }

  blockUser(id: string): Observable<void> {
    return this.http.patch<void>(`${this.baseUrl}/block/${id}`, {});
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
      map(res => ({ id: res.userId }))
    );
  }
}
