///|
fn issue143_and318_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue143_and318_test_layout(graph : @graph.ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
}

///|
fn issue143_and318_test_create_fixed_pos_port(
  parent : @graph.ElkNode,
  id : String,
  x : Double,
  y : Double,
) -> @graph.ElkPort {
  let port = create_port(Some(parent))
  port_set_identifier(port, id)
  port_set_dimensions(port, 3.0, 3.0)
  port_set_location(port, x, y)
  port
}

///|
fn issue143_and318_test_create_ordered_port(
  parent : @graph.ElkNode,
  id : String,
  side : String,
  index : Int,
) -> @graph.ElkPort {
  let port = create_port(Some(parent))
  port_set_identifier(port, id)
  port_set_dimensions(port, 3.0, 3.0)
  port_set_layout_option_string_by_id(port, "org.eclipse.elk.port.side", side)
  port_set_layout_option_string_by_id(
    port,
    "org.eclipse.elk.port.index",
    index.to_string(),
  )
  port
}

///|
fn issue143_and318_test_connect_ports(
  source : @graph.ElkPort,
  target : @graph.ElkPort,
  id : String,
) -> Unit {
  let edge = create_edge(None)
  edge_set_identifier(edge, id)
  edge_add_source(edge, make_port_shape(source))
  edge_add_target(edge, make_port_shape(target))
  update_containment(Some(edge))
}

///|
fn issue143_and318_test_build_issue143_graph() -> @graph.ElkNode {
  let graph = create_graph()
  @graph.node_set_string_property(
    graph, @core.algorithm, "org.eclipse.elk.layered",
  )
  @graph.node_set_string_property(graph, @core.edge_routing, "ORTHOGONAL")
  @graph.node_set_layout_option_string_by_id(
    graph, "org.eclipse.elk.layered.nodePlacement.strategy", "SIMPLE",
  )

  let n1 = @graph.create_node(Some(graph))
  @graph.node_set_identifier(n1, "n1")
  @graph.node_set_dimensions(n1, 40.0, 100.0)
  @graph.node_set_string_property(n1, @core.port_constraints, "FIXED_POS")
  let p1_1 = issue143_and318_test_create_fixed_pos_port(n1, "p1_1", 40.0, 33.0)
  let p1_2 = issue143_and318_test_create_fixed_pos_port(n1, "p1_2", 40.0, 42.0)

  let n2 = @graph.create_node(Some(graph))
  @graph.node_set_identifier(n2, "n2")
  @graph.node_set_dimensions(n2, 40.0, 40.0)
  @graph.node_set_string_property(n2, @core.port_constraints, "FIXED_POS")
  let p2_1 = issue143_and318_test_create_fixed_pos_port(n2, "p2_1", -3.0, 10.0)
  let p2_2 = issue143_and318_test_create_fixed_pos_port(n2, "p2_2", -3.0, 27.0)

  issue143_and318_test_connect_ports(p1_1, p2_1, "e1")
  issue143_and318_test_connect_ports(p1_2, p2_2, "e2")
  graph
}

///|
fn issue143_and318_test_build_issue318_graph() -> @graph.ElkNode {
  let graph = create_graph()
  @graph.node_set_string_property(
    graph, @core.algorithm, "org.eclipse.elk.layered",
  )
  @graph.node_set_string_property(graph, @core.edge_routing, "ORTHOGONAL")
  @graph.node_set_layout_option_string_by_id(
    graph, "org.eclipse.elk.layered.nodePlacement.strategy", "SIMPLE",
  )

  let n1 = @graph.create_node(Some(graph))
  @graph.node_set_identifier(n1, "n1")
  @graph.node_set_dimensions(n1, 40.0, 40.0)
  @graph.node_set_string_property(n1, @core.port_constraints, "FIXED_ORDER")
  let p1_1 = issue143_and318_test_create_ordered_port(n1, "p1_1", "EAST", 1)
  let p1_2 = issue143_and318_test_create_ordered_port(n1, "p1_2", "EAST", 2)

  let n2 = @graph.create_node(Some(graph))
  @graph.node_set_identifier(n2, "n2")
  @graph.node_set_dimensions(n2, 40.0, 40.0)
  @graph.node_set_string_property(n2, @core.port_constraints, "FIXED_ORDER")
  let p2_1 = issue143_and318_test_create_ordered_port(n2, "p2_1", "WEST", 2)
  let p2_2 = issue143_and318_test_create_ordered_port(n2, "p2_2", "WEST", 1)

  issue143_and318_test_connect_ports(p1_1, p2_2, "e1")
  issue143_and318_test_connect_ports(p1_2, p2_1, "e2")
  graph
}

///|
fn issue143_and318_test_collect_section_chain_points(
  section : @graph.ElkEdgeSection,
) -> Array[@core.KVector] {
  let points : Array[@core.KVector] = []
  let visited : Map[@graph.ElkEdgeSection, Unit] = {}
  let mut current = section
  points.push(
    @core.new_kvector_xy(
      @graph.edge_section_start_x(current),
      @graph.edge_section_start_y(current),
    ),
  )
  while true {
    points.push(
      @core.new_kvector_xy(
        @graph.edge_section_end_x(current),
        @graph.edge_section_end_y(current),
      ),
    )
    visited[current] = ()
    let outgoing = @graph.edge_section_outgoing_sections(current)
    if outgoing.is_empty() {
      break
    }
    let next = outgoing[0]
    if visited.contains(next) {
      break
    }
    current = next
  }
  points
}

