///|
pub let compare_fuzzy_tolerance = 0.0001

///|
pub fn compare_fuzzy_eq(d1 : Double, d2 : Double) -> Bool {
  (d1 - d2).abs() <= compare_fuzzy_tolerance
}

///|
pub fn compare_fuzzy_gt(d1 : Double, d2 : Double) -> Bool {
  d1 - d2 > compare_fuzzy_tolerance
}

///|
pub fn compare_fuzzy_lt(d1 : Double, d2 : Double) -> Bool {
  d2 - d1 > compare_fuzzy_tolerance
}

///|
pub fn compare_fuzzy_ge(d1 : Double, d2 : Double) -> Bool {
  d1 > d2 || compare_fuzzy_eq(d1, d2)
}

///|
pub fn compare_fuzzy_le(d1 : Double, d2 : Double) -> Bool {
  d1 < d2 || compare_fuzzy_eq(d1, d2)
}
