///|
pub struct PolyominoCompactor {
  unit : Unit
}

///|
pub fn new_polyomino_compactor() -> PolyominoCompactor {
  { unit: () }
}

///|
priv struct PolyominoDirectionStats {
  count : Int
  horizontal_count : Int
}

///|
fn polyomino_compactor_compare_int(left : Int, right : Int) -> Int {
  if left < right {
    return -1
  }
  if left == right {
    return 0
  }
  1
}

///|
fn polyomino_compactor_direction_stats(
  poly : Polyomino,
) -> PolyominoDirectionStats {
  let mut north = false
  let mut east = false
  let mut south = false
  let mut west = false

  for ext in poly.get_polyomino_extensions() {
    match ext.get_first() {
      North => north = true
      East => east = true
      South => south = true
      West => west = true
    }
  }

  let mut count = 0
  let mut horizontal_count = 0
  if north {
    count += 1
  }
  if east {
    count += 1
    horizontal_count += 1
  }
  if south {
    count += 1
  }
  if west {
    count += 1
    horizontal_count += 1
  }

  { count, horizontal_count }
}

///|
fn polyomino_compactor_compare_min_perimeter(
  left : Polyomino,
  right : Polyomino,
) -> Int {
  let half_peri_left = left.width() + left.height()
  let half_peri_right = right.width() + right.height()
  polyomino_compactor_compare_int(half_peri_left, half_peri_right)
}

///|
fn polyomino_compactor_compare_min_perimeter_with_shape(
  left : Polyomino,
  right : Polyomino,
) -> Int {
  let mut width = left.width()
  let mut height = left.height()
  if width < height {
    width = width * width
  } else {
    height = height * height
  }
  let val_left = width + height

  width = right.width()
  height = right.height()
  if width < height {
    width = width * width
  } else {
    height = height * height
  }
  let val_right = width + height

  polyomino_compactor_compare_int(val_left, val_right)
}

///|
fn polyomino_compactor_compare_min_num_extensions(
  left : Polyomino,
  right : Polyomino,
) -> Int {
  polyomino_compactor_compare_int(
    left.get_polyomino_extensions().length(),
    right.get_polyomino_extensions().length(),
  )
}

///|
fn polyomino_compactor_compare_min_num_extension_directions(
  left : Polyomino,
  right : Polyomino,
) -> Int {
  let stats_left = polyomino_compactor_direction_stats(left)
  let stats_right = polyomino_compactor_direction_stats(right)
  polyomino_compactor_compare_int(stats_left.count, stats_right.count)
}

///|
fn polyomino_compactor_compare_single_extension_side_greater_than_rest(
  left : Polyomino,
  right : Polyomino,
) -> Int {
  let mut left_value = polyomino_compactor_direction_stats(left).count
  let mut right_value = polyomino_compactor_direction_stats(right).count
  left_value = if left_value == 1 { 1 } else { 0 }
  right_value = if right_value == 1 { 1 } else { 0 }
  polyomino_compactor_compare_int(left_value, right_value)
}

///|
fn polyomino_compactor_compare_corner_cases_greater_than_rest(
  left : Polyomino,
  right : Polyomino,
) -> Int {
  let left_stats = polyomino_compactor_direction_stats(left)
  let mut left_value = if left_stats.count == 2 { 1 } else { 0 }
  if left_value == 1 {
    if left_stats.horizontal_count % 2 == 0 {
      left_value = 0
    }
  }

  let right_stats = polyomino_compactor_direction_stats(right)
  let mut right_value = if right_stats.count == 2 { 1 } else { 0 }
  if right_value == 1 {
    if right_stats.horizontal_count % 2 == 0 {
      right_value = 0
    }
  }

  polyomino_compactor_compare_int(left_value, right_value)
}

///|
fn[T] polyomino_compactor_sort_in_place(
  array : Array[T],
  compare : (T, T) -> Int,
) -> Unit {
  let length = array.length()
  if length <= 1 {
    return
  }

  for i in 1..<length {
    let key = array[i]
    let mut j = i
    while j > 0 && compare(array[j - 1], key) > 0 {
      array[j] = array[j - 1]
      j -= 1
    }
    array[j] = key
  }
}

///|
fn polyomino_compactor_choose_successor(
  strategy : TraversalStrategy,
) -> IPolyominoSuccessor {
  match strategy {
    Spiral => new_successor_max_norm_winding_in_math_pos_sense()
    LineByLine => new_successor_line_by_line()
    Manhattan => new_successor_manhattan()
    Jitter => new_successor_jitter()
    QuadrantsManhattan =>
      new_successor_quadrants_generic(new_successor_manhattan())
    QuadrantsLineByLine =>
      new_successor_quadrants_generic(new_successor_line_by_line())
    CombineLineByLineManhattan =>
      new_successor_combination(
        new_successor_quadrants_generic(new_successor_line_by_line()),
        new_successor_quadrants_generic(new_successor_manhattan()),
      )
    CombineJitterManhattan =>
      new_successor_combination(
        new_successor_quadrants_generic(new_successor_jitter()),
        new_successor_quadrants_generic(new_successor_manhattan()),
      )
    QuadrantsJitter => new_successor_quadrants_generic(new_successor_jitter())
  }
}

///|
pub fn PolyominoCompactor::pack_polyominoes(
  self : PolyominoCompactor,
  poly_holder : Polyominoes,
) -> Unit {
  ignore(self)
  let polys = poly_holder.get_polyominoes()
  let grid = poly_holder.get_grid()

  match poly_holder.get_low_level_sorting_criterion() {
    BySize =>
      polyomino_compactor_sort_in_place(polys, (left, right) => {
        -polyomino_compactor_compare_min_perimeter(left, right)
      })
    BySizeAndShape =>
      polyomino_compactor_sort_in_place(polys, (left, right) => {
        -polyomino_compactor_compare_min_perimeter_with_shape(left, right)
      })
  }

  match poly_holder.get_high_level_sorting_criterion() {
    CornerCasesThanSingleSideLast => {
      polyomino_compactor_sort_in_place(
        polys, polyomino_compactor_compare_min_num_extensions,
      )
      polyomino_compactor_sort_in_place(
        polys, polyomino_compactor_compare_single_extension_side_greater_than_rest,
      )
      polyomino_compactor_sort_in_place(
        polys, polyomino_compactor_compare_corner_cases_greater_than_rest,
      )
    }
    NumOfExternalSidesThanNumOfExtensionsLast => {
      polyomino_compactor_sort_in_place(
        polys, polyomino_compactor_compare_min_num_extensions,
      )
      polyomino_compactor_sort_in_place(
        polys, polyomino_compactor_compare_min_num_extension_directions,
      )
    }
  }

  let successor_based_on_cost = polyomino_compactor_choose_successor(
    poly_holder.get_traversal_strategy(),
  )

  for poly in polys {
    let mut off_x = 0
    let mut off_y = 0
    let mut next = new_polyomino_coords(off_x, off_y)

    while grid.intersects_with_center_based_polyomino(poly, off_x, off_y) {
      next = successor_based_on_cost.apply(next, poly)
      off_x = next.x
      off_y = next.y
    }
    grid.add_filled_cells_from_polyomino(poly, off_x, off_y)
  }
}
