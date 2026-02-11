///|
pub struct IThreeValueGrid {
  get_width_fn : () -> Int
  get_height_fn : () -> Int
  is_empty_fn : (Int, Int) -> Bool
  is_blocked_fn : (Int, Int) -> Bool
  is_weakly_blocked_fn : (Int, Int) -> Bool
  in_bounds_fn : (Int, Int) -> Bool
  reinitialize_fn : (Int, Int) -> Unit
  set_empty_fn : (Int, Int) -> Unit
  set_blocked_fn : (Int, Int) -> Unit
  set_weakly_blocked_fn : (Int, Int) -> Unit
}

///|
pub fn new_three_value_grid(
  get_width_fn : () -> Int,
  get_height_fn : () -> Int,
  is_empty_fn : (Int, Int) -> Bool,
  is_blocked_fn : (Int, Int) -> Bool,
  is_weakly_blocked_fn : (Int, Int) -> Bool,
  in_bounds_fn : (Int, Int) -> Bool,
  reinitialize_fn : (Int, Int) -> Unit,
  set_empty_fn : (Int, Int) -> Unit,
  set_blocked_fn : (Int, Int) -> Unit,
  set_weakly_blocked_fn : (Int, Int) -> Unit,
) -> IThreeValueGrid {
  {
    get_width_fn,
    get_height_fn,
    is_empty_fn,
    is_blocked_fn,
    is_weakly_blocked_fn,
    in_bounds_fn,
    reinitialize_fn,
    set_empty_fn,
    set_blocked_fn,
    set_weakly_blocked_fn,
  }
}

///|
pub fn new_three_value_grid_from_two_bit_grid(
  grid : TwoBitGrid,
) -> IThreeValueGrid {
  new_three_value_grid(
    () => grid.width(),
    () => grid.height(),
    (x, y) => grid.is_empty(x, y),
    (x, y) => grid.is_blocked(x, y),
    (x, y) => grid.is_weakly_blocked(x, y),
    (x, y) => grid.in_bounds(x, y),
    (width, height) => grid.reinitialize(width, height),
    (x, y) => grid.set_empty(x, y),
    (x, y) => grid.set_blocked(x, y),
    (x, y) => grid.set_weakly_blocked(x, y),
  )
}

///|
pub fn IThreeValueGrid::get_width(self : IThreeValueGrid) -> Int {
  (self.get_width_fn)()
}

///|
pub fn IThreeValueGrid::get_height(self : IThreeValueGrid) -> Int {
  (self.get_height_fn)()
}

///|
pub fn IThreeValueGrid::is_empty(
  self : IThreeValueGrid,
  x : Int,
  y : Int,
) -> Bool {
  (self.is_empty_fn)(x, y)
}

///|
pub fn IThreeValueGrid::is_blocked(
  self : IThreeValueGrid,
  x : Int,
  y : Int,
) -> Bool {
  (self.is_blocked_fn)(x, y)
}

///|
pub fn IThreeValueGrid::is_weakly_blocked(
  self : IThreeValueGrid,
  x : Int,
  y : Int,
) -> Bool {
  (self.is_weakly_blocked_fn)(x, y)
}

///|
pub fn IThreeValueGrid::in_bounds(
  self : IThreeValueGrid,
  x : Int,
  y : Int,
) -> Bool {
  (self.in_bounds_fn)(x, y)
}

///|
pub fn IThreeValueGrid::reinitialize(
  self : IThreeValueGrid,
  width : Int,
  height : Int,
) -> Unit {
  (self.reinitialize_fn)(width, height)
}

///|
pub fn IThreeValueGrid::set_empty(
  self : IThreeValueGrid,
  x : Int,
  y : Int,
) -> Unit {
  (self.set_empty_fn)(x, y)
}

///|
pub fn IThreeValueGrid::set_blocked(
  self : IThreeValueGrid,
  x : Int,
  y : Int,
) -> Unit {
  (self.set_blocked_fn)(x, y)
}

///|
pub fn IThreeValueGrid::set_weakly_blocked(
  self : IThreeValueGrid,
  x : Int,
  y : Int,
) -> Unit {
  (self.set_weakly_blocked_fn)(x, y)
}
