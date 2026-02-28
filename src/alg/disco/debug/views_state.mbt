///|
pub enum State {
  Lower
  Upper
  Depth
}

///|
pub fn dis_co_debug_state_values() -> Array[State] {
  [Lower, Upper, Depth]
}

///|
pub fn dis_co_debug_state_at(index : Int) -> State {
  dis_co_debug_state_values()[index]
}

///|
pub fn dis_co_debug_state_to_string(value : State) -> String {
  match value {
    Lower => "LOWER"
    Upper => "UPPER"
    Depth => "DEPTH"
  }
}
