///|
pub struct RunFailure {
  description : String
  message : String
}

///|
pub fn new_run_failure(description : String, message : String) -> RunFailure {
  { description, message }
}

///|
pub fn RunFailure::get_description(self : RunFailure) -> String {
  self.description
}

///|
pub fn RunFailure::get_message(self : RunFailure) -> String {
  self.message
}

///|
pub struct RunNotifier {
  started : Array[String]
  finished : Array[String]
  ignored : Array[String]
  failures : Array[RunFailure]
}

///|
pub fn new_run_notifier() -> RunNotifier {
  { started: [], finished: [], ignored: [], failures: [] }
}

///|
pub fn RunNotifier::fire_test_run_started(
  self : RunNotifier,
  _description : String,
) -> Unit {
  ignore(self)
}

///|
pub fn RunNotifier::fire_test_run_finished(self : RunNotifier) -> Unit {
  ignore(self)
}

///|
pub fn RunNotifier::fire_test_started(
  self : RunNotifier,
  description : String,
) -> Unit {
  self.started.push(description)
}

///|
pub fn RunNotifier::fire_test_failure(
  self : RunNotifier,
  failure : RunFailure,
) -> Unit {
  self.failures.push(failure)
}

///|
pub fn RunNotifier::fire_test_assumption_failed(
  self : RunNotifier,
  failure : RunFailure,
) -> Unit {
  self.failures.push(failure)
}

///|
pub fn RunNotifier::fire_test_ignored(
  self : RunNotifier,
  description : String,
) -> Unit {
  self.ignored.push(description)
}

///|
pub fn RunNotifier::fire_test_finished(
  self : RunNotifier,
  description : String,
) -> Unit {
  self.finished.push(description)
}

///|
pub fn RunNotifier::started_tests(self : RunNotifier) -> Array[String] {
  self.started
}

///|
pub fn RunNotifier::finished_tests(self : RunNotifier) -> Array[String] {
  self.finished
}

///|
pub fn RunNotifier::ignored_tests(self : RunNotifier) -> Array[String] {
  self.ignored
}

///|
pub fn RunNotifier::test_failures(self : RunNotifier) -> Array[RunFailure] {
  self.failures
}
