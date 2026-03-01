import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';

export interface CreateTariffRequest {
  name: string;
  interestRate: number;
}

export interface TariffDto {
  id: string;
  name: string;
  interestRate: number;
}

@Injectable({ providedIn: 'root' })
export class TariffsService {
  private http = inject(HttpClient);

  createTariff(dto: CreateTariffRequest) {
    return this.http.post<TariffDto>(
      'http://localhost:5173/api/Credits/tariffs',
      dto
    );
  }
}