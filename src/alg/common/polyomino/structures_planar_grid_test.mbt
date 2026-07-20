///|
fn poly_dir_north() -> PolyominoDirection {
  polyomino_direction_values()[0]
}

///|
test "PlanarGrid center coordinates and center based access" {
  let grid = new_planar_grid(5, 5)
  assert_eq(grid.get_center_x(), 2)
  assert_eq(grid.get_center_y(), 2)

  grid.set_blocked_center_based(0, 0)
  assert_eq(grid.is_blocked(2, 2), true)
  assert_eq(grid.is_blocked_center_based(0, 0), true)
  assert_eq(grid.in_bounds_center_based(2, 2), true)
}

///|
test "PlanarGrid intersects semantics with weak and blocked cells" {
  let left = new_planar_grid(5, 5)
  let right = new_planar_grid(3, 3)
  left.set_blocked_center_based(0, 0)
  right.set_blocked_center_based(0, 0)
  assert_eq(left.intersects_with_center_based(right, 0, 0), true)
  assert_eq(left.intersects_with_center_based(right, 2, 0), false)

  let weak_a = new_planar_grid(5, 5)
  let weak_b = new_planar_grid(3, 3)
  weak_a.set_weakly_blocked_center_based(0, 0)
  weak_b.set_weakly_blocked_center_based(0, 0)
  assert_eq(weak_a.intersects_with_center_based(weak_b, 0, 0), false)

  weak_b.set_blocked_center_based(0, 0)
  assert_eq(weak_a.intersects_with_center_based(weak_b, 0, 0), true)
}

///|
test "PlanarGrid add_filled_cells_from precedence and bounds helpers" {
  let target = new_planar_grid(7, 7)
  target.set_weakly_blocked_center_based(0, 0)
  target.set_blocked(1, 1)
  target.set_blocked(4, 3)

  let source = new_planar_grid(3, 3)
  source.set_blocked_center_based(0, 0)
  source.set_weakly_blocked_center_based(1, 0)
  target.add_filled_cells_from(source, 0, 0)

  assert_eq(target.is_weakly_blocked_center_based(0, 0), true)
  assert_eq(target.is_blocked_center_based(1, 0), true)
  assert_eq(target.is_weakly_blocked_center_based(1, 0), false)

  target.weakly_block_area(0, 0, 1, 1)
  assert_eq(target.weakly_intersects_area(0, 0, 1, 1), true)

  let bounds = target.get_filled_bounds()
  assert_eq(bounds.get_first(), 1)
  assert_eq(bounds.get_second(), 1)
  assert_eq(bounds.get_third(), 4)
  assert_eq(bounds.get_fourth(), 3)
}

///|
test "PlanarGrid add_filled_cells_from_polyomino applies extensions" {
  let grid = new_planar_grid(9, 9)
  let poly = new_polyomino(3, 3)
  poly.set_blocked_center_based(0, 0)
  poly.add_extension(poly_dir_north(), 1, 1)

  grid.add_filled_cells_from_polyomino(poly, 0, 0)

  assert_eq(poly.get_x(), 3)
  assert_eq(poly.get_y(), 3)
  assert_eq(grid.is_blocked(4, 4), true)
  assert_eq(grid.is_weakly_blocked(4, 0), true)
  assert_eq(grid.is_weakly_blocked(4, 2), true)
}
