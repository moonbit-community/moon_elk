///|
fn issue734_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue734_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
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
fn issue734_test_parse_model(content : String) -> ElkNode {
  let graph = new_elk_graph_parser().parse(content)
  node_set_string_property(graph, algorithm, "org.eclipse.elk.layered")
  graph
}

///|
fn issue734_test_build_flat_graph() -> ElkNode {
  issue734_test_parse_model(
    "node n1 {\n\tlayout[ size: 50, 50 ]\n\t\n\tportConstraints: FIXED_SIDE\n\t\n\tport in { ^port.side: WEST }\n\tport out { ^port.side: EAST }\n}\nnode n2 {\n\tlayout[ size: 50, 50 ]\n\t\n\tportConstraints: FIXED_SIDE\n\t\n\tport in { ^port.side: WEST }\n\tport out { ^port.side: EAST }\n}\n\nedge n1.out -> n2.in\nedge n2.out -> n1.in\n",
  )
}

///|
fn issue734_test_build_flat_more_complex_graph() -> ElkNode {
  issue734_test_parse_model(
    "layering.strategy: INTERACTIVE\ncycleBreaking.strategy: INTERACTIVE\n\nnode n1 {\n\tlayout[ size: 50, 50 position: 0, 0 ]\n\t\n\tportConstraints: FIXED_SIDE\n\t\n\tport in { ^port.side: WEST }\n\tport out { ^port.side: EAST }\n}\nnode n2 {\n\tlayout[ size: 50, 50 position: 100, 0 ]\n\t\n\tportConstraints: FIXED_SIDE\n\t\n\tport in { ^port.side: WEST }\n\tport out { ^port.side: EAST }\n}\nnode n3 {\n\tlayout[ size: 50, 50 position: 100, 0 ]\n\t\n\tportConstraints: FIXED_SIDE\n\t\n\tport in { ^port.side: WEST }\n}\n\nedge n1.out -> n2.in\nedge n1.out -> n3.in\nedge n2.out -> n1.in\n",
  )
}

///|
fn issue734_test_build_hierarchical_graph() -> ElkNode {
  let content = "hierarchyHandling: INCLUDE_CHILDREN\n\nnode n1\n{\n    node n1a\n}\nnode n2\n{\n}\nnode n3\n{\n    node n3a\n}\n\nedge n1 -> n2\nedge n2 -> n3\nedge n3.n3a -> n1.n1a\n"
  issue734_test_parse_model(content)
}

