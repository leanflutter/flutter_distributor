export type Result<T> = {
  code?: number;
  message?: string;
  data?: T;
};
