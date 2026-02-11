///|
pub struct FailIfNotExecuted {
  marker : Int
}

///|
pub fn new_fail_if_not_executed() -> FailIfNotExecuted {
  { marker: 0 }
}
