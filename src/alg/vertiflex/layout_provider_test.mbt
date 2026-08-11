///|
fn vertiflex_assert_close(
  actual : Double,
  expected : Double,
  eps : Double,
) -> Unit {
  let diff = (actual - expected).abs()
  if diff > eps {
    abort("expected=\{expected} actual=\{actual} diff=\{diff}")
  }
}

///|
fn vertiflex_make_node(
  parent : @graph.ElkNode,
  width : Double,
  height : Double,
) -> @graph.ElkNode {
  let node = @graph.create_node(Some(parent))
  @graph.node_set_dimensions(node, width, height)
  node
}

///|
fn vertiflex_set_required_options(
  graph : @graph.ElkNode,
  layer_distance : Double,
  spacing : Double,
  strategy : String,
) -> Unit {
  @graph.node_set_double_property(
    graph, vertiflex_layer_distance, layer_distance,
  )
  @graph.node_set_double_property(graph, vertiflex_spacing_node_node, spacing)
  @graph.node_set_string_property(graph, vertiflex_layout_strategy, strategy)
  @graph.node_set_bool_property(graph, vertiflex_omit_node_micro_layout, true)
  @graph.node_set_string_property(
    graph, vertiflex_padding, "[left=0, top=0, right=0, bottom=0]",
  )
}

///|
fn vertiflex_run_layout(graph : @graph.ElkNode) -> String? {
  let session = @core.new_layout_session()
  try {
    new_vertiflex_layout_provider().layout(
      graph,
      @core.new_basic_progress_monitor(),
    )
    None
  } catch {
    error => {
      session.record_error(error)
      session.take_error_message()
    }
  }
}

///|
fn vertiflex_error_message_or_abort(error : String?) -> String {
  match error {
    Some(message) => message
    None => abort("expected runtime error message")
  }
}

///|
test "Vertiflex util finds root node" {
  let graph = @graph.create_graph()
  let root = vertiflex_make_node(graph, 20.0, 10.0)
  let child = vertiflex_make_node(graph, 10.0, 10.0)
  ignore(@graph.create_simple_edge(root, child))
  debug_inspect(vertiflex_find_root(graph), content="Some(\{root})")
}

///|
test "Vertiflex layout sets y levels and routes straight edges" {
  let graph = @graph.create_graph()
  let root = vertiflex_make_node(graph, 20.0, 10.0)
  let left = vertiflex_make_node(graph, 10.0, 10.0)
  let right = vertiflex_make_node(graph, 10.0, 10.0)
  let e1 = @graph.create_simple_edge(root, left)
  let e2 = @graph.create_simple_edge(root, right)

  vertiflex_set_required_options(graph, 10.0, 0.0, "STRAIGHT")

  assert_true(vertiflex_run_layout(graph) is None)

  vertiflex_assert_close(@graph.node_y(root), 0.0, 0.0001)
  vertiflex_assert_close(@graph.node_y(left), 20.0, 0.0001)
  vertiflex_assert_close(@graph.node_y(right), 20.0, 0.0001)

  inspect(@graph.edge_sections(e1).length(), content="1")
  inspect(@graph.edge_sections(e2).length(), content="1")
  let s1 = @graph.edge_sections(e1)[0]
  let s2 = @graph.edge_sections(e2)[0]
  vertiflex_assert_close(
    @graph.edge_section_start_y(s1),
    @graph.node_y(root) + @graph.node_height(root),
    0.0001,
  )
  vertiflex_assert_close(
    @graph.edge_section_end_y(s1),
    @graph.node_y(left),
    0.0001,
  )
  vertiflex_assert_close(
    @graph.edge_section_start_y(s2),
    @graph.node_y(root) + @graph.node_height(root),
    0.0001,
  )
  vertiflex_assert_close(
    @graph.edge_section_end_y(s2),
    @graph.node_y(right),
    0.0001,
  )
}

///|
test "Vertiflex rejects invalid vertical constraints" {
  let graph = @graph.create_graph()
  let root = vertiflex_make_node(graph, 20.0, 10.0)
  let child = vertiflex_make_node(graph, 10.0, 10.0)
  ignore(@graph.create_simple_edge(root, child))

  vertiflex_set_required_options(graph, 10.0, 0.0, "STRAIGHT")
  @graph.node_set_double_property(child, vertiflex_vertical_constraint, 0.0)
  let message = vertiflex_error_message_or_abort(vertiflex_run_layout(graph))
  assert_true(message.contains("Invalid vertical constraints. Node "))
  assert_true(
    message.contains(
      "has a vertical constraint that is too low for its ancestors.",
    ),
  )
}

///|
test "Vertiflex bend strategy sets bend heights on branching tree" {
  let graph = @graph.create_graph()
  let root = vertiflex_make_node(graph, 30.0, 12.0)
  let left = vertiflex_make_node(graph, 12.0, 10.0)
  let right = vertiflex_make_node(graph, 12.0, 10.0)
  let left_leaf = vertiflex_make_node(graph, 10.0, 8.0)
  let right_leaf = vertiflex_make_node(graph, 10.0, 8.0)

  let e1 = @graph.create_simple_edge(root, left)
  let e2 = @graph.create_simple_edge(root, right)
  ignore(@graph.create_simple_edge(left, left_leaf))
  ignore(@graph.create_simple_edge(right, right_leaf))

  vertiflex_set_required_options(graph, 10.0, 2.0, "BEND")

  assert_true(vertiflex_run_layout(graph) is None)

  inspect(@graph.edge_sections(e1).length(), content="1")
  inspect(@graph.edge_sections(e2).length(), content="1")
}

///|
test "Vertiflex rejects node with multiple parents" {
  let graph = @graph.create_graph()
  let root = vertiflex_make_node(graph, 20.0, 10.0)
  let left = vertiflex_make_node(graph, 10.0, 10.0)
  let right = vertiflex_make_node(graph, 10.0, 10.0)
  let child = vertiflex_make_node(graph, 10.0, 10.0)

  ignore(@graph.create_simple_edge(root, left))
  ignore(@graph.create_simple_edge(root, right))
  ignore(@graph.create_simple_edge(left, child))
  ignore(@graph.create_simple_edge(right, child))

  vertiflex_set_required_options(graph, 10.0, 0.0, "STRAIGHT")
  assert_true(
    vertiflex_error_message_or_abort(vertiflex_run_layout(graph)).contains(
      "The given graph is not an acyclic tree!",
    ),
  )
}
