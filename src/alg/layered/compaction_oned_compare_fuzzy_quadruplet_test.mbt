///|
fn layered_direction_undefined() -> @core.Direction {
  @core.direction_values()[0]
}

///|
fn layered_direction_right() -> @core.Direction {
  @core.direction_values()[1]
}

///|
fn layered_direction_left() -> @core.Direction {
  @core.direction_values()[2]
}

///|
fn layered_direction_down() -> @core.Direction {
  @core.direction_values()[3]
}

///|
fn layered_direction_up() -> @core.Direction {
  @core.direction_values()[4]
}

///|
test "layered compare fuzzy follows tolerance semantics" {
  assert_true(layered_compare_fuzzy_eq(1.0, 1.00005))
  assert_false(layered_compare_fuzzy_eq(1.0, 1.0002))
  assert_true(layered_compare_fuzzy_gt(2.0, 1.0))
  assert_false(layered_compare_fuzzy_gt(1.00005, 1.0))
  assert_true(layered_compare_fuzzy_lt(1.0, 2.0))
  assert_false(layered_compare_fuzzy_lt(1.0, 1.00005))
  assert_true(layered_compare_fuzzy_ge(1.00005, 1.0))
  assert_true(layered_compare_fuzzy_le(1.0, 1.00005))
}

///|
test "quadruplet default and directional set/get match upstream behavior" {
  let lock = new_layered_quadruplet()

  assert_false(lock.get(layered_direction_left()))
  assert_false(lock.get(layered_direction_right()))
  assert_false(lock.get(layered_direction_up()))
  assert_false(lock.get(layered_direction_down()))
  assert_false(lock.get(layered_direction_undefined()))

  lock.set_for_direction(true, layered_direction_left())
  lock.set_for_direction(true, layered_direction_up())
  assert_true(lock.get(layered_direction_left()))
  assert_false(lock.get(layered_direction_right()))
  assert_true(lock.get(layered_direction_up()))
  assert_false(lock.get(layered_direction_down()))

  lock.set_values(false, true, false, true)
  assert_false(lock.get(layered_direction_left()))
  assert_true(lock.get(layered_direction_right()))
  assert_false(lock.get(layered_direction_up()))
  assert_true(lock.get(layered_direction_down()))
}
