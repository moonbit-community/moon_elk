///|
fn disco_transform_test_close(a : Double, b : Double) -> Bool {
  (a - b).abs() < 1.0e-6
}

///|
test "ElkGraphTransformer imports and applies offsets" {
  reset_graph_model_for_test()
  let root = create_graph()
  node_set_dimensions(root, 60.0, 30.0)

  let root_label = create_label(Some(make_node_label_parent(root)))
  label_set_location(root_label, 10.0, 5.0)
  label_set_dimensions(root_label, 8.0, 4.0)

  let left = create_node(Some(root))
  node_set_location(left, 10.0, 10.0)
  node_set_dimensions(left, 10.0, 10.0)
  let right = create_node(Some(root))
  node_set_location(right, 40.0, 10.0)
  node_set_dimensions(right, 10.0, 10.0)

  let edge = create_simple_edge(left, right)
  let section = create_edge_section(edge)
  edge_section_set_start(section, 20.0, 15.0)
  edge_section_set_end(section, 40.0, 15.0)
  edge_section_set_incoming_shape(section, Some(make_node_shape(left)))
  edge_section_set_outgoing_shape(section, Some(make_node_shape(right)))
  let edge_label = create_label(Some(make_edge_label_parent(edge)))
  label_set_location(edge_label, 30.0, 12.0)
  label_set_dimensions(edge_label, 6.0, 3.0)

  let transformer = new_elk_graph_transformer(component_spacing=4.0)
  let graph = transformer.import_graph(root)
  assert_eq(graph.get_components().length(), 1)

  graph.get_components()[0].set_offset(new_kvector_xy(5.0, 7.0))
  graph.set_dimensions(new_kvector_xy(80.0, 40.0))
  transformer.apply_layout()

  assert_eq(disco_transform_test_close(node_x(left), 15.0), true)
  assert_eq(disco_transform_test_close(node_y(left), 17.0), true)
  assert_eq(disco_transform_test_close(node_x(right), 45.0), true)
  assert_eq(disco_transform_test_close(node_y(right), 17.0), true)

  assert_eq(
    disco_transform_test_close(edge_section_start_x(section), 25.0),
    true,
  )
  assert_eq(
    disco_transform_test_close(edge_section_start_y(section), 22.0),
    true,
  )
  assert_eq(disco_transform_test_close(edge_section_end_x(section), 45.0), true)
  assert_eq(disco_transform_test_close(edge_section_end_y(section), 22.0), true)

  assert_eq(disco_transform_test_close(label_x(edge_label), 35.0), true)
  assert_eq(disco_transform_test_close(label_y(edge_label), 19.0), true)
  assert_eq(
    disco_transform_test_close(label_x(root_label), 10.0 * (80.0 / 60.0)),
    true,
  )
  assert_eq(
    disco_transform_test_close(label_y(root_label), 5.0 * (40.0 / 30.0)),
    true,
  )
}
