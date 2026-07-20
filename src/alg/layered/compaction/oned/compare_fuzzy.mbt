///|
pub let layered_compare_fuzzy_tolerance = 0.0001

///|
pub fn layered_compare_fuzzy_eq(d1 : Double, d2 : Double) -> Bool {
  (d1 - d2).abs() <= layered_compare_fuzzy_tolerance
}

///|
pub fn layered_compare_fuzzy_gt(d1 : Double, d2 : Double) -> Bool {
  d1 - d2 > layered_compare_fuzzy_tolerance
}

///|
pub fn layered_compare_fuzzy_lt(d1 : Double, d2 : Double) -> Bool {
  d2 - d1 > layered_compare_fuzzy_tolerance
}

///|
pub fn layered_compare_fuzzy_ge(d1 : Double, d2 : Double) -> Bool {
  d1 > d2 || layered_compare_fuzzy_eq(d1, d2)
}

///|
pub fn layered_compare_fuzzy_le(d1 : Double, d2 : Double) -> Bool {
  d1 < d2 || layered_compare_fuzzy_eq(d1, d2)
}
