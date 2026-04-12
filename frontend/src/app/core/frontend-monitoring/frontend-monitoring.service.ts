import { Injectable, signal } from '@angular/core';
import {
  FrontendExceptionLog,
  FrontendMonitoringSnapshot,
  FrontendRequestLog,
} from './frontend-monitoring.models';

const STORAGE_KEY = 'frontend_monitoring_logs';
const MAX_REQUESTS = 250;
const MAX_EXCEPTIONS = 100;

@Injectable({ providedIn: 'root' })
export class FrontendMonitoringService {
  private readonly snapshotSignal = signal<FrontendMonitoringSnapshot>(this.readSnapshot());

  readonly snapshot = this.snapshotSignal.asReadonly();

  recordRequest(log: Omit<FrontendRequestLog, 'id' | 'serviceName' | 'createdAt'>): void {
    const item: FrontendRequestLog = {
      ...log,
      id: this.createId(),
      serviceName: 'Frontend',
      createdAt: new Date().toISOString(),
    };

    this.update((snapshot) => ({
      ...snapshot,
      requests: [item, ...snapshot.requests].slice(0, MAX_REQUESTS),
    }));
  }

  recordException(log: Omit<FrontendExceptionLog, 'id' | 'serviceName' | 'createdAt'>): void {
    const item: FrontendExceptionLog = {
      ...log,
      id: this.createId(),
      serviceName: 'Frontend',
      createdAt: new Date().toISOString(),
    };

    this.update((snapshot) => ({
      ...snapshot,
      exceptions: [item, ...snapshot.exceptions].slice(0, MAX_EXCEPTIONS),
    }));
  }

  clear(): void {
    const empty = this.emptySnapshot();
    this.snapshotSignal.set(empty);
    localStorage.setItem(STORAGE_KEY, JSON.stringify(empty));
  }

  private update(project: (snapshot: FrontendMonitoringSnapshot) => FrontendMonitoringSnapshot): void {
    const next = project(this.snapshotSignal());
    this.snapshotSignal.set(next);
    localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
  }

  private readSnapshot(): FrontendMonitoringSnapshot {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (!raw) {
        return this.emptySnapshot();
      }

      const parsed: unknown = JSON.parse(raw);
      if (!this.isSnapshot(parsed)) {
        return this.emptySnapshot();
      }

      return parsed;
    } catch {
      return this.emptySnapshot();
    }
  }

  private emptySnapshot(): FrontendMonitoringSnapshot {
    return {
      requests: [],
      exceptions: [],
    };
  }

  private isSnapshot(value: unknown): value is FrontendMonitoringSnapshot {
    return (
      typeof value === 'object' &&
      value !== null &&
      Array.isArray((value as FrontendMonitoringSnapshot).requests) &&
      Array.isArray((value as FrontendMonitoringSnapshot).exceptions)
    );
  }

  private createId(): string {
    return typeof crypto.randomUUID === 'function'
      ? crypto.randomUUID()
      : `${Date.now()}-${Math.random().toString(16).slice(2)}`;
  }
}
