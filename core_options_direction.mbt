///|
pub enum Direction {
  Undefined
  Rightward
  Leftward
  Downward
  Upward
}

///|
pub fn direction_values() -> Array[Direction] {
  [Undefined, Rightward, Leftward, Downward, Upward]
}

///|
pub fn direction_to_string(value : Direction) -> String {
  match value {
    Undefined => "UNDEFINED"
    Rightward => "RIGHT"
    Leftward => "LEFT"
    Downward => "DOWN"
    Upward => "UP"
  }
}

///|
fn direction_equals(left : Direction, right : Direction) -> Bool {
  match (left, right) {
    (Undefined, Undefined) => true
    (Rightward, Rightward) => true
    (Leftward, Leftward) => true
    (Downward, Downward) => true
    (Upward, Upward) => true
    _ => false
  }
}

///|
pub fn Direction::is_horizontal(self : Direction) -> Bool {
  direction_equals(self, Leftward) || direction_equals(self, Rightward)
}

///|
pub fn Direction::is_vertical(self : Direction) -> Bool {
  direction_equals(self, Upward) || direction_equals(self, Downward)
}

///|
pub fn Direction::opposite(self : Direction) -> Direction {
  match self {
    Leftward => Rightward
    Rightward => Leftward
    Upward => Downward
    Downward => Upward
    Undefined => Undefined
  }
}
