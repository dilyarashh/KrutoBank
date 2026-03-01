export interface LoanDto {
  id: string;
  name: string;
  balance: number;
  openedAt: string;  
  isClosed: boolean;
  closedAt: string | null;
}

export interface LoanOperationDto {
  id: string;
  accountId: string;
  createdAt: string; 
  type: string;      
  amount: number;
  account?: unknown;
}

export interface UserAccountListItemDto {
  userId: string;
  accountId: string;
  accountName: string;
  balance: number;
  isClosed: boolean;
}
