///|
fn self_loop_holder_test_edge_handle_set(
  edges : Array[LEdge],
) -> Map[Int, Bool] {
  let handles : Map[Int, Bool] = {}
  for edge in edges {
    handles[edge.get_handle()] = true
  }
  handles
}

///|
fn self_loop_holder_test_hyper_loop_edge_handle_set(
  sl_hyper_loop : SelfHyperLoop,
) -> Map[Int, Bool] {
  let handles : Map[Int, Bool] = {}
  for sl_edge in sl_hyper_loop.get_sl_edges() {
    handles[sl_edge.get_l_edge().get_handle()] = true
  }
  handles
}

///|
fn self_loop_holder_test_same_edge_handle_set(
  left : Map[Int, Bool],
  right : Map[Int, Bool],
) -> Bool {
  if left.length() != right.length() {
    return false
  }

  for entry in left.to_array() {
    let (handle, _) = entry
    if right.get(handle) is None {
      return false
    }
  }

  true
}

///|
fn self_loop_holder_test_install_or_abort(l_node : LNode) -> SelfLoopHolder {
  self_loop_holder_install(l_node) catch {
    error => abort(self_loop_holder_exception_message(error))
  }
}

///|
test "self loop holder does not process non-self-loop graph" {
  let l_graph = self_loop_test_graph_creator_basic_graph_without_self_loops()
  for l_node in l_graph.get_layerless_nodes() {
    assert_false(self_loop_holder_needs_self_loop_processing(l_node))
  }
}

///|
test "self loop holder install rejects nodes without self loops" {
  let l_graph = self_loop_test_graph_creator_basic_graph_without_self_loops()
  let l_node = l_graph.get_layerless_nodes()[0]
  try {
    ignore(self_loop_holder_install(l_node))
    abort("expected UnsupportedConfigurationException")
  } catch {
    SelfLoopHolderException::UnsupportedConfigurationException(_) => ()
    SelfLoopHolderException::IllegalStateException(message) =>
      abort("unexpected IllegalStateException: \{message}")
  }
}

///|
test "self loop holder initializes basic self loop model" {
  let l_graph = self_loop_test_graph_creator_basic_graph_with_self_loops()
  let l_node = l_graph.get_layerless_nodes()[1]

  assert_true(self_loop_holder_needs_self_loop_processing(l_node))

  let sl_holder = self_loop_holder_test_install_or_abort(l_node)
  assert_true(
    l_node.has_property_self_loop_holder(internal_properties_self_loop_holder),
  )

  match
    l_node.get_property_self_loop_holder(internal_properties_self_loop_holder) {
    Some(saved_holder) =>
      assert_eq(
        saved_holder.get_sl_port_map().length(),
        sl_holder.get_sl_port_map().length(),
      )
    None => abort("node should have SELF_LOOP_HOLDER property")
  }

  assert_eq(l_node.get_ports().length(), sl_holder.get_sl_port_map().length())
  assert_eq(
    l_node.get_ports().length() / 2,
    sl_holder.get_sl_hyper_loops().length(),
  )
}

///|
test "self loop holder groups disconnected self loops into separate hyper loops" {
  let l_graph = self_loop_test_graph_creator_basic_graph_without_self_loops()
  let l_node = l_graph.get_layerless_nodes()[1]

  self_loop_test_graph_creator_ports(l_node, 2, 2, 2, 1)

  let first_loops = []
  let first_limit = l_node.get_ports().length() / 2
  for i in 1..<first_limit {
    let l_edge = self_loop_test_graph_creator_edge(
      l_node.get_ports()[i - 1],
      l_node.get_ports()[i],
    )
    first_loops.push(l_edge)
  }

  let second_loops = []
  let second_start = first_limit + 1
  let second_limit = l_node.get_ports().length()
  for i in second_start..<second_limit {
    let l_edge = self_loop_test_graph_creator_edge(
      l_node.get_ports()[i - 1],
      l_node.get_ports()[i],
    )
    second_loops.push(l_edge)
  }

  let sl_holder = self_loop_holder_test_install_or_abort(l_node)
  assert_eq(sl_holder.get_sl_hyper_loops().length(), 2)

  let first_hyper_edges = self_loop_holder_test_hyper_loop_edge_handle_set(
    sl_holder.get_sl_hyper_loops()[0],
  )
  let second_hyper_edges = self_loop_holder_test_hyper_loop_edge_handle_set(
    sl_holder.get_sl_hyper_loops()[1],
  )

  let first_loop_edges = self_loop_holder_test_edge_handle_set(first_loops)
  let second_loop_edges = self_loop_holder_test_edge_handle_set(second_loops)

  let match_first = self_loop_holder_test_same_edge_handle_set(
      first_hyper_edges, first_loop_edges,
    ) &&
    self_loop_holder_test_same_edge_handle_set(
      second_hyper_edges, second_loop_edges,
    )
  let match_second = self_loop_holder_test_same_edge_handle_set(
      first_hyper_edges, second_loop_edges,
    ) &&
    self_loop_holder_test_same_edge_handle_set(
      second_hyper_edges, first_loop_edges,
    )

  assert_true(match_first || match_second)
}
