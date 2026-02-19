///|
fn successor_jitter_apply(
  coords : PolyominoCoords,
  poly : Polyomino,
) -> PolyominoCoords {
  ignore(poly)
  let x = coords.x
  let y = coords.y

  let mut new_x = x
  let mut new_y = y

  let cost = @cmp.maximum(x.abs(), y.abs())

  if x <= 0 && x == y {
    new_x = 0
    new_y = y - 1
  } else if x == -cost && y != cost {
    new_x = y
    new_y = x
    if y >= 0 {
      new_x = new_x + 1
    }
  } else {
    new_x = -y
    new_y = x
  }
  new_polyomino_coords(new_x, new_y)
}

///|
pub fn new_successor_jitter() -> IPolyominoSuccessor {
  new_ipolyomino_successor(successor_jitter_apply)
}
