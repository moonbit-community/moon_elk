///|
test "ProfileFill fills closed hole" {
  let poly = new_polyomino(3, 3)
  poly.set_blocked(0, 0)
  poly.set_blocked(1, 0)
  poly.set_blocked(2, 0)
  poly.set_blocked(0, 1)
  poly.set_blocked(2, 1)
  poly.set_blocked(0, 2)
  poly.set_blocked(1, 2)
  poly.set_blocked(2, 2)

  assert_eq(poly.is_blocked(1, 1), false)
  fill_polyomino(poly)
  assert_eq(poly.is_blocked(1, 1), true)
}
