///|
priv struct SuccessorQuadrantsMask {
  pos_x : Bool
  pos_y : Bool
  neg_x : Bool
  neg_y : Bool
}

///|
fn successor_quadrants_generic_mask(poly : Polyomino) -> SuccessorQuadrantsMask {
  let mut contains_north = false
  let mut contains_east = false
  let mut contains_south = false
  let mut contains_west = false

  for poly_ext in poly.get_polyomino_extensions() {
    match poly_ext.get_first() {
      North => contains_north = true
      East => contains_east = true
      South => contains_south = true
      West => contains_west = true
    }
  }

  let mut pos_x = true
  let mut pos_y = true
  let mut neg_x = true
  let mut neg_y = true

  if contains_north && !contains_south {
    pos_y = false
  }
  if !contains_north && contains_south {
    neg_y = false
  }

  if contains_east && !contains_west {
    neg_x = false
  }
  if !contains_east && contains_west {
    pos_x = false
  }

  { pos_x, pos_y, neg_x, neg_y }
}

///|
fn successor_quadrants_generic_apply(
  cost_fun : IPolyominoSuccessor,
  coords : PolyominoCoords,
  poly : Polyomino,
) -> PolyominoCoords {
  let mask = successor_quadrants_generic_mask(poly)
  let next_coords = cost_fun.apply(coords, poly)
  let new_x = next_coords.x
  let new_y = next_coords.y

  let mut invalid = false
  if new_x < 0 {
    if !mask.neg_x {
      invalid = true
    }
  } else if !mask.pos_x {
    invalid = true
  }
  if new_y < 0 {
    if !mask.neg_y {
      invalid = true
    }
  } else if !mask.pos_y {
    invalid = true
  }

  if invalid {
    return successor_quadrants_generic_apply(cost_fun, next_coords, poly)
  }
  next_coords
}

///|
pub fn new_successor_quadrants_generic(
  cost_fun : IPolyominoSuccessor,
) -> IPolyominoSuccessor {
  new_ipolyomino_successor((coords, poly) => {
    successor_quadrants_generic_apply(cost_fun, coords, poly)
  })
}
