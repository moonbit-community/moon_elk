///|
fn successor_manhattan_apply(
  coords : PolyominoCoords,
  poly : Polyomino,
) -> PolyominoCoords {
  ignore(poly)
  let x = coords.x
  let y = coords.y

  let mut new_x = x
  let mut new_y = y

  if x == 0 && y == 0 {
    new_y -= 1
  } else if x == -1 && y <= 0 {
    new_x = 0
    new_y -= 2
  } else if x <= 0 && y > 0 {
    new_x -= 1
    new_y -= 1
  } else if x >= 0 && y < 0 {
    new_x += 1
    new_y += 1
  } else if x > 0 && y >= 0 {
    new_x -= 1
    new_y += 1
  } else {
    new_x += 1
    new_y -= 1
  }

  new_polyomino_coords(new_x, new_y)
}

///|
pub fn new_successor_manhattan() -> IPolyominoSuccessor {
  new_ipolyomino_successor(successor_manhattan_apply)
}
