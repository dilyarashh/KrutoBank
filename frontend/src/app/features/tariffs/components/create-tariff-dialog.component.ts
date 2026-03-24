import { ChangeDetectionStrategy, Component, EventEmitter, Output, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { TariffsService } from '../../../core/tariff/tariff.service';
import { FeedbackService } from '../../../shared/feedback/feedback.service';
import { toErrorMessage } from '../../../shared/api/api-error';
import { DialogFrameComponent } from '../../../shared/components/dialog-frame/dialog-frame.component';
import { ModalSurfaceComponent } from '../../../shared/components/modal-surface/modal-surface.component';

@Component({
  selector: 'app-create-tariff-modal',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, DialogFrameComponent, ModalSurfaceComponent],
  templateUrl: './create-tariff-dialog.component.html',
  styleUrls: ['./create-tariff-dialog.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CreateTariffDialogComponent {
  private readonly fb = inject(FormBuilder);
  private readonly api = inject(TariffsService);
  private readonly feedback = inject(FeedbackService);

  readonly success = signal(false);
  readonly loading = signal(false);
  readonly error = signal<string | null>(null);

  @Output() closed = new EventEmitter<boolean>();

  readonly form = this.fb.nonNullable.group({
    name: ['', [Validators.required, Validators.maxLength(100)]],
    interestRate: [0, [Validators.required, Validators.min(0)]],
  });

  close(created = false) {
    this.closed.emit(created);
  }

  submit() {
    if (this.form.invalid || this.loading()) return;

    this.loading.set(true);
    this.error.set(null);
    this.success.set(false);

    this.api.createTariff(this.form.getRawValue()).subscribe({
      next: () => {
        this.loading.set(false);
        this.success.set(true);
        this.feedback.success('Тариф успешно создан.');
        setTimeout(() => this.close(true), 1000);
      },
      error: (error: unknown) => {
        const message = toErrorMessage(error, 'Не удалось создать тариф.');
        this.error.set(message);
        this.feedback.error(message);
        this.loading.set(false);
      },
    });
  }
}
