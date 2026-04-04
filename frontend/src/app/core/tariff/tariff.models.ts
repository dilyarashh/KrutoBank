export interface CreateTariffRequest {
  name: string;
  interestRate: number;
}

export interface TariffDto {
  id: string;
  name: string;
  interestRate: number;
}
