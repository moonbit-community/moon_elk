///|
test "SuccessorLineByLine follows reference sequence" {
  let succ = new_successor_line_by_line()
  let poly = new_empty_polyomino()

  let mut coords = new_polyomino_coords(0, 0)
  coords = succ.apply(coords, poly)
  assert_eq(coords.x, -1)
  assert_eq(coords.y, -1)

  coords = succ.apply(coords, poly)
  assert_eq(coords.x, 0)
  assert_eq(coords.y, -1)

  coords = succ.apply(coords, poly)
  assert_eq(coords.x, 1)
  assert_eq(coords.y, -1)

  coords = succ.apply(coords, poly)
  assert_eq(coords.x, -1)
  assert_eq(coords.y, 0)
}

///|
test "SuccessorManhattan follows reference sequence" {
  let succ = new_successor_manhattan()
  let poly = new_empty_polyomino()

  let mut coords = new_polyomino_coords(0, 0)
  coords = succ.apply(coords, poly)
  assert_eq(coords.x, 0)
  assert_eq(coords.y, -1)

  coords = succ.apply(coords, poly)
  assert_eq(coords.x, 1)
  assert_eq(coords.y, 0)

  coords = succ.apply(coords, poly)
  assert_eq(coords.x, 0)
  assert_eq(coords.y, 1)

  coords = succ.apply(coords, poly)
  assert_eq(coords.x, -1)
  assert_eq(coords.y, 0)
}

///|
test "SuccessorJitter follows reference sequence" {
  let succ = new_successor_jitter()
  let poly = new_empty_polyomino()

  let mut coords = new_polyomino_coords(0, 0)
  coords = succ.apply(coords, poly)
  assert_eq(coords.x, 0)
  assert_eq(coords.y, -1)

  coords = succ.apply(coords, poly)
  assert_eq(coords.x, 1)
  assert_eq(coords.y, 0)

  coords = succ.apply(coords, poly)
  assert_eq(coords.x, 0)
  assert_eq(coords.y, 1)

  coords = succ.apply(coords, poly)
  assert_eq(coords.x, -1)
  assert_eq(coords.y, 0)
}

///|
test "SuccessorMaxNormWinding follows reference sequence" {
  let succ = new_successor_max_norm_winding_in_math_pos_sense()
  let poly = new_empty_polyomino()

  let mut coords = new_polyomino_coords(0, 0)
  coords = succ.apply(coords, poly)
  assert_eq(coords.x, -1)
  assert_eq(coords.y, 0)

  coords = succ.apply(coords, poly)
  assert_eq(coords.x, -1)
  assert_eq(coords.y, -1)

  coords = succ.apply(coords, poly)
  assert_eq(coords.x, 0)
  assert_eq(coords.y, -1)

  coords = succ.apply(coords, poly)
  assert_eq(coords.x, 1)
  assert_eq(coords.y, -1)
}

///|
test "SuccessorQuadrantsGeneric skips invalid quadrants" {
  let base = new_successor_manhattan()
  let succ = new_successor_quadrants_generic(base)
  let north = polyomino_direction_values()[0]
  let poly = new_polyomino_with_extensions(1, 1, [unique_triple_of(north, 0, 0)])

  let first = succ.apply(new_polyomino_coords(0, 0), poly)
  assert_eq(first.x, 0)
  assert_eq(first.y, -1)

  let second = succ.apply(first, poly)
  assert_eq(second.x, 0)
  assert_eq(second.y, -2)
}

///|
test "SuccessorCombination selects function by extensions" {
  let normal = new_successor_manhattan()
  let external = new_successor_jitter()
  let succ = new_successor_combination(normal, external)
  let east = polyomino_direction_values()[1]

  let no_extension_poly = new_polyomino(1, 1)
  let extension_poly = new_polyomino_with_extensions(1, 1, [
    unique_triple_of(east, 0, 0),
  ])

  let start = new_polyomino_coords(-1, 0)
  let normal_next = succ.apply(start, no_extension_poly)
  let external_next = succ.apply(start, extension_poly)

  assert_eq(normal_next.x, 0)
  assert_eq(normal_next.y, -2)
  assert_eq(external_next.x, 1)
  assert_eq(external_next.y, -1)
}
