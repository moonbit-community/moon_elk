///|
fn build_stress_graph() -> (FGraph, FNode, FNode) {
  let graph = new_fgraph()
  graph.set_double_property(stress_desired_edge_length, 5.0)
  graph.set_double_property(stress_epsilon, 0.001)
  graph.set_int_property(stress_iteration_limit, 20)
  graph.set_int_property(stress_dimension, 0)
  let left = new_fnode(label="left")
  fnode_set_id(left, 0)
  ignore(fnode_position(left).set_xy(0.0, 10.0))
  ignore(fnode_size(left).set_xy(2.0, 2.0))
  let right = new_fnode(label="right")
  fnode_set_id(right, 1)
  ignore(fnode_position(right).set_xy(20.0, 30.0))
  ignore(fnode_size(right).set_xy(2.0, 2.0))
  graph.add_node(left)
  graph.add_node(right)
  let edge = new_fedge()
  fedge_set_source(edge, left)
  fedge_set_target(edge, right)
  graph.add_edge(edge)
  (graph, left, right)
}

///|
fn stress_majorization_test_expect_ok(
  action : () -> Unit raise StressMajorizationException,
) -> Unit {
  try action() catch {
    StressMajorizationException(message) =>
      abort("unexpected StressMajorizationException: \{message}")
  } noraise {
    _ => ()
  }
}

///|
test "StressMajorization execute keeps finite positions" {
  reset_force_graph_model_for_test()
  let (graph, left, right) = build_stress_graph()
  let stress = new_stress_majorization()
  stress_majorization_test_expect_ok(() => stress.initialize(graph))
  stress.execute()
  assert_eq(fnode_position(left).is_nan(), false)
  assert_eq(fnode_position(left).is_infinite(), false)
  assert_eq(fnode_position(right).is_nan(), false)
  assert_eq(fnode_position(right).is_infinite(), false)
}

///|
test "StressMajorization respects X-only dimension" {
  reset_force_graph_model_for_test()
  let (graph, left, right) = build_stress_graph()
  graph.set_int_property(stress_dimension, 1)
  let left_y = fnode_position(left).y
  let right_y = fnode_position(right).y
  let stress = new_stress_majorization()
  stress_majorization_test_expect_ok(() => stress.initialize(graph))
  stress.execute()
  assert_eq(fnode_position(left).y, left_y)
  assert_eq(fnode_position(right).y, right_y)
}
