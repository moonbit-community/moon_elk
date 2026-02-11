///|
let layered_oned_eps = 0.0001

///|
fn layered_oned_rect(
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> ElkRectangle {
  let rect = new_elk_rectangle()
  rect.set_rect(x, y, width, height)
  rect
}

///|
fn layered_oned_assert_close(actual : Double, expected : Double) -> Unit raise {
  assert_true((actual - expected).abs() <= layered_oned_eps)
}

///|
fn layered_oned_dir_right() -> Direction {
  direction_values()[1]
}

///|
fn layered_oned_dir_left() -> Direction {
  direction_values()[2]
}

///|
fn layered_oned_dir_down() -> Direction {
  direction_values()[3]
}

///|
fn layered_oned_dir_up() -> Direction {
  direction_values()[4]
}

///|
fn layered_oned_compactor(
  graph : LayeredCGraph,
) -> LayeredOneDimensionalCompactor {
  new_layered_one_dimensional_compactor(graph).set_constraint_algorithm(
    layered_one_dimensional_compactor_quadratic_constraints,
  )
}

///|
test "Layered CGraph supports configured directions" {
  reset_layered_compaction_oned_model_for_test()

  let graph = new_layered_c_graph(direction_values())
  assert_true(graph.supports(layered_oned_dir_left()))
  assert_true(graph.supports(layered_oned_dir_right()))
  assert_true(graph.supports(layered_oned_dir_up()))
  assert_true(graph.supports(layered_oned_dir_down()))
}

///|
test "Layered OneDimensionalCompactor left compaction" {
  reset_layered_compaction_oned_model_for_test()

  let graph = new_layered_c_graph(direction_values())
  let left = layered_cnode_of()
    .hitbox(layered_oned_rect(0.0, 0.0, 20.0, 20.0))
    .create(graph)
  let right = layered_cnode_of()
    .hitbox(layered_oned_rect(30.0, 0.0, 20.0, 20.0))
    .create(graph)

  ignore(layered_oned_compactor(graph).change_direction(layered_oned_dir_left()).compact().finish())

  layered_oned_assert_close(left.hitbox().x, 0.0)
  layered_oned_assert_close(right.hitbox().x, 20.0)
}

///|
test "Layered OneDimensionalCompactor right compaction" {
  reset_layered_compaction_oned_model_for_test()

  let graph = new_layered_c_graph(direction_values())
  let left = layered_cnode_of()
    .hitbox(layered_oned_rect(0.0, 0.0, 20.0, 20.0))
    .create(graph)
  let right = layered_cnode_of()
    .hitbox(layered_oned_rect(30.0, 0.0, 20.0, 20.0))
    .create(graph)

  ignore(layered_oned_compactor(graph).change_direction(layered_oned_dir_right()).compact().finish())

  layered_oned_assert_close(left.hitbox().x, 10.0)
  layered_oned_assert_close(right.hitbox().x, 30.0)
}

///|
test "Layered OneDimensionalCompactor preserves grouped offsets" {
  reset_layered_compaction_oned_model_for_test()

  let graph = new_layered_c_graph(direction_values())
  let left = layered_cnode_of()
    .hitbox(layered_oned_rect(0.0, 0.0, 20.0, 20.0))
    .create(graph)
  let upper_right = layered_cnode_of()
    .hitbox(layered_oned_rect(40.0, 5.0, 20.0, 20.0))
    .create(graph)
  let lower_right = layered_cnode_of()
    .hitbox(layered_oned_rect(30.0, 25.0, 20.0, 20.0))
    .create(graph)

  ignore(layered_cgroup_of().nodes([upper_right, lower_right]).create(graph))
  ignore(layered_oned_compactor(graph).change_direction(layered_oned_dir_left()).compact().finish())

  layered_oned_assert_close(left.hitbox().x, 0.0)
  layered_oned_assert_close(upper_right.hitbox().x, 20.0)
  layered_oned_assert_close(lower_right.hitbox().x, 10.0)
}
