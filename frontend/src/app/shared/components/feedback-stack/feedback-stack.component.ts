import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FeedbackService } from '../../feedback/feedback.service';
import { MatIconModule } from '@angular/material/icon';

@Component({
  selector: 'app-feedback-stack',
  standalone: true,
  imports: [CommonModule, MatIconModule],
  templateUrl: './feedback-stack.component.html',
  styleUrl: './feedback-stack.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FeedbackStackComponent {
  readonly feedback = inject(FeedbackService);

  dismiss(id: number) {
    this.feedback.dismiss(id);
  }

  icon(kind: 'success' | 'error' | 'info'): string {
    switch (kind) {
      case 'success':
        return 'check_circle';
      case 'error':
        return 'error';
      default:
        return 'info';
    }
  }
}
