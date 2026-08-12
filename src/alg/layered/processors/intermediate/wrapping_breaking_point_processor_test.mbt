///|
fn breaking_point_processor_test_node_type(name : String) -> @runtime.NodeType {
  for node_type in @runtime.node_type_values() {
    match node_type {
      Normal => if name == "NORMAL" { return node_type }
      LongEdge => if name == "LONG_EDGE" { return node_type }
      ExternalPort => if name == "EXTERNAL_PORT" { return node_type }
      NorthSouthPort => if name == "NORTH_SOUTH_PORT" { return node_type }
      LabelNode => if name == "LABEL_NODE" { return node_type }
      BreakingPoint => if name == "BREAKING_POINT" { return node_type }
      Placeholder => if name == "PLACEHOLDER" { return node_type }
      NonshiftingPlaceholder =>
        if name == "NONSHIFTING_PLACEHOLDER" {
          return node_type
        }
    }
  }
  abort("unknown node type")
}

///|
fn breaking_point_processor_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown side")
}

///|
fn breaking_point_processor_test_node_type_equals(
  left : @runtime.NodeType,
  right : @runtime.NodeType,
) -> Bool {
  match (left, right) {
    (Normal, Normal) => true
    (LongEdge, LongEdge) => true
    (ExternalPort, ExternalPort) => true
    (NorthSouthPort, NorthSouthPort) => true
    (LabelNode, LabelNode) => true
    (BreakingPoint, BreakingPoint) => true
    (Placeholder, Placeholder) => true
    (NonshiftingPlaceholder, NonshiftingPlaceholder) => true
    _ => false
  }
}

///|
fn breaking_point_processor_test_add_port(
  node : @runtime.LNode,
  side : String,
) -> @runtime.LPort {
  let port = @runtime.new_l_port()
  port.set_node(Some(node))
  port.set_side(breaking_point_processor_test_port_side(side))
  port
}

///|
fn breaking_point_processor_test_connect(
  source : @runtime.LNode,
  target : @runtime.LNode,
) -> @runtime.LEdge {
  let source_port = breaking_point_processor_test_add_port(source, "EAST")
  let target_port = breaking_point_processor_test_add_port(target, "WEST")
  let edge = @runtime.new_l_edge()
  edge.set_source(Some(source_port))
  edge.set_target(Some(target_port))
  edge
}

///|
fn breaking_point_processor_test_new_graph() -> (
  @runtime.LayeredRunState,
  @runtime.LGraph,
) raise {
  let state = @runtime.new_layered_run_state()
  let graph = @runtime.new_l_graph()
  let layers = []
  let nodes = []

  for _ in 0..<4 {
    let layer = @runtime.new_layer(graph)
    graph.get_layers().push(layer)
    layers.push(layer)

    let node = @runtime.new_l_node(graph=Some(graph))
    node.set_layer(Some(layer))
    nodes.push(node)
  }

  for i in 0..<3 {
    ignore(breaking_point_processor_test_connect(nodes[i], nodes[i + 1]))
  }

  graph.set_property_string(
    @options.layered_options_wrapping_cutting_strategy, "MANUAL",
  )
  graph.set_property_string(
    @options.layered_options_wrapping_cutting_cuts, "[2]",
  )
  graph.set_property_bool(
    @options.layered_options_wrapping_multi_edge_improve_cuts, false,
  )
  graph.set_property_string(
    @options.layered_options_wrapping_validify_strategy, "NO",
  )
  graph.set_property_bool(
    @options.layered_options_wrapping_multi_edge_improve_wrapped_edges, false,
  )

  let inserter = new_breaking_point_inserter_layout_processor(state~)
  inserter.process(graph, None)

  (state, graph)
}

///|
test "breaking point processor reports expected task name" {
  let processor = new_breaking_point_processor_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(@runtime.new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Breaking Point Processor")
}

///|
test "breaking point processor wraps layers and creates in-layer dummy metadata" {
  let (state, graph) = breaking_point_processor_test_new_graph()

  let mut start_dummy : @runtime.LNode? = None
  let mut end_dummy : @runtime.LNode? = None
  for layer in graph.get_layers() {
    for node in layer.get_nodes() {
      if bp_info_is_start(state, node) {
        start_dummy = Some(node)
      }
      if bp_info_is_end(state, node) {
        end_dummy = Some(node)
      }
    }
  }
  let start = match start_dummy {
    Some(value) => value
    None => abort("missing breaking-point start dummy")
  }
  let end = match end_dummy {
    Some(value) => value
    None => abort("missing breaking-point end dummy")
  }

  let processor = new_breaking_point_processor_layout_processor(state~)
  processor.process(graph, None)

  assert_true(graph.get_property_bool(@runtime.internal_properties_cyclic))

  let info = match state.get_breaking_point(start) {
    Some(value) => value
    None => abort("missing BPInfo after wrapping")
  }
  assert_true(info.start_in_layer_dummy is Some(_))
  assert_true(info.start_in_layer_edge is Some(_))
  assert_true(info.end_in_layer_dummy is Some(_))
  assert_true(info.end_in_layer_edge is Some(_))

  let mut long_edge_dummy_count = 0
  for layer in graph.get_layers() {
    for node in layer.get_nodes() {
      if breaking_point_processor_test_node_type_equals(
          node.get_type(),
          breaking_point_processor_test_node_type("LONG_EDGE"),
        ) {
        long_edge_dummy_count = long_edge_dummy_count + 1
      }
    }
  }
  assert_true(long_edge_dummy_count > 0)

  assert_true(start.get_layer() is Some(_))
  assert_true(end.get_layer() is Some(_))
}
