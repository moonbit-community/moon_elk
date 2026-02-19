///|
let white_box_test_processor_id : String = "org.eclipse.elk.alg.layered.p2layers.NetworkSimplexLayerer"

///|
fn white_box_test_default_configuration() -> TestConfiguration[Ref[Int]] {
  new_test_configuration(apply_base_configuration_fn=(
    _test_instance : Ref[Int],
    _graph : ElkNode,
  ) => ())
}

///|
fn new_white_box_test_runner(
  whitebox_tests : Array[WhiteboxTestMethod[Ref[Int], Int]],
) -> LayoutTestRunner[Ref[Int], Int] {
  let graph = new_test_graph(
    (_test_instance : Ref[Int]) => create_graph(),
    "graphMethod(compoundGraph)",
  )
  new_layout_test_runner(
    () => Ref::new(0),
    [test_algorithm_identity()],
    [white_box_test_default_configuration()],
    [graph],
    [],
    whitebox_tests,
  )
}

///|
test "WhiteBoxTest executes whitebox test after matching processor event" {
  reset_graph_model_for_test()
  reset_experiment_runner_ids_for_test()

  let counter = Ref::new(0)
  let whitebox_test = new_whitebox_test_method(
    "testNoLayerlessNodes",
    (test_instance : Ref[Int], graph : Int) => {
      if graph <= 0 {
        abort("There are layerless nodes left!")
      }
      test_instance.val = test_instance.val + 1
    },
    fail_if_not_executed=true,
    after_processor_ids=[white_box_test_processor_id],
  )

  let graph = new_test_graph(
    (_test_instance : Ref[Int]) => create_graph(),
    "graphMethod(compoundGraph)",
  )
  let runner : LayoutTestRunner[Ref[Int], Int] = new_layout_test_runner(
    () => counter,
    [test_algorithm_identity()],
    [white_box_test_default_configuration()],
    [graph],
    [],
    [whitebox_test],
  )

  let notifier = new_run_notifier()
  let statement = new_experiment_statement(runner.get_children()[0], notifier)
  statement.add_layout_processor_finished_event(
    white_box_test_processor_id, 1, true,
  )
  statement.evaluate()

  assert_eq(counter.val, 1)
  assert_eq(notifier.test_failures().length(), 0)
  assert_eq(notifier.started_tests().length(), 1)
  assert_eq(notifier.finished_tests().length(), 1)
}

///|
test "WhiteBoxTest fails when fail_if_not_executed whitebox test did not run" {
  reset_graph_model_for_test()
  reset_experiment_runner_ids_for_test()

  let whitebox_test = new_whitebox_test_method(
    "testProperLayering",
    (test_instance : Ref[Int], graph : Int) => {
      ignore(test_instance)
      ignore(graph)
    },
    fail_if_not_executed=true,
    after_processor_ids=[white_box_test_processor_id],
  )

  let runner = new_white_box_test_runner([whitebox_test])
  let notifier = new_run_notifier()
  let statement = new_experiment_statement(runner.get_children()[0], notifier)
  statement.evaluate()

  let failures = notifier.test_failures()
  assert_eq(failures.length(), 1)
  assert_eq(
    failures[0].get_message(),
    "Test was not executed, but was supposed to.",
  )
}

///|
test "WhiteBoxTest only_on_root_node ignores non-root execution points" {
  reset_graph_model_for_test()
  reset_experiment_runner_ids_for_test()

  let whitebox_test = new_whitebox_test_method(
    "testOnlyOnRoot",
    (test_instance : Ref[Int], graph : Int) => {
      ignore(test_instance)
      ignore(graph)
    },
    fail_if_not_executed=true,
    only_on_root_node=true,
    after_processor_ids=[white_box_test_processor_id],
  )

  let runner = new_white_box_test_runner([whitebox_test])
  let notifier = new_run_notifier()
  let statement = new_experiment_statement(runner.get_children()[0], notifier)
  statement.add_layout_processor_finished_event(
    white_box_test_processor_id, 1, false,
  )
  statement.evaluate()

  let failures = notifier.test_failures()
  assert_eq(failures.length(), 1)
  assert_eq(
    failures[0].get_message(),
    "Test was not executed, but was supposed to.",
  )
}
