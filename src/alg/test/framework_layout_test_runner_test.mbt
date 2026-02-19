///|
fn layout_runner_test_default_configuration() -> TestConfiguration[Unit] {
  new_test_configuration(apply_base_configuration_fn=(
    _test_instance : Unit,
    _graph : ElkNode,
  ) => ())
}

///|
test "LayoutTestRunner inflates all algorithm configuration graph combinations" {
  reset_graph_model_for_test()
  reset_experiment_runner_ids_for_test()

  let algorithms = [
    test_algorithm_identity(),
    new_test_algorithm(Some(new_layout_algorithm_data("org.eclipse.elk.force"))),
  ]
  let configurations = [
    layout_runner_test_default_configuration(),
    new_test_configuration(apply_base_configuration_fn=(_test_instance, graph) => {
      node_set_string_property(graph, algorithm, "org.eclipse.elk.box")
    }),
  ]
  let graphs = [
    new_test_graph(
      (_test_instance : Unit) => create_graph(),
      "graphMethod(firstGraph)",
    ),
    new_test_graph(
      (_test_instance : Unit) => create_graph(),
      "graphMethod(secondGraph)",
    ),
  ]

  let runner : LayoutTestRunner[Unit, Unit] = new_layout_test_runner(
    () => (),
    algorithms,
    configurations,
    graphs,
    [],
    [],
  )

  assert_eq(runner.get_children().length(), 8)
}

///|
test "ExperimentRunner appends runner id to test descriptions" {
  reset_graph_model_for_test()
  reset_experiment_runner_ids_for_test()

  let graph = new_test_graph(
    (_test_instance : Unit) => create_graph(),
    "graphMethod(graph)",
  )
  let blackbox = new_blackbox_test_method("sampleTest", (
    _test_instance : Unit,
    _graph : ElkNode,
  ) => ())
  let runner : LayoutTestRunner[Unit, Unit] = new_layout_test_runner(
    () => (),
    [test_algorithm_identity()],
    [layout_runner_test_default_configuration()],
    [graph],
    [blackbox],
    [],
  )
  let experiment = runner.get_children()[0]
  inspect(
    experiment.describe_method_name("sampleTest"),
    content="sampleTest (1)",
  )
}
