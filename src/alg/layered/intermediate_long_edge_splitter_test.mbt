///|
fn long_edge_splitter_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn long_edge_splitter_test_node_type(name : String) -> NodeType {
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
fn long_edge_splitter_test_node_type_equals(
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
fn long_edge_splitter_test_new_node(graph : LGraph, layer : Layer) -> LNode {
  let node = new_l_node(graph=Some(graph))
  node.set_layer(Some(layer))
  node
}

///|
fn long_edge_splitter_test_new_port(
  node : LNode,
  side : @core.PortSide,
) -> LPort {
  let port = new_l_port()
  port.set_side(side)
  port.set_node(Some(node))
  port
}

///|
fn long_edge_splitter_test_new_edge(source : LPort, target : LPort) -> LEdge {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
  edge
}

///|
fn long_edge_splitter_test_require_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source")
  }
}

///|
fn long_edge_splitter_test_require_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target")
  }
}

///|
fn long_edge_splitter_test_require_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(value) => value
    None => abort("port has no owner node")
  }
}

///|
fn long_edge_splitter_test_require_layer(node : LNode) -> Layer {
  match node.get_layer() {
    Some(value) => value
    None => abort("node has no layer")
  }
}

///|
test "long edge splitter reports expected task name" {
  let processor = new_long_edge_splitter_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Edge splitting")
}

///|
test "long edge splitter makes all edges connect adjacent forward layers" {
  let graph = new_l_graph()
  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  let layer2 = new_layer(graph)
  let layer3 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)
  graph.get_layers().push(layer2)
  graph.get_layers().push(layer3)

  let source = long_edge_splitter_test_new_node(graph, layer0)
  let target = long_edge_splitter_test_new_node(graph, layer3)

  let source_out = long_edge_splitter_test_new_port(
    source,
    long_edge_splitter_test_port_side("EAST"),
  )
  let target_in = long_edge_splitter_test_new_port(
    target,
    long_edge_splitter_test_port_side("WEST"),
  )
  ignore(long_edge_splitter_test_new_edge(source_out, target_in))

  let processor = new_long_edge_splitter_layout_processor()
  processor.process(graph, None)

  let layers = graph.get_layers()
  let mut next_id = 0
  for layer in layers {
    layer.set_id(next_id)
    next_id = next_id + 1
  }

  for layer in layers {
    for node in layer.get_nodes() {
      for edge in node.get_outgoing_edges() {
        let source_layer = long_edge_splitter_test_require_layer(node)
        let target_layer = long_edge_splitter_test_require_layer(
          long_edge_splitter_test_require_node(
            long_edge_splitter_test_require_target(edge),
          ),
        )
        assert_true(source_layer.get_id() < target_layer.get_id())
        assert_eq(source_layer.get_id() + 1, target_layer.get_id())
      }
    }
  }

  assert_eq(layer1.get_nodes().length(), 1)
  assert_eq(layer2.get_nodes().length(), 1)
  assert_true(
    long_edge_splitter_test_node_type_equals(
      layer1.get_nodes()[0].get_type(),
      long_edge_splitter_test_node_type("LONG_EDGE"),
    ),
  )
  assert_true(
    long_edge_splitter_test_node_type_equals(
      layer2.get_nodes()[0].get_type(),
      long_edge_splitter_test_node_type("LONG_EDGE"),
    ),
  )
}

