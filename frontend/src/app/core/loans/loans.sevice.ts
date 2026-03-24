import { Injectable, inject } from '@angular/core';
import { LoanDto, LoanOperationDto, UserAccountListItemDto } from './loans.models';
import { LoansApi } from './loans.api';

@Injectable({ providedIn: 'root' })
export class LoansService {
  private readonly api = inject(LoansApi);

  getAccountsByUserId(userId: string, onlyOpened?: boolean) {
    void onlyOpened;
    return this.api.getAccountsByUserId(userId);
  }
  getById(accountId: string) {
    return this.api.getById(accountId);
  }

  getOperations(accountId: string) {
    return this.api.getOperations(accountId);
  }
}
