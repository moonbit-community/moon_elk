///|
fn configurator_provider_test_property() -> IProperty[Double] {
  new_property("org.eclipse.elk.alg.common.test", 0.0)
}

///|
test "ConfiguratorProviderTest applies layout configurator provider" {
  reset_graph_model_for_test()

  let test_property = configurator_provider_test_property()
  let test_property_value = 42.0

  let graph = new_test_graph(
    (_test_instance : Unit) => create_graph(),
    "graphMethod(basicGraph)",
  )

  let configuration = new_configurator_test_configuration(
    "configuratorProvider",
    (_test_instance : Unit) => {
      let layout_config = new_layout_configurator()
      layout_config.configure_class_property(
        class_node_element, test_property, test_property_value,
      )
      layout_config
    },
  ).as_test_configuration()

  let blackbox_test = new_blackbox_test_method("testConfiguratorProvider", (
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
