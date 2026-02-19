///|
fn count_blocked_cells(grid : PlanarGrid) -> Int {
  let mut count = 0
  for x in 0..<grid.width() {
    for y in 0..<grid.height() {
      if grid.is_blocked(x, y) {
        count = count + 1
      }
    }
  }
  count
}

///|
test "PolyominoCompactor packs without overlap" {
  let poly1 = new_polyomino(1, 1)
  poly1.set_blocked(0, 0)
  let poly2 = new_polyomino(1, 1)
  poly2.set_blocked(0, 0)

  let holder = new_polyominoes([poly1, poly2], 1.0)
  let spiral = traversal_strategy_values()[0]
  let by_size_and_shape = low_level_sorting_criterion_values()[1]
  let default_high_level = high_level_sorting_criterion_values()[0]
  ignore(holder.set_traversal_strategy(spiral))
  ignore(holder.set_low_level_sorting_criterion(by_size_and_shape))
  ignore(holder.set_high_level_sorting_criterion(default_high_level))

  let compactor = new_polyomino_compactor()
  compactor.pack_polyominoes(holder)

  let polys = holder.get_polyominoes()
  assert_eq(polys.length(), 2)
  assert_eq(polys[0].get_x() == polys[1].get_x(), false)

  let blocked_count = count_blocked_cells(holder.get_grid())
  assert_eq(blocked_count, 2)
}
