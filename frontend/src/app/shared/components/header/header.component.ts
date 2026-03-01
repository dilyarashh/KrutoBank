import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { CreateTariffDialogComponent } from '../../../features/tariffs/components/create-tariff-dialog.component';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-header',
  standalone: true,
  imports: [CreateTariffDialogComponent, CommonModule],
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AppHeaderComponent {
  modalOpen = signal(false);

  openCreateTariff() {
    this.modalOpen.set(true);
  }

  onModalClosed(_created: boolean) {
  this.modalOpen.set(false); 
}
}
