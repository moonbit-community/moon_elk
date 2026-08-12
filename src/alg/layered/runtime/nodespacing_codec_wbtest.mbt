///|
test "node spacing codec applies explicit output and releases caches" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)
  let node = new_l_node(graph=Some(graph))
  node.set_layer(Some(layer))

  let adapter = adapt_l_graph_with_options(graph, true, true, node => {
    node.get_type() is Normal
  })
  let input = capture_l_node_spacing_input(adapter)
  let output = @nodespacing.node_dimension_calculation_calculate_label_and_node_sizes_for_input(
    input,
  )
  apply_l_node_spacing_output(adapter, output)

  assert_true(adapter.node_adapters is None)
}

///|
test "node spacing input is detached until output is applied" {
  let graph = new_l_graph()
  let node = new_l_node(graph=Some(graph))
  graph.get_layerless_nodes().push(node)
  node.get_size().x = 10.0
  node.get_size().y = 20.0

  let adapter = adapt_l_graph(graph)
  let input = capture_l_node_spacing_input(adapter)
  input.nodes[0].size = @core.new_kvector_xy(30.0, 40.0)

  assert_eq(node.get_size().x, 10.0)
  assert_eq(node.get_size().y, 20.0)
  apply_l_node_spacing_output(adapter, input.output())
  assert_eq(node.get_size().x, 30.0)
  assert_eq(node.get_size().y, 40.0)
}
