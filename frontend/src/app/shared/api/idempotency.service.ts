import { Injectable } from '@angular/core';
import { v4 as uuidv4 } from 'uuid';

@Injectable({ providedIn: 'root' })
export class IdempotencyService {
  private readonly PREFIX = 'idempotency_';
  private readonly SESSION_TTL_MS = 24 * 60 * 60 * 1000; 

  getOrCreateKey(method: string, url: string, body?: unknown): string {
    const operationId = this.generateOperationId(method, url, body);
    const storageKey = `${this.PREFIX}${operationId}`;

    const existingKey = this.getFromStorage(storageKey);
    if (existingKey) {
      return existingKey;
    }

    const newKey = uuidv4();
    this.saveToStorage(storageKey, newKey);
    return newKey;
  }

  private generateOperationId(method: string, url: string, body?: unknown): string {
  
    const bodyStr = body ? JSON.stringify(body) : '';
    const combined = `${method}:${url}:${bodyStr}`;

    let hash = 0;
    for (let i = 0; i < combined.length; i++) {
      const char = combined.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; 
    }

    return Math.abs(hash).toString(16);
  }

  private saveToStorage(key: string, value: string): void {
    try {
      const data = {
        value,
        timestamp: Date.now(),
      };
      sessionStorage.setItem(key, JSON.stringify(data));
    } catch (error) {
      console.warn('не получилось сохранить ключ', error);
    }
  }

  private getFromStorage(key: string): string | null {
    try {
      const stored = sessionStorage.getItem(key);
      if (!stored) return null;

      const data = JSON.parse(stored);
      const age = Date.now() - data.timestamp;

      if (age < this.SESSION_TTL_MS) {
        return data.value;
      }

      sessionStorage.removeItem(key);
      return null;
    } catch (error) {
      console.warn('анлак', error);
      return null;
    }
  }

  clearAllKeys(): void {
    try {
      const keys = Array.from({ length: sessionStorage.length }, (_, i) =>
        sessionStorage.key(i),
      );

      keys.forEach((key) => {
        if (key?.startsWith(this.PREFIX)) {
          sessionStorage.removeItem(key);
        }
      });
    } catch (error) {
      console.warn('не получилось очистить ключи:', error);
    }
  }
}
