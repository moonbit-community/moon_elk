///|
fn create_port_to_port_edge(
  container : @graph.ElkNode,
  source_port : @graph.ElkPort,
  target_port : @graph.ElkPort,
) -> @graph.ElkEdge {
  let edge = @graph.create_edge(Some(container))
  @graph.edge_sources(edge).push(@graph.make_port_shape(source_port))
  @graph.edge_targets(edge).push(@graph.make_port_shape(target_port))
  edge
}

///|
fn create_node_to_node_edge(
  container : @graph.ElkNode,
  source_node : @graph.ElkNode,
  target_node : @graph.ElkNode,
) -> @graph.ElkEdge {
  let edge = @graph.create_edge(Some(container))
  @graph.edge_sources(edge).push(@graph.make_node_shape(source_node))
  @graph.edge_targets(edge).push(@graph.make_node_shape(target_node))
  edge
}

///|
fn selection_iterator_collect(
  iterator : DefaultSelectionIterator,
  max_steps : Int,
) -> Array[SelectionGraphElement] {
  let result = []
  let mut remaining = max_steps
  while remaining > 0 {
    match iterator.next() {
      Some(value) => result.push(value)
      None => break
    }
    remaining = remaining - 1
  }
  result
}

///|
fn selection_graph_elements_to_strings(
  values : Array[SelectionGraphElement],
) -> Array[String] {
  let result = []
  for value in values {
    if value is SelectionEdge(edge) {
      result.push("E:\{edge}")
    } else if value is SelectionPort(port) {
      result.push("P:\{port}")
    }
  }
  result
}

///|
test "DefaultSelectionIterator follows edge direction without ports" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  let node0 = @graph.create_node(Some(root))
  let node1 = @graph.create_node(Some(root))
  let node2 = @graph.create_node(Some(root))
  let node3 = @graph.create_node(Some(root))
  let port0 = @graph.create_port(Some(node0))
  let port1 = @graph.create_port(Some(node1))
  let port2 = @graph.create_port(Some(node2))
  let port3 = @graph.create_port(Some(node3))

  let edge0 = create_port_to_port_edge(root, port0, port1)
  let edge1 = create_port_to_port_edge(root, port1, port2)
  let edge2 = create_port_to_port_edge(root, port2, port3)

  let iterator = new_default_selection_iterator(edge0, false, true)
  let result = selection_graph_elements_to_strings(
    selection_iterator_collect(iterator, 32),
  )
  @core_debug.assert_eq(result, ["E:\{edge1}", "E:\{edge2}"])
}

///|
test "DefaultSelectionIterator optionally includes ports" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  let node0 = @graph.create_node(Some(root))
  let node1 = @graph.create_node(Some(root))
  let node2 = @graph.create_node(Some(root))
  let node3 = @graph.create_node(Some(root))
  let port0 = @graph.create_port(Some(node0))
  let port1 = @graph.create_port(Some(node1))
  let port2 = @graph.create_port(Some(node2))
  let port3 = @graph.create_port(Some(node3))

  let edge0 = create_port_to_port_edge(root, port0, port1)
  let edge1 = create_port_to_port_edge(root, port1, port2)
  let edge2 = create_port_to_port_edge(root, port2, port3)

  let iterator = new_default_selection_iterator(edge0, true, true)
  let result = selection_graph_elements_to_strings(
    selection_iterator_collect(iterator, 32),
  )
  @core_debug.assert_eq(result, [
    "P:\{port1}",
    "E:\{edge1}",
    "P:\{port2}",
    "E:\{edge2}",
    "P:\{port3}",
  ])
}

///|
test "DefaultSelectionIterator can traverse against edge direction" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  let node0 = @graph.create_node(Some(root))
  let node1 = @graph.create_node(Some(root))
  let node2 = @graph.create_node(Some(root))
  let port0 = @graph.create_port(Some(node0))
  let port1 = @graph.create_port(Some(node1))
  let port2 = @graph.create_port(Some(node2))

  let edge0 = create_port_to_port_edge(root, port0, port1)
  let edge1 = create_port_to_port_edge(root, port2, port0)

  let iterator = new_default_selection_iterator(edge0, false, false)
  let result = selection_graph_elements_to_strings(
    selection_iterator_collect(iterator, 32),
  )
  @core_debug.assert_eq(result, ["E:\{edge1}"])
}

///|
test "DefaultSelectionIterator ignores non-port edge endpoints" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  let source_node = @graph.create_node(Some(root))
  let target_node = @graph.create_node(Some(root))

  let edge = create_node_to_node_edge(root, source_node, target_node)
  let iterator = new_default_selection_iterator(edge, true, true)
  let result = selection_graph_elements_to_strings(
    selection_iterator_collect(iterator, 32),
  )
  @core_debug.assert_eq(result, [])
}

///|
test "DefaultSelectionIterator supports shared visited sets" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  let node0 = @graph.create_node(Some(root))
  let node1 = @graph.create_node(Some(root))
  let port0 = @graph.create_port(Some(node0))
  let port1 = @graph.create_port(Some(node1))

  let edge0 = create_port_to_port_edge(root, port0, port1)
  let edge1 = create_port_to_port_edge(root, port1, port0)

  let forward = new_default_selection_iterator(edge0, false, true)
  let backward = new_default_selection_iterator(edge0, false, false)
  let visited = []
  forward.attach_visited_set(visited)
  backward.attach_visited_set(visited)

  let forward_result = selection_graph_elements_to_strings(
    selection_iterator_collect(forward, 32),
  )
  @core_debug.assert_eq(forward_result, ["E:\{edge1}", "E:\{edge0}"])

  let backward_result = selection_graph_elements_to_strings(
    selection_iterator_collect(backward, 32),
  )
  @core_debug.assert_eq(backward_result, [])
  assert_false(backward.has_next())
}
