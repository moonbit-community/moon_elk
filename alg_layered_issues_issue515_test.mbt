///|
fn issue515_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue515_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
fn issue515_test_create_port(
  parent : ElkNode,
  id : String,
  side : String,
) -> ElkPort {
  let port = create_port(Some(parent))
  port_set_identifier(port, id)
  port_set_dimensions(port, 10.0, 10.0)
  port_set_layout_option_string_by_id(port, "org.eclipse.elk.port.side", side)
  port
}

///|
fn issue515_test_connect(
  source : ElkPort,
  target : ElkPort,
  id : String,
) -> ElkEdge {
  let edge = create_edge(None)
  edge_set_identifier(edge, id)
  edge_add_source(edge, make_port_shape(source))
  edge_add_target(edge, make_port_shape(target))
  update_containment(Some(edge))
  edge
}

///|
fn issue515_test_build_graph() -> ElkNode {
  let graph = create_graph()
  node_set_string_property(graph, algorithm, "org.eclipse.elk.layered")
  node_set_string_property(graph, direction, "RIGHT")
  node_set_string_property(graph, edge_routing, "ORTHOGONAL")

  let left = create_node(Some(graph))
  node_set_identifier(left, "left")
  node_set_dimensions(left, 60.0, 40.0)
  node_set_string_property(left, port_constraints, "FIXED_SIDE")

  let right = create_node(Some(graph))
  node_set_identifier(right, "right")
  node_set_dimensions(right, 60.0, 40.0)
  node_set_string_property(right, port_constraints, "FIXED_SIDE")

  let left_port = issue515_test_create_port(left, "left_out", "EAST")
  let right_port = issue515_test_create_port(right, "right_in", "WEST")
  ignore(issue515_test_connect(left_port, right_port, "edge_main"))

  graph
}

///|
fn issue515_test_all_nodes_as_boxes(graph : ElkNode) -> Array[ElkRectangle] {
  let boxes : Array[ElkRectangle] = []
  for node in node_children(graph) {
    boxes.push(
      new_elk_rectangle_xywh(
        node_x(node),
        node_y(node),
        node_width(node),
        node_height(node),
      ),
    )
  }
  boxes
}

///|
fn issue515_test_assert_no_edge_overlaps(graph : ElkNode) -> Unit {
  let edges = node_contained_edges(graph)
  if edges.is_empty() {
    abort("Issue515 expected root contained edges.")
  }

  let all_nodes_as_boxes = issue515_test_all_nodes_as_boxes(graph)
  for edge in edges {
    for section in edge_sections(edge) {
      let start = new_kvector_xy(
        edge_section_start_x(section),
        edge_section_start_y(section),
      )
      let end = new_kvector_xy(
        edge_section_end_x(section),
        edge_section_end_y(section),
      )
      for box in all_nodes_as_boxes {
        if intersects_rect_line(box, start, end) {
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
