import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-modal-surface',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './modal-surface.component.html',
  styleUrl: './modal-surface.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ModalSurfaceComponent {
  @Input() maxWidth = '560px';

  @Output() dismiss = new EventEmitter<void>();

  onBackdropClick() {
    this.dismiss.emit();
  }

  onKeydown(event: KeyboardEvent) {
    if (event.key === 'Escape') {
      this.dismiss.emit();
    }
  }
}
