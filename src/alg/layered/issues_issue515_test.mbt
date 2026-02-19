///|
fn issue515_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue515_test_layout(graph : @graph.ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
}

///|
fn issue515_test_create_port(
  parent : @graph.ElkNode,
  id : String,
  side : String,
) -> @graph.ElkPort {
  let port = create_port(Some(parent))
  port_set_identifier(port, id)
  port_set_dimensions(port, 10.0, 10.0)
  port_set_layout_option_string_by_id(port, "org.eclipse.elk.port.side", side)
  port
}

///|
fn issue515_test_connect(
  source : @graph.ElkPort,
  target : @graph.ElkPort,
  id : String,
) -> @graph.ElkEdge {
  let edge = create_edge(None)
  edge_set_identifier(edge, id)
  edge_add_source(edge, make_port_shape(source))
  edge_add_target(edge, make_port_shape(target))
  update_containment(Some(edge))
  edge
}

///|
fn issue515_test_build_graph() -> @graph.ElkNode {
  let graph = create_graph()
  @graph.node_set_string_property(graph, @core.algorithm, "org.eclipse.elk.layered")
  @graph.node_set_string_property(graph, @core.direction, "RIGHT")
  @graph.node_set_string_property(graph, @core.edge_routing, "ORTHOGONAL")

  let left = @graph.create_node(Some(graph))
  @graph.node_set_identifier(left, "left")
  @graph.node_set_dimensions(left, 60.0, 40.0)
  @graph.node_set_string_property(left, @core.port_constraints, "FIXED_SIDE")

  let right = @graph.create_node(Some(graph))
  @graph.node_set_identifier(right, "right")
  @graph.node_set_dimensions(right, 60.0, 40.0)
  @graph.node_set_string_property(right, @core.port_constraints, "FIXED_SIDE")

  let left_port = issue515_test_create_port(left, "left_out", "EAST")
  let right_port = issue515_test_create_port(right, "right_in", "WEST")
  ignore(issue515_test_connect(left_port, right_port, "edge_main"))

  graph
}

///|
fn issue515_test_all_nodes_as_boxes(graph : @graph.ElkNode) -> Array[@core.ElkRectangle] {
  let boxes : Array[@core.ElkRectangle] = []
  for node in @graph.node_children(graph) {
    boxes.push(
      @core.new_elk_rectangle_xywh(
        @graph.node_x(node),
        @graph.node_y(node),
        @graph.node_width(node),
        @graph.node_height(node),
      ),
    )
  }
  boxes
}

///|
fn issue515_test_assert_no_edge_overlaps(graph : @graph.ElkNode) -> Unit {
  let edges = @graph.node_contained_edges(graph)
  if edges.is_empty() {
    abort("Issue515 expected root contained edges.")
  }

  let all_nodes_as_boxes = issue515_test_all_nodes_as_boxes(graph)
  for edge in edges {
    for section in @graph.edge_sections(edge) {
      let start = @core.new_kvector_xy(
        @graph.edge_section_start_x(section),
        @graph.edge_section_start_y(section),
      )
      let end = @core.new_kvector_xy(
        @graph.edge_section_end_x(section),
        @graph.edge_section_end_y(section),
      )
      for box in all_nodes_as_boxes {
        if @core.intersects_rect_line(box, start, end) {
          abort("Edge path overlaps with node.")
        }
      }
    }
  }
}

///|
test "Issue515 edge routes avoid node box overlaps" {
  reset_graph_model_for_test()
  issue515_test_setup_plain_java_layout()

  let graph = issue515_test_build_graph()
  issue515_test_layout(graph)
  issue515_test_assert_no_edge_overlaps(graph)
}
