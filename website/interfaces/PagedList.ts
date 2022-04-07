export type PagedList<T> = {
  items: Array<T>;
  currentPage: number;
  perPage: number;
  lastPage: number;
  total: number;
};
