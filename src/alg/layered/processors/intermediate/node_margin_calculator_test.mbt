///|
fn node_margin_calculator_test_new_node(
  graph : @runtime.LGraph,
  layer : @runtime.Layer,
  id : Int,
  width : Double,
  height : Double,
) -> @runtime.LNode {
  let node = @runtime.new_l_node(graph=Some(graph))
  node.set_id(id)
  node.set_layer(Some(layer))
  ignore(node.get_size().set_xy(width, height))
  node
}

///|
test "comment node margin calculator reports expected task name" {
  let graph = @runtime.new_l_graph()
  let processor = @engine.new_layered_phase_registry()
    .intermediate_processor_factory(graph, CommentNodeMarginCalculator)
    .create()
  let monitor = new_elk_progress_monitor()
  processor.run(Some(monitor))
  inspect(monitor.get_task_name(), content="Node margin calculation")
}

///|
test "comment node margin calculator expands margins for top and bottom comments" {
  let graph = @runtime.new_l_graph()
  graph.set_property_double(
    @options.layered_options_spacing_comment_comment, 5.0,
  )
  graph.set_property_double(@options.layered_options_spacing_comment_node, 7.0)

  let layer = @runtime.new_layer(graph)
  graph.get_layers().push(layer)

  let node = node_margin_calculator_test_new_node(graph, layer, 1, 100.0, 50.0)
  node.get_margin().set_values(1.0, 2.0, 3.0, 4.0)

  let top_a = node_margin_calculator_test_new_node(graph, layer, 2, 80.0, 10.0)
  let top_b = node_margin_calculator_test_new_node(graph, layer, 3, 40.0, 20.0)
  let bottom_a = node_margin_calculator_test_new_node(
    graph, layer, 4, 120.0, 15.0,
  )

  node.set_property_l_node_array(@runtime.internal_properties_top_comments, [
    top_a, top_b,
  ])
  node.set_property_l_node_array(@runtime.internal_properties_bottom_comments, [
    bottom_a,
  ])

  let processor = @engine.new_layered_phase_registry()
    .intermediate_processor_factory(graph, CommentNodeMarginCalculator)
    .create()
  processor.run(None)

  inspect(node.get_margin().get_top(), content="28")
  inspect(node.get_margin().get_bottom(), content="25")
  inspect(node.get_margin().get_left(), content="12.5")
  inspect(node.get_margin().get_right(), content="12.5")
}

///|
test "comment node margin calculator keeps margins unchanged without comments" {
  let graph = @runtime.new_l_graph()
  graph.set_property_double(
    @options.layered_options_spacing_comment_comment, 5.0,
  )
  graph.set_property_double(@options.layered_options_spacing_comment_node, 7.0)

  let layer = @runtime.new_layer(graph)
  graph.get_layers().push(layer)

  let node = node_margin_calculator_test_new_node(graph, layer, 10, 100.0, 40.0)
  node.get_margin().set_values(2.0, 3.0, 4.0, 5.0)

  let processor = @engine.new_layered_phase_registry()
    .intermediate_processor_factory(graph, CommentNodeMarginCalculator)
    .create()
  processor.run(None)

  inspect(node.get_margin().get_top(), content="2")
  inspect(node.get_margin().get_right(), content="3")
  inspect(node.get_margin().get_bottom(), content="4")
  inspect(node.get_margin().get_left(), content="5")
}

///|
test "comment node margin calculator treats empty comment list as present property" {
  let graph = @runtime.new_l_graph()
  graph.set_property_double(
    @options.layered_options_spacing_comment_comment, 5.0,
  )
  graph.set_property_double(@options.layered_options_spacing_comment_node, 7.0)

  let layer = @runtime.new_layer(graph)
  graph.get_layers().push(layer)

  let node = node_margin_calculator_test_new_node(graph, layer, 20, 100.0, 40.0)
  node.get_margin().set_values(2.0, 3.0, 4.0, 5.0)
  node.set_property_l_node_array(@runtime.internal_properties_top_comments, [])

  let processor = @engine.new_layered_phase_registry()
    .intermediate_processor_factory(graph, CommentNodeMarginCalculator)
    .create()
  processor.run(None)

  inspect(node.get_margin().get_top(), content="9")
  inspect(node.get_margin().get_right(), content="3")
  inspect(node.get_margin().get_bottom(), content="4")
  inspect(node.get_margin().get_left(), content="5")
}
