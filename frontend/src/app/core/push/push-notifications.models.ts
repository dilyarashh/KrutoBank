export type PushPlatform = 'Web' | 'Android';

export type PushAudience = 'Client' | 'Employee';

export type RegisterPushSubscriptionRequest = {
  platform: PushPlatform;
  audience: PushAudience;
  token: string;
};

export type RemovePushSubscriptionRequest = {
  token: string;
};
