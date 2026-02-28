///|
fn label_dummy_inserter_test_strategy(
  name : String,
) -> IntermediateProcessorStrategy {
  for strategy in intermediate_processor_strategy_values() {
    if intermediate_processor_strategy_to_string(strategy) == name {
      return strategy
    }
  }
  abort("unknown strategy")
}

///|
fn label_dummy_inserter_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn label_dummy_inserter_test_node_type_is_label(node_type : NodeType) -> Bool {
  match node_type {
    NodeType::LabelNode => true
    _ => false
  }
}

///|
fn label_dummy_inserter_test_require_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target")
  }
}

///|
fn label_dummy_inserter_test_require_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source")
  }
}

///|
fn label_dummy_inserter_test_require_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(value) => value
    None => abort("port has no owner node")
  }
}

///|
fn label_dummy_inserter_test_find_label_dummy(graph : LGraph) -> LNode {
  for node in graph.get_layerless_nodes() {
    if label_dummy_inserter_test_node_type_is_label(node.get_type()) {
      return node
    }
  }
  abort("label dummy not found")
}

///|
test "label dummy inserter reports expected task name" {
  let processor = new_label_dummy_inserter_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Label dummy insertions")
}

///|
test "label dummy inserter creates one dummy for center labels and splits edge" {
  let graph = new_l_graph()
  graph.set_property_double(@core.spacing_edge_label, 5.0)
  graph.set_property_double(@core.spacing_label_label, 2.0)
  graph.set_property_string(@core.direction, "RIGHT")

  let source = new_l_node(graph=Some(graph))
  let target = new_l_node(graph=Some(graph))
  graph.get_layerless_nodes().push(source)
  graph.get_layerless_nodes().push(target)

  let source_out = new_l_port()
  source_out.set_side(label_dummy_inserter_test_port_side("EAST"))
  source_out.set_node(Some(source))

  let target_in = new_l_port()
  target_in.set_side(label_dummy_inserter_test_port_side("WEST"))
  target_in.set_node(Some(target))

  let edge = new_l_edge()
  edge.set_source(Some(source_out))
  edge.set_target(Some(target_in))
  edge.set_property_double(@core.edge_thickness, -3.0)

  let center_label = new_l_label_text("center")
  center_label.set_property_string(@core.edge_labels_placement, "CENTER")
  ignore(center_label.get_size().set_xy(10.0, 4.0))
  let head_label = new_l_label_text("head")
  head_label.set_property_string(@core.edge_labels_placement, "HEAD")
  ignore(head_label.get_size().set_xy(6.0, 2.0))
  edge.get_labels().push(center_label)
  edge.get_labels().push(head_label)

  let processor = new_label_dummy_inserter_layout_processor()
  processor.process(graph, None)

  assert_eq(graph.get_layerless_nodes().length(), 3)
  let dummy = label_dummy_inserter_test_find_label_dummy(graph)

  assert_eq(edge.get_property_double(@core.edge_thickness), 0.0)
  assert_eq(dummy.get_size().x, 10.0)
  assert_eq(dummy.get_size().y, 9.0)

  let represented = dummy.get_property_l_label_array(
    internal_properties_represented_labels,
  )
  assert_eq(represented.length(), 1)
  assert_eq(represented[0].get_text(), "center")
  assert_eq(edge.get_labels().length(), 0)

  let edge_target_node = label_dummy_inserter_test_require_node(
    label_dummy_inserter_test_require_target(edge),
  )
  assert_eq(edge_target_node.get_handle(), dummy.get_handle())

  assert_eq(dummy.get_ports().length(), 2)
  for port in dummy.get_ports() {
    assert_eq(port.get_position().y, 0.0)
  }

  let mut has_edge_to_target = false
  let mut edge_to_target : LEdge? = None
  for out_edge in dummy.get_outgoing_edges() {
    let out_target_node = label_dummy_inserter_test_require_node(
      label_dummy_inserter_test_require_target(out_edge),
    )
    if out_target_node.get_handle() == target.get_handle() {
      has_edge_to_target = true
      edge_to_target = Some(out_edge)
      break
    }
  }
  assert_true(has_edge_to_target)
  match edge_to_target {
    Some(value) => {
      assert_eq(value.get_labels().length(), 1)
      assert_eq(value.get_labels()[0].get_text(), "head")
    }
    None => abort("missing dummy edge to original target")
  }
}

///|
test "label dummy inserter ignores self loops" {
  let graph = new_l_graph()
  graph.set_property_string(@core.direction, "RIGHT")

  let node = new_l_node(graph=Some(graph))
  graph.get_layerless_nodes().push(node)

  let source_out = new_l_port()
  source_out.set_side(label_dummy_inserter_test_port_side("EAST"))
  source_out.set_node(Some(node))

  let target_in = new_l_port()
  target_in.set_side(label_dummy_inserter_test_port_side("WEST"))
  target_in.set_node(Some(node))

  let edge = new_l_edge()
  edge.set_source(Some(source_out))
  edge.set_target(Some(target_in))

  let center_label = new_l_label_text("center")
  center_label.set_property_string(@core.edge_labels_placement, "CENTER")
  edge.get_labels().push(center_label)

  let processor = new_label_dummy_inserter_layout_processor()
  processor.process(graph, None)

  assert_eq(graph.get_layerless_nodes().length(), 1)
  assert_eq(edge.get_labels().length(), 1)
  assert_eq(
    label_dummy_inserter_test_require_node(
      label_dummy_inserter_test_require_source(edge),
    ).get_handle(),
    node.get_handle(),
  )
  assert_eq(
    label_dummy_inserter_test_require_node(
      label_dummy_inserter_test_require_target(edge),
    ).get_handle(),
    node.get_handle(),
  )
}

///|
test "label dummy inserter strategy creates concrete processor" {
  let factory = layered_intermediate_processor_factory(
    label_dummy_inserter_test_strategy("LABEL_DUMMY_INSERTER"),
  )
  let processor = factory.create()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Label dummy insertions")
}
