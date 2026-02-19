///|
fn successor_line_by_line_apply(
  coords : PolyominoCoords,
  poly : Polyomino,
) -> PolyominoCoords {
  ignore(poly)
  let x = coords.x
  let y = coords.y
  if x >= 0 {
    if x == y {
      return new_polyomino_coords(-x - 1, -x - 1)
    }
    if x == -y {
      return new_polyomino_coords(-x, y + 1)
    }
  }
  if x.abs() > y.abs() {
    if x < 0 {
      return new_polyomino_coords(-x, y)
    }
    return new_polyomino_coords(-x, y + 1)
  }
  new_polyomino_coords(x + 1, y)
}

///|
pub fn new_successor_line_by_line() -> IPolyominoSuccessor {
  new_ipolyomino_successor(successor_line_by_line_apply)
}
