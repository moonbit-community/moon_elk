///|
fn successor_max_norm_winding_in_math_pos_sense_apply(
  coords : PolyominoCoords,
  poly : Polyomino,
) -> PolyominoCoords {
  ignore(poly)
  let x = coords.x
  let y = coords.y
  let cost = @cmp.maximum(x.abs(), y.abs())
  if x < cost && y == -cost {
    return new_polyomino_coords(x + 1, y)
  }
  if x == cost && y < cost {
    return new_polyomino_coords(x, y + 1)
  }
  if x >= -cost && y == cost {
    return new_polyomino_coords(x - 1, y)
  }
  new_polyomino_coords(x, y - 1)
}

///|
pub fn new_successor_max_norm_winding_in_math_pos_sense() -> IPolyominoSuccessor {
  new_ipolyomino_successor(successor_max_norm_winding_in_math_pos_sense_apply)
}
