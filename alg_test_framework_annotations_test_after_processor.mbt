///|
pub struct TestAfterProcessor {
  processor_id : String
}

///|
pub fn new_test_after_processor(processor_id : String) -> TestAfterProcessor {
  { processor_id, }
}

///|
pub fn TestAfterProcessor::get_processor_id(
  self : TestAfterProcessor,
) -> String {
  self.processor_id
}
