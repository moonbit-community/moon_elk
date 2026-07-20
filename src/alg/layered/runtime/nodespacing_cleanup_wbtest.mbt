///|
test "node spacing cleanup breaks temporary context and adapter cycles" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)
  let node = new_l_node(graph=Some(graph))
  node.set_layer(Some(layer))
  let port = new_l_port()
  port.set_node(Some(node))

  let graph_adapter = adapt_l_graph(graph)
  let node_adapter = graph_adapter.get_nodes()[0]
  let node_context = try new_node_context(node_adapter) catch {
    _ => abort("failed to create node context")
  } noraise {
    value => value
  }
  let port_context = new_port_context(
    node_context,
    new_l_port_adapter(port, false),
    0,
  )
  node_context.port_contexts["EAST"] = [port_context]

  assert_false(node_context.port_contexts.is_empty())
  assert_true(graph_adapter.node_adapters is Some(_))

  node_context.cleanup()
  graph_adapter.cleanup()

  assert_true(node_context.port_contexts.is_empty())
  assert_true(graph_adapter.node_adapters is None)
}
