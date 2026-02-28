///|
pub struct Quadruplet {
  mut left : Bool
  mut right : Bool
  mut up : Bool
  mut down : Bool
}

///|
pub fn new_quadruplet() -> Quadruplet {
  { left: false, right: false, up: false, down: false }
}

///|
pub fn new_quadruplet_values(
  left : Bool,
  right : Bool,
  up : Bool,
  down : Bool,
) -> Quadruplet {
  { left, right, up, down }
}

///|
pub fn Quadruplet::set(
  self : Quadruplet,
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
pub fn Quadruplet::apply_or(self : Quadruplet, other : Quadruplet) -> Unit {
  self.left = self.left || other.left
  self.right = self.right || other.right
  self.up = self.up || other.up
  self.down = self.down || other.down
}

///|
pub fn Quadruplet::set_direction(
  self : Quadruplet,
  value : Bool,
  direction : @core.Direction,
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
pub fn Quadruplet::get(self : Quadruplet, direction : @core.Direction) -> Bool {
  match direction {
    Leftward => self.left
    Rightward => self.right
    Upward => self.up
    Downward => self.down
    Undefined => false
  }
}
