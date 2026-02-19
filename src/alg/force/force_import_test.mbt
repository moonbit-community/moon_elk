///|
fn check_simple_graph(graph : FGraph) -> Unit raise {
  assert_eq(graph.get_nodes().length(), 3)
  assert_eq(graph.get_edges().length(), 2)
  assert_eq(graph.get_labels().length(), 2)
}

///|
fn create_elk_graph() -> @graph.ElkNode {
  let graph = create_graph()
  let n1 = @graph.create_node(Some(graph))
  let n2 = @graph.create_node(Some(graph))
  let n3 = @graph.create_node(Some(graph))
  let edge1 = create_simple_edge(n1, n2)
  let label1 = @graph.create_label(Some(make_edge_label_parent(edge1)))
  @graph.label_set_text(label1, "test")
  let edge2 = create_simple_edge(n1, n3)
  let label2 = @graph.create_label(Some(make_edge_label_parent(edge2)))
  @graph.label_set_text(label2, "test2")
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
  let g1n1 = @graph.create_node(Some(graph))
  let g1n2 = @graph.create_node(Some(graph))
  let g1n3 = @graph.create_node(Some(graph))
  let g1e1 = create_simple_edge(g1n1, g1n2)
  let g1l1 = @graph.create_label(Some(make_edge_label_parent(g1e1)))
  @graph.label_set_text(g1l1, "g1-e1")
  let g1e2 = create_simple_edge(g1n1, g1n3)
  let g1l2 = @graph.create_label(Some(make_edge_label_parent(g1e2)))
  @graph.label_set_text(g1l2, "g1-e2")
  let g2n1 = @graph.create_node(Some(graph))
  let g2n2 = @graph.create_node(Some(graph))
  let g2n3 = @graph.create_node(Some(graph))
  let g2e1 = create_simple_edge(g2n1, g2n2)
  let g2l1 = @graph.create_label(Some(make_edge_label_parent(g2e1)))
  @graph.label_set_text(g2l1, "g2-e1")
  let g2e2 = create_simple_edge(g2n1, g2n3)
  let g2l2 = @graph.create_label(Some(make_edge_label_parent(g2e2)))
  @graph.label_set_text(g2l2, "g2-e2")
  let importer = new_elk_graph_importer()
  importer.import_graph(graph)
}

///|
fn imported_node_by_origin(graph : FGraph, origin : @graph.ElkNode) -> FNode? {
  for node in graph.get_nodes() {
    if fnode_origin(node) == Some(origin) {
      return Some(node)
    }
  }
  None
}

///|
fn imported_edge_by_origin(graph : FGraph, origin : @graph.ElkEdge) -> FEdge? {
  for edge in graph.get_edges() {
    if fedge_origin(edge) == Some(origin) {
      return Some(edge)
    }
  }
  None
}

///|
fn imported_label_by_origin(graph : FGraph, origin : @graph.ElkLabel) -> FLabel? {
  for label in graph.get_labels() {
    if flabel_origin(label) == Some(origin) {
      return Some(label)
    }
  }
  None
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
  let node = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(node, 10.0, 10.0)
  let importer = new_elk_graph_importer()
  let force_graph = importer.import_graph(graph)
  importer.apply_layout(force_graph)
  assert_eq(@graph.node_width(graph), 110.0)
  assert_eq(@graph.node_height(graph), 110.0)
  assert_eq(@graph.node_get_double_property(graph, @core.child_area_width), 10.0)
  assert_eq(@graph.node_get_double_property(graph, @core.child_area_height), 10.0)
}

