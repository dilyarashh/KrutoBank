import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { CreateTariffDialogComponent } from '../../../features/tariffs/components/create-tariff-dialog.component';
import { CommonModule } from '@angular/common';
import { ThemeService } from '../../../core/theme/theme.service';
import { MatIconModule } from '@angular/material/icon';
import { FeedbackService } from '../../feedback/feedback.service';
import { toErrorMessage } from '../../api/api-error';
import { AuthService } from '../../../core/auth/auth.service';

@Component({
  selector: 'app-header',
  standalone: true,
  imports: [CreateTariffDialogComponent, CommonModule, MatIconModule],
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AppHeaderComponent {
  readonly modalOpen = signal(false);
  readonly themeService = inject(ThemeService);
  private readonly auth = inject(AuthService);
  private readonly feedback = inject(FeedbackService);

  openCreateTariff() {
    this.modalOpen.set(true);
  }

  async toggleTheme() {
    try {
      await this.themeService.toggleTheme();
      this.feedback.info(
        this.themeService.isDark() ? 'Включена темная тема.' : 'Включена светлая тема.'
      );
    } catch (error: unknown) {
      this.feedback.error(toErrorMessage(error, 'Не удалось сохранить выбранную тему.'));
    }
  }

  async logout() {
    try {
      await this.auth.logout();
    } catch (error: unknown) {
      this.feedback.error(toErrorMessage(error, 'Не удалось выйти из аккаунта.'));
    }
  }

  onModalClosed(_created: boolean) {
    this.modalOpen.set(false);
  }
}
