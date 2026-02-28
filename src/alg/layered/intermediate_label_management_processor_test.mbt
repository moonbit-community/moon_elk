///|
fn label_management_test_manager() -> @core.ILabelManager {
  new_i_label_manager((origin, target_width) => {
    match origin {
      "node-label" => Some(@core.new_kvector_xy(target_width + 1.0, 11.0))
      "port-label" => Some(@core.new_kvector_xy(target_width + 2.0, 12.0))
      "edge-label" => Some(@core.new_kvector_xy(target_width + 3.0, 13.0))
      "comment-label" => Some(@core.new_kvector_xy(target_width + 4.0, 14.0))
      "center-a" => Some(@core.new_kvector_xy(target_width - 10.0, 8.0))
      "center-b" => Some(@core.new_kvector_xy(target_width - 20.0, 6.0))
      "vertical-a" => Some(@core.new_kvector_xy(30.0, 7.0))
      "vertical-b" => Some(@core.new_kvector_xy(20.0, 9.0))
      _ => None
    }
  })
}

///|
fn label_management_test_node_type(name : String) -> NodeType {
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
fn label_management_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
test "label management processor reports task name and noops without manager" {
  let graph = new_l_graph()
  graph.set_property_string(@core.direction, "RIGHT")

  let label = new_l_label_text("node")
  label.set_origin_identifier(Some("node-label"))
  ignore(label.get_size().set_xy(12.0, 3.0))

  let layer = new_layer(graph)
  graph.get_layers().push(layer)
  let node = new_l_node(graph=Some(graph))
  node.set_type(label_management_test_node_type("NORMAL"))
  node.set_layer(Some(layer))
  node.get_labels().push(label)

  let processor = new_label_management_processor(false)
  let monitor = new_elk_progress_monitor()
  processor.process(graph, Some(monitor))

  inspect(monitor.get_task_name(), content="Label management")
  assert_eq(label.get_size().x, 12.0)
  assert_eq(label.get_size().y, 3.0)
}

///|
test "label management non-center mode manages node port edge and comment labels" {
  let graph = new_l_graph()
  graph.set_property_string(@core.direction, "RIGHT")
  graph.set_property_double(@core.spacing_label_label, 1.0)
  graph.set_property_i_label_manager(
    @core.label_management_options_label_manager,
    Some(label_management_test_manager()),
  )

  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let source = new_l_node(graph=Some(graph))
  source.set_type(label_management_test_node_type("NORMAL"))
  source.set_layer(Some(layer))
  let target = new_l_node(graph=Some(graph))
  target.set_type(label_management_test_node_type("NORMAL"))
  target.set_layer(Some(layer))

  let node_label = new_l_label_text("node")
  node_label.set_origin_identifier(Some("node-label"))
  source.get_labels().push(node_label)

  let source_port = new_l_port()
  source_port.set_side(label_management_test_port_side("EAST"))
  source_port.set_node(Some(source))
  let target_port = new_l_port()
  target_port.set_side(label_management_test_port_side("WEST"))
  target_port.set_node(Some(target))

  let port_label = new_l_label_text("port")
  port_label.set_origin_identifier(Some("port-label"))
  source_port.get_labels().push(port_label)

  let edge = new_l_edge()
  edge.set_source(Some(source_port))
  edge.set_target(Some(target_port))
  let edge_label = new_l_label_text("edge")
  edge_label.set_origin_identifier(Some("edge-label"))
  edge.get_labels().push(edge_label)

  let comment_node = new_l_node()
  let comment_label = new_l_label_text("comment")
  comment_label.set_origin_identifier(Some("comment-label"))
  comment_node.get_labels().push(comment_label)
  source.set_property_l_node_array(internal_properties_top_comments, [
    comment_node,
  ])

  let processor = new_label_management_processor(false)
  processor.process(graph, None)

  assert_eq(node_label.get_size().x, 41.0)
  assert_eq(port_label.get_size().x, 22.0)
  assert_eq(edge_label.get_size().x, 63.0)
  assert_eq(comment_label.get_size().x, 44.0)
}

///|
test "label management center mode manages represented labels and resizes dummy" {
  let graph = new_l_graph()
  graph.set_property_string(@core.direction, "RIGHT")
  graph.set_property_double(@core.spacing_edge_label, 2.0)
  graph.set_property_double(@core.spacing_label_label, 1.0)
  graph.set_property_i_label_manager(
    @core.label_management_options_label_manager,
    Some(label_management_test_manager()),
  )

  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let normal = new_l_node(graph=Some(graph))
  normal.set_type(label_management_test_node_type("NORMAL"))
  normal.set_layer(Some(layer))
  ignore(normal.get_size().set_xy(120.0, 0.0))

  let label_dummy = new_l_node(graph=Some(graph))
  label_dummy.set_type(label_management_test_node_type("LABEL_NODE"))
  label_dummy.set_layer(Some(layer))

  let normal_port = new_l_port()
  normal_port.set_side(label_management_test_port_side("EAST"))
  normal_port.set_node(Some(normal))
  let dummy_port = new_l_port()
  dummy_port.set_side(label_management_test_port_side("WEST"))
  dummy_port.set_node(Some(label_dummy))

  let edge = new_l_edge()
  edge.set_source(Some(normal_port))
  edge.set_target(Some(dummy_port))
  edge.set_property_double(@core.edge_thickness, 3.0)

  let represented_a = new_l_label_text("A")
  represented_a.set_origin_identifier(Some("center-a"))
  let represented_b = new_l_label_text("B")
  represented_b.set_origin_identifier(Some("center-b"))
  label_dummy.set_property_l_label_array(
    internal_properties_represented_labels,
    [represented_a, represented_b],
  )

  let processor = new_label_management_processor(true)
  processor.process(graph, None)

  assert_eq(represented_a.get_size().x, 110.0)
  assert_eq(represented_b.get_size().x, 100.0)
  assert_eq(label_dummy.get_size().x, 110.0)
  assert_eq(label_dummy.get_size().y, 20.0)
}

///|
test "label management do_manage_labels rotates sizes for vertical layouts" {
  let manager = label_management_test_manager()
  let label_a = new_l_label_text("vertical-a")
  label_a.set_origin_identifier(Some("vertical-a"))
  let label_b = new_l_label_text("vertical-b")
  label_b.set_origin_identifier(Some("vertical-b"))

  let required = label_management_processor_do_manage_labels(
    manager,
    [label_a, label_b],
    99.0,
    2.0,
    true,
  )

  assert_eq(label_a.get_size().x, 7.0)
  assert_eq(label_a.get_size().y, 30.0)
  assert_eq(label_b.get_size().x, 9.0)
  assert_eq(label_b.get_size().y, 20.0)
  assert_eq(required.x, 18.0)
  assert_eq(required.y, 30.0)
}
