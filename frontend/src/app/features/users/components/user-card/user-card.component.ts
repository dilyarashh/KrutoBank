import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatChipsModule } from '@angular/material/chips';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { UserItem } from '../../../../core/users/users.models';

@Component({
  selector: 'app-user-card',
  standalone: true,
  imports: [CommonModule, MatCardModule, MatChipsModule, MatButtonModule, MatIconModule,],
  templateUrl: './user-card.component.html',
  styleUrl: './user-card.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class UserCardComponent {
  @Input({ required: true }) user!: UserItem;
  @Output() open = new EventEmitter<string>();
  @Output() toggleBlock = new EventEmitter<UserItem>();

  get fullName(): string {
    const parts = [this.user.lastName, this.user.firstName, this.user.middleName].filter(Boolean);
    return parts.join(' ');
  }

  get canBlock(): boolean {
    return !this.user.isBlocked;
  }

  get initials(): string {
    const f = this.user.firstName?.[0] ?? '';
    const l = this.user.lastName?.[0] ?? '';
    return (l + f).toUpperCase();
  }

  onOpen() {
    this.open.emit(this.user.id);
  }

  onToggleBlock() {
    this.toggleBlock.emit(this.user);
  }
}