///|
test "ElkGraphImporter applyLayout respects fixed graph size" {
  reset_graph_model_for_test()
  reset_force_graph_model_for_test()
  let graph = create_graph()
  @graph.node_set_dimensions(graph, 37.0, 41.0)
  @graph.node_set_bool_property(graph, @core.node_size_fixed_graph_size, true)
  let node = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(node, 10.0, 10.0)
  let importer = new_elk_graph_importer()
  let force_graph = importer.import_graph(graph)
  importer.apply_layout(force_graph)
  assert_eq(@graph.node_width(graph), 37.0)
  assert_eq(@graph.node_height(graph), 41.0)
  assert_eq(@graph.node_get_double_property(graph, @core.child_area_width), 10.0)
  assert_eq(@graph.node_get_double_property(graph, @core.child_area_height), 10.0)
}

///|
test "ElkGraphImporter importGraph copies graph and element options" {
  reset_graph_model_for_test()
  reset_force_graph_model_for_test()
  let graph = create_graph()
  @graph.node_set_layout_option_string_by_id(graph, force_model.get_id(), "EADES")
  @graph.node_set_layout_option_string_by_id(graph, force_iterations.get_id(), "17")
  @graph.node_set_layout_option_string_by_id(graph, force_random_seed.get_id(), "42")
  @graph.node_set_layout_option_string_by_id(graph, stress_dimension.get_id(), "Y")
  @graph.node_set_layout_option_string_by_id(
    graph,
    stress_iteration_limit.get_id(),
    "25",
  )
  @graph.node_set_layout_option_string_by_id(graph, force_temperature.get_id(), "0.25")
  @graph.node_set_layout_option_string_by_id(graph, force_repulsion.get_id(), "7.5")
  @graph.node_set_layout_option_string_by_id(
    graph,
    force_spacing_node_node.get_id(),
    "123.0",
  )
  @graph.node_set_layout_option_string_by_id(
    graph,
    force_aspect_ratio.get_id(),
    "2.5f",
  )
  @graph.node_set_layout_option_string_by_id(
    graph,
    stress_desired_edge_length.get_id(),
    "33.3",
  )
  @graph.node_set_layout_option_string_by_id(graph, stress_epsilon.get_id(), "0.02")
  @graph.node_set_layout_option_string_by_id(
    graph,
    force_edge_labels_inline.get_id(),
    "true",
  )
  @graph.node_set_layout_option_string_by_id(
    graph,
    force_padding.get_id(),
    "[top=1,right=2,bottom=3,left=4]",
  )
  let left = @graph.create_node(Some(graph))
  let right = @graph.create_node(Some(graph))
  let edge = create_simple_edge(left, right)
  let edge_label = @graph.create_label(Some(make_edge_label_parent(edge)))
  @graph.node_set_layout_option_string_by_id(left, force_priority.get_id(), "4")
  @graph.node_set_layout_option_string_by_id(left, stress_fixed.get_id(), "true")
  edge_set_layout_option_string_by_id(edge, force_priority.get_id(), "9")
  edge_set_layout_option_string_by_id(edge, force_repulsive_power.get_id(), "3")
  edge_set_layout_option_string_by_id(
    edge,
    stress_desired_edge_length.get_id(),
    "55.5",
  )
  edge_set_layout_option_string_by_id(
    edge,
    force_edge_labels_inline.get_id(),
    "false",
  )
  label_set_layout_option_string_by_id(
    edge_label,
    force_edge_labels_inline.get_id(),
    "true",
  )
  let importer = new_elk_graph_importer()
  let force_graph = importer.import_graph(graph)
  ignore(force_graph.get_model_property(force_model))
  assert_eq(force_graph.get_int_property(force_iterations), 17)
  assert_eq(force_graph.get_int_property(force_random_seed), 42)
  assert_eq(force_graph.get_int_property(stress_dimension), 2)
  assert_eq(force_graph.get_int_property(stress_iteration_limit), 25)
  assert_eq(force_graph.get_double_property(force_temperature), 0.25)
  assert_eq(force_graph.get_double_property(force_repulsion), 7.5)
  assert_eq(force_graph.get_double_property(force_spacing_node_node), 123.0)
  assert_eq(force_graph.get_double_property(force_aspect_ratio), 2.5)
  assert_eq(force_graph.get_double_property(stress_desired_edge_length), 33.3)
  assert_eq(force_graph.get_double_property(stress_epsilon), 0.02)
  assert_eq(force_graph.get_property(force_edge_labels_inline), true)
  let padding = force_graph.get_padding_property(force_padding)
  assert_eq(padding.get_top(), 1.0)
  assert_eq(padding.get_right(), 2.0)
  assert_eq(padding.get_bottom(), 3.0)
  assert_eq(padding.get_left(), 4.0)
  let imported_left = match imported_node_by_origin(force_graph, left) {
    Some(node) => node
    None => abort("missing imported node")
  }
  assert_eq(fnode_get_int_property(imported_left, force_priority), 4)
  assert_eq(fnode_get_bool_property(imported_left, stress_fixed), true)
  let imported_edge = match imported_edge_by_origin(force_graph, edge) {
    Some(imported) => imported
    None => abort("missing imported edge")
  }
  assert_eq(fedge_get_int_property(imported_edge, force_priority), 9)
  assert_eq(fedge_get_int_property(imported_edge, force_repulsive_power), 3)
  assert_eq(
    fedge_get_double_property(imported_edge, stress_desired_edge_length),
    55.5,
  )
  let imported_label = match imported_label_by_origin(force_graph, edge_label) {
    Some(label) => label
    None => abort("missing imported label")
  }
  assert_eq(
    flabel_get_bool_property(imported_label, force_edge_labels_inline),
    true,
  )
}

