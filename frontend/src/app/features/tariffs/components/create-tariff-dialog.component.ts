import { ChangeDetectionStrategy, Component, EventEmitter, Output, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { TariffsService } from '../../../core/tariff/tariff.service';

@Component({
  selector: 'app-create-tariff-modal',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './create-tariff-dialog.component.html',
  styleUrls: ['./create-tariff-dialog.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CreateTariffDialogComponent {
  private fb = inject(FormBuilder);
  private api = inject(TariffsService);
  success = signal(false);

  @Output() closed = new EventEmitter<boolean>();

  loading = signal(false);
  error = signal<string | null>(null);

  form = this.fb.nonNullable.group({
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

      setTimeout(() => this.close(true), 1000);
    },
    error: () => {
      this.error.set('Не удалось создать тариф');
      this.loading.set(false);
    },
  });
}

  onKeydown(e: KeyboardEvent) {
    if (e.key === 'Escape') this.close(false);
  }
}