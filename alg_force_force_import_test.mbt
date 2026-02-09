///|
fn check_simple_graph(graph : FGraph) -> Unit raise {
  assert_eq(graph.get_nodes().length(), 3)
  assert_eq(graph.get_edges().length(), 2)
  assert_eq(graph.get_labels().length(), 2)
}

///|
fn create_elk_graph() -> ElkNode {
  let graph = create_graph()
  let n1 = create_node(Some(graph))
  let n2 = create_node(Some(graph))
  let n3 = create_node(Some(graph))
  let edge1 = create_simple_edge(n1, n2)
  let label1 = create_label(Some(make_edge_label_parent(edge1)))
  label_set_text(label1, "test")
  let edge2 = create_simple_edge(n1, n3)
  let label2 = create_label(Some(make_edge_label_parent(edge2)))
  label_set_text(label2, "test2")
  graph
}

///|
fn create_simple_graph() -> FGraph {
  let importer = new_elk_graph_importer()
  importer.import_graph(create_elk_graph())
}

///|
fn create_two_components_graph() -> FGraph {
  let graph = create_graph()
  let g1n1 = create_node(Some(graph))
  let g1n2 = create_node(Some(graph))
  let g1n3 = create_node(Some(graph))
  let g1e1 = create_simple_edge(g1n1, g1n2)
  let g1l1 = create_label(Some(make_edge_label_parent(g1e1)))
  label_set_text(g1l1, "g1-e1")
  let g1e2 = create_simple_edge(g1n1, g1n3)
  let g1l2 = create_label(Some(make_edge_label_parent(g1e2)))
  label_set_text(g1l2, "g1-e2")
  let g2n1 = create_node(Some(graph))
  let g2n2 = create_node(Some(graph))
  let g2n3 = create_node(Some(graph))
  let g2e1 = create_simple_edge(g2n1, g2n2)
  let g2l1 = create_label(Some(make_edge_label_parent(g2e1)))
  label_set_text(g2l1, "g2-e1")
  let g2e2 = create_simple_edge(g2n1, g2n3)
  let g2l2 = create_label(Some(make_edge_label_parent(g2e2)))
  label_set_text(g2l2, "g2-e2")
  let importer = new_elk_graph_importer()
  importer.import_graph(graph)
}

///|
test "ForceImportTest import simple graph" {
  reset_graph_model_for_test()
  reset_force_graph_model_for_test()
  let graph = create_simple_graph()
  check_simple_graph(graph)
}

///|
test "ForceImportTest separate connected components" {
  reset_graph_model_for_test()
  reset_force_graph_model_for_test()
  let processor = new_components_processor()
  let graph = create_two_components_graph()
  graph.set_property(force_separate_connected_components, true)
  let components = processor.split(graph)
  assert_eq(components.length(), 2)
  for component in components {
    check_simple_graph(component)
  }
}

///|
test "ForceImportTest do not separate connected components" {
  reset_graph_model_for_test()
  reset_force_graph_model_for_test()
  let processor = new_components_processor()
  let graph = create_two_components_graph()
  graph.set_property(force_separate_connected_components, false)
  let components = processor.split(graph)
  assert_eq(components.length(), 1)
  let result = components[0]
  assert_eq(result.get_nodes().length(), 6)
  assert_eq(result.get_edges().length(), 4)
  assert_eq(result.get_labels().length(), 4)
}

///|
test "ElkGraphImporter applyLayout resizes parent and sets child area" {
  reset_graph_model_for_test()
  reset_force_graph_model_for_test()
  let graph = create_graph()
  let node = create_node(Some(graph))
  node_set_dimensions(node, 10.0, 10.0)
  let importer = new_elk_graph_importer()
  let force_graph = importer.import_graph(graph)
  importer.apply_layout(force_graph)
  assert_eq(node_width(graph), 110.0)
  assert_eq(node_height(graph), 110.0)
  assert_eq(node_get_double_property(graph, child_area_width), 10.0)
  assert_eq(node_get_double_property(graph, child_area_height), 10.0)
}

///|
test "ElkGraphImporter applyLayout respects fixed graph size" {
  reset_graph_model_for_test()
  reset_force_graph_model_for_test()
  let graph = create_graph()
  node_set_dimensions(graph, 37.0, 41.0)
  node_set_bool_property(graph, node_size_fixed_graph_size, true)
  let node = create_node(Some(graph))
  node_set_dimensions(node, 10.0, 10.0)
  let importer = new_elk_graph_importer()
  let force_graph = importer.import_graph(graph)
  importer.apply_layout(force_graph)
  assert_eq(node_width(graph), 37.0)
  assert_eq(node_height(graph), 41.0)
  assert_eq(node_get_double_property(graph, child_area_width), 10.0)
  assert_eq(node_get_double_property(graph, child_area_height), 10.0)
}