///|
test "ElkGraphImporter importGraph keeps edge desired length as explicit override only" {
  reset_graph_model_for_test()
  reset_force_graph_model_for_test()
  let graph = create_graph()
  @graph.node_set_layout_option_string_by_id(
    graph,
    stress_desired_edge_length.get_id(),
    "77.0",
  )
  @graph.node_set_layout_option_string_by_id(
    graph,
    force_edge_labels_inline.get_id(),
    "true",
  )
  let a = @graph.create_node(Some(graph))
  let b = @graph.create_node(Some(graph))
  let c = @graph.create_node(Some(graph))
  let edge1 = create_simple_edge(a, b)
  let edge2 = create_simple_edge(a, c)
  edge_set_layout_option_string_by_id(
    edge2,
    stress_desired_edge_length.get_id(),
    "12.5",
  )
  edge_set_layout_option_string_by_id(
    edge2,
    force_edge_labels_inline.get_id(),
    "false",
  )
  let label1 = @graph.create_label(Some(make_edge_label_parent(edge1)))
  let label2 = @graph.create_label(Some(make_edge_label_parent(edge2)))
  let importer = new_elk_graph_importer()
  let force_graph = importer.import_graph(graph)
  assert_eq(force_graph.get_double_property(stress_desired_edge_length), 77.0)
  let imported_edge1 = match imported_edge_by_origin(force_graph, edge1) {
    Some(edge) => edge
    None => abort("missing imported edge1")
  }
  let imported_edge2 = match imported_edge_by_origin(force_graph, edge2) {
    Some(edge) => edge
    None => abort("missing imported edge2")
  }
  assert_eq(
    fedge_has_double_property(imported_edge1, stress_desired_edge_length),
    false,
  )
  assert_eq(
    fedge_has_double_property(imported_edge2, stress_desired_edge_length),
    true,
  )
  assert_eq(
    fedge_get_double_property(imported_edge2, stress_desired_edge_length),
    12.5,
  )
  let imported_label1 = match imported_label_by_origin(force_graph, label1) {
    Some(label) => label
    None => abort("missing imported label1")
  }
  let imported_label2 = match imported_label_by_origin(force_graph, label2) {
    Some(label) => label
    None => abort("missing imported label2")
  }
  assert_eq(
    flabel_get_bool_property(imported_label1, force_edge_labels_inline),
    true,
  )
  assert_eq(
    flabel_get_bool_property(imported_label2, force_edge_labels_inline),
    false,
  )
}
