import { Injectable, signal } from '@angular/core';

export type FeedbackKind = 'success' | 'error' | 'info';

export type FeedbackItem = {
  id: number;
  kind: FeedbackKind;
  message: string;
};

@Injectable({ providedIn: 'root' })
export class FeedbackService {
  readonly items = signal<FeedbackItem[]>([]);
  private nextId = 1;

  success(message: string) {
    this.push('success', message);
  }

  error(message: string) {
    this.push('error', message);
  }

  info(message: string) {
    this.push('info', message);
  }

  dismiss(id: number) {
    this.items.update((items) => items.filter((item) => item.id !== id));
  }

  private push(kind: FeedbackKind, message: string) {
    const item: FeedbackItem = {
      id: this.nextId++,
      kind,
      message,
    };

    this.items.update((items) => [...items, item]);
    setTimeout(() => this.dismiss(item.id), 4200);
  }
}
