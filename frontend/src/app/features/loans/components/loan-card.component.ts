import { ChangeDetectionStrategy, Component, Input, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatChipsModule } from '@angular/material/chips';
import { MatIconModule } from '@angular/material/icon';
import { LoansService } from '../../../core/loans/loans.sevice';
import { LoanDto, LoanOperationDto } from '../../../core/loans/loans.models';

@Component({
  selector: 'app-loan-card',
  standalone: true,
  imports: [CommonModule, MatCardModule, MatChipsModule, MatIconModule],
  templateUrl: './loan-card.component.html',
  styleUrls: ['./loan-card.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class LoanCardComponent {
  private loansService = inject(LoansService);

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
    if (next) this.loadOpsIfNeeded();
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

  formatMoney(v: number): string {
    return new Intl.NumberFormat('ru-RU').format(v) + ' ₽';
  }

  accountStatus(a: LoanDto): string {
    return a.isClosed ? 'Закрыт' : 'Открыт';
  }

  operationTypeText(t: string): string {
    const map: Record<string, string> = {
      Deposit: 'Пополнение',
      Withdraw: 'Списание',
      Transfer: 'Перевод',
      Payment: 'Платёж',
    };
    return map[t] ?? t;
  }
}
