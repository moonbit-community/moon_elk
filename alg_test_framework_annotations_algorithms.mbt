///|
pub struct Algorithms {
  value : Array[Algorithm]
}

///|
pub fn new_algorithms(value : Array[Algorithm]) -> Algorithms {
  { value: value.copy() }
}

///|
pub fn Algorithms::get_value(self : Algorithms) -> Array[Algorithm] {
  self.value.copy()
}
