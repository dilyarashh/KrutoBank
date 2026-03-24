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
        await this.connection?.invoke('SubscribeAccount', accountId);
      } else {
        await this.connection?.invoke('RequestOperations', accountId);
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
        await this.connection.invoke('UnsubscribeAccount', accountId);
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
      this.connectionStartPromise = connection.start().finally(() => {
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
      .withAutomaticReconnect()
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

    connection.onreconnected(async () => {
      const accountIds = [...this.channels.entries()]
        .filter(([, channel]) => channel.refs > 0)
        .map(([accountId]) => accountId);

      for (const accountId of accountIds) {
        try {
          await connection.invoke('SubscribeAccount', accountId);
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
    if (this.connection?.state !== HubConnectionState.Connected) {
      return;
    }

    try {
      await this.connection.invoke('RequestOperations', accountId);
    } catch (error) {
      this.channels.get(accountId)?.subject.error(error);
      this.channels.delete(accountId);
    }
  }
}
