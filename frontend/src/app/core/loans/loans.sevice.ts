import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { LoanDto, LoanOperationDto, UserAccountListItemDto } from './loans.models';

@Injectable({ providedIn: 'root' })
export class LoansService {
  private http = inject(HttpClient);

  getAccountsByUserId(userId: string, onlyOpened?: boolean) {
    const q = onlyOpened === undefined ? '' : `?onlyOpened=${onlyOpened}`;
    return this.http.get<UserAccountListItemDto[]>(
      `http://localhost:5251/api/accounts/user/${userId}`,
    );
  }
  getById(accountId: string) {
    return this.http.get<LoanDto>(`http://localhost:5251/api/accounts/${accountId}`);
  }

  getOperations(accountId: string) {
    return this.http.get<LoanOperationDto | LoanOperationDto[]>(
      `http://localhost:5251/api/accounts/${accountId}/operations`,
    );
  }
}
