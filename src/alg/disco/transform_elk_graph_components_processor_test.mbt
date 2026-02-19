///|
fn disco_components_sorted(nodes : Array[@graph.ElkNode]) -> Array[@graph.ElkNode] {
  let result = nodes.copy()
  for i = 1; i < result.length(); i = i + 1 {
    let current = result[i]
    let mut j = i
    while j > 0 && result[j - 1] > current {
      result[j] = result[j - 1]
      j = j - 1
    }
    result[j] = current
  }
  result
}

///|
fn disco_components_signature(components : Array[Array[@graph.ElkNode]]) -> String {
  let groups : Array[String] = []
  for component in components {
    let sorted = disco_components_sorted(component)
    let ids : Array[String] = []
    for node in sorted {
      ids.push(node.to_string())
    }
    groups.push(ids.join(","))
  }
  let sorted_groups = groups.copy()
  for i = 1; i < sorted_groups.length(); i = i + 1 {
    let current = sorted_groups[i]
    let mut j = i
    while j > 0 && sorted_groups[j - 1] > current {
      sorted_groups[j] = sorted_groups[j - 1]
      j = j - 1
    }
    sorted_groups[j] = current
  }
  sorted_groups.join("|")
}

///|
test "ElkGraphComponentsProcessor split handles disconnected nodes" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  let node_a = @graph.create_node(Some(root))
  let node_b = @graph.create_node(Some(root))
  let node_c = @graph.create_node(Some(root))
  ignore(@graph.create_simple_edge(node_a, node_b))

  let components = elk_graph_components_processor_split(root)
  assert_eq(components.length(), 2)
  assert_eq(
    disco_components_signature(components),
    disco_components_signature([[node_a, node_b], [node_c]]),
  )
}

///|
test "ElkGraphComponentsProcessor split connects through parent port" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  let node_a = @graph.create_node(Some(root))
  let node_b = @graph.create_node(Some(root))
  let node_c = @graph.create_node(Some(root))
  let parent_port = @graph.create_port(Some(root))

  let to_parent = @graph.create_edge(Some(root))
  @graph.edge_add_source(to_parent, @graph.make_node_shape(node_a))
  @graph.edge_add_target(to_parent, @graph.make_port_shape(parent_port))
  @graph.update_containment(Some(to_parent))

  let from_parent = @graph.create_edge(Some(root))
  @graph.edge_add_source(from_parent, @graph.make_port_shape(parent_port))
  @graph.edge_add_target(from_parent, @graph.make_node_shape(node_b))
  @graph.update_containment(Some(from_parent))

  let components = elk_graph_components_processor_split(root)
  assert_eq(components.length(), 2)
  assert_eq(
    disco_components_signature(components),
    disco_components_signature([[node_a, node_b], [node_c]]),
  )
}
