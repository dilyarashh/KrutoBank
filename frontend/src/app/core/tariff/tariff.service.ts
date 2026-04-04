import { Injectable, inject } from '@angular/core';
import { TariffsApi } from './tariffs.api';
import { CreateTariffRequest, TariffDto } from './tariff.models';

@Injectable({ providedIn: 'root' })
export class TariffsService {
  private readonly api = inject(TariffsApi);

  createTariff(dto: CreateTariffRequest) {
    return this.api.createTariff(dto);
  }
}
