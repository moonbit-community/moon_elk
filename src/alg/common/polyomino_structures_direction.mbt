///|
pub enum PolyominoDirection {
  North
  East
  South
  West
}

///|
pub fn PolyominoDirection::is_horizontal(self : PolyominoDirection) -> Bool {
  match self {
    North => false
    East => true
    South => false
    West => true
  }
}

///|
pub fn polyomino_direction_values() -> Array[PolyominoDirection] {
  [North, East, South, West]
}
