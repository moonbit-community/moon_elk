///|
pub struct TestBeforeProcessor {
  processor_id : String
}

///|
pub fn new_test_before_processor(processor_id : String) -> TestBeforeProcessor {
  { processor_id, }
}

///|
pub fn TestBeforeProcessor::get_processor_id(
  self : TestBeforeProcessor,
) -> String {
  self.processor_id
}
