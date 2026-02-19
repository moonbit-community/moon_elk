///|
fn issue447_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue447_test_layout(graph : @graph.ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
}

///|
fn issue447_test_port_size() -> Double {
  10.0
}

///|
fn issue447_test_port_anchor() -> Double {
  5.0
}

///|
fn issue447_test_coordinate_fuzziness() -> Double {
  0.5
}

///|
fn issue447_test_assert_close(
  actual : Double,
  expected : Double,
  epsilon : Double,
  context : String,
) -> Unit {
  if (actual - expected).abs() > epsilon {
    abort(
      "\{context}: expected=\{expected}, actual=\{actual}, epsilon=\{epsilon}",
    )
  }
}

///|
fn issue447_test_absolute_node_position(node : @graph.ElkNode) -> @core.KVector {
  let absolute = @core.new_kvector_xy(@graph.node_x(node), @graph.node_y(node))
  match @graph.node_parent(node) {
    Some(parent) =>
      ignore(absolute.add(issue447_test_absolute_node_position(parent)))
    None => ()
  }
  absolute
}

///|
fn issue447_test_absolute_point_in_node(
  node : @graph.ElkNode,
  x : Double,
  y : Double,
) -> @core.KVector {
  issue447_test_absolute_node_position(node).add_xy(x, y)
}

///|
fn issue447_test_absolute_port_anchor(port : @graph.ElkPort) -> @core.KVector {
  match @graph.port_parent(port) {
    Some(parent_node) =>
      issue447_test_absolute_node_position(parent_node).add_xy(
        port_x(port) + issue447_test_port_anchor(),
        port_y(port) + issue447_test_port_anchor(),
      )
    None =>
      @core.new_kvector_xy(
        port_x(port) + issue447_test_port_anchor(),
        port_y(port) + issue447_test_port_anchor(),
      )
  }
}

///|
fn issue447_test_configure_port(port : @graph.ElkPort) -> Unit {
  port_set_dimensions(
    port,
    issue447_test_port_size(),
    issue447_test_port_size(),
  )
  port_set_layout_option_string_by_id(
    port,
    layered_options_port_anchor.get_id(),
    "(\{issue447_test_port_anchor()},\{issue447_test_port_anchor()})",
  )
}

///|
fn issue447_test_configure_port_sizes_and_anchors(
  graph : @graph.ElkNode,
) -> Unit {
  for node in node_all_descendants_including_self(graph) {
    for port in @graph.node_ports(node) {
      issue447_test_configure_port(port)
    }
  }
}

///|
fn issue447_test_create_port(
  parent : @graph.ElkNode,
  id : String,
  side : String,
) -> @graph.ElkPort {
  let port = create_port(Some(parent))
  port_set_identifier(port, id)
  port_set_layout_option_string_by_id(port, "org.eclipse.elk.port.side", side)
  port
}

