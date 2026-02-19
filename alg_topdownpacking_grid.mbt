///|
pub struct Grid[T] {
  put_fn : (Int, Int, T) -> Unit
  get_fn : (Int, Int) -> T
  get_row_fn : (Int) -> Array[T]
  get_column_fn : (Int) -> Array[T]
  get_columns_fn : () -> Int
  get_rows_fn : () -> Int
  set_grid_size_fn : (Int, Int) -> Unit
}

///|
pub fn[T] new_grid(
  put : (Int, Int, T) -> Unit,
  get : (Int, Int) -> T,
  get_row : (Int) -> Array[T],
  get_column : (Int) -> Array[T],
  get_columns : () -> Int,
  get_rows : () -> Int,
  set_grid_size : (Int, Int) -> Unit,
) -> Grid[T] {
  {
    put_fn: put,
    get_fn: get,
    get_row_fn: get_row,
    get_column_fn: get_column,
    get_columns_fn: get_columns,
    get_rows_fn: get_rows,
    set_grid_size_fn: set_grid_size,
  }
}

///|
pub fn[T] Grid::put(self : Grid[T], col : Int, row : Int, item : T) -> Unit {
  (self.put_fn)(col, row, item)
}

///|
pub fn[T] Grid::get(self : Grid[T], col : Int, row : Int) -> T {
  (self.get_fn)(col, row)
}

///|
pub fn[T] Grid::get_row(self : Grid[T], row : Int) -> Array[T] {
  (self.get_row_fn)(row)
}

///|
pub fn[T] Grid::get_column(self : Grid[T], col : Int) -> Array[T] {
  (self.get_column_fn)(col)
}

///|
pub fn[T] Grid::get_columns(self : Grid[T]) -> Int {
  (self.get_columns_fn)()
}

///|
pub fn[T] Grid::get_rows(self : Grid[T]) -> Int {
  (self.get_rows_fn)()
}

///|
pub fn[T] Grid::set_grid_size(self : Grid[T], cols : Int, rows : Int) -> Unit {
  (self.set_grid_size_fn)(cols, rows)
}
