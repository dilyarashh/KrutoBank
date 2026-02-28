import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatNativeDateModule } from '@angular/material/core';
import { CreateUserRequest } from '../../../../core/users/users.models';

type DialogResult = CreateUserRequest;

const NAME_RE = /^[A-ZА-ЯЁ][a-zа-яё]+$/;
const PHONE_RE = /^\+?\d{11}$/;
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function toIsoDateOnly(d: Date): string {
  const yyyy = d.getFullYear();
  const mm = String(d.getMonth() + 1).padStart(2, '0');
  const dd = String(d.getDate()).padStart(2, '0');
  return `${yyyy}-${mm}-${dd}`;
}

@Component({
  selector: 'app-user-create-dialog',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatDialogModule,
    MatButtonModule,
    MatIconModule,
    MatInputModule,
    MatSelectModule,
    MatDatepickerModule,
    MatNativeDateModule,
  ],
  templateUrl: './user-create-dialog.component.html',
  styleUrl: './user-create-dialog.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class UserCreateDialogComponent {
  private readonly fb = inject(FormBuilder);
  private readonly ref = inject(MatDialogRef<UserCreateDialogComponent, DialogResult>);
  readonly loading = signal(false);

  readonly data = inject(MAT_DIALOG_DATA, { optional: true });

  readonly form = this.fb.nonNullable.group({
    lastName: this.fb.nonNullable.control('', [
      Validators.required,
      Validators.maxLength(50),
      Validators.pattern(NAME_RE),
    ]),
    firstName: this.fb.nonNullable.control('', [
      Validators.required,
      Validators.maxLength(50),
      Validators.pattern(NAME_RE),
    ]),
    middleName: this.fb.nonNullable.control('', [
      Validators.required,
      Validators.maxLength(50),
      Validators.pattern(NAME_RE),
    ]),
    phone: this.fb.nonNullable.control('', [Validators.required, Validators.pattern(PHONE_RE)]),
    email: this.fb.control<string | null>(null, [Validators.maxLength(100)]),
    birthday: this.fb.control<Date | null>(null, [Validators.required]),
    password: this.fb.nonNullable.control('', [Validators.required, Validators.minLength(8)]),
    role: this.fb.nonNullable.control<'Client' | 'Employee'>('Client', [Validators.required]),
  });

  readonly minDate = new Date(1900, 0, 1);
  readonly maxDate = new Date(2025, 11, 31);

  hidePassword = true;

  isInvalid(name: string): boolean {
    const c = this.form.get(name);
    return !!c && c.invalid && (c.touched || c.dirty || this.submitted);
  }

  errorText(name: string): string {
    const c = this.form.get(name);
    if (!c) return '';

    if (c.hasError('required')) return 'Обязательное поле';
    if (c.hasError('maxlength')) return 'Не более 50 символов';
    if (c.hasError('minlength')) return 'Минимум 8 символов';
    if (c.hasError('pattern')) return 'Некорректный формат';
    if (c.hasError('email')) return 'Некорректная почта';
    if (c.hasError('range')) return 'Дата должна быть между 1900 и 2025';

    return 'Ошибка';
  }

  submitted = false;

  close() {
    this.ref.close();
  }

  submit() {
    if (this.loading()) return;

    const raw = this.form.getRawValue();
    const emailNormalized = (raw.email ?? '').trim();
    if (emailNormalized.length > 0 && !EMAIL_RE.test(emailNormalized)) {
      this.form.controls.email.setErrors({ email: true });
    }

    if (raw.birthday) {
      if (raw.birthday < this.minDate || raw.birthday > this.maxDate) {
        this.form.controls.birthday.setErrors({ range: true });
      }
    }

    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    const v = this.form.getRawValue();

    const payload: CreateUserRequest = {
      firstName: v.firstName.trim(),
      lastName: v.lastName.trim(),
      middleName: v.middleName.trim(),
      phone: v.phone.trim(),
      email: emailNormalized.length ? emailNormalized : null,
      birthday: toIsoDateOnly(v.birthday!),
      role: v.role,
      password: v.password,
    };

    this.ref.close(payload);
  }
}
