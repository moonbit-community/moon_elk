///|
fn test_algorithm_test_prepare_registry() -> Unit {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_algorithm(
    new_layout_algorithm_data("org.eclipse.elk.b"),
  )
  layout_meta_data_service_register_algorithm(
    new_layout_algorithm_data("org.eclipse.elk.a"),
  )
}

///|
test "TestAlgorithm resolves and sorts annotations" {
  test_algorithm_test_prepare_registry()
  let errors : Array[String] = []
  let algorithms = test_algorithm_from_annotations(
    [new_algorithm("org.eclipse.elk.b"), new_algorithm("org.eclipse.elk.a")],
    false,
    errors,
  )
  assert_eq(errors.length(), 0)
  assert_eq(algorithms.length(), 2)
  inspect(algorithms[0].to_string(), content="algorithm(org.eclipse.elk.a)")
  inspect(algorithms[1].to_string(), content="algorithm(org.eclipse.elk.b)")
}

///|
test "TestAlgorithm applies configured algorithm id to graph tree" {
  test_algorithm_test_prepare_registry()
  reset_graph_model_for_test()
  let graph = create_graph()
  let child = create_node(Some(graph))
  let alg_data = layout_meta_data_service_get_algorithm_data(
    "org.eclipse.elk.a",
  )
  let test_algorithm = match alg_data {
    Some(value) => new_test_algorithm(Some(value))
    None => abort("missing algorithm data")
  }
  test_algorithm.apply(graph)
  inspect(
    node_get_string_property(graph, algorithm),
    content="org.eclipse.elk.a",
  )
  inspect(
    node_get_string_property(child, algorithm),
    content="org.eclipse.elk.a",
  )
}
