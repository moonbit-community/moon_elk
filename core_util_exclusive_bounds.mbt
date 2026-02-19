///|
pub struct ExclusiveLowerBound {
  exclusive_lower_bound : Double
}

///|
pub struct ExclusiveUpperBound {
  exclusive_upper_bound : Double
}

///|
pub fn greater_than(exclusive_lower_bound : Double) -> ExclusiveLowerBound {
  { exclusive_lower_bound, }
}

///|
pub fn less_than(exclusive_upper_bound : Double) -> ExclusiveUpperBound {
  { exclusive_upper_bound, }
}

///|
pub fn ExclusiveLowerBound::compare_to(
  self : ExclusiveLowerBound,
  x : Double,
) -> Int {
  if self.exclusive_lower_bound < x {
    -1
  } else {
    1
  }
}

///|
pub fn ExclusiveUpperBound::compare_to(
  self : ExclusiveUpperBound,
  x : Double,
) -> Int {
  if self.exclusive_upper_bound > x {
    1
  } else {
    -1
  }
}

///|
pub fn ExclusiveLowerBound::value(self : ExclusiveLowerBound) -> Double {
  self.exclusive_lower_bound
}

///|
pub fn ExclusiveUpperBound::value(self : ExclusiveUpperBound) -> Double {
  self.exclusive_upper_bound
}

///|
pub fn ExclusiveLowerBound::to_string(self : ExclusiveLowerBound) -> String {
  "\{self.exclusive_lower_bound} (exclusive)"
}

///|
pub fn ExclusiveUpperBound::to_string(self : ExclusiveUpperBound) -> String {
  "\{self.exclusive_upper_bound} (exclusive)"
}
