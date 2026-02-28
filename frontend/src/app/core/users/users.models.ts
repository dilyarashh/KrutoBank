export type UserRole = 'Employee' | 'Client';

export type UserItem = {
  id: string;
  firstName: string;
  lastName: string;
  middleName?: string | null;
  phone?: string | null;
  email?: string | null;
  birthday?: string | null; 
  role: UserRole;
  isBlocked: boolean;
};

export type UsersListRequest = {
  page: number;
  pageSize: number;
  sortBy?: string;
  ascending?: boolean;
};

export type UsersListResponse = {
  page: number;
  pageSize: number;
  totalCount: number;
  items: UserItem[];
};

export type CreateUserRequest = {
  firstName: string;
  lastName: string;
  middleName: string;
  phone: string;
  email?: string | null;
  birthday: string; 
  role: 'Client' | 'Employee';
  password: string;
};

export type CreateUserResponse = { id: string };