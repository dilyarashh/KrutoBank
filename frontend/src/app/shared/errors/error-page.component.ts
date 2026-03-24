import { ChangeDetectionStrategy, Component, computed, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';

@Component({
  selector: 'app-error-page',
  standalone: true,
  imports: [CommonModule, RouterModule, MatButtonModule],
  templateUrl: './error-page.component.html',
  styleUrl: './error-page.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ErrorPageComponent {
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);

  readonly isNotFound = computed(() => this.route.snapshot.data['kind'] === 'not-found');
  readonly navigationState = computed<Record<string, unknown>>(() => history.state ?? {});

  readonly title = computed(() =>
    this.isNotFound() ? 'Страница не найдена' : 'Что-то пошло не так'
  );

  readonly message = computed(() => {
    if (this.isNotFound()) {
      return 'Запрошенная страница отсутствует или была перемещена.';
    }

    const state = this.navigationState();
    return typeof state['message'] === 'string' && state['message'].trim()
      ? state['message']
      : 'Приложение столкнулось с необработанной ошибкой.';
  });

  goHome() {
    void this.router.navigateByUrl('/users');
  }
}
