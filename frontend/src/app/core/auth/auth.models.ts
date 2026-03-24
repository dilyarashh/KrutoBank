export type RegisterRequest = {
  firstName: string;
  lastName: string;
  middleName?: string;
  phone: string;
  email?: string;
  birthday: string;
  password: string;
  role: 'Client' | 'Employee';
};

export type OAuthTokenResponse = {
  access_token: string;
  refresh_token?: string;
  expires_in: number;
  token_type: 'Bearer';
  scope: string;
};

export type RegisterResponse = {
  userId: string;
};
