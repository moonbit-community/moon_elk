///|
fn hyperedge_dummy_merger_test_strategy(
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
fn hyperedge_dummy_merger_test_port_side(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn hyperedge_dummy_merger_test_node_type(name : String) -> NodeType {
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
fn hyperedge_dummy_merger_test_require_port_on_side(
  node : LNode,
  side_name : String,
) -> LPort {
  let ports = node.get_ports_by_side(
    hyperedge_dummy_merger_test_port_side(side_name),
  )
  if ports.is_empty() {
    abort("missing required side port")
  }
  ports[0]
}

///|
fn hyperedge_dummy_merger_test_build_graph() -> (
  LGraph,
  Layer,
  LNode,
  LNode,
  LPort,
) {
  let graph = new_l_graph()
  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  let layer2 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)
  graph.get_layers().push(layer2)

  let source = new_l_node(graph=Some(graph))
  source.set_layer(Some(layer0))
  let target1 = new_l_node(graph=Some(graph))
  target1.set_layer(Some(layer2))
  let target2 = new_l_node(graph=Some(graph))
  target2.set_layer(Some(layer2))

  let first_dummy = new_l_node(graph=Some(graph))
  first_dummy.set_type(hyperedge_dummy_merger_test_node_type("LONG_EDGE"))
  first_dummy.set_layer(Some(layer1))
  let second_dummy = new_l_node(graph=Some(graph))
  second_dummy.set_type(hyperedge_dummy_merger_test_node_type("LONG_EDGE"))
  second_dummy.set_layer(Some(layer1))

  let source_out = new_l_port()
  source_out.set_side(hyperedge_dummy_merger_test_port_side("EAST"))
  source_out.set_node(Some(source))

  let first_in = new_l_port()
  first_in.set_side(hyperedge_dummy_merger_test_port_side("WEST"))
  first_in.set_node(Some(first_dummy))
  let first_out = new_l_port()
  first_out.set_side(hyperedge_dummy_merger_test_port_side("EAST"))
  first_out.set_node(Some(first_dummy))

  let second_in = new_l_port()
  second_in.set_side(hyperedge_dummy_merger_test_port_side("WEST"))
  second_in.set_node(Some(second_dummy))
  let second_out = new_l_port()
  second_out.set_side(hyperedge_dummy_merger_test_port_side("EAST"))
  second_out.set_node(Some(second_dummy))

  let target1_in = new_l_port()
  target1_in.set_side(hyperedge_dummy_merger_test_port_side("WEST"))
  target1_in.set_node(Some(target1))
  let target2_in = new_l_port()
  target2_in.set_side(hyperedge_dummy_merger_test_port_side("WEST"))
  target2_in.set_node(Some(target2))

  let edge_s1 = new_l_edge()
  edge_s1.set_source(Some(source_out))
  edge_s1.set_target(Some(first_in))
  let edge_s2 = new_l_edge()
  edge_s2.set_source(Some(source_out))
  edge_s2.set_target(Some(second_in))
  let edge_1t = new_l_edge()
  edge_1t.set_source(Some(first_out))
  edge_1t.set_target(Some(target1_in))
  let edge_2t = new_l_edge()
  edge_2t.set_source(Some(second_out))
  edge_2t.set_target(Some(target2_in))

  first_dummy.set_property_l_port(
    internal_properties_long_edge_source,
    Some(source_out),
  )
  first_dummy.set_property_l_port(
    internal_properties_long_edge_target,
    Some(target1_in),
  )
  first_dummy.set_property_bool(
    internal_properties_long_edge_has_label_dummies, false,
  )

  second_dummy.set_property_l_port(
    internal_properties_long_edge_source,
    Some(source_out),
  )
  second_dummy.set_property_l_port(
    internal_properties_long_edge_target,
    Some(target2_in),
  )
  second_dummy.set_property_bool(
    internal_properties_long_edge_has_label_dummies, false,
  )

  (graph, layer1, first_dummy, second_dummy, source_out)
}

///|
test "hyperedge dummy merger reports expected task name" {
  let processor = new_hyperedge_dummy_merger_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Hyperedge merging")
}

///|
test "hyperedge dummy merger merges adjacent long-edge dummies with same source" {
  let (graph, layer1, first_dummy, _second_dummy, source_out) = hyperedge_dummy_merger_test_build_graph()
  let processor = new_hyperedge_dummy_merger_layout_processor()
  processor.process(graph, None)

  assert_eq(layer1.get_nodes().length(), 1)
  let merged = layer1.get_nodes()[0]
  assert_eq(merged.get_handle(), first_dummy.get_handle())

  let merged_in = hyperedge_dummy_merger_test_require_port_on_side(
    merged, "WEST",
  )
  let merged_out = hyperedge_dummy_merger_test_require_port_on_side(
    merged, "EAST",
  )
  assert_eq(merged_in.get_incoming_edges().length(), 2)
  assert_eq(merged_out.get_outgoing_edges().length(), 2)

  match merged.get_property_l_port(internal_properties_long_edge_source) {
    Some(port) => assert_eq(port.get_handle(), source_out.get_handle())
    None => abort("expected LONG_EDGE_SOURCE to be preserved")
  }
  assert_true(
    match merged.get_property_l_port(internal_properties_long_edge_target) {
      Some(_) => false
      None => true
    },
  )
}

///|
test "hyperedge dummy merger respects before-label-dummy gating" {
  let (graph, layer1, first_dummy, second_dummy, _source_out) = hyperedge_dummy_merger_test_build_graph()
  first_dummy.set_property_bool(
    internal_properties_long_edge_has_label_dummies, true,
  )
  second_dummy.set_property_bool(
    internal_properties_long_edge_has_label_dummies, true,
  )
  first_dummy.set_property_bool(
    internal_properties_long_edge_before_label_dummy, true,
  )
  second_dummy.set_property_bool(
    internal_properties_long_edge_before_label_dummy, false,
  )

  let processor = new_hyperedge_dummy_merger_layout_processor()
  processor.process(graph, None)
  assert_eq(layer1.get_nodes().length(), 2)
}

///|
test "hyperedge dummy merger strategy creates concrete processor" {
  let factory = layered_intermediate_processor_factory(
    hyperedge_dummy_merger_test_strategy("HYPEREDGE_DUMMY_MERGER"),
  )
  let processor = factory.create()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Hyperedge merging")
}
