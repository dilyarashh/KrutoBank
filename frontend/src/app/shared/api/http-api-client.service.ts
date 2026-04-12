import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, catchError, throwError } from 'rxjs';
import { mapHttpError } from './api-error';

type RequestOptions = {
  headers?: HttpHeaders;
  params?: HttpParams;
  body?: unknown;
};

@Injectable({ providedIn: 'root' })
export class HttpApiClient {
  private readonly http = inject(HttpClient);

  get<TResponse>(url: string, options?: RequestOptions): Observable<TResponse> {
    return this.http.get<TResponse>(url, options).pipe(catchError(this.handleError));
  }

  post<TResponse, TBody>(url: string, body: TBody, options?: RequestOptions): Observable<TResponse> {
    return this.http.post<TResponse>(url, body, options).pipe(catchError(this.handleError));
  }

  patch<TResponse, TBody>(url: string, body: TBody, options?: RequestOptions): Observable<TResponse> {
    return this.http.patch<TResponse>(url, body, options).pipe(catchError(this.handleError));
  }

  delete<TResponse, TBody>(url: string, body: TBody, options?: RequestOptions): Observable<TResponse> {
    return this.http.delete<TResponse>(url, { ...options, body }).pipe(catchError(this.handleError));
  }

  private readonly handleError = (error: unknown) => throwError(() => mapHttpError(error));
}
