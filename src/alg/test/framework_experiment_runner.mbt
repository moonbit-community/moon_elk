///|
let next_experiment_runner_id_ref : Ref[Int] = Ref(0)

///|
fn next_experiment_runner_id() -> Int {
  let next = next_experiment_runner_id_ref.val + 1
  next_experiment_runner_id_ref.val = next
  next
}

///|
pub fn reset_experiment_runner_ids_for_test() -> Unit {
  next_experiment_runner_id_ref.val = 0
}

///|
fn describe_method_name_for_runner(
  method_name : String,
  runner_id : Int,
) -> String {
  method_name + " (" + runner_id.to_string() + ")"
}

///|
fn[T, G] register_whitebox_processor_mappings(
  tests : Array[WhiteboxTestMethod[T, G]],
  before_mappings : Map[String, Array[WhiteboxTestMethod[T, G]]],
  after_mappings : Map[String, Array[WhiteboxTestMethod[T, G]]],
) -> Unit {
  for test_method in tests {
    for processor_id in test_method.get_before_processor_ids() {
      match before_mappings.get(processor_id) {
        Some(mapped) => mapped.push(test_method)
        None => before_mappings[processor_id] = [test_method]
      }
    }
    for processor_id in test_method.get_after_processor_ids() {
      match after_mappings.get(processor_id) {
        Some(mapped) => mapped.push(test_method)
        None => after_mappings[processor_id] = [test_method]
      }
    }
  }
}

///|
pub struct ExperimentRunner[T, G] {
  runner_id : Int
  create_test_instance_fn : () -> T
  experimental_object : ExperimentalObject[T]
  blackbox_tests : Array[BlackboxTestMethod[T]]
  whitebox_tests : Array[WhiteboxTestMethod[T, G]]
  whitebox_before_tests : Map[String, Array[WhiteboxTestMethod[T, G]]]
  whitebox_after_tests : Map[String, Array[WhiteboxTestMethod[T, G]]]
  test_descriptions : Map[String, String]
}

///|
pub fn[T, G] new_experiment_runner(
  create_test_instance_fn : () -> T,
  experimental_object : ExperimentalObject[T],
  blackbox_tests : Array[BlackboxTestMethod[T]],
  whitebox_tests : Array[WhiteboxTestMethod[T, G]],
) -> ExperimentRunner[T, G] {
  let runner_id = next_experiment_runner_id()
  let descriptions : Map[String, String] = {}
  for blackbox in blackbox_tests {
    descriptions[blackbox.get_method_name()] = describe_method_name_for_runner(
      blackbox.get_method_name(),
      runner_id,
    )
  }
  for whitebox in whitebox_tests {
    descriptions[whitebox.get_method_name()] = describe_method_name_for_runner(
      whitebox.get_method_name(),
      runner_id,
    )
  }
  let before_mappings : Map[String, Array[WhiteboxTestMethod[T, G]]] = {}
  let after_mappings : Map[String, Array[WhiteboxTestMethod[T, G]]] = {}
  register_whitebox_processor_mappings(
    whitebox_tests, before_mappings, after_mappings,
  )
  {
    runner_id,
    create_test_instance_fn,
    experimental_object,
    blackbox_tests,
    whitebox_tests,
    whitebox_before_tests: before_mappings,
    whitebox_after_tests: after_mappings,
    test_descriptions: descriptions,
  }
}

///|
pub fn[T, G] ExperimentRunner::get_name(
  self : ExperimentRunner[T, G],
) -> String {
  self.experimental_object.to_string()
}

///|
pub fn[T, G] ExperimentRunner::get_runner_id(
  self : ExperimentRunner[T, G],
) -> Int {
  self.runner_id
}

///|
pub fn[T, G] ExperimentRunner::create_test_instance(
  self : ExperimentRunner[T, G],
) -> T {
  (self.create_test_instance_fn)()
}

///|
pub fn[T, G] ExperimentRunner::get_experimental_object(
  self : ExperimentRunner[T, G],
) -> ExperimentalObject[T] {
  self.experimental_object
}

///|
pub fn[T, G] ExperimentRunner::get_blackbox_tests(
  self : ExperimentRunner[T, G],
) -> Array[BlackboxTestMethod[T]] {
  self.blackbox_tests
}

///|
pub fn[T, G] ExperimentRunner::get_whitebox_tests(
  self : ExperimentRunner[T, G],
) -> Array[WhiteboxTestMethod[T, G]] {
  self.whitebox_tests
}

///|
pub fn[T, G] ExperimentRunner::get_whitebox_before_tests(
  self : ExperimentRunner[T, G],
  processor_id : String,
) -> Array[WhiteboxTestMethod[T, G]] {
  match self.whitebox_before_tests.get(processor_id) {
    Some(tests) => tests
    None => []
  }
}

///|
pub fn[T, G] ExperimentRunner::get_whitebox_after_tests(
  self : ExperimentRunner[T, G],
  processor_id : String,
) -> Array[WhiteboxTestMethod[T, G]] {
  match self.whitebox_after_tests.get(processor_id) {
    Some(tests) => tests
    None => []
  }
}

///|
pub fn[T, G] ExperimentRunner::describe_method_name(
  self : ExperimentRunner[T, G],
  method_name : String,
) -> String {
  match self.test_descriptions.get(method_name) {
    Some(description) => description
    None => describe_method_name_for_runner(method_name, self.runner_id)
  }
}

///|
pub fn[T, G] ExperimentRunner::describe_blackbox_test(
  self : ExperimentRunner[T, G],
  test_method : BlackboxTestMethod[T],
) -> String {
  self.describe_method_name(test_method.get_method_name())
}

///|
pub fn[T, G] ExperimentRunner::describe_whitebox_test(
  self : ExperimentRunner[T, G],
  test_method : WhiteboxTestMethod[T, G],
) -> String {
  self.describe_method_name(test_method.get_method_name())
}

///|
pub fn[T, G] ExperimentRunner::is_blackbox_ignored(
  self : ExperimentRunner[T, G],
  test_method : BlackboxTestMethod[T],
) -> Bool {
  ignore(self)
  test_method.is_ignored()
}

///|
pub fn[T, G] ExperimentRunner::is_whitebox_ignored(
  self : ExperimentRunner[T, G],
  test_method : WhiteboxTestMethod[T, G],
) -> Bool {
  ignore(self)
  test_method.is_ignored()
}
