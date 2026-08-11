///|
test "shared node spacing kernel releases layered adapter caches" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)
  let node = new_l_node(graph=Some(graph))
  node.set_layer(Some(layer))

  let adapter = adapt_l_graph_with_options(graph, true, true, node => {
    node.get_type() is Normal
  })
  @nodespacing.node_dimension_calculation_calculate_label_and_node_sizes_for_adapter(
    adapter,
  )

  assert_true(adapter.node_adapters is None)
}
