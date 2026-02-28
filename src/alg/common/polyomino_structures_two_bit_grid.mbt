///|
pub struct TwoBitGrid {
  mut x_size : Int
  mut y_size : Int
  mut cells : Array[Int]
}

///|
fn create_cells(width : Int, height : Int) -> Array[Int] {
  if width < 0 || height < 0 {
    @core.layout_runtime_report_unsupported_configuration(
      "grid dimensions must be non-negative",
    )
    return []
  }
  Array::make(width * height, 0)
}

///|
fn grid_cell_index(grid : TwoBitGrid, x : Int, y : Int) -> Int {
  if !grid.in_bounds(x, y) {
    @core.layout_runtime_report_unsupported_configuration(
      "requested point is out of bounds",
    )
    return 0
  }
  y * grid.x_size + x
}

///|
pub fn new_two_bit_grid(width : Int, height : Int) -> TwoBitGrid {
  { x_size: width, y_size: height, cells: create_cells(width, height) }
}

///|
pub fn TwoBitGrid::width(self : TwoBitGrid) -> Int {
  self.x_size
}

///|
pub fn TwoBitGrid::height(self : TwoBitGrid) -> Int {
  self.y_size
}

///|
pub fn TwoBitGrid::in_bounds(self : TwoBitGrid, x : Int, y : Int) -> Bool {
  x >= 0 && y >= 0 && x < self.x_size && y < self.y_size
}

///|
pub fn TwoBitGrid::is_empty(self : TwoBitGrid, x : Int, y : Int) -> Bool {
  self.cells[grid_cell_index(self, x, y)] == 0
}

///|
pub fn TwoBitGrid::is_blocked(self : TwoBitGrid, x : Int, y : Int) -> Bool {
  self.cells[grid_cell_index(self, x, y)] == 1
}

///|
pub fn TwoBitGrid::is_weakly_blocked(
  self : TwoBitGrid,
  x : Int,
  y : Int,
) -> Bool {
  self.cells[grid_cell_index(self, x, y)] == 2
}

///|
pub fn TwoBitGrid::reinitialize(
  self : TwoBitGrid,
  width : Int,
  height : Int,
) -> Unit {
  self.x_size = width
  self.y_size = height
  self.cells = create_cells(width, height)
}

///|
pub fn TwoBitGrid::set_empty(self : TwoBitGrid, x : Int, y : Int) -> Unit {
  self.cells[grid_cell_index(self, x, y)] = 0
}

///|
pub fn TwoBitGrid::set_blocked(self : TwoBitGrid, x : Int, y : Int) -> Unit {
  self.cells[grid_cell_index(self, x, y)] = 1
}

///|
pub fn TwoBitGrid::set_weakly_blocked(
  self : TwoBitGrid,
  x : Int,
  y : Int,
) -> Unit {
  self.cells[grid_cell_index(self, x, y)] = 2
}

///|
fn next_mod_ten(num : Int) -> Int {
  if num > 8 {
    0
  } else {
    num + 1
  }
}

///|
pub fn TwoBitGrid::to_string(self : TwoBitGrid) -> String {
  let builder = StringBuilder::new()
  builder.write_string(" ")
  let mut x_count = 0
  for _x = 0; _x < self.x_size; _x = _x + 1 {
    builder.write_object(x_count)
    x_count = next_mod_ten(x_count)
  }
  builder.write_char('\n')
  let mut y_count = 0
  for y = 0; y < self.y_size; y = y + 1 {
    builder.write_object(y_count)
    y_count = next_mod_ten(y_count)
    for x = 0; x < self.x_size; x = x + 1 {
      let cell = self.cells[y * self.x_size + x]
      if cell == 0 {
        builder.write_char('_')
      } else if cell == 1 {
        builder.write_char('X')
      } else {
        builder.write_char('0')
      }
    }
    if y + 1 < self.y_size {
      builder.write_char('\n')
    }
  }
  builder.to_string()
}