///|
test "long edge splitter split_edge reroutes edge and moves head labels" {
  let graph = new_l_graph()
  let source = new_l_node(graph=Some(graph))
  let target = new_l_node(graph=Some(graph))
  let source_out = long_edge_splitter_test_new_port(
    source,
    long_edge_splitter_test_port_side("EAST"),
  )
  let target_in = long_edge_splitter_test_new_port(
    target,
    long_edge_splitter_test_port_side("WEST"),
  )
  let edge = long_edge_splitter_test_new_edge(source_out, target_in)
  edge.set_property_double(@core.edge_thickness, -2.0)

  let head_label = new_l_label_text("head")
  head_label.set_property_string(@core.edge_labels_placement, "HEAD")
  let center_label = new_l_label_text("center")
  center_label.set_property_string(@core.edge_labels_placement, "CENTER")
  edge.get_labels().push(head_label)
  edge.get_labels().push(center_label)

  let dummy = new_l_node(graph=Some(graph))
  let dummy_edge = long_edge_splitter_split_edge(edge, dummy)

  let old_target_node = long_edge_splitter_test_require_node(
    long_edge_splitter_test_require_target(edge),
  )
  assert_eq(old_target_node.get_handle(), dummy.get_handle())

  let dummy_edge_source_node = long_edge_splitter_test_require_node(
    long_edge_splitter_test_require_source(dummy_edge),
  )
  let dummy_edge_target_node = long_edge_splitter_test_require_node(
    long_edge_splitter_test_require_target(dummy_edge),
  )
  assert_eq(dummy_edge_source_node.get_handle(), dummy.get_handle())
  assert_eq(dummy_edge_target_node.get_handle(), target.get_handle())

  assert_eq(edge.get_labels().length(), 1)
  assert_eq(edge.get_labels()[0].get_text(), "center")
  assert_eq(dummy_edge.get_labels().length(), 1)
  assert_eq(dummy_edge.get_labels()[0].get_text(), "head")

  let moved_head = dummy_edge.get_labels()[0]
  assert_true(
    moved_head.has_property_l_edge(internal_properties_end_label_edge),
  )
  match moved_head.get_property_l_edge(internal_properties_end_label_edge) {
    Some(value) => assert_eq(value.get_handle(), edge.get_handle())
    None => abort("END_LABEL_EDGE should point to original edge")
  }

  assert_eq(edge.get_property_double(@core.edge_thickness), 0.0)
  assert_eq(dummy.get_size().y, 0.0)
}

///|
test "long edge splitter split_edge copies long-edge source and target from label dummy" {
  let graph = new_l_graph()

  let origin_source_node = new_l_node(graph=Some(graph))
  let origin_target_node = new_l_node(graph=Some(graph))
  let origin_source = long_edge_splitter_test_new_port(
    origin_source_node,
    long_edge_splitter_test_port_side("EAST"),
  )
  let origin_target = long_edge_splitter_test_new_port(
    origin_target_node,
    long_edge_splitter_test_port_side("WEST"),
  )

  let label_dummy = new_l_node(graph=Some(graph))
  label_dummy.set_type(long_edge_splitter_test_node_type("LABEL_NODE"))
  label_dummy.set_property_l_port(
    internal_properties_long_edge_source,
    Some(origin_source),
  )
  label_dummy.set_property_l_port(
    internal_properties_long_edge_target,
    Some(origin_target),
  )

  let label_dummy_out = long_edge_splitter_test_new_port(
    label_dummy,
    long_edge_splitter_test_port_side("EAST"),
  )
  let real_target_node = new_l_node(graph=Some(graph))
  let real_target_in = long_edge_splitter_test_new_port(
    real_target_node,
    long_edge_splitter_test_port_side("WEST"),
  )
  let edge = long_edge_splitter_test_new_edge(label_dummy_out, real_target_in)

  let dummy = new_l_node(graph=Some(graph))
  ignore(long_edge_splitter_split_edge(edge, dummy))

  match dummy.get_property_l_port(internal_properties_long_edge_source) {
    Some(value) => assert_eq(value.get_handle(), origin_source.get_handle())
    None => abort("LONG_EDGE_SOURCE must be copied from label dummy")
  }
  match dummy.get_property_l_port(internal_properties_long_edge_target) {
    Some(value) => assert_eq(value.get_handle(), origin_target.get_handle())
    None => abort("LONG_EDGE_TARGET must be copied from label dummy")
  }
  assert_true(
    dummy.get_property_bool(internal_properties_long_edge_has_label_dummies),
  )
}
