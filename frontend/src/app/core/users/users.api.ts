import { HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { HttpApiClient } from '../../shared/api/http-api-client.service';
import { API_ENDPOINTS } from '../../shared/api/api-endpoints';
import { UserDto, UsersListRequest, UsersListResponse } from './users.models';

@Injectable({ providedIn: 'root' })
export class UsersApi {
  private readonly api = inject(HttpApiClient);
  private readonly baseUrl = API_ENDPOINTS.users;

  getUsersList(req: UsersListRequest): Observable<UsersListResponse> {
    return this.api.get<UsersListResponse>(`${this.baseUrl}/list`, {
      params: this.buildListParams(req),
    });
  }

  getById(id: string): Observable<UserDto> {
    return this.api.get<UserDto>(`${this.baseUrl}/${id}`);
  }

  blockUser(id: string): Observable<void> {
    return this.api.patch<void, Record<string, never>>(`${this.baseUrl}/block/${id}`, {});
  }

  private buildListParams(req: UsersListRequest): HttpParams {
    let params = new HttpParams()
      .set('Page', String(req.page))
      .set('PageSize', String(req.pageSize));

    if (req.sortBy?.trim()) {
      params = params.set('SortBy', req.sortBy.trim());
    }

    if (req.ascending !== undefined) {
      params = params.set('Ascending', String(req.ascending));
    }

    return params;
  }
}
