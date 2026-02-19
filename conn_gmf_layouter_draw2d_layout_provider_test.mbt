///|
fn conn_gmf_draw2d_test_graph() -> (ElkNode, ElkNode, ElkNode, ElkEdge) {
  reset_graph_model_for_test()
  let parent = create_graph()
  let source = create_node(Some(parent))
  let target = create_node(Some(parent))
  node_set_dimensions(source, 40.0, 20.0)
  node_set_dimensions(target, 30.0, 10.0)
  let edge = create_simple_edge(source, target)
  (parent, source, target, edge)
}

///|
test "Draw2DLayoutProvider initialize toggles compound mode" {
  let provider = new_draw2d_layout_provider()
  inspect(provider.is_compound_mode(), content="false")
  provider.initialize(Some("Compound"))
  inspect(provider.is_compound_mode(), content="true")
  provider.initialize(Some("Other"))
  inspect(provider.is_compound_mode(), content="false")
}

///|
test "Draw2DLayoutProvider layouts nodes horizontally and sets parent size" {
  let (parent, source, target, _edge) = conn_gmf_draw2d_test_graph()
  node_set_double_property(parent, draw2d_spacing_node_node, 10.0)
  node_set_string_property(
    parent, draw2d_padding, "[top=5,left=7,bottom=11,right=13]",
  )
  node_set_string_property(parent, draw2d_direction, "RIGHT")
  let provider = new_draw2d_layout_provider()
  let monitor = new_elk_progress_monitor()
  provider.layout(parent, monitor)

  inspect(node_x(source), content="7")
  inspect(node_y(source), content="5")
  inspect(node_x(target), content="57")
  inspect(node_y(target), content="5")
  inspect(node_width(parent), content="100")
  inspect(node_height(parent), content="36")
}

///|
test "Draw2DLayoutProvider supports vertical direction and writes edge section" {
  let (parent, source, target, edge) = conn_gmf_draw2d_test_graph()
  node_set_double_property(parent, draw2d_spacing_node_node, 8.0)
  node_set_string_property(
    parent, draw2d_padding, "[top=2,left=3,bottom=4,right=5]",
  )
  node_set_string_property(parent, draw2d_direction, "DOWN")
  let provider = new_draw2d_layout_provider()
  let monitor = new_elk_progress_monitor()
  provider.layout(parent, monitor)

  inspect(node_x(source), content="3")
  inspect(node_y(source), content="2")
  inspect(node_x(target), content="3")
  inspect(node_y(target), content="30")
  inspect(edge_sections(edge).length(), content="1")
  let section = edge_sections(edge)[0]
  inspect(edge_section_start_x(section), content="23")
  inspect(edge_section_start_y(section), content="12")
  inspect(edge_section_end_x(section), content="23")
  inspect(edge_section_end_y(section), content="12")
}
