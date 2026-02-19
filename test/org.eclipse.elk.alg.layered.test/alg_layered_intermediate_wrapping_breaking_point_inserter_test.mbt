///|
fn breaking_point_inserter_test_node_type(name : String) -> NodeType {
  for node_type in node_type_values() {
    match node_type {
      NodeType::Normal => if name == "NORMAL" { return node_type }
      NodeType::LongEdge => if name == "LONG_EDGE" { return node_type }
      NodeType::ExternalPort => if name == "EXTERNAL_PORT" { return node_type }
      NodeType::NorthSouthPort =>
        if name == "NORTH_SOUTH_PORT" {
          return node_type
        }
      NodeType::LabelNode => if name == "LABEL_NODE" { return node_type }
      NodeType::BreakingPoint =>
        if name == "BREAKING_POINT" {
          return node_type
        }
      NodeType::Placeholder => if name == "PLACEHOLDER" { return node_type }
      NodeType::NonshiftingPlaceholder =>
        if name == "NONSHIFTING_PLACEHOLDER" {
          return node_type
        }
    }
  }
  abort("unknown node type")
}

///|
fn breaking_point_inserter_test_port_side(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown side")
}

///|
fn breaking_point_inserter_test_node_type_equals(
  left : NodeType,
  right : NodeType,
) -> Bool {
  match (left, right) {
    (NodeType::Normal, NodeType::Normal) => true
    (NodeType::LongEdge, NodeType::LongEdge) => true
    (NodeType::ExternalPort, NodeType::ExternalPort) => true
    (NodeType::NorthSouthPort, NodeType::NorthSouthPort) => true
    (NodeType::LabelNode, NodeType::LabelNode) => true
    (NodeType::BreakingPoint, NodeType::BreakingPoint) => true
    (NodeType::Placeholder, NodeType::Placeholder) => true
    (NodeType::NonshiftingPlaceholder, NodeType::NonshiftingPlaceholder) => true
    _ => false
  }
}

///|
fn breaking_point_inserter_test_add_port(node : LNode, side : String) -> LPort {
  let port = new_l_port()
  port.set_node(Some(node))
  port.set_side(breaking_point_inserter_test_port_side(side))
  port
}

///|
fn breaking_point_inserter_test_connect(
  source : LNode,
  target : LNode,
) -> LEdge {
  let source_port = breaking_point_inserter_test_add_port(source, "EAST")
  let target_port = breaking_point_inserter_test_add_port(target, "WEST")

  let edge = new_l_edge()
  edge.set_source(Some(source_port))
  edge.set_target(Some(target_port))
  edge
}

///|
fn breaking_point_inserter_test_new_path_graph(
  layer_count : Int,
) -> (LGraph, Array[Layer], Array[LNode], Array[LEdge]) {
  let graph = new_l_graph()
  let layers = []
  let nodes = []
  let edges = []

  for _ in 0..<layer_count {
    let layer = new_layer(graph)
    graph.get_layers().push(layer)
    layers.push(layer)

    let node = new_l_node(graph=Some(graph))
    node.set_layer(Some(layer))
    nodes.push(node)
  }

  for i in 0..<(layer_count - 1) {
    edges.push(breaking_point_inserter_test_connect(nodes[i], nodes[i + 1]))
  }

  (graph, layers, nodes, edges)
}

///|
test "breaking point inserter reports expected task name" {
  let processor = new_breaking_point_inserter_layout_processor()
  let monitor = new_elk_progress_monitor()
  let graph = new_l_graph()
  graph.get_layers().push(new_layer(graph))
  processor.process(graph, Some(monitor))
  inspect(monitor.get_task_name(), content="Breaking Point Insertion")
}

