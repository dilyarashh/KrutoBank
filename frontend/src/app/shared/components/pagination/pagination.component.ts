import {
  ChangeDetectionStrategy,
  Component,
  computed,
  EventEmitter,
  Input,
  Output,
} from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-pagination',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './pagination.component.html',
  styleUrls: ['./pagination.component.css'],  
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PaginationComponent {
  @Input({ required: true }) page!: number;        
  @Input({ required: true }) pageSize!: number;
  @Input({ required: true }) totalCount!: number;

  @Output() pageChange = new EventEmitter<number>();

  readonly totalPages = computed(() => {
    const pages = Math.ceil(this.totalCount / this.pageSize);
    return Math.max(1, pages);
  });

  readonly pagesToShow = computed(() => {
    const total = this.totalPages();
    const current = this.page;

    const windowSize = 7; 
    const half = Math.floor(windowSize / 2);

    let start = Math.max(1, current - half);
    let end = Math.min(total, start + windowSize - 1);

    start = Math.max(1, end - windowSize + 1);

    const pages: number[] = [];
    for (let i = start; i <= end; i++) pages.push(i);
    return pages;
  });

  prev() {
    if (this.page > 1) this.pageChange.emit(this.page - 1);
  }

  next() {
    if (this.page < this.totalPages()) this.pageChange.emit(this.page + 1);
  }

  go(p: number) {
    if (p !== this.page) this.pageChange.emit(p);
  }
}