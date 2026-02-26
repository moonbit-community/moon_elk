///|
pub struct JavaTTriangleSet {
  values : @set.Set[TTriangle]
}

///|
pub fn new_java_ttriangle_set() -> JavaTTriangleSet {
  { values: @set.Set::new() }
}

///|
pub fn JavaTTriangleSet::add(
  self : JavaTTriangleSet,
  triangle : TTriangle,
) -> Bool {
  if self.values.contains(triangle) {
    false
  } else {
    self.values.add(triangle)
    true
  }
}

///|
pub fn JavaTTriangleSet::remove(
  self : JavaTTriangleSet,
  triangle : TTriangle,
) -> Bool {
  if self.values.contains(triangle) {
    self.values.remove(triangle)
    true
  } else {
    false
  }
}

///|
pub fn JavaTTriangleSet::to_array(self : JavaTTriangleSet) -> Array[TTriangle] {
  self.values.to_array()
}
