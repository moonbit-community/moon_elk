///|
fn radial_assert_close(
  actual : Double,
  expected : Double,
  eps : Double,
) -> Unit {
  let diff = if actual >= expected {
    actual - expected
  } else {
    expected - actual
  }
  if diff > eps {
    abort("expected=\{expected} actual=\{actual} diff=\{diff}")
  }
}

///|
fn radial_make_node(
  parent : ElkNode,
  width : Double,
  height : Double,
) -> ElkNode {
  let node = create_node(Some(parent))
  node_set_dimensions(node, width, height)
  node
}

///|
fn radial_assert_centered(parent : ElkNode, root : ElkNode) -> Unit {
  radial_assert_close(
    node_width(parent) / 2.0,
    node_x(root) + node_width(root) / 2.0,
    0.1,
  )
  radial_assert_close(
    node_height(parent) / 2.0,
    node_y(root) + node_height(root) / 2.0,
    0.1,
  )
}

///|
test "Radial center on root simple tree" {
  reset_graph_model_for_test()

  let parent = create_graph()
  let root = radial_make_node(parent, 20.0, 20.0)
  let n1 = radial_make_node(parent, 20.0, 20.0)
  let n2 = radial_make_node(parent, 20.0, 20.0)
  let n3 = radial_make_node(parent, 20.0, 20.0)
  ignore(create_simple_edge(root, n1))
  ignore(create_simple_edge(root, n2))
  ignore(create_simple_edge(root, n3))

  node_set_string_property(parent, algorithm, radial_algorithm_id)
  node_set_bool_property(parent, radial_center_on_root, true)

  let provider = new_radial_layout_provider()
  provider.layout(parent, new_basic_progress_monitor())

  radial_assert_centered(parent, root)
}

///|
test "Radial center on root larger tree" {
  reset_graph_model_for_test()

  let parent = create_graph()
  let root = radial_make_node(parent, 20.0, 20.0)

  let n1 = radial_make_node(parent, 20.0, 20.0)
  let n2 = radial_make_node(parent, 20.0, 20.0)
  let n3 = radial_make_node(parent, 20.0, 20.0)
  ignore(create_simple_edge(root, n1))
  ignore(create_simple_edge(root, n2))
  ignore(create_simple_edge(root, n3))

  let n11 = radial_make_node(parent, 20.0, 20.0)
  let n12 = radial_make_node(parent, 20.0, 20.0)
  let n13 = radial_make_node(parent, 20.0, 20.0)
  ignore(create_simple_edge(n1, n11))
  ignore(create_simple_edge(n1, n12))
  ignore(create_simple_edge(n1, n13))

  node_set_string_property(parent, algorithm, radial_algorithm_id)
  node_set_bool_property(parent, radial_center_on_root, true)

  let provider = new_radial_layout_provider()
  provider.layout(parent, new_basic_progress_monitor())

  radial_assert_centered(parent, root)
}
