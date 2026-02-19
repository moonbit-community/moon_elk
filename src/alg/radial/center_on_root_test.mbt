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
  parent : @graph.ElkNode,
  width : Double,
  height : Double,
) -> @graph.ElkNode {
  let node = @test.create_node(Some(parent))
  @graph.node_set_dimensions(node, width, height)
  node
}

///|
fn radial_assert_centered(parent : @graph.ElkNode, root : @graph.ElkNode) -> Unit {
  radial_assert_close(
    @graph.node_width(parent) / 2.0,
    @graph.node_x(root) + @graph.node_width(root) / 2.0,
    0.1,
  )
  radial_assert_close(
    @graph.node_height(parent) / 2.0,
    @graph.node_y(root) + @graph.node_height(root) / 2.0,
    0.1,
  )
}

///|
test "Radial center on root simple tree" {
  @test.reset_graph_model_for_test()

  let parent = @test.create_graph()
  let root = radial_make_node(parent, 20.0, 20.0)
  let n1 = radial_make_node(parent, 20.0, 20.0)
  let n2 = radial_make_node(parent, 20.0, 20.0)
  let n3 = radial_make_node(parent, 20.0, 20.0)
  ignore(@test.create_simple_edge(root, n1))
  ignore(@test.create_simple_edge(root, n2))
  ignore(@test.create_simple_edge(root, n3))

  @graph.node_set_string_property(parent, @test.algorithm, radial_algorithm_id)
  @graph.node_set_bool_property(parent, radial_center_on_root, true)

  let provider = new_radial_layout_provider()
  provider.layout(parent, @core.new_basic_progress_monitor())

  radial_assert_centered(parent, root)
}

///|
test "Radial center on root larger tree" {
  @test.reset_graph_model_for_test()

  let parent = @test.create_graph()
  let root = radial_make_node(parent, 20.0, 20.0)

  let n1 = radial_make_node(parent, 20.0, 20.0)
  let n2 = radial_make_node(parent, 20.0, 20.0)
  let n3 = radial_make_node(parent, 20.0, 20.0)
  ignore(@test.create_simple_edge(root, n1))
  ignore(@test.create_simple_edge(root, n2))
  ignore(@test.create_simple_edge(root, n3))

  let n11 = radial_make_node(parent, 20.0, 20.0)
  let n12 = radial_make_node(parent, 20.0, 20.0)
  let n13 = radial_make_node(parent, 20.0, 20.0)
  ignore(@test.create_simple_edge(n1, n11))
  ignore(@test.create_simple_edge(n1, n12))
  ignore(@test.create_simple_edge(n1, n13))

  @graph.node_set_string_property(parent, @test.algorithm, radial_algorithm_id)
  @graph.node_set_bool_property(parent, radial_center_on_root, true)

  let provider = new_radial_layout_provider()
  provider.layout(parent, @core.new_basic_progress_monitor())

  radial_assert_centered(parent, root)
}
