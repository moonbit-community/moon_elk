///|
/// Uses package-private DOT enum variants to exercise the full writer.
test "GraphvizDotModel serializes deterministic DOT" {
  let model = dot_create_graphviz_model()
  let graph = dot_create_graph()
  graph.set_type(Some(DotGraphTypeDigraph))
  graph.set_name(Some("g"))
  graph.set_strict(true)

  let graph_attributes = dot_create_attribute_statement()
  let rankdir = dot_create_attribute()
  rankdir.set_name(Some("rankdir"))
  rankdir.set_value(Some("LR"))
  graph_attributes.get_attributes().push(rankdir)
  graph
  .get_statements()
  .push(dot_statement_attribute_statement(graph_attributes))

  let node_statement = dot_create_node_statement()
  let node = dot_create_node()
  node.set_name(Some("n1"))
  node_statement.set_node(Some(node))
  let node_label = dot_create_attribute()
  node_label.set_name(Some("label"))
  node_label.set_value(Some("A \"quoted\""))
  node_statement.get_attributes().push(node_label)
  graph.get_statements().push(dot_statement_node_statement(node_statement))

  let edge_statement = dot_create_edge_statement()
  let source = dot_create_node()
  source.set_name(Some("n1"))
  edge_statement.set_source_node(Some(source))
  let target = dot_create_edge_target()
  let target_node = dot_create_node()
  target_node.set_name(Some("n2"))
  target.set_targetnode(Some(target_node))
  edge_statement.get_edge_targets().push(target)
  graph.get_statements().push(dot_statement_edge_statement(edge_statement))

  model.get_graphs().push(graph)
  let serialized = graphviz_dot_serialize_model(model)
  inspect(
    serialized,
    content=(
      #|strict digraph "g" {
      #|  graph ["rankdir" = "LR"];
      #|  "n1" ["label" = "A \"quoted\""];
      #|  "n1" -> "n2";
      #|}
      #|
    ),
  )
  let parsed = graphviz_dot_parse_model_bytes(
    graphviz_dot_serialize_model_bytes(model),
  )
  inspect(parsed.get_graphs().length(), content="1")
}
