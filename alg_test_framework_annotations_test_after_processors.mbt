///|
pub struct TestAfterProcessors {
  value : Array[TestAfterProcessor]
}

///|
pub fn new_test_after_processors(
  value : Array[TestAfterProcessor],
) -> TestAfterProcessors {
  { value: value.copy() }
}

///|
pub fn TestAfterProcessors::get_value(
  self : TestAfterProcessors,
) -> Array[TestAfterProcessor] {
  self.value.copy()
}
