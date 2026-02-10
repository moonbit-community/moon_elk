///|
test "PolyominoDirection horizontal semantics" {
  let dirs = polyomino_direction_values()
  assert_eq(dirs[0].is_horizontal(), false)
  assert_eq(dirs[1].is_horizontal(), true)
  assert_eq(dirs[2].is_horizontal(), false)
  assert_eq(dirs[3].is_horizontal(), true)
}
