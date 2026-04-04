export interface CreditDto {
  loanId: string;
  initialAmount: number;
  remainingAmount: number;
  tariffName: string;
  interestRate: number;
  createdAt: string;
  isActive: boolean;
}

export interface CreditOperationDto {
  operationId: string;
  amount: number;
  operationDate: string;
  operationType: string; 
}

export interface CreditScoreDto {
  userId: string;
  score: number;
  activeLoans: number;
  closedLoans: number;
  overduePayments: number;
}
