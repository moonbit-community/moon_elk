///|
pub struct LayeredQuadruplet {
  mut left : Bool
  mut right : Bool
  mut up : Bool
  mut down : Bool
}

///|
pub fn new_layered_quadruplet() -> LayeredQuadruplet {
  { left: false, right: false, up: false, down: false }
}

///|
pub fn new_layered_quadruplet_with_values(
  left : Bool,
  right : Bool,
  up : Bool,
  down : Bool,
) -> LayeredQuadruplet {
  { left, right, up, down }
}

///|
pub fn LayeredQuadruplet::set_values(
  self : LayeredQuadruplet,
  left : Bool,
  right : Bool,
  up : Bool,
  down : Bool,
) -> Unit {
  self.left = left
  self.right = right
  self.up = up
  self.down = down
}

///|
pub fn LayeredQuadruplet::set_for_direction(
  self : LayeredQuadruplet,
  value : Bool,
  direction : Direction,
) -> Unit {
  match direction {
    Leftward => self.left = value
    Rightward => self.right = value
    Upward => self.up = value
    Downward => self.down = value
    Undefined => ()
  }
}

///|
pub fn LayeredQuadruplet::get(
  self : LayeredQuadruplet,
  direction : Direction,
) -> Bool {
  match direction {
    Leftward => self.left
    Rightward => self.right
    Upward => self.up
    Downward => self.down
    Undefined => false
  }
}
