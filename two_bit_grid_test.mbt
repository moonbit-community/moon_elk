///|
test "TwoBitGrid dimension" {
  let test_grid = new_two_bit_grid(35, 3)
  assert_eq(test_grid.width(), 35)
  assert_eq(test_grid.height(), 3)
  let second_grid = new_two_bit_grid(64, 64)
  assert_eq(second_grid.width(), 64)
  assert_eq(second_grid.height(), 64)
}

///|
test "TwoBitGrid inBounds" {
  let test_grid = new_two_bit_grid(35, 3)
  assert_eq(test_grid.in_bounds(0, 0), true)
  assert_eq(test_grid.in_bounds(-1, 0), false)
  assert_eq(test_grid.in_bounds(0, -1), false)
  assert_eq(test_grid.in_bounds(-1, -1), false)
  assert_eq(test_grid.in_bounds(34, 2), true)
  assert_eq(test_grid.in_bounds(34, 3), false)
  assert_eq(test_grid.in_bounds(35, 2), false)
  assert_eq(test_grid.in_bounds(35, 3), false)
  assert_eq(test_grid.in_bounds(17, 1), true)
}

///|
test "TwoBitGrid cell states" {
  let test_grid = new_two_bit_grid(35, 3)
  assert_eq(test_grid.is_empty(0, 0), true)
  assert_eq(test_grid.is_empty(34, 2), true)
  test_grid.set_blocked(0, 0)
  assert_eq(test_grid.is_blocked(0, 0), true)
  assert_eq(test_grid.is_empty(0, 0), false)
  assert_eq(test_grid.is_weakly_blocked(0, 0), false)
  test_grid.set_weakly_blocked(1, 0)
  assert_eq(test_grid.is_blocked(0, 0), true)
  assert_eq(test_grid.is_empty(0, 0), false)
  assert_eq(test_grid.is_weakly_blocked(0, 0), false)
  assert_eq(test_grid.is_blocked(1, 0), false)
  assert_eq(test_grid.is_empty(1, 0), false)
  assert_eq(test_grid.is_weakly_blocked(1, 0), true)
  test_grid.set_empty(0, 0)
  assert_eq(test_grid.is_blocked(0, 0), false)
  assert_eq(test_grid.is_empty(0, 0), true)
  assert_eq(test_grid.is_weakly_blocked(0, 0), false)
  assert_eq(test_grid.is_blocked(1, 0), false)
  assert_eq(test_grid.is_empty(1, 0), false)
  assert_eq(test_grid.is_weakly_blocked(1, 0), true)
  assert_eq(test_grid.is_empty(33, 2), true)
  test_grid.set_blocked(33, 2)
  assert_eq(test_grid.is_blocked(33, 2), true)
  assert_eq(test_grid.is_empty(33, 2), false)
  assert_eq(test_grid.is_weakly_blocked(33, 2), false)
  let second_grid = new_two_bit_grid(64, 64)
  for yi = 0; yi < second_grid.height(); yi = yi + 1 {
    for xi = 0; xi < second_grid.width(); xi = xi + 1 {
      second_grid.set_blocked(xi, yi)
    }
  }
  for yi = 0; yi < second_grid.height(); yi = yi + 1 {
    for xi = 0; xi < second_grid.width(); xi = xi + 1 {
      assert_eq(second_grid.is_blocked(xi, yi), true)
    }
  }
  for yi = 0; yi < second_grid.height(); yi = yi + 1 {
    for xi = 0; xi < second_grid.width(); xi = xi + 1 {
      second_grid.set_weakly_blocked(xi, yi)
    }
  }
  for yi = 0; yi < second_grid.height(); yi = yi + 1 {
    for xi = 0; xi < second_grid.width(); xi = xi + 1 {
      assert_eq(second_grid.is_weakly_blocked(xi, yi), true)
    }
  }
  for yi = 0; yi < second_grid.height(); yi = yi + 1 {
    for xi = 0; xi < second_grid.width(); xi = xi + 1 {
      second_grid.set_empty(xi, yi)
    }
  }
  for yi = 0; yi < second_grid.height(); yi = yi + 1 {
    for xi = 0; xi < second_grid.width(); xi = xi + 1 {
      assert_eq(second_grid.is_empty(xi, yi), true)
    }
  }
}
