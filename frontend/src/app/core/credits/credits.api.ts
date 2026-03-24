import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { HttpApiClient } from '../../shared/api/http-api-client.service';
import { API_ENDPOINTS } from '../../shared/api/api-endpoints';
import { CreditDto, CreditOperationDto, CreditScoreDto } from './credits.models';

@Injectable({ providedIn: 'root' })
export class CreditsApi {
  private readonly api = inject(HttpApiClient);
  private readonly baseUrl = API_ENDPOINTS.credits;

  getLoansByUserId(userId: string): Observable<CreditDto[]> {
    return this.api.get<CreditDto[]>(`${this.baseUrl}/users/${userId}/loans`);
  }

  getCreditOperations(userId: string, loanId: string): Observable<CreditOperationDto[]> {
    return this.api.get<CreditOperationDto[]>(`${this.baseUrl}/users/${userId}/loans/${loanId}/operations`);
  }

  getCreditScore(userId: string): Observable<CreditScoreDto> {
    return this.api.get<CreditScoreDto>(`${this.baseUrl}/users/${userId}/credit-score`);
  }
}
