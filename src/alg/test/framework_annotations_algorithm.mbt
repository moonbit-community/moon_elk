///|
pub struct Algorithm {
  value : String
}

///|
pub fn new_algorithm(value : String) -> Algorithm {
  { value, }
}

///|
pub fn Algorithm::get_value(self : Algorithm) -> String {
  self.value
}
