///|
fn register_foo_algorithm_for_graph_validator_test() -> Unit {
  let algorithm_data = new_layout_algorithm_data(
    "foo.algorithm",
    validator=Some(node => {
      if @graph.node_identifier(node) == "foo" {
        [new_graph_issue_node(node, "FOO!", issue_error)]
      } else {
        []
      }
    }),
  )
  layout_meta_data_service_register_algorithm(algorithm_data)
}

///|
test "GraphValidator unconnected edge" {
  @graph.reset_graph_model_for_test()
  layout_meta_data_service_reset_for_test()
  let graph = @graph.create_graph()
  ignore(@graph.create_edge(Some(graph)))
  let validator = new_graph_validator()
  apply_visitors(graph, [validator.to_visitor()])
  assert_eq(
    graph_issue_list_to_string(validator.get_issues()),
    "[ERROR: Edge is not connected. (Root Node > Edge)]",
  )
}

///|
test "GraphValidator custom validation" {
  @graph.reset_graph_model_for_test()
  layout_meta_data_service_reset_for_test()
  register_foo_algorithm_for_graph_validator_test()
  let graph = @graph.create_graph()
  let child = @graph.create_node(Some(graph))
  @graph.node_set_identifier(child, "foo")
  @graph.node_set_string_property(graph, algorithm, "foo.algorithm")
  let resolver = new_layout_algorithm_resolver()
  let validator = new_graph_validator()
  apply_visitors(graph, [resolver.to_visitor(), validator.to_visitor()])
  assert_eq(
    graph_issue_list_to_string(validator.get_issues()),
    "[ERROR: FOO! (Root Node > Node foo)]",
  )
}
