import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { firstValueFrom } from 'rxjs';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { Router } from '@angular/router';
import { PaginationComponent } from '../../../../shared/components/pagination/pagination.component';
import { FeedbackService } from '../../../../shared/feedback/feedback.service';
import { toErrorMessage } from '../../../../shared/api/api-error';
import { AsyncStateComponent } from '../../../../shared/components/async-state/async-state.component';
import { UserCardComponent } from '../../components/user-card/user-card.component';
import { UserItem } from '../../../../core/users/users.models';
import { UsersService } from '../../../../core/users/users.service';
import { UserCreateDialogComponent } from '../../components/user-create-dialog/user-create-dialog.component';

@Component({
  selector: 'app-users-page',
  standalone: true,
  imports: [
    CommonModule,
    PaginationComponent,
    AsyncStateComponent,
    UserCardComponent,
    MatDialogModule,
    MatButtonModule,
    MatIconModule,
  ],
  templateUrl: './users-page.component.html',
  styleUrl: './users-page.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class UsersPageComponent {
  private readonly usersApi = inject(UsersService);
  private readonly dialog = inject(MatDialog);
  private readonly feedback = inject(FeedbackService);
  private readonly router = inject(Router);

  readonly loading = signal(false);
  readonly error = signal<string | null>(null);

  readonly page = signal(1);
  readonly pageSize = signal(10);
  readonly sortBy = signal<string | undefined>(undefined);
  readonly ascending = signal<boolean | undefined>(undefined);
  readonly totalCount = signal(0);
  readonly items = signal<UserItem[]>([]);

  constructor() {
    void this.load();
  }

  async load() {
    this.loading.set(true);
    this.error.set(null);

    try {
      const res = await firstValueFrom(
        this.usersApi.getUsersList({
          page: this.page(),
          pageSize: this.pageSize(),
          sortBy: this.sortBy(),
          ascending: this.ascending(),
        })
      );

      this.totalCount.set(res.totalCount);
      this.items.set(res.items);
    } catch (error: unknown) {
      this.error.set(toErrorMessage(error, 'Не удалось загрузить пользователей.'));
    } finally {
      this.loading.set(false);
    }
  }

  async onPageChange(newPage: number) {
    if (newPage === this.page()) return;
    this.page.set(newPage);
    await this.load();
  }

  onOpenUser(userId: string) {
    void this.router.navigate(['/users', userId]);
  }

  async onToggleBlock(user: UserItem) {
    if (user.isBlocked) return;

    try {
      this.loading.set(true);
      await firstValueFrom(this.usersApi.blockUser(user.id));

      this.items.update((list) =>
        list.map((u) => (u.id === user.id ? { ...u, isBlocked: true } : u))
      );

      this.feedback.success('Пользователь заблокирован.');
    } catch (error: unknown) {
      const message = toErrorMessage(error, 'Не удалось заблокировать пользователя.');
      this.error.set(message);
      this.feedback.error(message);
    } finally {
      this.loading.set(false);
    }
  }

  async openCreateUserDialog() {
    const ref = this.dialog.open(UserCreateDialogComponent, {
      width: '860px',
      maxWidth: '92vw',
      panelClass: 'sweet-dialog',
    });

    const payload = await firstValueFrom(ref.afterClosed());
    if (!payload) return;

    try {
      this.loading.set(true);
      const res = await firstValueFrom(this.usersApi.createUser(payload));
      this.feedback.success('Пользователь успешно создан.');
      await this.router.navigate(['/users', res.id]);
    } catch (error: unknown) {
      const message = toErrorMessage(error, 'Не удалось создать пользователя.');
      this.error.set(message);
      this.feedback.error(message);
    } finally {
      this.loading.set(false);
    }
  }
}
