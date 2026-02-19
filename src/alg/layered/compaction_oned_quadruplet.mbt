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
  direction : @core.Direction,
) -> Unit {
  match direction {
    @core.Direction::Leftward => self.left = value
    @core.Direction::Rightward => self.right = value
    @core.Direction::Upward => self.up = value
    @core.Direction::Downward => self.down = value
    Undefined => ()
  }
}

///|
pub fn LayeredQuadruplet::get(
  self : LayeredQuadruplet,
  direction : @core.Direction,
) -> Bool {
  match direction {
    @core.Direction::Leftward => self.left
    @core.Direction::Rightward => self.right
    @core.Direction::Upward => self.up
    @core.Direction::Downward => self.down
    Undefined => false
  }
}
