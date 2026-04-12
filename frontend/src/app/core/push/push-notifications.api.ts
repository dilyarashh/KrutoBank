import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { API_ENDPOINTS } from '../../shared/api/api-endpoints';
import { HttpApiClient } from '../../shared/api/http-api-client.service';
import {
  RegisterPushSubscriptionRequest,
  RemovePushSubscriptionRequest,
} from './push-notifications.models';

@Injectable({ providedIn: 'root' })
export class PushNotificationsApi {
  private readonly api = inject(HttpApiClient);
  private readonly baseUrl = `${new URL(API_ENDPOINTS.accounts).origin}/api/push-subscriptions`;

  register(payload: RegisterPushSubscriptionRequest): Observable<void> {
    return this.api.post<void, RegisterPushSubscriptionRequest>(this.baseUrl, payload);
  }

  remove(payload: RemovePushSubscriptionRequest): Observable<void> {
    return this.api.delete<void, RemovePushSubscriptionRequest>(this.baseUrl, payload);
  }
}
