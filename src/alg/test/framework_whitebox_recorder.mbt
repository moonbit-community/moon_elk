///|
fn whitebox_recorder_contains_description(
  descriptions : Array[String],
  description : String,
) -> Bool {
  for existing in descriptions {
    if existing == description {
      return true
    }
  }
  false
}

///|
fn whitebox_recorder_put_failure(
  failures : Map[String, Array[RunFailure]],
  description : String,
  failure : RunFailure,
) -> Unit {
  match failures.get(description) {
    Some(existing) => existing.push(failure)
    None => failures[description] = [failure]
  }
}

///|
pub struct WhiteboxRecorder {
  executed_whitebox_tests : Array[String]
  whitebox_test_failures : Map[String, Array[RunFailure]]
  mut currently_running_test : String?
}

///|
pub fn new_whitebox_recorder() -> WhiteboxRecorder {
  {
    executed_whitebox_tests: [],
    whitebox_test_failures: {},
    currently_running_test: None,
  }
}

///|
pub fn WhiteboxRecorder::was_executed(
  self : WhiteboxRecorder,
  description : String,
) -> Bool {
  whitebox_recorder_contains_description(
    self.executed_whitebox_tests,
    description,
  )
}

///|
pub fn WhiteboxRecorder::get_failures(
  self : WhiteboxRecorder,
  description : String,
) -> Array[RunFailure] {
  match self.whitebox_test_failures.get(description) {
    Some(failures) => failures
    None => []
  }
}

///|
pub fn WhiteboxRecorder::fire_test_run_started(
  self : WhiteboxRecorder,
  _description : String,
) -> Unit {
  ignore(self)
}

///|
pub fn WhiteboxRecorder::fire_test_run_finished(
  self : WhiteboxRecorder,
) -> Unit {
  ignore(self)
}

///|
pub fn WhiteboxRecorder::fire_test_started(
  self : WhiteboxRecorder,
  description : String,
) -> Unit {
  self.currently_running_test = Some(description)
  if !whitebox_recorder_contains_description(
      self.executed_whitebox_tests,
      description,
    ) {
    self.executed_whitebox_tests.push(description)
  }
}

///|
pub fn WhiteboxRecorder::fire_test_failure(
  self : WhiteboxRecorder,
  failure : RunFailure,
) -> Unit {
  match self.currently_running_test {
    Some(description) =>
      whitebox_recorder_put_failure(
        self.whitebox_test_failures,
        description,
        failure,
      )
    None => ()
  }
}

///|
pub fn WhiteboxRecorder::fire_test_assumption_failed(
  self : WhiteboxRecorder,
  failure : RunFailure,
) -> Unit {
  self.fire_test_failure(failure)
}

///|
pub fn WhiteboxRecorder::fire_test_ignored(
  self : WhiteboxRecorder,
  _description : String,
) -> Unit {
  ignore(self)
}

///|
pub fn WhiteboxRecorder::fire_test_finished(
  self : WhiteboxRecorder,
  _description : String,
) -> Unit {
  self.currently_running_test = None
}
