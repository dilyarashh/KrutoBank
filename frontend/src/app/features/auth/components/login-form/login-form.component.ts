import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  EventEmitter,
  inject,
  Output,
  signal,
} from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { ReactiveFormsModule, Validators, FormBuilder, AbstractControl } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { startWith, merge } from 'rxjs';

export type LoginCredentials = {
  phone: string;
  password: string;
};

@Component({
  selector: 'app-login-form',
  imports: [
    ReactiveFormsModule,
    MatIconModule,
    MatButtonModule,
    CommonModule,
  ],
  standalone: true,
  templateUrl: './login-form.component.html',
  styleUrl: './login-form.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class LoginFormComponent {
  @Output() login = new EventEmitter<LoginCredentials>();

  private readonly fb = inject(FormBuilder);

  readonly loading = signal(false);
  readonly errorText = signal<string | null>(null);
  readonly passwordHidden = signal(true);
  readonly submitted = signal(false);

  readonly form = this.fb.nonNullable.group({
    phone: this.fb.nonNullable.control('', [
      Validators.required,
      Validators.pattern(/^\+?\d{11}$/),
    ]),
    password: this.fb.nonNullable.control('', [Validators.required, Validators.minLength(6)]),
  });

  private readonly formTick = toSignal(
    merge(this.form.valueChanges, this.form.statusChanges).pipe(startWith(null)),
    { initialValue: null },
  );

  readonly disabled = computed(() => {
    this.formTick();
    return this.loading() || this.form.invalid;
  });

  readonly isInvalid = (ctrl: AbstractControl) =>
    computed(() => {
      this.formTick();
      return (ctrl.touched || ctrl.dirty || this.submitted()) && ctrl.invalid;
    });

  readonly phoneInvalid = this.isInvalid(this.form.controls.phone);
  readonly passwordInvalid = this.isInvalid(this.form.controls.password);

  readonly phoneErrorText = computed(() => {
    this.formTick();
    const c = this.form.controls.phone;

    if (c.hasError('required')) return 'Это обязательное поле';
    if (c.hasError('pattern')) return 'Введите корректный номер телефона';
    return 'Ошибка';
  });

  readonly passwordErrorText = computed(() => {
    this.formTick();
    const c = this.form.controls.password;
    if (c.hasError('required')) return 'Это обязательное поле';
    if (c.hasError('minlength')) return 'Пароль должен быть не менее 6 символов';
    return 'Ошибка';
  });

  togglePassword() {
    this.passwordHidden.update((v) => !v);
  }

  setLoading(v: boolean) {
    this.loading.set(v);
  }

  setError(message: string | null) {
    this.errorText.set(message);
  }

  submit() {
    this.submitted.set(true);
    this.setError(null);

    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    const { phone, password } = this.form.getRawValue();
    this.login.emit({ phone, password });
  }
}
