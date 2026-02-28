///|
pub struct PlanarGrid {
  two_bit_grid : TwoBitGrid
  mut x_center : Int
  mut y_center : Int
}

///|
pub fn new_planar_grid(width : Int, height : Int) -> PlanarGrid {
  {
    two_bit_grid: new_two_bit_grid(width, height),
    x_center: (width - 1) >> 1,
    y_center: (height - 1) >> 1,
  }
}

///|
pub fn new_empty_planar_grid() -> PlanarGrid {
  { two_bit_grid: new_two_bit_grid(0, 0), x_center: 0, y_center: 0 }
}

///|
pub fn PlanarGrid::width(self : PlanarGrid) -> Int {
  self.two_bit_grid.width()
}

///|
pub fn PlanarGrid::height(self : PlanarGrid) -> Int {
  self.two_bit_grid.height()
}

///|
pub fn PlanarGrid::is_empty(self : PlanarGrid, x : Int, y : Int) -> Bool {
  self.two_bit_grid.is_empty(x, y)
}

///|
pub fn PlanarGrid::is_blocked(self : PlanarGrid, x : Int, y : Int) -> Bool {
  self.two_bit_grid.is_blocked(x, y)
}

///|
pub fn PlanarGrid::is_weakly_blocked(
  self : PlanarGrid,
  x : Int,
  y : Int,
) -> Bool {
  self.two_bit_grid.is_weakly_blocked(x, y)
}

///|
pub fn PlanarGrid::in_bounds(self : PlanarGrid, x : Int, y : Int) -> Bool {
  self.two_bit_grid.in_bounds(x, y)
}

///|
pub fn PlanarGrid::reinitialize(
  self : PlanarGrid,
  width : Int,
  height : Int,
) -> Unit {
  self.two_bit_grid.reinitialize(width, height)
  self.x_center = (width - 1) >> 1
  self.y_center = (height - 1) >> 1
}

///|
pub fn PlanarGrid::set_empty(self : PlanarGrid, x : Int, y : Int) -> Unit {
  self.two_bit_grid.set_empty(x, y)
}

///|
pub fn PlanarGrid::set_blocked(self : PlanarGrid, x : Int, y : Int) -> Unit {
  self.two_bit_grid.set_blocked(x, y)
}

///|
pub fn PlanarGrid::set_weakly_blocked(
  self : PlanarGrid,
  x : Int,
  y : Int,
) -> Unit {
  self.two_bit_grid.set_weakly_blocked(x, y)
}

///|
pub fn PlanarGrid::to_string(self : PlanarGrid) -> String {
  self.two_bit_grid.to_string()
}

///|
pub fn PlanarGrid::is_empty_center_based(
  self : PlanarGrid,
  x : Int,
  y : Int,
) -> Bool {
  self.is_empty(x + self.x_center, y + self.y_center)
}

///|
pub fn PlanarGrid::is_blocked_center_based(
  self : PlanarGrid,
  x : Int,
  y : Int,
) -> Bool {
  self.is_blocked(x + self.x_center, y + self.y_center)
}

///|
pub fn PlanarGrid::is_weakly_blocked_center_based(
  self : PlanarGrid,
  x : Int,
  y : Int,
) -> Bool {
  self.is_weakly_blocked(x + self.x_center, y + self.y_center)
}

///|
pub fn PlanarGrid::in_bounds_center_based(
  self : PlanarGrid,
  x : Int,
  y : Int,
) -> Bool {
  self.in_bounds(x + self.x_center, y + self.y_center)
}

///|
pub fn PlanarGrid::intersects_with_center_based(
  self : PlanarGrid,
  other : PlanarGrid,
  x_offset : Int,
  y_offset : Int,
) -> Bool {
  for x = 0; x < other.width(); x = x + 1 {
    let x_translated = x - other.get_center_x() + x_offset
    for y = 0; y < other.height(); y = y + 1 {
      let y_translated = y - other.get_center_y() + y_offset
      if self.in_bounds_center_based(x_translated, y_translated) &&
        (
          (
            !other.is_empty(x, y) &&
            self.is_blocked_center_based(x_translated, y_translated)
          ) ||
          (
            other.is_blocked(x, y) &&
            !self.is_empty_center_based(x_translated, y_translated)
          )
        ) {
        return true
      }
    }
  }
  false
}

///|
pub fn PlanarGrid::intersects_with_center_based_polyomino(
  self : PlanarGrid,
  other : Polyomino,
  x_offset : Int,
  y_offset : Int,
) -> Bool {
  if self.intersects_with_center_based(
      other.as_planar_grid(),
      x_offset,
      y_offset,
    ) {
    return true
  }

  for ext in other.get_polyomino_extensions() {
    let mut intersects = false
    let left_x = self.get_center_x() - other.get_center_x() + x_offset
    let right_x = left_x + other.width()
    let top_y = self.get_center_y() - other.get_center_y() + y_offset
    let bottom_y = top_y + other.height()

    match ext.get_first() {
      North =>
        intersects = self.weakly_intersects_area(
          left_x + ext.get_second(),
          0,
          left_x + ext.get_third(),
          top_y - 1,
        )
      East =>
        intersects = self.weakly_intersects_area(
          right_x,
          top_y + ext.get_second(),
          self.width() - 1,
          top_y + ext.get_third(),
        )
      South =>
        intersects = self.weakly_intersects_area(
          left_x + ext.get_second(),
          bottom_y,
          left_x + ext.get_third(),
          self.height() - 1,
        )
      West =>
        intersects = self.weakly_intersects_area(
          0,
          top_y + ext.get_second(),
          left_x - 1,
          top_y + ext.get_third(),
        )
    }

    if intersects {
      return true
    }
  }

  false
}

