///|
struct WhiteboxLayoutEvent[G] {
  processor_id : String
  graph : G
  is_root : Bool
  run_before : Bool
}

///|
fn[G] new_whitebox_layout_event(
  processor_id : String,
  graph : G,
  is_root : Bool,
  run_before : Bool,
) -> WhiteboxLayoutEvent[G] {
  { processor_id, graph, is_root, run_before }
}

///|
pub struct ExperimentStatement[T, G] {
  experiment_runner : ExperimentRunner[T, G]
  notifier : RunNotifier
  whitebox_recorder : WhiteboxRecorder
  mut whitebox_events : Array[WhiteboxLayoutEvent[G]]
  mut test_graph : ElkNode?
}

///|
pub fn[T, G] new_experiment_statement(
  experiment_runner : ExperimentRunner[T, G],
  notifier : RunNotifier,
) -> ExperimentStatement[T, G] {
  {
    experiment_runner,
    notifier,
    whitebox_recorder: new_whitebox_recorder(),
    whitebox_events: [],
    test_graph: None,
  }
}

///|
pub fn[T, G] ExperimentStatement::add_layout_processor_ready_event(
  self : ExperimentStatement[T, G],
  processor_id : String,
  graph : G,
  is_root : Bool,
) -> Unit {
  self.whitebox_events.push(
    new_whitebox_layout_event(processor_id, graph, is_root, true),
  )
}

///|
pub fn[T, G] ExperimentStatement::add_layout_processor_finished_event(
  self : ExperimentStatement[T, G],
  processor_id : String,
  graph : G,
  is_root : Bool,
) -> Unit {
  self.whitebox_events.push(
    new_whitebox_layout_event(processor_id, graph, is_root, false),
  )
}

///|
fn[T, G] experiment_statement_create_test_graph(
  statement : ExperimentStatement[T, G],
) -> ElkNode {
  let test_instance = statement.experiment_runner.create_test_instance()
  statement.experiment_runner.get_experimental_object().realize(test_instance)
}

///|
fn[T, G] experiment_statement_run_blackbox_test(
  statement : ExperimentStatement[T, G],
  test_method : BlackboxTestMethod[T],
  graph : ElkNode,
) -> Unit {
  let description = statement.experiment_runner.describe_blackbox_test(
    test_method,
  )
  if statement.experiment_runner.is_blackbox_ignored(test_method) {
    statement.notifier.fire_test_ignored(description)
    return
  }
  statement.notifier.fire_test_started(description)
  let test_instance = statement.experiment_runner.create_test_instance()
  test_method.invoke(test_instance, graph)
  statement.notifier.fire_test_finished(description)
}

///|
fn[T, G] experiment_statement_run_whitebox_test_with_recorder(
  statement : ExperimentStatement[T, G],
  test_method : WhiteboxTestMethod[T, G],
  graph : G,
) -> Unit {
  let description = statement.experiment_runner.describe_whitebox_test(
    test_method,
  )
  if statement.experiment_runner.is_whitebox_ignored(test_method) {
    statement.whitebox_recorder.fire_test_ignored(description)
    return
  }
  statement.whitebox_recorder.fire_test_started(description)
  let test_instance = statement.experiment_runner.create_test_instance()
  test_method.invoke(test_instance, graph)
  statement.whitebox_recorder.fire_test_finished(description)
}

///|
fn[T, G] experiment_statement_run_whitebox_tests(
  statement : ExperimentStatement[T, G],
  tests : Array[WhiteboxTestMethod[T, G]],
  graph : G,
  is_root : Bool,
) -> Unit {
  for test_method in tests {
    if is_root || !test_method.get_only_on_root_node() {
      experiment_statement_run_whitebox_test_with_recorder(
        statement, test_method, graph,
      )
    }
  }
}

///|
fn[T, G] experiment_statement_run_scheduled_whitebox_events(
  statement : ExperimentStatement[T, G],
) -> Unit {
  for event in statement.whitebox_events {
    if event.run_before {
      experiment_statement_run_whitebox_tests(
        statement,
        statement.experiment_runner.get_whitebox_before_tests(
          event.processor_id,
        ),
        event.graph,
        event.is_root,
      )
    } else {
      experiment_statement_run_whitebox_tests(
        statement,
        statement.experiment_runner.get_whitebox_after_tests(event.processor_id),
        event.graph,
        event.is_root,
      )
    }
  }
}

///|
fn[T, G] experiment_statement_run_blackbox_tests(
  statement : ExperimentStatement[T, G],
  graph : ElkNode,
) -> Unit {
  for blackbox_test in statement.experiment_runner.get_blackbox_tests() {
    experiment_statement_run_blackbox_test(statement, blackbox_test, graph)
  }
}

///|
fn[T, G] experiment_statement_simulate_whitebox_tests_for_notifier(
  statement : ExperimentStatement[T, G],
) -> Unit {
  for whitebox_test in statement.experiment_runner.get_whitebox_tests() {
    let description = statement.experiment_runner.describe_whitebox_test(
      whitebox_test,
    )
    if statement.experiment_runner.is_whitebox_ignored(whitebox_test) {
      statement.notifier.fire_test_ignored(description)
      continue
    }
    statement.notifier.fire_test_started(description)
    if statement.whitebox_recorder.was_executed(description) {
      for failure in statement.whitebox_recorder.get_failures(description) {
        statement.notifier.fire_test_failure(failure)
      }
    } else if whitebox_test.get_fail_if_not_executed() {
      statement.notifier.fire_test_failure(
        new_run_failure(
          description, "Test was not executed, but was supposed to.",
        ),
      )
    }
    statement.notifier.fire_test_finished(description)
  }
}

///|
pub fn[T, G] ExperimentStatement::evaluate(
  self : ExperimentStatement[T, G],
) -> Unit {
  let graph = experiment_statement_create_test_graph(self)
  self.test_graph = Some(graph)

  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_basic_progress_monitor())

  experiment_statement_run_scheduled_whitebox_events(self)
  experiment_statement_run_blackbox_tests(self, graph)
  experiment_statement_simulate_whitebox_tests_for_notifier(self)

  self.whitebox_events = []
  self.test_graph = None
}

///|
pub fn[T, G] ExperimentStatement::get_notifier(
  self : ExperimentStatement[T, G],
) -> RunNotifier {
  self.notifier
}

///|
pub fn[T, G] ExperimentStatement::get_whitebox_recorder(
  self : ExperimentStatement[T, G],
) -> WhiteboxRecorder {
  self.whitebox_recorder
}