///|
fn issue447_test_connect(
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
fn issue447_test_build_graph() -> @graph.ElkNode {
  let graph = create_graph()
  @graph.node_set_string_property(
    graph, @core.algorithm, "org.eclipse.elk.layered",
  )
  @graph.node_set_string_property(graph, @core.direction, "RIGHT")
  @graph.node_set_string_property(graph, @core.edge_routing, "ORTHOGONAL")
  @graph.node_set_string_property(
    graph, layered_options_hierarchy_handling, "INCLUDE_CHILDREN",
  )

  let left = @graph.create_node(Some(graph))
  @graph.node_set_identifier(left, "left")
  @graph.node_set_dimensions(left, 120.0, 100.0)
  @graph.node_set_string_property(left, @core.port_constraints, "FIXED_SIDE")

  let right = @graph.create_node(Some(graph))
  @graph.node_set_identifier(right, "right")
  @graph.node_set_dimensions(right, 120.0, 100.0)
  @graph.node_set_string_property(right, @core.port_constraints, "FIXED_SIDE")

  let left_inner = @graph.create_node(Some(left))
  @graph.node_set_identifier(left_inner, "left_inner")
  @graph.node_set_dimensions(left_inner, 60.0, 40.0)
  @graph.node_set_string_property(
    left_inner, @core.port_constraints, "FIXED_SIDE",
  )

  let right_inner = @graph.create_node(Some(right))
  @graph.node_set_identifier(right_inner, "right_inner")
  @graph.node_set_dimensions(right_inner, 60.0, 40.0)
  @graph.node_set_string_property(
    right_inner, @core.port_constraints, "FIXED_SIDE",
  )

  let left_outer_port = issue447_test_create_port(left, "left_outer", "EAST")
  let right_outer_port = issue447_test_create_port(right, "right_outer", "WEST")
  let left_inner_port = issue447_test_create_port(
    left_inner, "left_inner_port", "EAST",
  )
  let right_inner_port = issue447_test_create_port(
    right_inner, "right_inner_port", "WEST",
  )

  ignore(issue447_test_connect(left_outer_port, right_outer_port, "edge_outer"))
  ignore(issue447_test_connect(left_inner_port, right_inner_port, "edge_inner"))
  ignore(
    issue447_test_connect(left_outer_port, left_inner_port, "edge_left_hier"),
  )
  ignore(
    issue447_test_connect(right_inner_port, right_outer_port, "edge_right_hier"),
  )
  ignore(
    issue447_test_connect(left_inner_port, right_outer_port, "edge_cross_hier"),
  )

  graph
}

///|
fn issue447_test_edge_endpoint_absolute_position(
  edge : @graph.ElkEdge,
  x : Double,
  y : Double,
) -> @core.KVector {
  match edge_containing_node(edge) {
    Some(containing_node) =>
      issue447_test_absolute_point_in_node(containing_node, x, y)
    None => @core.new_kvector_xy(x, y)
  }
}

///|
fn issue447_test_test_edge_end_point(
  edge : @graph.ElkEdge,
  port : @graph.ElkPort,
  x : Double,
  y : Double,
  endpoint_name : String,
) -> Unit {
  let absolute_port_anchor = issue447_test_absolute_port_anchor(port)
  let absolute_end_point = issue447_test_edge_endpoint_absolute_position(
    edge, x, y,
  )
  let context = edge_identifier(edge) + "." + endpoint_name
  issue447_test_assert_close(
    absolute_end_point.x,
    absolute_port_anchor.x,
    issue447_test_coordinate_fuzziness(),
    context + ".x",
  )
  issue447_test_assert_close(
    absolute_end_point.y,
    absolute_port_anchor.y,
    issue447_test_coordinate_fuzziness(),
    context + ".y",
  )
}

///|
fn issue447_test_test_edge(edge : @graph.ElkEdge) -> Unit {
  for section in @graph.edge_sections(edge) {
    match
      @graph.connectable_shape_to_port(edge_section_incoming_shape(section)) {
      Some(port) =>
        issue447_test_test_edge_end_point(
          edge,
          port,
          @graph.edge_section_start_x(section),
          @graph.edge_section_start_y(section),
          "incoming",
        )
      None => ()
    }
    match
      @graph.connectable_shape_to_port(edge_section_outgoing_shape(section)) {
      Some(port) =>
        issue447_test_test_edge_end_point(
          edge,
          port,
          @graph.edge_section_end_x(section),
          @graph.edge_section_end_y(section),
          "outgoing",
        )
      None => ()
    }
  }
}

///|
fn issue447_test_assert_edges_connect_to_anchors(
  graph : @graph.ElkNode,
) -> Unit {
  let mut checked_edges = 0
  for node in node_all_descendants_including_self(graph) {
    for edge in @graph.node_contained_edges(node) {
      checked_edges = checked_edges + 1
      issue447_test_test_edge(edge)
    }
  }
  if checked_edges == 0 {
    abort("Issue447 expected routed edges, found none.")
  }
}

///|
test "Issue447 edge endpoints connect to hierarchical port anchors" {
  reset_graph_model_for_test()
  issue447_test_setup_plain_java_layout()

  let graph = issue447_test_build_graph()
  issue447_test_configure_port_sizes_and_anchors(graph)
  issue447_test_layout(graph)
  issue447_test_assert_edges_connect_to_anchors(graph)
}
