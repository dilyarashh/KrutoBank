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
import { UserDto } from '../../../../core/users/users.models';
import { UsersService } from '../../../../core/users/users.service';
import { CreditCardComponent } from '../../../credits/components/credit-card/credit-card.component';
import { CreditDto } from '../../../../core/credits/credits.models';
import { LoanCardComponent } from '../../../loans/components/loan-card.component';
import { LoansService } from '../../../../core/loans/loans.sevice';
import { UserAccountListItemDto } from '../../../../core/loans/loans.models';

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
  ],
  templateUrl: './user-profile-page.component.html',
  styleUrls: ['./user-profile-page.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class UserProfilePageComponent {
  private route = inject(ActivatedRoute);
  private usersService = inject(UsersService);
  private creditsApi = inject(CreditsService);
  private accountsApi = inject(LoansService);
  userId = computed(() => this.route.snapshot.paramMap.get('id') ?? '');

  loadingUser = signal(true);
  user = signal<UserDto | null>(null);
  userError = signal<string | null>(null);

  tab = signal<TabKey>('accounts');

  loansLoading = signal(false);
  loans = signal<CreditDto[] | null>(null);
  loansError = signal<string | null>(null);

  accountsLoading = signal(false);
  accountsError = signal<string | null>(null);
  accounts = signal<UserAccountListItemDto[] | null>(null);
  onlyOpened = signal(false);

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

  initials = computed(() => {
    const u = this.user();
    if (!u) return '—';
    const a = u.lastName?.[0] ?? '';
    const b = u.firstName?.[0] ?? '';
    return (a + b).toUpperCase();
  });

  fullName = computed(() => {
    const u = this.user();
    if (!u) return '';
    return [u.lastName, u.firstName, u.middleName].filter(Boolean).join(' ');
  });

 selectTab(key: TabKey) {
  this.tab.set(key);

  if (key === 'loans') this.loadLoansIfNeeded();
  if (key === 'accounts') this.loadAccountsIfNeeded();
}

  roleText = computed(() => {
    const u = this.user();
    if (!u) return '';
    return u.role === 'Client' ? 'Клиент' : 'Сотрудник';
  });

  statusText = computed(() => {
    const u = this.user();
    if (!u) return '';
    return u.isBlocked ? 'Заблокирован' : 'Активен';
  });

  private loadLoansIfNeeded() {
    if (this.loans() !== null || this.loansLoading()) return;

    this.loansLoading.set(true);
    this.loansError.set(null);

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
