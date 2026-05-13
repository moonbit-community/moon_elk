///|
test "IThreeValueGrid adapter delegates to TwoBitGrid" {
  let raw_grid = new_two_bit_grid(3, 2)
  let grid = new_three_value_grid_from_two_bit_grid(raw_grid)

  assert_eq(grid.get_width(), 3)
  assert_eq(grid.get_height(), 2)
  assert_eq(grid.in_bounds(1, 1), true)
  assert_eq(grid.in_bounds(3, 1), false)

  grid.set_blocked(1, 0)
  assert_eq(grid.is_blocked(1, 0), true)
  assert_eq(grid.is_empty(1, 0), false)

  grid.set_weakly_blocked(2, 1)
  assert_eq(grid.is_weakly_blocked(2, 1), true)

  grid.set_empty(1, 0)
  assert_eq(grid.is_empty(1, 0), true)
}

///|
test "IThreeValueGrid custom implementation callbacks" {
  let get_width_calls = Ref(0)
  let get_height_calls = Ref(0)
  let reinit_width = Ref(-1)
  let reinit_height = Ref(-1)
  let set_empty_calls = Ref(0)
  let set_blocked_calls = Ref(0)
  let set_weakly_blocked_calls = Ref(0)

  let grid = new_three_value_grid(
    () => {
      get_width_calls.val = get_width_calls.val + 1
      7
    },
    () => {
      get_height_calls.val = get_height_calls.val + 1
      9
    },
    (x, y) => x == y,
    (x, y) => x > y,
    (x, y) => x < y,
    (x, y) => x >= 0 && y >= 0 && x < 10 && y < 10,
    (width, height) => {
      reinit_width.val = width
      reinit_height.val = height
    },
    (_x, _y) => set_empty_calls.val = set_empty_calls.val + 1,
    (_x, _y) => set_blocked_calls.val = set_blocked_calls.val + 1,
    (_x, _y) => set_weakly_blocked_calls.val = set_weakly_blocked_calls.val + 1,
  )

  assert_eq(grid.get_width(), 7)
  assert_eq(grid.get_height(), 9)
  assert_eq(grid.is_empty(2, 2), true)
  assert_eq(grid.is_blocked(3, 1), true)
  assert_eq(grid.is_weakly_blocked(1, 3), true)
  assert_eq(grid.in_bounds(9, 9), true)
  assert_eq(grid.in_bounds(10, 9), false)

  grid.reinitialize(4, 5)
  grid.set_empty(0, 0)
  grid.set_blocked(1, 1)
  grid.set_weakly_blocked(2, 2)

  assert_eq(get_width_calls.val, 1)
  assert_eq(get_height_calls.val, 1)
  assert_eq(reinit_width.val, 4)
  assert_eq(reinit_height.val, 5)
  assert_eq(set_empty_calls.val, 1)
  assert_eq(set_blocked_calls.val, 1)
  assert_eq(set_weakly_blocked_calls.val, 1)
}
