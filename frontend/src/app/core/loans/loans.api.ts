import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { HttpApiClient } from '../../shared/api/http-api-client.service';
import { API_ENDPOINTS } from '../../shared/api/api-endpoints';
import { LoanDto, LoanOperationDto, UserAccountListItemDto } from './loans.models';

@Injectable({ providedIn: 'root' })
export class LoansApi {
  private readonly api = inject(HttpApiClient);
  private readonly baseUrl = API_ENDPOINTS.accounts;

  getAccountsByUserId(userId: string): Observable<UserAccountListItemDto[]> {
    return this.api.get<UserAccountListItemDto[]>(`${this.baseUrl}/user/${userId}`);
  }

  getById(accountId: string): Observable<LoanDto> {
    return this.api.get<LoanDto>(`${this.baseUrl}/${accountId}`);
  }

  getOperations(accountId: string): Observable<LoanOperationDto | LoanOperationDto[]> {
    return this.api.get<LoanOperationDto | LoanOperationDto[]>(`${this.baseUrl}/${accountId}/operations`);
  }
}
