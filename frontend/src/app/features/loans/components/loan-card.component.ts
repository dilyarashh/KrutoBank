import {
  ChangeDetectionStrategy,
  Component,
  Input,
  OnDestroy,
  inject,
  signal,
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { Subscription } from 'rxjs';
import { MatCardModule } from '@angular/material/card';
import { MatChipsModule } from '@angular/material/chips';
import { MatIconModule } from '@angular/material/icon';
import { LoansService } from '../../../core/loans/loans.sevice';
import { LoanDto, LoanOperationDto } from '../../../core/loans/loans.models';
import { AsyncStateComponent } from '../../../shared/components/async-state/async-state.component';

@Component({
  selector: 'app-loan-card',
  standalone: true,
  imports: [CommonModule, MatCardModule, MatChipsModule, MatIconModule, AsyncStateComponent],
  templateUrl: './loan-card.component.html',
  styleUrls: ['./loan-card.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class LoanCardComponent implements OnDestroy {
  private readonly loansService = inject(LoansService);
  private opsSubscription?: Subscription;

  @Input({ required: true }) accountId!: string;

  expanded = signal(false);

  loading = signal(true);
  error = signal<string | null>(null);
  account = signal<LoanDto | null>(null);

  opsLoading = signal(false);
  opsError = signal<string | null>(null);
  ops = signal<LoanOperationDto[] | null>(null);

  ngOnInit() {
    this.loadAccount();
  }

  ngOnDestroy() {
    this.opsSubscription?.unsubscribe();
  }

  toggle() {
    const next = !this.expanded();
    this.expanded.set(next);

    if (next) {
      this.connectOperationsRealtime();
    }
  }

  private loadAccount(showLoading = true) {
    if (showLoading) {
      this.loading.set(true);
      this.error.set(null);
    }

    this.loansService.getById(this.accountId).subscribe({
      next: (a) => {
        this.account.set(a);
        if (showLoading) {
          this.loading.set(false);
        }
      },
      error: () => {
        if (showLoading) {
          this.error.set('Не удалось загрузить счет');
          this.loading.set(false);
        }
      },
    });
  }

  private connectOperationsRealtime() {
    if (this.opsSubscription) {
      return;
    }

    this.opsLoading.set(true);
    this.opsError.set(null);

    this.opsSubscription = this.loansService.watchOperations(this.accountId).subscribe({
      next: (items) => {
        this.ops.set(items);
        this.loadAccount(false);
        this.opsLoading.set(false);
      },
      error: () => {
        this.opsError.set('Не удалось подключить обновление операций');
        this.opsLoading.set(false);
        this.opsSubscription?.unsubscribe();
        this.opsSubscription = undefined;
      },
    });
  }

  formatDate(iso: string): string {
    return new Date(iso).toLocaleString('ru-RU');
  }

  formatMoney(v: number, currency?: string): string {
    const formatted = new Intl.NumberFormat('ru-RU').format(v);
    const code = this.currencyLabel(currency);
    return code ? `${formatted} ${code}` : formatted;
  }

  accountStatus(a: LoanDto): string {
    return a.isClosed ? 'Закрыт' : 'Открыт';
  }

  operationTypeText(t: string): string {
    const map: Record<string, string> = {
      Deposit: 'Пополнение',
      Withdraw: 'Списание',
      Transfer: 'Перевод',
      Payment: 'Платеж',
      Exchange: 'Обмен валюты',
      Interest: 'Начисление',
    };

    return map[t] ?? t;
  }

  operationTypeTone(t: string): 'income' | 'expense' | 'transfer' | 'neutral' {
    const map: Record<string, 'income' | 'expense' | 'transfer' | 'neutral'> = {
      Deposit: 'income',
      Withdraw: 'expense',
      Transfer: 'transfer',
      Payment: 'expense',
      Exchange: 'transfer',
      Interest: 'income',
    };

    return map[t] ?? 'neutral';
  }

  operationIcon(t: string): string {
    const map: Record<string, string> = {
      Deposit: 'south_west',
      Withdraw: 'north_east',
      Transfer: 'swap_horiz',
      Payment: 'receipt_long',
      Exchange: 'currency_exchange',
      Interest: 'savings',
    };

    return map[t] ?? 'payments';
  }

  amountPrefix(t: string): string {
    const tone = this.operationTypeTone(t);
    if (tone === 'income') return '+';
    if (tone === 'expense') return '-';
    return '';
  }

  private currencyLabel(currency?: string): string {
    const map: Record<string, string> = {
      RUB: 'RUB',
      USD: 'USD',
      EUR: 'EUR',
    };

    return map[currency ?? ''] ?? (currency || '');
  }
}
