import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { HttpApiClient } from '../../shared/api/http-api-client.service';
import { API_ENDPOINTS } from '../../shared/api/api-endpoints';
import { CreateTariffRequest, TariffDto } from './tariff.models';

@Injectable({ providedIn: 'root' })
export class TariffsApi {
  private readonly api = inject(HttpApiClient);

  createTariff(dto: CreateTariffRequest): Observable<TariffDto> {
    return this.api.post<TariffDto, CreateTariffRequest>(`${API_ENDPOINTS.credits}/tariffs`, dto);
  }
}
