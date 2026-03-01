import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { firstValueFrom } from 'rxjs';

import { UserCardComponent } from '../../components/user-card/user-card.component';
import { CreateUserRequest, UserItem } from '../../../../core/users/users.models';
import { UsersService } from '../../../../core/users/users.service';
import { PaginationComponent } from '../../../../shared/components/pagination/pagination.component';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { UserCreateDialogComponent } from '../../components/user-create-dialog/user-create-dialog.component';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { Router } from '@angular/router';

@Component({
  selector: 'app-users-page',
  standalone: true,
  imports: [
    CommonModule,
    PaginationComponent,
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
  readonly loading = signal(false);
  readonly error = signal<string | null>(null);

  readonly page = signal(1);
  readonly pageSize = signal(10);

  readonly sortBy = signal<string | undefined>(undefined);
  readonly ascending = signal<boolean | undefined>(undefined);

  readonly totalCount = signal(0);
  readonly items = signal<UserItem[]>([]);
  router = inject(Router);

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
        }),
      );

      this.totalCount.set(res.totalCount);
      this.items.set(res.items);
    } catch (e) {
      console.error(e);
      this.error.set('Не удалось загрузить пользователей');
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
    this.router.navigate(['/users', userId]);
  }

  async onToggleBlock(user: UserItem) {
    if (user.isBlocked) return;

    try {
      this.loading.set(true);

      await firstValueFrom(this.usersApi.blockUser(user.id));

      this.items.update((list) =>
        list.map((u) => (u.id === user.id ? { ...u, isBlocked: true } : u)),
      );
    } catch (e) {
      console.error(e);
      this.error.set('Не удалось заблокировать пользователя');
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
      await this.router.navigate(['/users', res.id]);
    } catch (e) {
      console.error(e);
      this.error.set('Не удалось создать пользователя');
    } finally {
      this.loading.set(false);
    }
  }
}
