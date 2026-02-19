///|
test "Polyominoes grid sizing with aspect ratio" {
  let poly1 = new_polyomino(2, 3)
  let poly2 = new_polyomino(4, 1)
  let polyominoes = new_polyominoes([poly1, poly2], 2.0)

  assert_eq(polyominoes.get_polyominoes().length(), 2)
  assert_eq(polyominoes.get_grid().width(), 32)
  assert_eq(polyominoes.get_grid().height(), 14)
}

///|
test "Polyominoes fill option invokes profile fill" {
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
  ignore(new_polyominoes([poly], 1.0, fill=true))
  assert_eq(poly.is_blocked(1, 1), true)
}