///|
pub fn PlanarGrid::add_filled_cells_from(
  self : PlanarGrid,
  other : PlanarGrid,
  x_offset : Int,
  y_offset : Int,
) -> Unit {
  for x = 0; x < other.width(); x = x + 1 {
    let x_translated = x - other.get_center_x() + x_offset
    for y = 0; y < other.height(); y = y + 1 {
      let y_translated = y - other.get_center_y() + y_offset
      if other.is_blocked(x, y) {
        if !self.is_weakly_blocked_center_based(x_translated, y_translated) {
          self.set_blocked_center_based(x_translated, y_translated)
        }
      } else if other.is_weakly_blocked(x, y) {
        if !self.is_blocked_center_based(x_translated, y_translated) {
          self.set_weakly_blocked_center_based(x_translated, y_translated)
        }
      }
    }
  }
}

///|
pub fn PlanarGrid::add_filled_cells_from_polyomino(
  self : PlanarGrid,
  other : Polyomino,
  x_offset : Int,
  y_offset : Int,
) -> Unit {
  self.add_filled_cells_from(other.as_planar_grid(), x_offset, y_offset)
  other.set_x(self.x_center - other.get_center_x() + x_offset)
  other.set_y(self.y_center - other.get_center_y() + y_offset)

  for ext in other.get_polyomino_extensions() {
    match ext.get_first() {
      North =>
        self.weakly_block_area(
          other.get_x() + ext.get_second(),
          0,
          other.get_x() + ext.get_third(),
          other.get_y() - 1,
        )
      East =>
        self.weakly_block_area(
          other.get_x() + other.width(),
          other.get_y() + ext.get_second(),
          self.width() - 1,
          other.get_y() + ext.get_third(),
        )
      South =>
        self.weakly_block_area(
          other.get_x() + ext.get_second(),
          other.get_y() + other.height(),
          other.get_x() + ext.get_third(),
          self.height() - 1,
        )
      West =>
        self.weakly_block_area(
          0,
          other.get_y() + ext.get_second(),
          other.get_x() - 1,
          other.get_y() + ext.get_third(),
        )
    }
  }
}

///|
pub fn PlanarGrid::get_filled_bounds(
  self : PlanarGrid,
) -> @core.Quadruple[Int, Int, Int, Int] {
  let grid_width = self.width()
  let grid_height = self.height()
  let mut min_x = @int.max_value
  let mut max_x = -@int.max_value
  let mut min_y = @int.max_value
  let mut max_y = -@int.max_value

  for xi = 0; xi < grid_width; xi = xi + 1 {
    for yi = 0; yi < grid_height; yi = yi + 1 {
      if self.is_blocked(xi, yi) {
        if xi < min_x {
          min_x = xi
        }
        if xi > max_x {
          max_x = xi
        }
        if yi < min_y {
          min_y = yi
        }
        if yi > max_y {
          max_y = yi
        }
      }
    }
  }

  let width = max_x - min_x + 1
  let height = max_y - min_y + 1
  @core.quadruple_of(min_x, min_y, width, height)
}

///|
pub fn PlanarGrid::weakly_block_area(
  self : PlanarGrid,
  x_upper_left : Int,
  y_upper_left : Int,
  x_bottom_right : Int,
  y_bottom_right : Int,
) -> Unit {
  for yi = y_upper_left; yi <= y_bottom_right; yi = yi + 1 {
    for xi = x_upper_left; xi <= x_bottom_right; xi = xi + 1 {
      if !self.is_blocked(xi, yi) {
        self.set_weakly_blocked(xi, yi)
      }
    }
  }
}

///|
pub fn PlanarGrid::weakly_intersects_area(
  self : PlanarGrid,
  x_upper_left : Int,
  y_upper_left : Int,
  x_bottom_right : Int,
  y_bottom_right : Int,
) -> Bool {
  for yi = y_upper_left; yi <= y_bottom_right; yi = yi + 1 {
    for xi = x_upper_left; xi <= x_bottom_right; xi = xi + 1 {
      if self.is_blocked(xi, yi) {
        return true
      }
    }
  }
  false
}

///|
pub fn PlanarGrid::get_center_x(self : PlanarGrid) -> Int {
  self.x_center
}

///|
pub fn PlanarGrid::get_center_y(self : PlanarGrid) -> Int {
  self.y_center
}

///|
pub fn PlanarGrid::set_blocked_center_based(
  self : PlanarGrid,
  x : Int,
  y : Int,
) -> Unit {
  self.set_blocked(x + self.x_center, y + self.y_center)
}

///|
pub fn PlanarGrid::set_empty_center_based(
  self : PlanarGrid,
  x : Int,
  y : Int,
) -> Unit {
  self.set_empty(x + self.x_center, y + self.y_center)
}

///|
pub fn PlanarGrid::set_weakly_blocked_center_based(
  self : PlanarGrid,
  x : Int,
  y : Int,
) -> Unit {
  self.set_weakly_blocked(x + self.x_center, y + self.y_center)
}
