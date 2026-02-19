///|
pub struct TestBeforeProcessors {
  value : Array[TestBeforeProcessor]
}

///|
pub fn new_test_before_processors(
  value : Array[TestBeforeProcessor],
) -> TestBeforeProcessors {
  { value: value.copy() }
}

///|
pub fn TestBeforeProcessors::get_value(
  self : TestBeforeProcessors,
) -> Array[TestBeforeProcessor] {
  self.value.copy()
}
