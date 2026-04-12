import { ChangeDetectionStrategy, Component, computed, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { FrontendMonitoringService } from '../../core/frontend-monitoring/frontend-monitoring.service';

@Component({
  selector: 'app-frontend-monitoring-page',
  standalone: true,
  imports: [CommonModule, MatIconModule],
  templateUrl: './frontend-monitoring-page.component.html',
  styleUrl: './frontend-monitoring-page.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FrontendMonitoringPageComponent {
  private readonly monitoring = inject(FrontendMonitoringService);

  readonly requests = computed(() => this.monitoring.snapshot().requests);
  readonly exceptions = computed(() => this.monitoring.snapshot().exceptions);

  readonly totalRequests = computed(() => this.requests().length);
  readonly errorRequests = computed(() => this.requests().filter((request) => request.isError).length);
  readonly errorPercent = computed(() => {
    const total = this.totalRequests();
    return total === 0 ? 0 : Math.round((this.errorRequests() * 1000) / total) / 10;
  });

  readonly averageDurationMs = computed(() => {
    const requests = this.requests();
    if (requests.length === 0) {
      return 0;
    }

    const total = requests.reduce((sum, request) => sum + request.durationMs, 0);
    return Math.round(total / requests.length);
  });

  readonly lastRequests = computed(() => this.requests().slice(0, 20));
  readonly lastExceptions = computed(() => this.exceptions().slice(0, 10));

  clear() {
    this.monitoring.clear();
  }

  formatDate(value: string): string {
    return new Date(value).toLocaleString('ru-RU');
  }

  statusText(statusCode: number): string {
    return statusCode === 0 ? 'нет ответа' : String(statusCode);
  }

  shortUrl(url: string): string {
    try {
      const parsed = new URL(url, window.location.origin);
      return `${parsed.origin}${parsed.pathname}`;
    } catch {
      return url;
    }
  }
}
