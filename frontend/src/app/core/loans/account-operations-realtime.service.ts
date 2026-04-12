import { Injectable, inject } from '@angular/core';
import { Observable, ReplaySubject } from 'rxjs';
import {
  HubConnection,
  HubConnectionBuilder,
  HubConnectionState,
} from '@microsoft/signalr';
import { API_ENDPOINTS } from '../../shared/api/api-endpoints';
import { AuthService } from '../auth/auth.service';
import { LoanOperationDto } from './loans.models';

type AccountChannel = {
  refs: number;
  subject: ReplaySubject<LoanOperationDto[]>;
};

const REALTIME_RETRY_COUNT = 5;
const REALTIME_RETRY_DELAY_MS = 250;
const RECONNECT_DELAYS_MS = [0, 1_000, 3_000, 7_000, 15_000];

@Injectable({ providedIn: 'root' })
export class AccountOperationsRealtimeService {
  private readonly auth = inject(AuthService);
  private readonly hubUrl = `${new URL(API_ENDPOINTS.accounts).origin}/ws/account-operations`;

  private connection: HubConnection | null = null;
  private connectionStartPromise: Promise<void> | null = null;
  private readonly channels = new Map<string, AccountChannel>();

  watchOperations(accountId: string): Observable<LoanOperationDto[]> {
    return new Observable<LoanOperationDto[]>((subscriber) => {
      const channel = this.ensureChannel(accountId);
      const innerSub = channel.subject.subscribe(subscriber);

      channel.refs += 1;
      void this.activateAccount(accountId);

      return () => {
        innerSub.unsubscribe();
        void this.deactivateAccount(accountId);
      };
    });
  }

  private ensureChannel(accountId: string): AccountChannel {
    let channel = this.channels.get(accountId);

    if (!channel) {
      channel = {
        refs: 0,
        subject: new ReplaySubject<LoanOperationDto[]>(1),
      };

      this.channels.set(accountId, channel);
    }

    return channel;
  }

  private async activateAccount(accountId: string): Promise<void> {
    try {
      await this.ensureConnection();

      if (this.channels.get(accountId)?.refs === 1) {
        await this.invokeWithRetry('SubscribeAccount', accountId);
      } else {
        await this.invokeWithRetry('RequestOperations', accountId);
      }
    } catch (error) {
      this.channels.get(accountId)?.subject.error(error);
      this.channels.delete(accountId);
    }
  }

  private async deactivateAccount(accountId: string): Promise<void> {
    const channel = this.channels.get(accountId);
    if (!channel) {
      return;
    }

    channel.refs = Math.max(0, channel.refs - 1);

    if (channel.refs > 0) {
      return;
    }

    try {
      if (this.connection?.state === HubConnectionState.Connected) {
        await this.invokeWithRetry('UnsubscribeAccount', accountId);
      }
    } catch {
    }

    this.channels.delete(accountId);

    if (this.channels.size === 0 && this.connection?.state === HubConnectionState.Connected) {
      await this.connection.stop();
    }
  }

  private async ensureConnection(): Promise<void> {
    const connection = this.getOrCreateConnection();

    if (connection.state === HubConnectionState.Connected) {
      return;
    }

    if (!this.connectionStartPromise) {
      this.connectionStartPromise = this.runWithRetry(() => connection.start()).finally(() => {
        this.connectionStartPromise = null;
      });
    }

    await this.connectionStartPromise;
  }

  private getOrCreateConnection(): HubConnection {
    if (this.connection) {
      return this.connection;
    }

    const connection = new HubConnectionBuilder()
      .withUrl(this.hubUrl, {
        accessTokenFactory: () => this.auth.getToken() ?? '',
      })
      .withAutomaticReconnect(RECONNECT_DELAYS_MS)
      .build();

    connection.on('OperationsSnapshot', (accountId: string, payload: LoanOperationDto[]) => {
      const channel = this.channels.get(accountId);
      if (!channel) {
        return;
      }

      const sorted = [...payload].sort(
        (a, b) => +new Date(b.createdAt) - +new Date(a.createdAt)
      );

      channel.subject.next(sorted);
    });

    connection.on('OperationsInvalidated', (accountId: string) => {
      void this.requestOperations(accountId);
    });

    connection.onclose((error) => {
      this.connection = null;
      this.connectionStartPromise = null;

      if (!error) {
        return;
      }

      for (const [, channel] of this.channels) {
        channel.subject.error(error);
      }

      this.channels.clear();
    });

    connection.onreconnected(async () => {
      const accountIds = [...this.channels.entries()]
        .filter(([, channel]) => channel.refs > 0)
        .map(([accountId]) => accountId);

      for (const accountId of accountIds) {
        try {
          await this.invokeWithRetry('SubscribeAccount', accountId);
        } catch (error) {
          this.channels.get(accountId)?.subject.error(error);
          this.channels.delete(accountId);
        }
      }
    });

    this.connection = connection;
    return connection;
  }

  private async requestOperations(accountId: string): Promise<void> {
    try {
      await this.ensureConnection();
      const connection = this.connection;
      if (!connection) {
        return;
      }

      await this.invokeWithRetry('RequestOperations', accountId);
    } catch (error) {
      this.channels.get(accountId)?.subject.error(error);
      this.channels.delete(accountId);
    }
  }

  private async invokeWithRetry(methodName: string, ...args: unknown[]): Promise<void> {
    await this.runWithRetry(async () => {
      const connection = this.connection;
      if (!connection || connection.state !== HubConnectionState.Connected) {
        await this.ensureConnection();
      }

      const readyConnection = this.connection;
      if (!readyConnection) {
        throw new Error('Realtime connection is not available.');
      }

      await readyConnection.invoke(methodName, ...args);
    });
  }

  private async runWithRetry(action: () => Promise<void>): Promise<void> {
    let lastError: unknown;

    for (let attempt = 1; attempt <= REALTIME_RETRY_COUNT; attempt += 1) {
      try {
        await action();
        return;
      } catch (error) {
        lastError = error;

        if (attempt === REALTIME_RETRY_COUNT) {
          break;
        }

        await this.delay(REALTIME_RETRY_DELAY_MS * attempt);
      }
    }

    throw lastError;
  }

  private delay(ms: number): Promise<void> {
    return new Promise((resolve) => window.setTimeout(resolve, ms));
  }
}
