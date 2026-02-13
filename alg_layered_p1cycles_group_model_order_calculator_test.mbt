///|
fn gmoc_new_node(
  constraint : String,
  model_order : Int,
  group_id : Int,
) -> LNode {
  let node = new_l_node()
  node.set_property_string(
    layered_options_layering_layer_constraint, constraint,
  )
  node.set_property_int(internal_properties_model_order, model_order)
  node.set_property_int(
    layered_options_consider_model_order_group_model_order_cycle_breaking_id, group_id,
  )
  node
}

///|
fn gmoc_new_node_without_model_order(constraint : String) -> LNode {
  let node = new_l_node()
  node.set_property_string(
    layered_options_layering_layer_constraint, constraint,
  )
  node
}

///|
fn gmoc_constraint_none() -> String {
  layer_constraint_values()[0]
}

///|
fn gmoc_constraint_first() -> String {
  layer_constraint_values()[1]
}

///|
fn gmoc_constraint_first_separate() -> String {
  layer_constraint_values()[2]
}

///|
fn gmoc_constraint_last() -> String {
  layer_constraint_values()[3]
}

///|
fn gmoc_constraint_last_separate() -> String {
  layer_constraint_values()[4]
}

///|
test "GroupModelOrderCalculator computes constraint model order" {
  let calculator = new_group_model_order_calculator()
  assert_eq(
    calculator.compute_constraint_model_order(
      gmoc_new_node(gmoc_constraint_first_separate(), 7, 0),
      10,
    ),
    -13,
  )
  assert_eq(
    calculator.compute_constraint_model_order(
      gmoc_new_node(gmoc_constraint_first_separate(), 8, 0),
      10,
    ),
    -11,
  )
  assert_eq(
    calculator.compute_constraint_model_order(
      gmoc_new_node(gmoc_constraint_first(), 5, 0),
      10,
    ),
    -5,
  )
  assert_eq(
    calculator.compute_constraint_model_order(
      gmoc_new_node(gmoc_constraint_none(), 4, 0),
      10,
    ),
    4,
  )
  assert_eq(
    calculator.compute_constraint_model_order(
      gmoc_new_node(gmoc_constraint_last(), 3, 0),
      10,
    ),
    13,
  )
  assert_eq(
    calculator.compute_constraint_model_order(
      gmoc_new_node(gmoc_constraint_last_separate(), 2, 0),
      10,
    ),
    22,
  )
  assert_eq(
    calculator.compute_constraint_model_order(
      gmoc_new_node(gmoc_constraint_last_separate(), 2, 0),
      10,
    ),
    23,
  )
}

///|
test "GroupModelOrderCalculator computes constraint group model order" {
  let calculator = new_group_model_order_calculator()
  assert_eq(
    calculator.compute_constraint_group_model_order(
      gmoc_new_node(gmoc_constraint_none(), 2, 3),
      100,
      10,
    ),
    32,
  )
  assert_eq(
    calculator.compute_constraint_group_model_order(
      gmoc_new_node(gmoc_constraint_first(), 4, 1),
      100,
      10,
    ),
    -86,
  )
  assert_eq(
    calculator.compute_constraint_group_model_order(
      gmoc_new_node(gmoc_constraint_last_separate(), 1, 2),
      100,
      10,
    ),
    221,
  )
  assert_eq(
    calculator.compute_constraint_group_model_order(
      gmoc_new_node_without_model_order(gmoc_constraint_last_separate()),
      100,
      10,
    ),
    201,
  )
}

///|
test "GroupModelOrderCalculator resets internal counters" {
  let calculator = new_group_model_order_calculator()
  assert_eq(
    calculator.compute_constraint_model_order(
      gmoc_new_node_without_model_order(gmoc_constraint_first_separate()),
      10,
    ),
    -20,
  )
  assert_eq(
    calculator.compute_constraint_model_order(
      gmoc_new_node_without_model_order(gmoc_constraint_first_separate()),
      10,
    ),
    -19,
  )

  calculator.reset_internal_counters()

  assert_eq(
    calculator.compute_constraint_model_order(
      gmoc_new_node_without_model_order(gmoc_constraint_first_separate()),
      10,
    ),
    -20,
  )
}
