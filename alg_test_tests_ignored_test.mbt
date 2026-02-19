///|
fn ignored_test_graph_provider_name(index : Int) -> String {
  if index == 0 {
    "graphMethod(firstGraph)"
  } else {
    "graphMethod(secondGraph)"
  }
}

///|
fn ignored_test_default_configuration() -> TestConfiguration[Unit] {
  new_test_configuration(apply_base_configuration_fn=(
    _test_instance : Unit,
    _graph : ElkNode,
  ) => ())
}

///|
test "IgnoredTest marks ignored blackbox tests for each experiment" {
  reset_graph_model_for_test()

  let test_graphs : Array[TestGraph[Unit]] = []
  let mut index = 0
  while index < 2 {
    let provider_index = index
    test_graphs.push(
      new_test_graph(
        (_test_instance : Unit) => {
          ignore(provider_index)
          create_graph()
        },
        ignored_test_graph_provider_name(index),
      ),
    )
    index = index + 1
  }

  let success = new_blackbox_test_method("success", (
    _test_instance : Unit,
    _graph : ElkNode,
  ) => ())
  let fail_but_ignored = new_blackbox_test_method(
    "fail",
    (_test_instance : Unit, _graph : ElkNode) => abort("must stay ignored"),
    ignored=true,
  )

  let runner : LayoutTestRunner[Unit, Int] = new_layout_test_runner(
    () => (),
    [test_algorithm_identity()],
    [ignored_test_default_configuration()],
    test_graphs,
    [success, fail_but_ignored],
    [],
  )
  let notifier = new_run_notifier()
  runner.run(notifier)

  assert_eq(notifier.test_failures().length(), 0)
  assert_eq(notifier.started_tests().length(), 2)
  assert_eq(notifier.finished_tests().length(), 2)
  assert_eq(notifier.ignored_tests().length(), 2)
}
