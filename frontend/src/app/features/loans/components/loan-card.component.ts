import { ChangeDetectionStrategy, Component, Input, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
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
export class LoanCardComponent {
  private readonly loansService = inject(LoansService);

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

  toggle() {
    const next = !this.expanded();
    this.expanded.set(next);

    if (next) {
      this.loadOpsIfNeeded();
    }
  }

  private loadAccount() {
    this.loading.set(true);
    this.error.set(null);

    this.loansService.getById(this.accountId).subscribe({
      next: (a) => {
        this.account.set(a);
        this.loading.set(false);
      },
      error: () => {
        this.error.set('Не удалось загрузить счет');
        this.loading.set(false);
      },
    });
  }

  private loadOpsIfNeeded() {
    if (this.ops() !== null || this.opsLoading()) return;

    this.opsLoading.set(true);
    this.opsError.set(null);

    this.loansService.getOperations(this.accountId).subscribe({
      next: (res) => {
        const items = Array.isArray(res) ? res : [res];
        const sorted = [...items].sort((a, b) => +new Date(b.createdAt) - +new Date(a.createdAt));
        this.ops.set(sorted);
        this.opsLoading.set(false);
      },
      error: () => {
        this.opsError.set('Не удалось загрузить операции');
        this.opsLoading.set(false);
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
