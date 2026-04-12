export type FrontendRequestLog = {
  id: string;
  serviceName: 'Frontend';
  method: string;
  url: string;
  route: string;
  statusCode: number;
  durationMs: number;
  traceId: string;
  spanId: string;
  isError: boolean;
  errorMessage?: string;
  createdAt: string;
};

export type FrontendExceptionLog = {
  id: string;
  serviceName: 'Frontend';
  message: string;
  stack?: string;
  route: string;
  traceId: string;
  spanId: string;
  createdAt: string;
};

export type FrontendMonitoringSnapshot = {
  requests: FrontendRequestLog[];
  exceptions: FrontendExceptionLog[];
};
