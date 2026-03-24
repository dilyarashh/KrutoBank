import { ChangeDetectionStrategy, Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-async-state',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './async-state.component.html',
  styleUrl: './async-state.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AsyncStateComponent {
  @Input() loading = false;
  @Input() error: string | null = null;
  @Input() empty = false;
  @Input() loadingText = 'Загрузка...';
  @Input() emptyText = 'Данных пока нет.';
}
