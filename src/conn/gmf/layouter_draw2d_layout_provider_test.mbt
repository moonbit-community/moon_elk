///|
fn conn_gmf_draw2d_test_graph() -> (
  @graph.ElkNode,
  @graph.ElkNode,
  @graph.ElkNode,
  @graph.ElkEdge,
) {
  @graph.reset_graph_model_for_test()
  let parent = @graph.create_graph()
  let source = @graph.create_node(Some(parent))
  let target = @graph.create_node(Some(parent))
  @graph.node_set_dimensions(source, 40.0, 20.0)
  @graph.node_set_dimensions(target, 30.0, 10.0)
  let edge = @graph.create_simple_edge(source, target)
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
  @graph.node_set_double_property(parent, draw2d_spacing_node_node, 10.0)
  @graph.node_set_string_property(
    parent, draw2d_padding, "[top=5,left=7,bottom=11,right=13]",
  )
  @graph.node_set_string_property(parent, draw2d_direction, "RIGHT")
  let provider = new_draw2d_layout_provider()
  let monitor = @core.new_elk_progress_monitor()
  provider.layout(parent, monitor)

  inspect(@graph.node_x(source), content="7")
  inspect(@graph.node_y(source), content="5")
  inspect(@graph.node_x(target), content="57")
  inspect(@graph.node_y(target), content="5")
  inspect(@graph.node_width(parent), content="100")
  inspect(@graph.node_height(parent), content="36")
}

///|
test "Draw2DLayoutProvider supports vertical direction and writes edge section" {
  let (parent, source, target, edge) = conn_gmf_draw2d_test_graph()
  @graph.node_set_double_property(parent, draw2d_spacing_node_node, 8.0)
  @graph.node_set_string_property(
    parent, draw2d_padding, "[top=2,left=3,bottom=4,right=5]",
  )
  @graph.node_set_string_property(parent, draw2d_direction, "DOWN")
  let provider = new_draw2d_layout_provider()
  let monitor = @core.new_elk_progress_monitor()
  provider.layout(parent, monitor)

  inspect(@graph.node_x(source), content="3")
  inspect(@graph.node_y(source), content="2")
  inspect(@graph.node_x(target), content="3")
  inspect(@graph.node_y(target), content="30")
  inspect(@graph.edge_sections(edge).length(), content="1")
  let section = @graph.edge_sections(edge)[0]
  inspect(@graph.edge_section_start_x(section), content="23")
  inspect(@graph.edge_section_start_y(section), content="12")
  inspect(@graph.edge_section_end_x(section), content="23")
  inspect(@graph.edge_section_end_y(section), content="12")
}
