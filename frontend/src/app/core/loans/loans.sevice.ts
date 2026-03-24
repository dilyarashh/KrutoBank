import { Injectable, inject } from '@angular/core';
import { LoansApi } from './loans.api';
import { AccountOperationsRealtimeService } from './account-operations-realtime.service';

@Injectable({ providedIn: 'root' })
export class LoansService {
  private readonly api = inject(LoansApi);
  private readonly realtime = inject(AccountOperationsRealtimeService);

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

  watchOperations(accountId: string) {
    return this.realtime.watchOperations(accountId);
  }
}
