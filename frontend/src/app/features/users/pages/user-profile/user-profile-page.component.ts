import {
  ChangeDetectionStrategy,
  Component,
  computed,
  effect,
  inject,
  signal,
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterModule } from '@angular/router';
import { MatIconModule } from '@angular/material/icon';
import { MatCardModule } from '@angular/material/card';
import { MatChipsModule } from '@angular/material/chips';
import { CreditsService } from '../../../../core/credits/credits.service';
import { CreditDto, CreditScoreDto } from '../../../../core/credits/credits.models';
import { UserDto } from '../../../../core/users/users.models';
import { UsersService } from '../../../../core/users/users.service';
import { CreditCardComponent } from '../../../credits/components/credit-card/credit-card.component';
import { LoanCardComponent } from '../../../loans/components/loan-card.component';
import { LoansService } from '../../../../core/loans/loans.sevice';
import { UserAccountListItemDto } from '../../../../core/loans/loans.models';
import { AsyncStateComponent } from '../../../../shared/components/async-state/async-state.component';

type TabKey = 'accounts' | 'loans';

@Component({
  standalone: true,
  selector: 'app-user-profile-page',
  imports: [
    CommonModule,
    RouterModule,
    MatIconModule,
    MatCardModule,
    MatChipsModule,
    CreditCardComponent,
    LoanCardComponent,
    AsyncStateComponent,
  ],
  templateUrl: './user-profile-page.component.html',
  styleUrls: ['./user-profile-page.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class UserProfilePageComponent {
  private readonly route = inject(ActivatedRoute);
  private readonly usersService = inject(UsersService);
  private readonly creditsApi = inject(CreditsService);
  private readonly accountsApi = inject(LoansService);

  readonly userId = computed(() => this.route.snapshot.paramMap.get('id') ?? '');

  readonly loadingUser = signal(true);
  readonly user = signal<UserDto | null>(null);
  readonly userError = signal<string | null>(null);

  readonly tab = signal<TabKey>('accounts');

  readonly loansLoading = signal(false);
  readonly loans = signal<CreditDto[] | null>(null);
  readonly loansError = signal<string | null>(null);
  readonly creditScore = signal<CreditScoreDto | null>(null);
  readonly creditScoreLoading = signal(false);
  readonly creditScoreError = signal<string | null>(null);

  readonly accountsLoading = signal(false);
  readonly accountsError = signal<string | null>(null);
  readonly accounts = signal<UserAccountListItemDto[] | null>(null);
  readonly onlyOpened = signal(false);

  constructor() {
    effect(() => {
      const id = this.userId();
      if (!id) return;

      this.loadingUser.set(true);
      this.userError.set(null);

      this.usersService.getById(id).subscribe({
        next: (u) => {
          this.user.set(u);
          this.loadAccountsIfNeeded();
          this.loadingUser.set(false);
        },
        error: () => {
          this.userError.set('Не удалось загрузить пользователя');
          this.loadingUser.set(false);
        },
      });
    });
  }

  readonly initials = computed(() => {
    const u = this.user();
    if (!u) return '—';
    const a = u.lastName?.[0] ?? '';
    const b = u.firstName?.[0] ?? '';
    return (a + b).toUpperCase();
  });

  readonly fullName = computed(() => {
    const u = this.user();
    if (!u) return '';
    return [u.lastName, u.firstName, u.middleName].filter(Boolean).join(' ');
  });

  readonly roleText = computed(() => {
    const u = this.user();
    if (!u) return '';
    return u.role === 'Client' ? 'Клиент' : 'Сотрудник';
  });

  readonly statusText = computed(() => {
    const u = this.user();
    if (!u) return '';
    return u.isBlocked ? 'Заблокирован' : 'Активен';
  });

  readonly creditScoreLabel = computed(() => {
    const score = this.creditScore()?.score;
    if (score === undefined) return '';
    if (score >= 85) return 'Надежный заемщик';
    if (score >= 65) return 'Скорее всего кредит погасит';
    if (score >= 40) return 'Риск невозврата есть';
    return 'Высокий риск';
  });

  readonly creditScoreTone = computed(() => {
    const score = this.creditScore()?.score;
    if (score === undefined) return 'neutral';
    if (score >= 85) return 'excellent';
    if (score >= 65) return 'good';
    if (score >= 40) return 'warn';
    return 'danger';
  });

  readonly overdueSummary = computed(() => {
    const overdue = this.creditScore()?.overduePayments ?? 0;
    if (overdue === 0) return 'Просроченных платежей сейчас нет';
    if (overdue === 1) return 'Есть 1 просроченный платеж';
    return `Есть просроченные платежи: ${overdue}`;
  });

  readonly scoreRingOffset = computed(() => {
    const score = this.creditScore()?.score ?? 0;
    const clamped = Math.max(0, Math.min(score, 100));
    const circumference = 339.292;
    return circumference - (clamped / 100) * circumference;
  });

  selectTab(key: TabKey) {
    this.tab.set(key);

    if (key === 'loans') {
      this.loadLoansIfNeeded();
    }

    if (key === 'accounts') {
      this.loadAccountsIfNeeded();
    }
  }

  private loadLoansIfNeeded() {
    if (this.loans() !== null || this.loansLoading()) return;

    this.loansLoading.set(true);
    this.loansError.set(null);
    this.loadCreditScoreIfNeeded();

    this.creditsApi.getLoansByUserId(this.userId()).subscribe({
      next: (items) => {
        this.loans.set(items);
        this.loansLoading.set(false);
      },
      error: () => {
        this.loansError.set('Не удалось загрузить кредиты');
        this.loansLoading.set(false);
      },
    });
  }

  private loadCreditScoreIfNeeded() {
    if (this.creditScore() !== null || this.creditScoreLoading()) return;

    this.creditScoreLoading.set(true);
    this.creditScoreError.set(null);

    this.creditsApi.getCreditScore(this.userId()).subscribe({
      next: (score) => {
        this.creditScore.set(score);
        this.creditScoreLoading.set(false);
      },
      error: () => {
        this.creditScoreError.set('Не удалось загрузить кредитный рейтинг');
        this.creditScoreLoading.set(false);
      },
    });
  }

  private loadAccountsIfNeeded() {
    if (this.accounts() !== null || this.accountsLoading()) return;

    this.accountsLoading.set(true);
    this.accountsError.set(null);

    this.accountsApi.getAccountsByUserId(this.userId(), this.onlyOpened()).subscribe({
      next: (items) => {
        this.accounts.set(items);
        this.accountsLoading.set(false);
      },
      error: () => {
        this.accountsError.set('Не удалось загрузить счета');
        this.accountsLoading.set(false);
      },
    });
  }
}
