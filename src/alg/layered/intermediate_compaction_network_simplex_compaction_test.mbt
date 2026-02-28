///|
fn network_simplex_compaction_test_graph() -> @common.CGraph {
  @common.new_cgraph(@core.direction_values())
}

///|
test "network simplex compaction preserves required left-to-right order" {
  @common.reset_compaction_oned_model_for_test()
  horizontal_graph_compactor_clear_origin_lookup()

  let c_graph = network_simplex_compaction_test_graph()
  let left = @common.cnode_of()
    .hitbox(@core.new_elk_rectangle_xywh(0.0, 0.0, 10.0, 10.0))
    .create(c_graph)
  let right = @common.cnode_of()
    .hitbox(@core.new_elk_rectangle_xywh(30.0, 0.0, 10.0, 10.0))
    .create(c_graph)

  let compactor = @common.new_one_dimensional_compactor(c_graph)
  ignore(compactor.change_direction(@core.direction_values()[2]))

  left.add_constraint(right)

  network_simplex_compaction(compactor)

  let left_hitbox = left.hitbox()
  let right_hitbox = right.hitbox()
  assert_true(right_hitbox.x >= left_hitbox.x + left_hitbox.width)
}
