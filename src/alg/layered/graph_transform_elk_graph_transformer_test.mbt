///|
fn layered_graph_transform_test_fixture() -> (
  @graph.ElkNode,
  @graph.ElkNode,
  @graph.ElkNode,
  @graph.ElkEdge,
) {
  reset_graph_model_for_test()
  let graph = create_graph()
  @graph.node_set_string_property(
    graph, @core.padding, "[top=0,left=0,bottom=0,right=0]",
  )

  let left = @graph.create_node(Some(graph))
  @graph.node_set_identifier(left, "left")
  @graph.node_set_dimensions(left, 10.0, 10.0)

  let right = @graph.create_node(Some(graph))
  @graph.node_set_identifier(right, "right")
  @graph.node_set_dimensions(right, 10.0, 10.0)

  let edge = create_edge(Some(graph))
  edge_add_source(edge, make_node_shape(left))
  edge_add_target(edge, make_node_shape(right))
  (graph, left, right, edge)
}

///|
test "layered elk graph importer and transferrer round-trip node and edge geometry" {
  let (graph, left, right, edge) = layered_graph_transform_test_fixture()
  let importer = new_layered_elk_graph_importer()
  let layered_graph = importer.import_graph(graph)
  let layered_nodes = layered_graph.get_layerless_nodes()
  assert_eq(layered_nodes.length(), 2)

  ignore(layered_nodes[0].get_position().set_xy(10.0, 20.0))
  ignore(layered_nodes[0].get_size().set_xy(30.0, 40.0))
  ignore(layered_nodes[1].get_position().set_xy(55.0, 66.0))
  ignore(layered_nodes[1].get_size().set_xy(77.0, 88.0))

  let transferrer = new_layered_elk_graph_layout_transferrer()
  transferrer.apply_layout(layered_graph)

  assert_double_eq(@graph.node_x(left), 10.0, 0.0)
  assert_double_eq(@graph.node_y(left), 20.0, 0.0)
  assert_double_eq(@graph.node_width(left), 30.0, 0.0)
  assert_double_eq(@graph.node_height(left), 40.0, 0.0)

  assert_double_eq(@graph.node_x(right), 55.0, 0.0)
  assert_double_eq(@graph.node_y(right), 66.0, 0.0)
  assert_double_eq(@graph.node_width(right), 77.0, 0.0)
  assert_double_eq(@graph.node_height(right), 88.0, 0.0)

  assert_true(!@graph.edge_sections(edge).is_empty())
}

///|
test "layered elk graph transformer exposes layered igraph transformer bridge" {
  let (graph, left, _, _) = layered_graph_transform_test_fixture()
  let transformer = new_layered_elk_graph_transformer()
  let bridge = transformer.as_layered_igraph_transformer()
  let layered_graph = match bridge.import_graph(graph) {
    Some(value) => value
    None => abort("expected imported layered graph")
  }
  let layered_nodes = layered_graph.get_layerless_nodes()
  assert_eq(layered_nodes.length(), 2)
  ignore(layered_nodes[0].get_position().set_xy(8.0, 9.0))
  ignore(layered_nodes[0].get_size().set_xy(22.0, 33.0))
  bridge.apply_layout(layered_graph)
  assert_double_eq(@graph.node_x(left), 8.0, 0.0)
  assert_double_eq(@graph.node_y(left), 9.0, 0.0)
  assert_double_eq(@graph.node_width(left), 22.0, 0.0)
  assert_double_eq(@graph.node_height(left), 33.0, 0.0)
}

///|
test "layered layout provider sets layered @core.algorithm defaults and lays out graph" {
  let (graph, _, _, _) = layered_graph_transform_test_fixture()
  let provider = new_layered_layout_provider()
  provider.layout(graph, @core.new_null_elk_progress_monitor())
  assert_true(@graph.node_width(graph) > 0.0)
  assert_true(@graph.node_height(graph) > 0.0)
}

///|
test "layered layout provider handles include_children forceNodeModelOrder on compound nodes" {
  reset_graph_model_for_test()
  let root = create_graph()
  @graph.node_set_layout_option_string_by_id(
    root,
    layered_options_hierarchy_handling.get_id(),
    "INCLUDE_CHILDREN",
  )
  let compound = @graph.create_node(Some(root))
  @graph.node_set_identifier(compound, "compound")
  @graph.node_set_bool_property(
    compound, layered_options_crossing_minimization_force_node_model_order, true,
  )
  let left = @graph.create_node(Some(compound))
  @graph.node_set_identifier(left, "left")
  @graph.node_set_dimensions(left, 10.0, 10.0)
  let right = @graph.create_node(Some(compound))
  @graph.node_set_identifier(right, "right")
  @graph.node_set_dimensions(right, 10.0, 10.0)
  new_layered_layout_provider().layout(
    root,
    @core.new_null_elk_progress_monitor(),
  )
  assert_true(@graph.node_width(root) >= 0.0)
  assert_true(@graph.node_height(root) >= 0.0)
}

///|
test "layered layout provider allows forceNodeModelOrder on single-child compound" {
  reset_graph_model_for_test()
  let root = create_graph()
  @graph.node_set_layout_option_string_by_id(
    root,
    layered_options_hierarchy_handling.get_id(),
    "INCLUDE_CHILDREN",
  )
  let compound = @graph.create_node(Some(root))
  @graph.node_set_identifier(compound, "compound")
  @graph.node_set_bool_property(
    compound, layered_options_crossing_minimization_force_node_model_order, true,
  )
  let only_child = @graph.create_node(Some(compound))
  @graph.node_set_identifier(only_child, "only")
  @graph.node_set_dimensions(only_child, 10.0, 10.0)
  new_layered_layout_provider().layout(
    root,
    @core.new_null_elk_progress_monitor(),
  )
  assert_true(@graph.node_width(root) >= 0.0)
  assert_true(@graph.node_height(root) >= 0.0)
}
