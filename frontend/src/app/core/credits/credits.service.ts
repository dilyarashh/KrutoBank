import { Injectable, inject } from '@angular/core';
import { CreditDto, CreditOperationDto, CreditScoreDto } from './credits.models';
import { CreditsApi } from './credits.api';

@Injectable({ providedIn: 'root' })
export class CreditsService {
  private readonly api = inject(CreditsApi);

  getLoansByUserId(userId: string) {
    return this.api.getLoansByUserId(userId);
  }

  getCreditOperations(userId: string, loanId: string) {
    return this.api.getCreditOperations(userId, loanId);
  }

  getCreditScore(userId: string) {
    return this.api.getCreditScore(userId);
  }
}
