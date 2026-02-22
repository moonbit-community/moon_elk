///|
fn issue734_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue734_test_layout(graph : @graph.ElkNode) -> Unit {
  for edge in @graph.node_contained_edges(graph) {
    let source_desc = match @graph.edge_sources(edge)[0] {
      NodeShape(node) => "node:" + @graph.node_identifier(node)
      PortShape(port) =>
        match @graph.port_parent(port) {
          Some(parent) =>
            "port:" +
            @graph.node_identifier(parent) +
            "." +
            @graph.port_identifier(port)
          None => "port:<none>"
        }
    }
    let target_desc = match @graph.edge_targets(edge)[0] {
      NodeShape(node) => "node:" + @graph.node_identifier(node)
      PortShape(port) =>
        match @graph.port_parent(port) {
          Some(parent) =>
            "port:" +
            @graph.node_identifier(parent) +
            "." +
            @graph.port_identifier(port)
          None => "port:<none>"
        }
    }
    println("Issue734 debug parsed edge: \{source_desc} -> \{target_desc}")
  }
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
}

///|
fn issue734_test_assert_close(
  actual : Double,
  expected : Double,
  epsilon : Double,
  context : String,
) -> Unit {
  if (actual - expected).abs() > epsilon {
    let message = "\{context}: expected=\{expected}, actual=\{actual}, epsilon=\{epsilon}"
    println(message)
    abort(message)
  }
}

///|
fn issue734_test_parse_model(content : String) -> @graph.ElkNode {
  let graph = new_elk_graph_parser().parse(content)
  @graph.node_set_string_property(
    graph, @core.algorithm, "org.eclipse.elk.layered",
  )
  graph
}

///|
fn issue734_test_build_flat_graph() -> @graph.ElkNode {
  issue734_test_parse_model(
    "node n1 {\n\tlayout[ size: 50, 50 ]\n\t\n\tportConstraints: FIXED_SIDE\n\t\n\tport in { ^port.side: WEST }\n\tport out { ^port.side: EAST }\n}\nnode n2 {\n\tlayout[ size: 50, 50 ]\n\t\n\tportConstraints: FIXED_SIDE\n\t\n\tport in { ^port.side: WEST }\n\tport out { ^port.side: EAST }\n}\n\nedge n1.out -> n2.in\nedge n2.out -> n1.in\n",
  )
}

///|
fn issue734_test_build_flat_more_complex_graph() -> @graph.ElkNode {
  issue734_test_parse_model(
    "layering.strategy: INTERACTIVE\ncycleBreaking.strategy: INTERACTIVE\n\nnode n1 {\n\tlayout[ size: 50, 50 position: 0, 0 ]\n\t\n\tportConstraints: FIXED_SIDE\n\t\n\tport in { ^port.side: WEST }\n\tport out { ^port.side: EAST }\n}\nnode n2 {\n\tlayout[ size: 50, 50 position: 100, 0 ]\n\t\n\tportConstraints: FIXED_SIDE\n\t\n\tport in { ^port.side: WEST }\n\tport out { ^port.side: EAST }\n}\nnode n3 {\n\tlayout[ size: 50, 50 position: 100, 0 ]\n\t\n\tportConstraints: FIXED_SIDE\n\t\n\tport in { ^port.side: WEST }\n}\n\nedge n1.out -> n2.in\nedge n1.out -> n3.in\nedge n2.out -> n1.in\n",
  )
}

///|
fn issue734_test_build_hierarchical_graph() -> @graph.ElkNode {
  let content = "hierarchyHandling: INCLUDE_CHILDREN\n\nnode n1\n{\n    node n1a\n}\nnode n2\n{\n}\nnode n3\n{\n    node n3a\n}\n\nedge n1 -> n2\nedge n2 -> n3\nedge n3.n3a -> n1.n1a\n"
  issue734_test_parse_model(content)
}

///|
fn issue734_test_compute_node_coordinate_span(
  nodes : Array[@graph.ElkNode],
) -> (Double, Double) {
  if nodes.is_empty() {
    return (0.0, 0.0)
  }

  let mut min = @graph.node_x(nodes[0])
  let mut max = @graph.node_x(nodes[0]) + @graph.node_width(nodes[0])
  for node in nodes {
    let left = @graph.node_x(node)
    let right = @graph.node_x(node) + @graph.node_width(node)
    if left < min {
      min = left
    }
    if right > max {
      max = right
    }
  }
  (min, max)
}

