///|
fn label_side_selector_test_strategy(
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
fn label_side_selector_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn label_side_selector_test_node_type(name : String) -> NodeType {
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
fn label_side_selector_test_node_type_is_label(node_type : NodeType) -> Bool {
  match node_type {
    NodeType::LabelNode => true
    _ => false
  }
}

///|
test "label side selector reports expected task name" {
  let graph = new_l_graph()
  graph.set_property_string(
    layered_options_edge_labels_side_selection, "ALWAYS_UP",
  )
  let processor = new_label_side_selector_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(graph, Some(monitor))
  inspect(monitor.get_task_name(), content="Label side selection (ALWAYS_UP)")
}

///|
test "label side selector always up places edge labels and label dummies above" {
  let graph = new_l_graph()
  graph.set_property_string(
    layered_options_edge_labels_side_selection, "ALWAYS_UP",
  )

  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  let layer2 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)
  graph.get_layers().push(layer2)

  let source = new_l_node(graph=Some(graph))
  source.set_layer(Some(layer0))
  let label_dummy = new_l_node(graph=Some(graph))
  label_dummy.set_type(label_side_selector_test_node_type("LABEL_NODE"))
  label_dummy.set_layer(Some(layer1))
  ignore(label_dummy.get_size().set_xy(10.0, 12.0))
  let target = new_l_node(graph=Some(graph))
  target.set_layer(Some(layer2))

  let source_out = new_l_port()
  source_out.set_side(label_side_selector_test_port_side("EAST"))
  source_out.set_node(Some(source))
  let dummy_in = new_l_port()
  dummy_in.set_side(label_side_selector_test_port_side("WEST"))
  dummy_in.set_node(Some(label_dummy))
  let dummy_out = new_l_port()
  dummy_out.set_side(label_side_selector_test_port_side("EAST"))
  dummy_out.set_node(Some(label_dummy))
  let target_in = new_l_port()
  target_in.set_side(label_side_selector_test_port_side("WEST"))
  target_in.set_node(Some(target))

  let origin_edge = new_l_edge()
  origin_edge.set_source(Some(source_out))
  origin_edge.set_target(Some(dummy_in))
  origin_edge.set_property_double(@core.edge_thickness, 3.0)

  let trailing_edge = new_l_edge()
  trailing_edge.set_source(Some(dummy_out))
  trailing_edge.set_target(Some(target_in))

  let edge_label = new_l_label_text("tail")
  edge_label.set_property_string(@core.edge_labels_placement, "TAIL")
  origin_edge.get_labels().push(edge_label)

  label_dummy.set_property_l_edge(
    internal_properties_origin_l_edge,
    Some(origin_edge),
  )

  let processor = new_label_side_selector_layout_processor()
  processor.process(graph, None)

  assert_eq(
    label_side_to_string(
      edge_label.get_property_label_side(internal_properties_label_side),
    ),
    "ABOVE",
  )
  assert_eq(
    label_side_to_string(
      label_dummy.get_property_label_side(internal_properties_label_side),
    ),
    "ABOVE",
  )
  assert_eq(dummy_in.get_position().y, 10.0)
  assert_eq(dummy_out.get_position().y, 10.0)
  assert_eq(trailing_edge.get_labels().length(), 0)
}

///|
test "label side selector @core.direction up mirrors reversed edges" {
  let graph = new_l_graph()
  graph.set_property_string(
    layered_options_edge_labels_side_selection, "DIRECTION_UP",
  )

  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)

  let source = new_l_node(graph=Some(graph))
  source.set_layer(Some(layer0))
  let target = new_l_node(graph=Some(graph))
  target.set_layer(Some(layer1))

  let source_out0 = new_l_port()
  source_out0.set_side(label_side_selector_test_port_side("EAST"))
  source_out0.set_node(Some(source))
  let target_in0 = new_l_port()
  target_in0.set_side(label_side_selector_test_port_side("WEST"))
  target_in0.set_node(Some(target))
  let edge0 = new_l_edge()
  edge0.set_source(Some(source_out0))
  edge0.set_target(Some(target_in0))
  let label0 = new_l_label_text("forward")
  edge0.get_labels().push(label0)

  let source_out1 = new_l_port()
  source_out1.set_side(label_side_selector_test_port_side("EAST"))
  source_out1.set_node(Some(source))
  let target_in1 = new_l_port()
  target_in1.set_side(label_side_selector_test_port_side("WEST"))
  target_in1.set_node(Some(target))
  let edge1 = new_l_edge()
  edge1.set_source(Some(source_out1))
  edge1.set_target(Some(target_in1))
  edge1.set_property_bool(internal_properties_reversed, true)
  let label1 = new_l_label_text("reversed")
  edge1.get_labels().push(label1)

  let processor = new_label_side_selector_layout_processor()
  processor.process(graph, None)

  assert_eq(
    label_side_to_string(
      label0.get_property_label_side(internal_properties_label_side),
    ),
    "ABOVE",
  )
  assert_eq(
    label_side_to_string(
      label1.get_property_label_side(internal_properties_label_side),
    ),
    "BELOW",
  )
}

