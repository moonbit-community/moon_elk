///|
fn configurator_test_property() -> IProperty[Double] {
  new_property("org.eclipse.elk.alg.common.test", 0.0)
}

///|
test "ConfiguratorTest applies configurator method" {
  reset_graph_model_for_test()

  let test_property = configurator_test_property()
  let test_property_value = 42.0

  let graph = new_test_graph(
    (_test_instance : Unit) => create_graph(),
    "graphMethod(basicGraph)",
  )

  let configuration = new_method_test_configuration("configureStuff", (
    _test_instance : Unit,
    graph : ElkNode,
  ) => node_set_double_property(graph, test_property, test_property_value)).as_test_configuration()

  let blackbox_test = new_blackbox_test_method("testConfigurator", (
    _test_instance : Unit,
    graph : ElkNode,
  ) => {
    let actual_value = node_get_double_property(graph, test_property)
    if actual_value != test_property_value {
      abort("Property is not set properly.")
    }
  })

  let runner : LayoutTestRunner[Unit, Int] = new_layout_test_runner(
    () => (),
    [test_algorithm_identity()],
    [configuration],
    [graph],
    [blackbox_test],
    [],
  )
  let notifier = new_run_notifier()
  runner.run(notifier)

  assert_eq(notifier.test_failures().length(), 0)
  assert_eq(notifier.started_tests().length(), 1)
  assert_eq(notifier.finished_tests().length(), 1)
}
