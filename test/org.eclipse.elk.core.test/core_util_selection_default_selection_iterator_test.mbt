///|
fn create_port_to_port_edge(
  container : ElkNode,
  source_port : ElkPort,
  target_port : ElkPort,
) -> ElkEdge {
  let edge = create_edge(Some(container))
  edge_sources(edge).push(make_port_shape(source_port))
  edge_targets(edge).push(make_port_shape(target_port))
  edge
}

///|
fn create_node_to_node_edge(
  container : ElkNode,
  source_node : ElkNode,
  target_node : ElkNode,
) -> ElkEdge {
  let edge = create_edge(Some(container))
  edge_sources(edge).push(make_node_shape(source_node))
  edge_targets(edge).push(make_node_shape(target_node))
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
  reset_graph_model_for_test()
  let root = create_graph()
  let node0 = create_node(Some(root))
  let node1 = create_node(Some(root))
  let node2 = create_node(Some(root))
  let node3 = create_node(Some(root))
  let port0 = create_port(Some(node0))
  let port1 = create_port(Some(node1))
  let port2 = create_port(Some(node2))
  let port3 = create_port(Some(node3))

  let edge0 = create_port_to_port_edge(root, port0, port1)
  let edge1 = create_port_to_port_edge(root, port1, port2)
  let edge2 = create_port_to_port_edge(root, port2, port3)

  let iterator = new_default_selection_iterator(edge0, false, true)
  let result = selection_graph_elements_to_strings(
    selection_iterator_collect(iterator, 32),
  )
  assert_eq(result, ["E:\{edge1}", "E:\{edge2}"])
}

///|
test "DefaultSelectionIterator optionally includes ports" {
  reset_graph_model_for_test()
  let root = create_graph()
  let node0 = create_node(Some(root))
  let node1 = create_node(Some(root))
  let node2 = create_node(Some(root))
  let node3 = create_node(Some(root))
  let port0 = create_port(Some(node0))
  let port1 = create_port(Some(node1))
  let port2 = create_port(Some(node2))
  let port3 = create_port(Some(node3))

  let edge0 = create_port_to_port_edge(root, port0, port1)
  let edge1 = create_port_to_port_edge(root, port1, port2)
  let edge2 = create_port_to_port_edge(root, port2, port3)

  let iterator = new_default_selection_iterator(edge0, true, true)
  let result = selection_graph_elements_to_strings(
    selection_iterator_collect(iterator, 32),
  )
  assert_eq(result, [
    "P:\{port1}",
    "E:\{edge1}",
    "P:\{port2}",
    "E:\{edge2}",
    "P:\{port3}",
  ])
}

///|
test "DefaultSelectionIterator can traverse against edge direction" {
  reset_graph_model_for_test()
  let root = create_graph()
  let node0 = create_node(Some(root))
  let node1 = create_node(Some(root))
  let node2 = create_node(Some(root))
  let port0 = create_port(Some(node0))
  let port1 = create_port(Some(node1))
  let port2 = create_port(Some(node2))

  let edge0 = create_port_to_port_edge(root, port0, port1)
  let edge1 = create_port_to_port_edge(root, port2, port0)

  let iterator = new_default_selection_iterator(edge0, false, false)
  let result = selection_graph_elements_to_strings(
    selection_iterator_collect(iterator, 32),
  )
  assert_eq(result, ["E:\{edge1}"])
}

///|
test "DefaultSelectionIterator ignores non-port edge endpoints" {
  reset_graph_model_for_test()
  let root = create_graph()
  let source_node = create_node(Some(root))
  let target_node = create_node(Some(root))

  let edge = create_node_to_node_edge(root, source_node, target_node)
  let iterator = new_default_selection_iterator(edge, true, true)
  let result = selection_graph_elements_to_strings(
    selection_iterator_collect(iterator, 32),
  )
  assert_eq(result, [])
}

///|
test "DefaultSelectionIterator supports shared visited sets" {
  reset_graph_model_for_test()
  let root = create_graph()
  let node0 = create_node(Some(root))
  let node1 = create_node(Some(root))
  let port0 = create_port(Some(node0))
  let port1 = create_port(Some(node1))

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
  assert_eq(forward_result, ["E:\{edge1}", "E:\{edge0}"])

  let backward_result = selection_graph_elements_to_strings(
    selection_iterator_collect(backward, 32),
  )
  assert_eq(backward_result, [])
  assert_false(backward.has_next())
}
