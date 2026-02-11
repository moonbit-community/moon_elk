///|
test "ExperimentalObject realize combines graph algorithm and configuration" {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_algorithm(
    new_layout_algorithm_data("org.eclipse.elk.demo"),
  )
  reset_graph_model_for_test()
  let algorithm_data = match
    layout_meta_data_service_get_algorithm_data("org.eclipse.elk.demo") {
    Some(value) => value
    None => abort("missing algorithm data")
  }
  let graph_source = new_test_graph(
    (_test_instance : Unit) => create_graph(),
    "graphMethod(source)",
  )
  let configuration : TestConfiguration[Unit] = new_test_configuration(apply_base_configuration_fn=(
    _test_instance,
    graph,
  ) => node_set_bool_property(graph, no_layout, true))
  let object = new_experimental_object(
    new_test_algorithm(Some(algorithm_data)),
    configuration,
    graph_source,
  )
  let realized = object.realize(())
  inspect(
    node_get_string_property(realized, algorithm),
    content="org.eclipse.elk.demo",
  )
  inspect(node_get_bool_property(realized, no_layout), content="true")
}

///|
test "ExperimentalObject inflate creates cartesian product" {
  layout_meta_data_service_reset_for_test()
  let graph_a = new_test_graph((_test_instance : Unit) => create_graph(), "a")
  let graph_b = new_test_graph((_test_instance : Unit) => create_graph(), "b")
  let config : TestConfiguration[Unit] = new_test_configuration()
  let objects = experimental_object_inflate(
    [test_algorithm_identity(), test_algorithm_identity()],
    [config],
    [graph_a, graph_b],
  )
  inspect(objects.length(), content="4")
}
