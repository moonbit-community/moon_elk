///|
pub enum DCDirection {
  DCNorth
  DCEast
  DCSouth
  DCWest
}

///|
pub fn DCDirection::is_horizontal(self : DCDirection) -> Bool {
  match self {
    DCNorth => false
    DCEast => true
    DCSouth => false
    DCWest => true
  }
}

///|
pub fn dc_direction_values() -> Array[DCDirection] {
  [DCNorth, DCEast, DCSouth, DCWest]
}
