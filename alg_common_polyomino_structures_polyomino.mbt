///|
pub struct Polyomino {
  planar_grid : PlanarGrid
  mut x : Int
  mut y : Int
  polyomino_extensions : Array[UniqueTriple[PolyominoDirection, Int, Int]]
}

///|
pub fn new_polyomino_with_extensions(
  width : Int,
  height : Int,
  extensions : Array[UniqueTriple[PolyominoDirection, Int, Int]],
) -> Polyomino {
  {
    planar_grid: new_planar_grid(width, height),
    x: 0,
    y: 0,
    polyomino_extensions: extensions,
  }
}

///|
pub fn new_polyomino(width : Int, height : Int) -> Polyomino {
  new_polyomino_with_extensions(width, height, [])
}

///|
pub fn new_empty_polyomino() -> Polyomino {
  new_polyomino(0, 0)
}

///|
pub fn Polyomino::as_planar_grid(self : Polyomino) -> PlanarGrid {
  self.planar_grid
}

///|
pub fn Polyomino::width(self : Polyomino) -> Int {
  self.planar_grid.width()
}

///|
pub fn Polyomino::height(self : Polyomino) -> Int {
  self.planar_grid.height()
}

///|
pub fn Polyomino::is_empty(self : Polyomino, x : Int, y : Int) -> Bool {
  self.planar_grid.is_empty(x, y)
}

///|
pub fn Polyomino::is_blocked(self : Polyomino, x : Int, y : Int) -> Bool {
  self.planar_grid.is_blocked(x, y)
}

///|
pub fn Polyomino::is_weakly_blocked(self : Polyomino, x : Int, y : Int) -> Bool {
  self.planar_grid.is_weakly_blocked(x, y)
}

///|
pub fn Polyomino::in_bounds(self : Polyomino, x : Int, y : Int) -> Bool {
  self.planar_grid.in_bounds(x, y)
}

///|
pub fn Polyomino::reinitialize(
  self : Polyomino,
  width : Int,
  height : Int,
) -> Unit {
  self.planar_grid.reinitialize(width, height)
}

///|
pub fn Polyomino::set_empty(self : Polyomino, x : Int, y : Int) -> Unit {
  self.planar_grid.set_empty(x, y)
}

///|
pub fn Polyomino::set_blocked(self : Polyomino, x : Int, y : Int) -> Unit {
  self.planar_grid.set_blocked(x, y)
}

///|
pub fn Polyomino::set_weakly_blocked(
  self : Polyomino,
  x : Int,
  y : Int,
) -> Unit {
  self.planar_grid.set_weakly_blocked(x, y)
}

///|
pub fn Polyomino::is_empty_center_based(
  self : Polyomino,
  x : Int,
  y : Int,
) -> Bool {
  self.planar_grid.is_empty_center_based(x, y)
}

///|
pub fn Polyomino::is_blocked_center_based(
  self : Polyomino,
  x : Int,
  y : Int,
) -> Bool {
  self.planar_grid.is_blocked_center_based(x, y)
}

///|
pub fn Polyomino::is_weakly_blocked_center_based(
  self : Polyomino,
  x : Int,
  y : Int,
) -> Bool {
  self.planar_grid.is_weakly_blocked_center_based(x, y)
}

///|
pub fn Polyomino::in_bounds_center_based(
  self : Polyomino,
  x : Int,
  y : Int,
) -> Bool {
  self.planar_grid.in_bounds_center_based(x, y)
}

///|
pub fn Polyomino::set_blocked_center_based(
  self : Polyomino,
  x : Int,
  y : Int,
) -> Unit {
  self.planar_grid.set_blocked_center_based(x, y)
}

///|
pub fn Polyomino::set_empty_center_based(
  self : Polyomino,
  x : Int,
  y : Int,
) -> Unit {
  self.planar_grid.set_empty_center_based(x, y)
}

///|
pub fn Polyomino::set_weakly_blocked_center_based(
  self : Polyomino,
  x : Int,
  y : Int,
) -> Unit {
  self.planar_grid.set_weakly_blocked_center_based(x, y)
}

///|
pub fn Polyomino::get_center_x(self : Polyomino) -> Int {
  self.planar_grid.get_center_x()
}

///|
pub fn Polyomino::get_center_y(self : Polyomino) -> Int {
  self.planar_grid.get_center_y()
}

///|
pub fn Polyomino::get_x(self : Polyomino) -> Int {
  self.x
}

///|
pub fn Polyomino::get_y(self : Polyomino) -> Int {
  self.y
}

///|
pub fn Polyomino::set_x(self : Polyomino, value : Int) -> Unit {
  self.x = value
}

///|
pub fn Polyomino::set_y(self : Polyomino, value : Int) -> Unit {
  self.y = value
}

///|
pub fn Polyomino::get_polyomino_extensions(
  self : Polyomino,
) -> Array[UniqueTriple[PolyominoDirection, Int, Int]] {
  self.polyomino_extensions
}

///|
pub fn Polyomino::add_extension(
  self : Polyomino,
  dir : PolyominoDirection,
  offset : Int,
  width : Int,
) -> Unit {
  self.polyomino_extensions.push(unique_triple_of(dir, offset, width))
}