///|
fn issue143_and318_test_absolute_node_position(
  node : @graph.ElkNode,
) -> @core.KVector {
  let absolute = @core.new_kvector_xy(@graph.node_x(node), @graph.node_y(node))
  match @graph.node_parent(node) {
    Some(parent) =>
      ignore(absolute.add(issue143_and318_test_absolute_node_position(parent)))
    None => ()
  }
  absolute
}

///|
fn issue143_and318_test_absolute_port_position(
  port : @graph.ElkPort,
) -> @core.KVector {
  match @graph.port_parent(port) {
    Some(parent_node) =>
      issue143_and318_test_absolute_node_position(parent_node).add_xy(
        port_x(port) + port_width(port) / 2.0,
        port_y(port) + port_height(port) / 2.0,
      )
    None =>
      @core.new_kvector_xy(
        port_x(port) + port_width(port) / 2.0,
        port_y(port) + port_height(port) / 2.0,
      )
  }
}

///|
fn issue143_and318_test_shape_anchor(
  shape : @graph.ElkConnectableShape,
) -> @core.KVector {
  match shape {
    NodeShape(node) =>
      issue143_and318_test_absolute_node_position(node).add_xy(
        @graph.node_width(node) / 2.0,
        @graph.node_height(node) / 2.0,
      )
    PortShape(port) => issue143_and318_test_absolute_port_position(port)
  }
}

///|
fn issue143_and318_test_gather_horizontal_segments(
  graph : @graph.ElkNode,
) -> Array[(Double, Double, Double)] {
  let tolerance = 0.01
  let horizontal_segments : Array[(Double, Double, Double)] = []

  for edge in @graph.node_contained_edges(graph) {
    let sections = @graph.edge_sections(edge)
    if sections.is_empty() {
      let sources = @graph.edge_sources(edge)
      let targets = @graph.edge_targets(edge)
      if sources.length() == 1 && targets.length() == 1 {
        let source_anchor = issue143_and318_test_shape_anchor(sources[0])
        let target_anchor = issue143_and318_test_shape_anchor(targets[0])
        if source_anchor.x < target_anchor.x {
          horizontal_segments.push(
            (source_anchor.x, source_anchor.y, target_anchor.x),
          )
        } else {
          horizontal_segments.push(
            (target_anchor.x, source_anchor.y, source_anchor.x),
          )
        }
      }
      continue
    }

    for edge_section in sections {
      let points = issue143_and318_test_collect_section_chain_points(
        edge_section,
      )
      for index = 1; index < points.length(); index = index + 1 {
        let prev_point = points[index - 1]
        let curr_point = points[index]
        if (prev_point.y - curr_point.y).abs() < tolerance {
          if prev_point.x < curr_point.x {
            horizontal_segments.push((prev_point.x, prev_point.y, curr_point.x))
          } else {
            horizontal_segments.push((curr_point.x, curr_point.y, prev_point.x))
          }
        }
      }
    }
  }

  horizontal_segments
}

///|
fn issue143_and318_test_intersect_horizontally(
  first : (Double, Double, Double),
  second : (Double, Double, Double),
) -> Bool {
  let (first_start, _, first_end) = first
  let (second_start, _, second_end) = second
  first_start < second_end && second_start < first_end
}

///|
fn issue143_and318_test_assert_no_close_edge_proximities(
  graph : @graph.ElkNode,
  context : String,
) -> Unit {
  issue143_and318_test_layout(graph)
  let horizontal_segments = issue143_and318_test_gather_horizontal_segments(
    graph,
  )
  if horizontal_segments.length() < 2 {
    abort("Issue143/318 \{context}: expected at least two horizontal segments.")
  }

  let proximity_threshold = 2.0
  for first_index = 0
      first_index < horizontal_segments.length()
      first_index = first_index + 1 {
    let first = horizontal_segments[first_index]
    for second_index = first_index + 1
        second_index < horizontal_segments.length()
        second_index = second_index + 1 {
      let second = horizontal_segments[second_index]
      if issue143_and318_test_intersect_horizontally(first, second) {
        let (_, first_y, _) = first
        let (_, second_y, _) = second
        if (first_y - second_y).abs() <= proximity_threshold {
          abort(
            "Issue143/318 \{context}: overlapping horizontal segments are too close (y1=\{first_y}, y2=\{second_y}, threshold=\{proximity_threshold}).",
          )
        }
      }
    }
  }
}

///|
test "Issue143 small vertical edge segment spacing keeps horizontal segments separated" {
  reset_graph_model_for_test()
  issue143_and318_test_setup_plain_java_layout()
  issue143_and318_test_assert_no_close_edge_proximities(
    issue143_and318_test_build_issue143_graph(),
    "issue143",
  )
}

///|
test "Issue318 overlapping horizontal edge segments stay beyond proximity threshold" {
  reset_graph_model_for_test()
  issue143_and318_test_setup_plain_java_layout()
  issue143_and318_test_assert_no_close_edge_proximities(
    issue143_and318_test_build_issue318_graph(),
    "issue318",
  )
}
