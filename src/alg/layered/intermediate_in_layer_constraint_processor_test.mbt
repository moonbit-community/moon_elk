///|
fn in_layer_constraint_processor_test_strategy(
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
fn in_layer_constraint_processor_test_new_node(
  graph : LGraph,
  layer : Layer,
  id : Int,
  constraint : String,
) -> LNode {
  let node = new_l_node(graph=Some(graph))
  node.set_id(id)
  node.set_layer(Some(layer))
  node.set_property_string(internal_properties_in_layer_constraint, constraint)
  node
}

///|
fn in_layer_constraint_processor_test_constraints(
  layer : Layer,
) -> Array[String] {
  let result = []
  for node in layer.get_nodes() {
    result.push(
      node.get_property_string(internal_properties_in_layer_constraint),
    )
  }
  result
}

///|
fn in_layer_constraint_processor_test_ids(layer : Layer) -> Array[Int] {
  let result = []
  for node in layer.get_nodes() {
    result.push(node.get_id())
  }
  result
}

///|
test "in-layer constraint processor reports expected task name" {
  let processor = new_in_layer_constraint_processor_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  debug_inspect(
    monitor.get_task_name(),
    content="Layer constraint edge reversal",
  )
}

///|
test "in-layer constraint processor enforces top none bottom ordering per layer" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  ignore(in_layer_constraint_processor_test_new_node(graph, layer, 0, "NONE"))
  ignore(in_layer_constraint_processor_test_new_node(graph, layer, 1, "TOP"))
  ignore(in_layer_constraint_processor_test_new_node(graph, layer, 2, "BOTTOM"))
  ignore(in_layer_constraint_processor_test_new_node(graph, layer, 3, "TOP"))
  ignore(in_layer_constraint_processor_test_new_node(graph, layer, 4, "NONE"))
  ignore(in_layer_constraint_processor_test_new_node(graph, layer, 5, "BOTTOM"))

  let processor = new_in_layer_constraint_processor_layout_processor()
  processor.process(graph, None)

  debug_inspect(
    in_layer_constraint_processor_test_constraints(layer),
    content="[\"TOP\", \"TOP\", \"NONE\", \"NONE\", \"BOTTOM\", \"BOTTOM\"]",
  )
  debug_inspect(
    in_layer_constraint_processor_test_ids(layer),
    content="[1, 3, 0, 4, 2, 5]",
  )
}

///|
test "in-layer constraint processor strategy creates in-layer processor" {
  let factory = layered_intermediate_processor_factory(
    in_layer_constraint_processor_test_strategy("IN_LAYER_CONSTRAINT_PROCESSOR"),
  )
  let processor = factory.create()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  debug_inspect(
    monitor.get_task_name(),
    content="Layer constraint edge reversal",
  )
}
