///|
test "network simplex node/edge file-level exports are usable" {
  reset_network_simplex_model_for_test()

  let graph = new_ngraph()
  let source = network_simplex_nnode_of().id(1).create(graph)
  let target = network_simplex_nnode_of().id(2).create(graph)
  let edge = network_simplex_nedge_of()
    .id(3)
    .source(source)
    .target(target)
    .weight(2.5)
    .delta(4)
    .create()

  assert_eq(source.get_id(), 1)
  assert_eq(target.get_id(), 2)
  assert_eq(edge.get_id(), 3)
  assert_true(edge.get_source() == source)
  assert_true(edge.get_target() == target)
  assert_eq(edge.get_weight(), 2.5)
  assert_eq(edge.get_delta(), 4)
}
