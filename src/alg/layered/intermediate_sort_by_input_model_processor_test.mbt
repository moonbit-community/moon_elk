///|
fn sort_by_input_model_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn sort_by_input_model_test_node_type(name : String) -> NodeType {
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
fn sort_by_input_model_test_new_node(
  graph : LGraph,
  layer : Layer,
  model_order : Int,
) -> LNode {
  let node = new_l_node(graph=Some(graph))
  node.set_layer(Some(layer))
  node.set_property_int(internal_properties_model_order, model_order)
  node.set_property_string(@core.port_constraints, "FIXED_SIDE")
  node
}

///|
fn sort_by_input_model_test_new_port(node : LNode, side : String) -> LPort {
  let port = new_l_port()
  port.set_side(sort_by_input_model_test_port_side(side))
  port.set_node(Some(node))
  port
}

///|
fn sort_by_input_model_test_connect(
  source : LPort,
  target : LPort,
  model_order : Int,
  reversed : Bool,
) -> LEdge {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
  edge.set_property_int(internal_properties_model_order, model_order)
  edge.set_property_bool(internal_properties_reversed, reversed)
  edge
}

///|
test "sort by input model processor reports expected task name" {
  let processor = new_sort_by_input_model_processor_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Sort By Input Model NONE")
}

///|
test "sort by input model processor resolves long-edge target nodes" {
  let graph = new_l_graph()
  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  let layer2 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)
  graph.get_layers().push(layer2)

  let source = sort_by_input_model_test_new_node(graph, layer0, 0)
  let dummy = sort_by_input_model_test_new_node(graph, layer1, 0)
  dummy.set_type(sort_by_input_model_test_node_type("LONG_EDGE"))
  let target = sort_by_input_model_test_new_node(graph, layer2, 0)

  let source_out = sort_by_input_model_test_new_port(source, "EAST")
  let dummy_in = sort_by_input_model_test_new_port(dummy, "WEST")
  let dummy_out = sort_by_input_model_test_new_port(dummy, "EAST")
  let target_in = sort_by_input_model_test_new_port(target, "WEST")

  ignore(sort_by_input_model_test_connect(source_out, dummy_in, 0, false))
  ignore(sort_by_input_model_test_connect(dummy_out, target_in, 0, false))
  dummy.set_property_l_port(
    internal_properties_long_edge_target,
    Some(target_in),
  )

  let resolved = sort_by_input_model_processor_get_target_node(source_out)
  match resolved {
    Some(node) => assert_eq(node.get_handle(), target.get_handle())
    None => abort("expected a resolved target node")
  }
}

///|
test "sort by input model processor preprocessing caches minimum target model order" {
  let graph = new_l_graph()
  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)

  let source = sort_by_input_model_test_new_node(graph, layer0, 0)
  let target1 = sort_by_input_model_test_new_node(graph, layer1, 1)
  let target2 = sort_by_input_model_test_new_node(graph, layer1, 2)

  let source_out_1 = sort_by_input_model_test_new_port(source, "EAST")
  let source_out_2 = sort_by_input_model_test_new_port(source, "EAST")
  let source_out_3 = sort_by_input_model_test_new_port(source, "EAST")

  let target1_in_1 = sort_by_input_model_test_new_port(target1, "WEST")
  let target1_in_2 = sort_by_input_model_test_new_port(target1, "WEST")
  let target2_in = sort_by_input_model_test_new_port(target2, "WEST")

  ignore(sort_by_input_model_test_connect(source_out_1, target1_in_1, 5, false))
  let edge_two = sort_by_input_model_test_connect(
    source_out_2, target1_in_2, 2, false,
  )
  ignore(sort_by_input_model_test_connect(source_out_3, target2_in, 1, true))

  let preprocessed = sort_by_input_model_processor_long_edge_target_node_preprocessing(
    source,
  )
  match preprocessed.get(target1.get_handle()) {
    Some(value) => assert_eq(value, 2)
    None => abort("missing target1 model-order entry")
  }
  assert_true(!preprocessed.contains(target2.get_handle()))

  let target_from_out_1 = match
    source_out_1.get_property_l_node(internal_properties_long_edge_target_node) {
    Some(node) => node
    None => abort("port 1 target node missing")
  }
  let target_from_out_2 = match
    source_out_2.get_property_l_node(internal_properties_long_edge_target_node) {
    Some(node) => node
    None => abort("port 2 target node missing")
  }
  let target_from_out_3 = match
    source_out_3.get_property_l_node(internal_properties_long_edge_target_node) {
    Some(node) => node
    None => abort("port 3 target node missing")
  }
  assert_eq(target_from_out_1.get_handle(), target1.get_handle())
  assert_eq(target_from_out_2.get_handle(), target1.get_handle())
  assert_eq(target_from_out_3.get_handle(), target2.get_handle())

  edge_two.set_property_int(internal_properties_model_order, 0)
  let cached = sort_by_input_model_processor_long_edge_target_node_preprocessing(
    source,
  )
  match cached.get(target1.get_handle()) {
    Some(value) => assert_eq(value, 2)
    None => abort("missing cached target1 model-order entry")
  }
}

///|
test "sort by input model processor sorts layers nodes and ports by model order" {
  let graph = new_l_graph()
  graph.set_property_string(
    layered_options_consider_model_order_strategy, "NODES_AND_EDGES",
  )
  graph.set_property_string(
    layered_options_consider_model_order_long_edge_strategy, "DUMMY_NODE_OVER",
  )
  graph.set_property_string(
    layered_options_consider_model_order_group_model_order_cm_group_order_strategy,
    "ONLY_WITHIN_GROUP",
  )

  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)

  let source_high = sort_by_input_model_test_new_node(graph, layer0, 1)
  let source_low = sort_by_input_model_test_new_node(graph, layer0, 0)
  let source_high_out = sort_by_input_model_test_new_port(source_high, "EAST")
  let source_low_out = sort_by_input_model_test_new_port(source_low, "EAST")

  let target_high = sort_by_input_model_test_new_node(graph, layer1, 1)
  let target_low = sort_by_input_model_test_new_node(graph, layer1, 0)

  let target_high_from_low = sort_by_input_model_test_new_port(
    target_high, "WEST",
  )
  let target_high_from_high = sort_by_input_model_test_new_port(
    target_high, "WEST",
  )

  ignore(
    sort_by_input_model_test_connect(
      source_low_out, target_high_from_low, 0, false,
    ),
  )
  ignore(
    sort_by_input_model_test_connect(
      source_high_out, target_high_from_high, 1, false,
    ),
  )

  let processor = new_sort_by_input_model_processor_layout_processor()
  processor.process(graph, None)

  assert_eq(layer0.get_id(), 0)
  assert_eq(layer1.get_id(), 1)

  let sorted_layer0_nodes = layer0.get_nodes()
  assert_eq(sorted_layer0_nodes[0].get_handle(), source_low.get_handle())
  assert_eq(sorted_layer0_nodes[1].get_handle(), source_high.get_handle())

  let sorted_layer1_nodes = layer1.get_nodes()
  assert_eq(sorted_layer1_nodes[0].get_handle(), target_low.get_handle())
  assert_eq(sorted_layer1_nodes[1].get_handle(), target_high.get_handle())

  let sorted_target_high_ports = target_high.get_ports()
  assert_eq(
    sorted_target_high_ports[0].get_handle(),
    target_high_from_high.get_handle(),
  )
  assert_eq(
    sorted_target_high_ports[1].get_handle(),
    target_high_from_low.get_handle(),
  )
}
