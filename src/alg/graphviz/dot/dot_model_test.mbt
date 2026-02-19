///|
fn option_string_to_string(value : String?) -> String {
  match value {
    Some(v) => v
    None => "none"
  }
}

///|
test "Dot enum helpers" {
  inspect(dot_graph_type_to_string(dot_graph_type_graph()), content="graph")
  inspect(dot_graph_type_to_string(dot_graph_type_digraph()), content="digraph")
  inspect(dot_graph_type_from_int(1) is Some(_), content="true")
  inspect(
    option_string_to_string(
      match dot_edge_operator_from_string("--") {
        Some(op) => Some(dot_edge_operator_name(op))
        None => None
      },
    ),
    content="undirected",
  )
  inspect(
    option_string_to_string(
      match dot_attribute_type_from_name("edge") {
        Some(attr_type) => Some(dot_attribute_type_literal(attr_type))
        None => None
      },
    ),
    content="edge",
  )
}

///|
test "Dot model defaults and mutation" {
  let model = dot_create_graphviz_model()
  inspect(model.get_graphs().length(), content="0")

  let graph = dot_create_graph()
  inspect(graph.is_strict(), content="false")
  inspect(dot_graph_type_to_string(graph.get_type()), content="graph")
  inspect(option_string_to_string(graph.get_name()), content="none")

  graph.set_strict(true)
  graph.set_type(Some(dot_graph_type_digraph()))
  graph.set_name(Some("g"))
  inspect(graph.is_strict(), content="true")
  inspect(dot_graph_type_to_string(graph.get_type()), content="digraph")
  inspect(option_string_to_string(graph.get_name()), content="g")

  let node = dot_create_node()
  node.set_name(Some("n1"))
  let port = dot_create_port()
  port.set_name(Some("p"))
  port.set_compass_pt(Some("s"))
  node.set_port(Some(port))

  let node_statement = dot_create_node_statement()
  node_statement.set_node(Some(node))
  let node_attr = dot_create_attribute()
  node_attr.set_name(Some("shape"))
  node_attr.set_value(Some("box"))
  node_statement.get_attributes().push(node_attr)

  let edge_statement = dot_create_edge_statement()
  edge_statement.set_source_node(Some(node))
  let edge_target = dot_create_edge_target()
  edge_target.set_operator(Some(dot_edge_operator_undirected()))
  edge_target.set_targetnode(Some(node))
  edge_statement.get_edge_targets().push(edge_target)

  let attr_statement = dot_create_attribute_statement()
  attr_statement.set_type(Some(dot_attribute_type_node()))
  let graph_attr = dot_create_attribute()
  graph_attr.set_name(Some("rankdir"))
  graph_attr.set_value(Some("LR"))
  attr_statement.get_attributes().push(graph_attr)

  let subgraph = dot_create_subgraph()
  subgraph.set_name(Some("cluster_0"))
  subgraph.get_statements().push(dot_statement_node_statement(node_statement))

  graph.get_statements().push(dot_statement_attribute_statement(attr_statement))
  graph.get_statements().push(dot_statement_edge_statement(edge_statement))
  graph.get_statements().push(dot_statement_subgraph(subgraph))
  model.get_graphs().push(graph)

  inspect(model.get_graphs().length(), content="1")
  inspect(model.get_graphs()[0].get_statements().length(), content="3")
  inspect(
    option_string_to_string(
      match model.get_graphs()[0].get_statements()[2] {
        DotStatementSubgraph(value) => value.get_name()
        _ => None
      },
    ),
    content="cluster_0",
  )
}

///|
test "Dot factory instance" {
  let factory = dot_factory_instance
  let model = factory.create_graphviz_model()
  let graph = factory.create_graph()
  graph.set_name(Some("from_factory"))
  model.get_graphs().push(graph)
  inspect(model.get_graphs().length(), content="1")
  inspect(
    option_string_to_string(model.get_graphs()[0].get_name()),
    content="from_factory",
  )
  inspect(factory.get_dot_package(), content=alg_graphviz_dot_dot_ens_uri)
}

///|
test "Dot resource set provider delegates" {
  let mut counter = 0
  let provider = new_dot_resource_set_provider(() => {
    counter = counter + 1
    "resource-" + counter.to_string()
  })
  inspect(provider.create_resource_set(), content="resource-1")
  inspect(provider.create_resource_set(), content="resource-2")
}