///|
test "label side selector smart mode handles top label dummy and east end labels" {
  let graph = new_l_graph()
  graph.set_property_string(
    layered_options_edge_labels_side_selection, "SMART_DOWN",
  )

  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)

  let label_dummy = new_l_node(graph=Some(graph))
  label_dummy.set_type(label_side_selector_test_node_type("LABEL_NODE"))
  label_dummy.set_layer(Some(layer0))
  ignore(label_dummy.get_size().set_xy(6.0, 8.0))

  let dummy_in = new_l_port()
  dummy_in.set_side(label_side_selector_test_port_side("WEST"))
  dummy_in.set_node(Some(label_dummy))
  let dummy_out = new_l_port()
  dummy_out.set_side(label_side_selector_test_port_side("EAST"))
  dummy_out.set_node(Some(label_dummy))

  let dummy_src = new_l_node(graph=Some(graph))
  dummy_src.set_layer(Some(layer0))
  let dummy_src_out = new_l_port()
  dummy_src_out.set_side(label_side_selector_test_port_side("EAST"))
  dummy_src_out.set_node(Some(dummy_src))
  let dummy_tgt = new_l_node(graph=Some(graph))
  dummy_tgt.set_layer(Some(layer1))
  let dummy_tgt_in = new_l_port()
  dummy_tgt_in.set_side(label_side_selector_test_port_side("WEST"))
  dummy_tgt_in.set_node(Some(dummy_tgt))
  let dummy_origin_edge = new_l_edge()
  dummy_origin_edge.set_source(Some(dummy_src_out))
  dummy_origin_edge.set_target(Some(dummy_in))
  dummy_origin_edge.set_property_double(@core.edge_thickness, 2.0)
  let dummy_out_edge = new_l_edge()
  dummy_out_edge.set_source(Some(dummy_out))
  dummy_out_edge.set_target(Some(dummy_tgt_in))
  label_dummy.set_property_l_edge(
    internal_properties_origin_l_edge,
    Some(dummy_origin_edge),
  )

  let regular = new_l_node(graph=Some(graph))
  regular.set_layer(Some(layer0))

  let east0 = new_l_port()
  east0.set_side(label_side_selector_test_port_side("EAST"))
  east0.set_node(Some(regular))
  let east1 = new_l_port()
  east1.set_side(label_side_selector_test_port_side("EAST"))
  east1.set_node(Some(regular))

  let t0 = new_l_node(graph=Some(graph))
  t0.set_layer(Some(layer1))
  let t0_in = new_l_port()
  t0_in.set_side(label_side_selector_test_port_side("WEST"))
  t0_in.set_node(Some(t0))
  let e0 = new_l_edge()
  e0.set_source(Some(east0))
  e0.set_target(Some(t0_in))
  let l0 = new_l_label_text("tail0")
  l0.set_property_string(@core.edge_labels_placement, "TAIL")
  e0.get_labels().push(l0)

  let t1 = new_l_node(graph=Some(graph))
  t1.set_layer(Some(layer1))
  let t1_in = new_l_port()
  t1_in.set_side(label_side_selector_test_port_side("WEST"))
  t1_in.set_node(Some(t1))
  let e1 = new_l_edge()
  e1.set_source(Some(east1))
  e1.set_target(Some(t1_in))
  let l1 = new_l_label_text("tail1")
  l1.set_property_string(@core.edge_labels_placement, "TAIL")
  e1.get_labels().push(l1)

  let processor = new_label_side_selector_layout_processor()
  processor.process(graph, None)

  assert_eq(
    label_side_to_string(
      label_dummy.get_property_label_side(internal_properties_label_side),
    ),
    "ABOVE",
  )
  assert_eq(
    label_side_to_string(
      l0.get_property_label_side(internal_properties_label_side),
    ),
    "ABOVE",
  )
  assert_eq(
    label_side_to_string(
      l1.get_property_label_side(internal_properties_label_side),
    ),
    "BELOW",
  )
  assert_true(
    label_side_selector_test_node_type_is_label(label_dummy.get_type()),
  )
  assert_eq(dummy_out_edge.get_labels().length(), 0)
}

///|
test "label side selector strategy creates concrete processor" {
  let factory = layered_intermediate_processor_factory(
    label_side_selector_test_strategy("LABEL_SIDE_SELECTOR"),
  )
  let processor = factory.create()
  let graph = new_l_graph()
  graph.set_property_string(
    layered_options_edge_labels_side_selection, "ALWAYS_DOWN",
  )
  let monitor = new_elk_progress_monitor()
  processor.process(graph, Some(monitor))
  inspect(monitor.get_task_name(), content="Label side selection (ALWAYS_DOWN)")
}