///|
fn issue734_test_compute_node_coordinate_span(
  nodes : Array[ElkNode],
) -> (Double, Double) {
  if nodes.is_empty() {
    return (0.0, 0.0)
  }

  let mut min = node_x(nodes[0])
  let mut max = node_x(nodes[0]) + node_width(nodes[0])
  for node in nodes {
    let left = node_x(node)
    let right = node_x(node) + node_width(node)
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
fn issue734_test_compute_node_origin_span(
  nodes : Array[ElkNode],
) -> (Double, Double) {
  if nodes.is_empty() {
    return (0.0, 0.0)
  }

  let mut min = node_x(nodes[0])
  let mut max = node_x(nodes[0])
  for node in nodes {
    let x = node_x(node)
    if x < min {
      min = x
    }
    if x > max {
      max = x
    }
  }
  (min, max)
}

///|
fn issue734_test_absolute_node_x(node : ElkNode) -> Double {
  let mut x = node_x(node)
  match node_parent(node) {
    Some(parent) => x = x + issue734_test_absolute_node_x(parent)
    None => ()
  }
  x
}

///|
fn issue734_test_absolute_port_x(port : ElkPort) -> Double {
  match port_parent(port) {
    Some(parent_node) =>
      issue734_test_absolute_node_x(parent_node) +
      port_x(port) +
      port_width(port) / 2.0
    None => port_x(port) + port_width(port) / 2.0
  }
}

///|
fn issue734_test_shape_anchor_x(shape : ElkConnectableShape) -> Double {
  match shape {
    NodeShape(node) =>
      issue734_test_absolute_node_x(node) + node_width(node) / 2.0
    PortShape(port) => issue734_test_absolute_port_x(port)
  }
}

///|
fn issue734_test_absolute_edge_x(edge : ElkEdge, x : Double) -> Double {
  match edge_containing_node(edge) {
    Some(containing_node) => issue734_test_absolute_node_x(containing_node) + x
    None => x
  }
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
  edges : Array[ElkEdge],
) -> (Double, Double) {
  let mut initialized = false
  let mut min = 0.0
  let mut max = 0.0

  for edge in edges {
    let mut edge_has_section_points = false
    for section in edge_sections(edge) {
      edge_has_section_points = true
      let visited : Map[ElkEdgeSection, Unit] = {}
      let mut current = section
      while true {
        let start_x = issue734_test_absolute_edge_x(
          edge,
          edge_section_start_x(current),
        )
        let end_x = issue734_test_absolute_edge_x(
          edge,
          edge_section_end_x(current),
        )
        let (min_after_start, max_after_start, initialized_after_start) = issue734_test_expand_span_x(
          start_x, min, max, initialized,
        )
        min = min_after_start
        max = max_after_start
        initialized = initialized_after_start
        let (min_after_end, max_after_end, initialized_after_end) = issue734_test_expand_span_x(
          end_x, min, max, initialized,
        )
        min = min_after_end
        max = max_after_end
        initialized = initialized_after_end
        visited[current] = ()
        let outgoing = edge_section_outgoing_sections(current)
        if outgoing.is_empty() {
          break
        }
        let next = outgoing[0]
        if visited.contains(next) {
          break
        }
        current = next
      }
    }
    if !edge_has_section_points {
      for source in edge_sources(edge) {
        let source_x = issue734_test_shape_anchor_x(source)
        let (next_min, next_max, next_initialized) = issue734_test_expand_span_x(
          source_x, min, max, initialized,
        )
        min = next_min
        max = next_max
        initialized = next_initialized
      }
      for target in edge_targets(edge) {
        let target_x = issue734_test_shape_anchor_x(target)
        let (next_min, next_max, next_initialized) = issue734_test_expand_span_x(
          target_x, min, max, initialized,
        )
        min = next_min
        max = next_max
        initialized = next_initialized
      }
    }
  }

  if !initialized {
    abort("Issue734 expected at least one edge coordinate point.")
  }
  (min, max)
}

///|
fn issue734_test_assert_center_alignment(
  graph : ElkNode,
  context : String,
  use_node_width_span : Bool,
) -> Unit {
  issue734_test_layout(graph)
  let children = node_children(graph)
  let edges = node_contained_edges(graph)
  if children.is_empty() || edges.is_empty() {
    abort("Issue734 \{context}: expected top-level nodes and edges.")
  }
  let (node_min, node_max) = if use_node_width_span {
    issue734_test_compute_node_coordinate_span(children)
  } else {
    issue734_test_compute_node_origin_span(children)
  }
  let (edge_min, edge_max) = issue734_test_compute_edge_coordinate_span(edges)
  let node_span_center = (node_min + node_max) / 2.0
  let edge_span_center = (edge_min + edge_max) / 2.0
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
    true,
  )
}

///|
test "Issue734 flat complex model keeps node and edge span centers aligned" {
  reset_graph_model_for_test()
  issue734_test_setup_plain_java_layout()
  issue734_test_assert_center_alignment(
    issue734_test_build_flat_more_complex_graph(),
    "flat_more_complex",
    true,
  )
}

///|
test "Issue734 hierarchical model keeps node and edge span centers aligned" {
  reset_graph_model_for_test()
  issue734_test_setup_plain_java_layout()
  issue734_test_assert_center_alignment(
    issue734_test_build_hierarchical_graph(),
    "hierarchical",
    true,
  )
}
