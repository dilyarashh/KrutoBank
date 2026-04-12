import { Injectable } from '@angular/core';

const WINDOW_MS = 60_000;
const MIN_EVENTS = 10;
const FAILURE_THRESHOLD = 0.7;
const OPEN_MS = 30_000;

type CircuitEvent = {
  timestamp: number;
  failed: boolean;
};

type CircuitState = {
  events: CircuitEvent[];
  openUntil: number | null;
};

@Injectable({ providedIn: 'root' })
export class ResilienceCircuitBreakerService {
  private readonly states = new Map<string, CircuitState>();

  isOpen(key: string): boolean {
    const state = this.getState(key);
    this.cleanup(state);

    if (state.openUntil && state.openUntil > Date.now()) {
      return true;
    }

    state.openUntil = null;
    return false;
  }

  retryAfterSeconds(key: string): number {
    const state = this.getState(key);
    if (!state.openUntil) {
      return 0;
    }

    return Math.max(0, Math.ceil((state.openUntil - Date.now()) / 1000));
  }

  recordSuccess(key: string): void {
    this.record(key, false);
  }

  recordFailure(key: string): void {
    this.record(key, true);
  }

  private record(key: string, failed: boolean): void {
    const state = this.getState(key);
    state.events.push({
      timestamp: Date.now(),
      failed,
    });

    this.cleanup(state);

    if (state.events.length < MIN_EVENTS) {
      return;
    }

    const failures = state.events.filter((event) => event.failed).length;
    const ratio = failures / state.events.length;

    if (ratio > FAILURE_THRESHOLD) {
      state.openUntil = Date.now() + OPEN_MS;
    }
  }

  private getState(key: string): CircuitState {
    let state = this.states.get(key);
    if (!state) {
      state = {
        events: [],
        openUntil: null,
      };
      this.states.set(key, state);
    }

    return state;
  }

  private cleanup(state: CircuitState): void {
    const threshold = Date.now() - WINDOW_MS;
    state.events = state.events.filter((event) => event.timestamp >= threshold);
  }
}