///|
fn issue734_test_expand_span_x(
  x : Double,
  min : Double,
  max : Double,
  initialized : Bool,
) -> (Double, Double, Bool) {
  if !initialized {
    return (x, x, true)
  }
  let mut next_min = min
  let mut next_max = max
  if x < next_min {
    next_min = x
  }
  if x > next_max {
    next_max = x
  }
  (next_min, next_max, true)
}

///|
fn issue734_test_compute_edge_coordinate_span(
  edges : Array[@graph.ElkEdge],
) -> (Double, Double) {
  let mut initialized = false
  let mut min = 0.0
  let mut max = 0.0

  for edge in edges {
    for section in @graph.edge_sections(edge) {
      let start_x = @graph.edge_section_start_x(section)
      let (min_after_start, max_after_start, initialized_after_start) = issue734_test_expand_span_x(
        start_x, min, max, initialized,
      )
      min = min_after_start
      max = max_after_start
      initialized = initialized_after_start

      for bend_point in @graph.edge_section_bend_points(section) {
        let bend_x = bend_point.get_x()
        let (next_min, next_max, next_initialized) = issue734_test_expand_span_x(
          bend_x, min, max, initialized,
        )
        min = next_min
        max = next_max
        initialized = next_initialized
      }

      let end_x = @graph.edge_section_end_x(section)
      let (min_after_end, max_after_end, initialized_after_end) = issue734_test_expand_span_x(
        end_x, min, max, initialized,
      )
      min = min_after_end
      max = max_after_end
      initialized = initialized_after_end
    }
  }

  if !initialized {
    abort("Issue734 expected at least one edge coordinate point.")
  }
  (min, max)
}

///|
fn issue734_test_assert_center_alignment(
  graph : @graph.ElkNode,
  context : String,
) -> Unit {
  issue734_test_layout(graph)
  let children = @graph.node_children(graph)
  let edges = @graph.node_contained_edges(graph)
  if children.is_empty() || edges.is_empty() {
    abort("Issue734 \{context}: expected top-level nodes and edges.")
  }
  let (node_min, node_max) = issue734_test_compute_node_coordinate_span(
    children,
  )
  let (edge_min, edge_max) = issue734_test_compute_edge_coordinate_span(edges)
  let node_span_center = (node_min + node_max) / 2.0
  let edge_span_center = (edge_min + edge_max) / 2.0
  println(
    "Issue734 debug \{context}: root=(\{@graph.node_x(graph)},\{@graph.node_y(graph)}), node_span=(\{node_min},\{node_max}), edge_span=(\{edge_min},\{edge_max})",
  )
  for child in children {
    println(
      "Issue734 debug node \{context}: id=\{@graph.node_identifier(child)} x=\{@graph.node_x(child)} y=\{@graph.node_y(child)} w=\{@graph.node_width(child)} h=\{@graph.node_height(child)}",
    )
  }
  for edge in edges {
    for section in @graph.edge_sections(edge) {
      println(
        "Issue734 debug section \{context}: start=\{@graph.edge_section_start_x(section)} end=\{@graph.edge_section_end_x(section)} bends=\{@graph.edge_section_bend_points(section).length()}",
      )
      for bend in @graph.edge_section_bend_points(section) {
        println(
          "Issue734 debug bend \{context}: x=\{bend.get_x()} y=\{bend.get_y()}",
        )
      }
    }
  }
  issue734_test_assert_close(
    edge_span_center,
    node_span_center,
    0.5,
    "Issue734 \{context} span_center",
  )
}

///|
test "Issue734 flat model keeps node and edge span centers aligned" {
  reset_graph_model_for_test()
  issue734_test_setup_plain_java_layout()
  issue734_test_assert_center_alignment(
    issue734_test_build_flat_graph(),
    "flat",
  )
}

///|
test "Issue734 flat complex model keeps node and edge span centers aligned" {
  reset_graph_model_for_test()
  issue734_test_setup_plain_java_layout()
  issue734_test_assert_center_alignment(
    issue734_test_build_flat_more_complex_graph(),
    "flat_more_complex",
  )
}

///|
test "Issue734 hierarchical model keeps node and edge span centers aligned" {
  reset_graph_model_for_test()
  issue734_test_setup_plain_java_layout()
  issue734_test_assert_center_alignment(
    issue734_test_build_hierarchical_graph(),
    "hierarchical",
  )
}
