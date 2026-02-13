///|
fn constraints_postprocessor_test_node_type(name : String) -> NodeType {
  let values = node_type_values()
  if name == "NORMAL" {
    return values[0]
  }
  if name == "EXTERNAL_PORT" {
    return values[2]
  }
  if name == "LABEL" {
    return values[4]
  }
  abort("unknown node type")
}

///|
fn constraints_postprocessor_test_new_node(
  graph : LGraph,
  layer : Layer,
  id : Int,
  node_type : NodeType,
) -> LNode {
  let node = new_l_node(graph=Some(graph))
  node.set_id(id)
  node.set_type(node_type)
  node.set_layer(Some(layer))
  node
}

///|
test "constraints postprocessor reports expected task name" {
  let processor = new_constraints_postprocessor_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Constraints Postprocessor")
}

///|
test "constraints postprocessor assigns layer and position ids to normal nodes" {
  let graph = new_l_graph()
  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  let layer2 = new_layer(graph)
  let layer3 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)
  graph.get_layers().push(layer2)
  graph.get_layers().push(layer3)

  let layer0_label = constraints_postprocessor_test_new_node(
    graph,
    layer0,
    10,
    constraints_postprocessor_test_node_type("LABEL"),
  )

  let layer1_a = constraints_postprocessor_test_new_node(
    graph,
    layer1,
    20,
    constraints_postprocessor_test_node_type("NORMAL"),
  )
  let layer1_external = constraints_postprocessor_test_new_node(
    graph,
    layer1,
    21,
    constraints_postprocessor_test_node_type("EXTERNAL_PORT"),
  )

  let layer2_a = constraints_postprocessor_test_new_node(
    graph,
    layer2,
    30,
    constraints_postprocessor_test_node_type("NORMAL"),
  )
  let layer2_b = constraints_postprocessor_test_new_node(
    graph,
    layer2,
    31,
    constraints_postprocessor_test_node_type("NORMAL"),
  )

  let layer3_external = constraints_postprocessor_test_new_node(
    graph,
    layer3,
    40,
    constraints_postprocessor_test_node_type("EXTERNAL_PORT"),
  )

  let processor = new_constraints_postprocessor_layout_processor()
  processor.process(graph, None)

  assert_eq(layer1_a.get_property_int(layered_options_layering_layer_id), 0)
  assert_eq(
    layer1_a.get_property_int(layered_options_crossing_minimization_position_id),
    0,
  )
  assert_eq(layer2_a.get_property_int(layered_options_layering_layer_id), 1)
  assert_eq(
    layer2_a.get_property_int(layered_options_crossing_minimization_position_id),
    0,
  )
  assert_eq(layer2_b.get_property_int(layered_options_layering_layer_id), 1)
  assert_eq(
    layer2_b.get_property_int(layered_options_crossing_minimization_position_id),
    1,
  )

  assert_false(layer0_label.has_property_int(layered_options_layering_layer_id))
  assert_false(
    layer1_external.has_property_int(layered_options_layering_layer_id),
  )
  assert_false(
    layer3_external.has_property_int(layered_options_layering_layer_id),
  )
}
