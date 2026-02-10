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
  parent : ElkNode,
  width : Double,
  height : Double,
) -> ElkNode {
  let node = create_node(Some(parent))
  node_set_dimensions(node, width, height)
  node
}

///|
fn vertiflex_set_required_options(
  graph : ElkNode,
  layer_distance : Double,
  spacing : Double,
  strategy : String,
) -> Unit {
  node_set_double_property(graph, vertiflex_layer_distance, layer_distance)
  node_set_double_property(graph, vertiflex_spacing_node_node, spacing)
  node_set_string_property(graph, vertiflex_layout_strategy, strategy)
  node_set_bool_property(graph, vertiflex_omit_node_micro_layout, true)
  node_set_string_property(
    graph, vertiflex_padding, "[left=0, top=0, right=0, bottom=0]",
  )
}

///|
test "Vertiflex util finds root node" {
  reset_graph_model_for_test()
  let graph = create_graph()
  let root = vertiflex_make_node(graph, 20.0, 10.0)
  let child = vertiflex_make_node(graph, 10.0, 10.0)
  ignore(create_simple_edge(root, child))
  inspect(vertiflex_find_root(graph), content="Some(\{root})")
}

///|
test "Vertiflex layout sets y levels and routes straight edges" {
  reset_graph_model_for_test()
  let graph = create_graph()
  let root = vertiflex_make_node(graph, 20.0, 10.0)
  let left = vertiflex_make_node(graph, 10.0, 10.0)
  let right = vertiflex_make_node(graph, 10.0, 10.0)
  let e1 = create_simple_edge(root, left)
  let e2 = create_simple_edge(root, right)

  vertiflex_set_required_options(graph, 10.0, 0.0, "STRAIGHT")

  let provider = new_vertiflex_layout_provider()
  provider.layout(graph, new_basic_progress_monitor())

  vertiflex_assert_close(node_y(root), 0.0, 0.0001)
  vertiflex_assert_close(node_y(left), 20.0, 0.0001)
  vertiflex_assert_close(node_y(right), 20.0, 0.0001)

  inspect(edge_sections(e1).length(), content="1")
  inspect(edge_sections(e2).length(), content="1")
  let s1 = edge_sections(e1)[0]
  let s2 = edge_sections(e2)[0]
  vertiflex_assert_close(
    edge_section_start_y(s1),
    node_y(root) + node_height(root),
    0.0001,
  )
  vertiflex_assert_close(edge_section_end_y(s1), node_y(left), 0.0001)
  vertiflex_assert_close(
    edge_section_start_y(s2),
    node_y(root) + node_height(root),
    0.0001,
  )
  vertiflex_assert_close(edge_section_end_y(s2), node_y(right), 0.0001)
}

///|
test "panic Vertiflex rejects invalid vertical constraints" {
  reset_graph_model_for_test()
  let graph = create_graph()
  let root = vertiflex_make_node(graph, 20.0, 10.0)
  let child = vertiflex_make_node(graph, 10.0, 10.0)
  ignore(create_simple_edge(root, child))

  vertiflex_set_required_options(graph, 10.0, 0.0, "STRAIGHT")
  node_set_double_property(child, vertiflex_vertical_constraint, 0.0)

  new_vertiflex_layout_provider().layout(graph, new_basic_progress_monitor())
}

///|
test "Vertiflex bend strategy sets bend heights on branching tree" {
  reset_graph_model_for_test()
  let graph = create_graph()
  let root = vertiflex_make_node(graph, 30.0, 12.0)
  let left = vertiflex_make_node(graph, 12.0, 10.0)
  let right = vertiflex_make_node(graph, 12.0, 10.0)
  let left_leaf = vertiflex_make_node(graph, 10.0, 8.0)
  let right_leaf = vertiflex_make_node(graph, 10.0, 8.0)

  let e1 = create_simple_edge(root, left)
  let e2 = create_simple_edge(root, right)
  ignore(create_simple_edge(left, left_leaf))
  ignore(create_simple_edge(right, right_leaf))

  vertiflex_set_required_options(graph, 10.0, 2.0, "BEND")

  new_vertiflex_layout_provider().layout(graph, new_basic_progress_monitor())

  inspect(edge_sections(e1).length(), content="1")
  inspect(edge_sections(e2).length(), content="1")
  if vertiflex_internal_edge_bend_height(left) <= 0.0 {
    abort("expected bend height for left subtree")
  }
  if vertiflex_internal_edge_bend_height(right) <= 0.0 {
    abort("expected bend height for right subtree")
  }
}

///|
test "panic Vertiflex rejects node with multiple parents" {
  reset_graph_model_for_test()
  let graph = create_graph()
  let root = vertiflex_make_node(graph, 20.0, 10.0)
  let left = vertiflex_make_node(graph, 10.0, 10.0)
  let right = vertiflex_make_node(graph, 10.0, 10.0)
  let child = vertiflex_make_node(graph, 10.0, 10.0)

  ignore(create_simple_edge(root, left))
  ignore(create_simple_edge(root, right))
  ignore(create_simple_edge(left, child))
  ignore(create_simple_edge(right, child))

  vertiflex_set_required_options(graph, 10.0, 0.0, "STRAIGHT")

  new_vertiflex_layout_provider().layout(graph, new_basic_progress_monitor())
}
