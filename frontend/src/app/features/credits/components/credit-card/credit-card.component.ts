import { ChangeDetectionStrategy, Component, Input, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatChipsModule } from '@angular/material/chips';
import { MatIconModule } from '@angular/material/icon';
import { CreditsService } from '../../../../core/credits/credits.service';
import { CreditDto, CreditOperationDto } from '../../../../core/credits/credits.models';

@Component({
  selector: 'app-credit-card',
  standalone: true,
  imports: [CommonModule, MatCardModule, MatChipsModule, MatIconModule],
  templateUrl: './credit-card.component.html',
  styleUrls: ['./credit-card.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CreditCardComponent {
  private creditsService = inject(CreditsService);

  @Input({ required: true }) loan!: CreditDto;
  @Input({ required: true }) userId!: string;

  expanded = signal(false);

  opsLoading = signal(false);
  ops = signal<CreditOperationDto[] | null>(null); 
  opsError = signal<string | null>(null);

  toggle() {
    const next = !this.expanded();
    this.expanded.set(next);

    if (next) this.loadOpsIfNeeded();
  }

  private loadOpsIfNeeded() {
    if (this.ops() !== null || this.opsLoading()) return;

    this.opsLoading.set(true);
    this.opsError.set(null);

    this.creditsService.getCreditOperations(this.userId, this.loan.loanId).subscribe({
      next: (items) => {
        const sorted = [...items].sort(
          (a, b) => +new Date(b.operationDate) - +new Date(a.operationDate)
        );
        this.ops.set(sorted);
        this.opsLoading.set(false);
      },
      error: () => {
        this.opsError.set('Не удалось загрузить операции');
        this.opsLoading.set(false);
      },
    });
  }

  get statusText(): string {
    return this.loan.isActive ? 'Активен' : 'Закрыт';
  }

  formatDate(iso: string): string {
    return new Date(iso).toLocaleString('ru-RU');
  }

  formatAmount(amount: number): string {
    return new Intl.NumberFormat('ru-RU').format(amount) + ' ₽';
  }
}