///|
test "breaking point inserter manual cut inserts breaking point dummies and keeps bp info consistent" {
  let (graph, _layers, nodes, edges) = breaking_point_inserter_test_new_path_graph(
    4,
  )
  graph.set_property_string(layered_options_wrapping_cutting_strategy, "MANUAL")
  graph.set_property_string(layered_options_wrapping_cutting_cuts, "[2]")
  graph.set_property_bool(
    layered_options_wrapping_multi_edge_improve_cuts, false,
  )
  graph.set_property_string(layered_options_wrapping_validify_strategy, "NO")

  let processor = new_breaking_point_inserter_layout_processor()
  processor.process(graph, None)

  assert_eq(graph.get_layers().length(), 6)

  let mut start_dummy : LNode? = None
  let mut end_dummy : LNode? = None
  let mut bp_count = 0
  for layer in graph.get_layers() {
    for node in layer.get_nodes() {
      if breaking_point_inserter_test_node_type_equals(
          node.get_type(),
          breaking_point_inserter_test_node_type("BREAKING_POINT"),
        ) {
        bp_count = bp_count + 1
        if bp_info_is_start(node) {
          start_dummy = Some(node)
        }
        if bp_info_is_end(node) {
          end_dummy = Some(node)
        }
      }
    }
  }
  assert_eq(bp_count, 2)

  let start = match start_dummy {
    Some(value) => value
    None => abort("missing breaking-point start dummy")
  }
  let end = match end_dummy {
    Some(value) => value
    None => abort("missing breaking-point end dummy")
  }

  let info = match
    start.get_property_bp_info(internal_properties_breaking_point_info) {
    Some(value) => value
    None => abort("missing BPInfo on start dummy")
  }
  assert_eq(info.start.get_handle(), start.get_handle())
  assert_eq(info.end.get_handle(), end.get_handle())
  assert_true(info.prev is None)
  assert_true(info.next is None)

  let cut_edge = edges[1]
  let cut_edge_source = match cut_edge.get_source() {
    Some(source_port) => source_port
    None => abort("cut edge has no source after insertion")
  }
  let cut_edge_source_node = match cut_edge_source.get_node() {
    Some(source_node) => source_node
    None => abort("cut edge source has no node")
  }
  assert_eq(cut_edge_source_node.get_handle(), end.get_handle())

  let start_layer_index = match start.get_layer() {
    Some(layer) => layer.get_index()
    None => abort("start dummy has no layer")
  }
  let end_layer_index = match end.get_layer() {
    Some(layer) => layer.get_index()
    None => abort("end dummy has no layer")
  }
  assert_eq(start_layer_index, 2)
  assert_eq(end_layer_index, 3)

  assert_eq(nodes.length(), 4)
}

///|
test "breaking point inserter links multi-cut chains through prev and next info pointers" {
  let graph = new_l_graph()
  let layers = []
  for _ in 0..<3 {
    let layer = new_layer(graph)
    graph.get_layers().push(layer)
    layers.push(layer)
  }

  let source = new_l_node(graph=Some(graph))
  source.set_layer(Some(layers[0]))
  let middle = new_l_node(graph=Some(graph))
  middle.set_layer(Some(layers[1]))
  let target = new_l_node(graph=Some(graph))
  target.set_layer(Some(layers[2]))

  ignore(middle)
  ignore(breaking_point_inserter_test_connect(source, target))

  graph.set_property_string(layered_options_wrapping_cutting_strategy, "MANUAL")
  graph.set_property_string(layered_options_wrapping_cutting_cuts, "[1, 2]")
  graph.set_property_bool(
    layered_options_wrapping_multi_edge_improve_cuts, false,
  )
  graph.set_property_string(layered_options_wrapping_validify_strategy, "NO")

  let processor = new_breaking_point_inserter_layout_processor()
  processor.process(graph, None)

  let starts = []
  for layer in graph.get_layers() {
    for node in layer.get_nodes() {
      if bp_info_is_start(node) {
        starts.push(node)
      }
    }
  }
  assert_eq(starts.length(), 2)

  let mut first_info : BPInfo? = None
  let mut second_info : BPInfo? = None
  for node in starts {
    let info = match
      node.get_property_bp_info(internal_properties_breaking_point_info) {
      Some(value) => value
      None => abort("missing BPInfo")
    }
    if info.prev is None {
      first_info = Some(info)
    } else {
      second_info = Some(info)
    }
  }

  let first = match first_info {
    Some(value) => value
    None => abort("missing first BPInfo")
  }
  let second = match second_info {
    Some(value) => value
    None => abort("missing second BPInfo")
  }

  assert_true(first.prev is None)
  assert_true(second.next is None)
  match first.next {
    Some(value) =>
      assert_eq(value.start.get_handle(), second.start.get_handle())
    None => abort("expected chained next BPInfo")
  }
  match second.prev {
    Some(value) => assert_eq(value.end.get_handle(), first.end.get_handle())
    None => abort("expected chained previous BPInfo")
  }
}
