///|
fn[T] layout_test_runner_default_configuration() -> TestConfiguration[T] {
  new_test_configuration(apply_base_configuration_fn=(
    _test_instance : T,
    _graph : ElkNode,
  ) => ())
}

///|
pub struct LayoutTestRunner[T, G] {
  create_test_instance_fn : () -> T
  test_algorithms : Array[TestAlgorithm]
  test_configurations : Array[TestConfiguration[T]]
  test_graphs : Array[TestGraph[T]]
  blackbox_tests : Array[BlackboxTestMethod[T]]
  whitebox_tests : Array[WhiteboxTestMethod[T, G]]
  child_runners : Array[ExperimentRunner[T, G]]
}

///|
pub fn[T, G] new_layout_test_runner(
  create_test_instance_fn : () -> T,
  test_algorithms : Array[TestAlgorithm],
  test_configurations : Array[TestConfiguration[T]],
  test_graphs : Array[TestGraph[T]],
  blackbox_tests : Array[BlackboxTestMethod[T]],
  whitebox_tests : Array[WhiteboxTestMethod[T, G]],
) -> LayoutTestRunner[T, G] {
  if test_graphs.is_empty() {
    abort("No test graphs specified.")
  }
  let algorithms = if test_algorithms.is_empty() {
    [test_algorithm_identity()]
  } else {
    test_algorithms
  }
  let configurations = if test_configurations.is_empty() {
    [layout_test_runner_default_configuration()]
  } else {
    test_configurations
  }
  let experimental_objects = experimental_object_inflate(
    algorithms, configurations, test_graphs,
  )
  let children : Array[ExperimentRunner[T, G]] = []
  for experimental_object in experimental_objects {
    children.push(
      new_experiment_runner(
        create_test_instance_fn, experimental_object, blackbox_tests, whitebox_tests,
      ),
    )
  }
  {
    create_test_instance_fn,
    test_algorithms: algorithms,
    test_configurations: configurations,
    test_graphs,
    blackbox_tests,
    whitebox_tests,
    child_runners: children,
  }
}

///|
pub fn[T, G] LayoutTestRunner::get_blackbox_tests(
  self : LayoutTestRunner[T, G],
) -> Array[BlackboxTestMethod[T]] {
  self.blackbox_tests
}

///|
pub fn[T, G] LayoutTestRunner::get_whitebox_tests(
  self : LayoutTestRunner[T, G],
) -> Array[WhiteboxTestMethod[T, G]] {
  self.whitebox_tests
}

///|
pub fn[T, G] LayoutTestRunner::get_test_algorithms(
  self : LayoutTestRunner[T, G],
) -> Array[TestAlgorithm] {
  self.test_algorithms
}

///|
pub fn[T, G] LayoutTestRunner::get_test_configurations(
  self : LayoutTestRunner[T, G],
) -> Array[TestConfiguration[T]] {
  self.test_configurations
}

///|
pub fn[T, G] LayoutTestRunner::get_test_graphs(
  self : LayoutTestRunner[T, G],
) -> Array[TestGraph[T]] {
  self.test_graphs
}

///|
pub fn[T, G] LayoutTestRunner::get_children(
  self : LayoutTestRunner[T, G],
) -> Array[ExperimentRunner[T, G]] {
  self.child_runners
}

///|
pub fn[T, G] LayoutTestRunner::run_child(
  self : LayoutTestRunner[T, G],
  child : ExperimentRunner[T, G],
  notifier : RunNotifier,
) -> Unit {
  ignore(self)
  let statement = new_experiment_statement(child, notifier)
  statement.evaluate()
}

///|
pub fn[T, G] LayoutTestRunner::run(
  self : LayoutTestRunner[T, G],
  notifier : RunNotifier,
) -> Unit {
  for child in self.child_runners {
    self.run_child(child, notifier)
  }
}
