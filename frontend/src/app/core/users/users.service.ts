import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import {
  CreateUserRequest,
  CreateUserResponse,
  UsersListRequest,
  UsersListResponse,
} from './users.models';

@Injectable({ providedIn: 'root' })
export class UsersService {
  private readonly http = inject(HttpClient);
  private readonly baseUrl = 'https://localhost:7205/api/users';

  getUsersList(req: UsersListRequest): Observable<UsersListResponse> {
    const params = this.buildListParams(req);
    return this.http.get<UsersListResponse>(`${this.baseUrl}/list`, { params });
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

  createUser(payload: CreateUserRequest) {
    return this.http.post<CreateUserResponse>(`${this.baseUrl}`, payload);
  }
}
