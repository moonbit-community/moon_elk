///|
fn semi_interactive_test_strategy(
  name : String,
) -> IntermediateProcessorStrategy {
  for strategy in intermediate_processor_strategy_values() {
    if intermediate_processor_strategy_to_string(strategy) == name {
      return strategy
    }
  }
  abort("unknown intermediate processor strategy")
}

///|
fn semi_interactive_test_node_type(name : String) -> NodeType {
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
fn semi_interactive_test_node_type_equals(
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
fn semi_interactive_test_new_layered_node(
  graph : LGraph,
  layer : Layer,
  node_id : Int,
  node_type : NodeType,
  position? : @core.KVector? = None,
) -> LNode {
  let node = new_l_node(graph=Some(graph))
  node.set_id(node_id)
  node.set_type(node_type)
  node.set_layer(Some(layer))
  match position {
    Some(value) => node.set_property_kvector(layered_options_position, value)
    None => ()
  }
  node
}

///|
fn semi_interactive_test_successor_ids(node : LNode) -> Array[Int] {
  let result = []
  for
    successor in node.get_property_l_node_array(
      internal_properties_in_layer_successor_constraints,
    ) {
    result.push(successor.get_id())
  }
  result
}

///|
test "semi @core.interactive processor reports expected task name" {
  let processor = new_semi_interactive_cross_min_processor_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  debug_inspect(
    monitor.get_task_name(),
    content=(
      #|"Semi-Interactive Crossing Minimization Processor"
    ),
  )
}

///|
test "semi @core.interactive processor sorts positioned normal nodes by y and adds successor constraints" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let normal_high = semi_interactive_test_new_layered_node(
    graph,
    layer,
    1,
    semi_interactive_test_node_type("NORMAL"),
    position=Some(@core.new_kvector_xy(0.0, 30.0)),
  )
  let normal_low = semi_interactive_test_new_layered_node(
    graph,
    layer,
    2,
    semi_interactive_test_node_type("NORMAL"),
    position=Some(@core.new_kvector_xy(0.0, 10.0)),
  )
  let normal_no_position = semi_interactive_test_new_layered_node(
    graph,
    layer,
    3,
    semi_interactive_test_node_type("NORMAL"),
    position=None,
  )
  let dummy_positioned = semi_interactive_test_new_layered_node(
    graph,
    layer,
    4,
    semi_interactive_test_node_type("LONG_EDGE"),
    position=Some(@core.new_kvector_xy(0.0, 0.0)),
  )
  assert_true(
    semi_interactive_test_node_type_equals(
      dummy_positioned.get_type(),
      semi_interactive_test_node_type("LONG_EDGE"),
    ),
  )

  let processor = new_semi_interactive_cross_min_processor_layout_processor()
  processor.process(graph, None)

  debug_inspect(semi_interactive_test_successor_ids(normal_low), content="[1]")
  debug_inspect(semi_interactive_test_successor_ids(normal_high), content="[]")
  debug_inspect(
    semi_interactive_test_successor_ids(normal_no_position),
    content="[]",
  )
  assert_true(
    graph.get_property_bool(
      internal_properties_in_layer_successor_constraints_between_non_dummies,
    ),
  )
}

///|
test "semi @core.interactive processor keeps graph flag false when no constraints are added" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let single_positioned = semi_interactive_test_new_layered_node(
    graph,
    layer,
    10,
    semi_interactive_test_node_type("NORMAL"),
    position=Some(@core.new_kvector_xy(0.0, 5.0)),
  )
  ignore(single_positioned)

  let processor = layered_intermediate_processor_factory(
    semi_interactive_test_strategy("SEMI_INTERACTIVE_CROSSMIN_PROCESSOR"),
  ).create()
  processor.process(graph, None)

  assert_false(
    graph.get_property_bool(
      internal_properties_in_layer_successor_constraints_between_non_dummies,
    ),
  )
}
