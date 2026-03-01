import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { CreditDto, CreditOperationDto } from './credits.models';

@Injectable({ providedIn: 'root' })
export class CreditsService {
  private http = inject(HttpClient);

  getLoansByUserId(userId: string) {
    return this.http.get<CreditDto[]>(`http://localhost:5173/api/Credits/users/${userId}/loans`);
  }

  getCreditOperations(userId: string, loanId: string) {
    return this.http.get<CreditOperationDto[]>(
      `http://localhost:5173/api/Credits/users/${userId}/loans/${loanId}/operations`,
    );
  }
}
