import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';

@Component({
  selector: 'app-dialog-frame',
  standalone: true,
  imports: [CommonModule, MatIconModule],
  templateUrl: './dialog-frame.component.html',
  styleUrl: './dialog-frame.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DialogFrameComponent {
  @Input({ required: true }) title = '';
  @Input() icon?: string;
  @Input() subtitle?: string;
  @Input() compact = false;

  @Output() close = new EventEmitter<void>();

  onClose() {
    this.close.emit();
  }
}
