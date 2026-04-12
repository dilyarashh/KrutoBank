import { Injectable, inject } from '@angular/core';
import { FirebaseApp, getApp, getApps, initializeApp } from 'firebase/app';
import {
  MessagePayload,
  deleteToken,
  getMessaging,
  getToken,
  isSupported,
  onMessage,
} from 'firebase/messaging';
import { firstValueFrom } from 'rxjs';
import { FeedbackService } from '../../shared/feedback/feedback.service';
import { firebaseConfig, firebaseVapidKey } from './firebase-messaging.config';
import { PushAudience } from './push-notifications.models';
import { PushNotificationsApi } from './push-notifications.api';

const REGISTERED_TOKEN_KEY = 'firebase_push_token';
const SERVICE_WORKER_URL = '/firebase-messaging-sw.js';

@Injectable({ providedIn: 'root' })
export class PushNotificationsService {
  private readonly api = inject(PushNotificationsApi);
  private readonly feedback = inject(FeedbackService);

  private setupPromise: Promise<void> | null = null;
  private foregroundListenerRegistered = false;

  enable(audience: PushAudience): Promise<void> {
    if (!this.setupPromise) {
      this.setupPromise = this.setup(audience).finally(() => {
        this.setupPromise = null;
      });
    }

    return this.setupPromise;
  }

  async unregisterCurrentToken(): Promise<void> {
    const token = localStorage.getItem(REGISTERED_TOKEN_KEY);
    if (!token) {
      return;
    }

    try {
      await firstValueFrom(this.api.remove({ token }));
      localStorage.removeItem(REGISTERED_TOKEN_KEY);

      if (await this.canUseMessaging()) {
        await deleteToken(getMessaging(this.getFirebaseApp()));
      }
    } catch {
      localStorage.removeItem(REGISTERED_TOKEN_KEY);
    }
  }

  private async setup(audience: PushAudience): Promise<void> {
    if (!(await this.canUseMessaging())) {
      return;
    }

    const permission = await this.ensurePermission();
    if (permission !== 'granted') {
      return;
    }

    const registration = await navigator.serviceWorker.register(SERVICE_WORKER_URL);
    const messaging = getMessaging(this.getFirebaseApp());
    const token = await getToken(messaging, {
      vapidKey: firebaseVapidKey,
      serviceWorkerRegistration: registration,
    });

    if (!token) {
      return;
    }

    await firstValueFrom(
      this.api.register({
        platform: 'Web',
        audience,
        token,
      })
    );

    localStorage.setItem(REGISTERED_TOKEN_KEY, token);
    this.listenForegroundMessages();
  }

  private async canUseMessaging(): Promise<boolean> {
    if (!('Notification' in window) || !('serviceWorker' in navigator)) {
      return false;
    }

    if (!window.isSecureContext && window.location.hostname !== 'localhost') {
      return false;
    }

    return isSupported();
  }

  private ensurePermission(): Promise<NotificationPermission> {
    if (Notification.permission === 'granted' || Notification.permission === 'denied') {
      return Promise.resolve(Notification.permission);
    }

    return Notification.requestPermission();
  }

  private listenForegroundMessages() {
    if (this.foregroundListenerRegistered) {
      return;
    }

    this.foregroundListenerRegistered = true;
    onMessage(getMessaging(this.getFirebaseApp()), (payload) => this.handleForegroundMessage(payload));
  }

  private handleForegroundMessage(payload: MessagePayload) {
    const title = payload.notification?.title ?? 'KrutoBank';
    const body = payload.notification?.body ?? this.formatOperationPayload(payload.data);

    this.feedback.info(body ? `${title}: ${body}` : title);

    if (Notification.permission === 'granted' && document.visibilityState !== 'visible') {
      new Notification(title, {
        body,
        data: payload.data,
      });
    }
  }

  private formatOperationPayload(data: MessagePayload['data']): string {
    if (!data) {
      return 'New operation';
    }

    const type = data['operationType'] ?? 'Operation';
    const amount = data['amount'] ?? '';
    const currency = data['currency'] ?? '';

    return `${type} ${amount} ${currency}`.trim();
  }

  private getFirebaseApp(): FirebaseApp {
    return getApps().length ? getApp() : initializeApp(firebaseConfig);
  }
}
