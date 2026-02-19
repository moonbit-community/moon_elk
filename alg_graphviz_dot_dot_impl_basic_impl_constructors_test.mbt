///|
test "dot impl constructors map to dot model creators" {
  let model = new_dot_graphviz_model_impl()
  inspect(model.get_graphs().length(), content="0")

  let graph = new_dot_graph_impl()
  inspect(graph.is_strict(), content="false")

  let statement = new_dot_statement_impl()
  inspect(statement is DotStatementBase, content="true")

  let attribute = new_dot_attribute_impl()
  inspect(attribute.get_name() is None, content="true")

  let node_statement = new_dot_node_statement_impl()
  inspect(node_statement.get_attributes().length(), content="0")

  let node = new_dot_node_impl()
  inspect(node.get_name() is None, content="true")

  let edge_statement = new_dot_edge_statement_impl()
  inspect(edge_statement.get_edge_targets().length(), content="0")

  let edge_target = new_dot_edge_target_impl()
  inspect(
    dot_edge_operator_name(edge_target.get_operator()),
    content="directed",
  )

  let attribute_statement = new_dot_attribute_statement_impl()
  inspect(
    dot_attribute_type_literal(attribute_statement.get_type()),
    content="graph",
  )

  let subgraph = new_dot_subgraph_impl()
  inspect(subgraph.get_statements().length(), content="0")

  let port = new_dot_port_impl()
  inspect(port.get_name() is None, content="true")

  inspect(
    new_dot_factory_impl().create_graphviz_model().get_graphs().length(),
    content="0",
  )
  inspect(dot_factory_impl_init().create_graph().is_strict(), content="false")
  inspect(new_dot_package_impl() == dot_package_instance, content="true")
  inspect(dot_package_impl_init() == dot_package_instance, content="true")
}
