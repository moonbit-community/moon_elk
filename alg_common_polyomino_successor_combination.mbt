///|
fn successor_combination_apply(
  normal_fun : IPolyominoSuccessor,
  external_fun : IPolyominoSuccessor,
  coords : PolyominoCoords,
  poly : Polyomino,
) -> PolyominoCoords {
  if poly.get_polyomino_extensions().length() > 0 {
    external_fun.apply(coords, poly)
  } else {
    normal_fun.apply(coords, poly)
  }
}

///|
pub fn new_successor_combination(
  normal_fun : IPolyominoSuccessor,
  external_fun : IPolyominoSuccessor,
) -> IPolyominoSuccessor {
  new_ipolyomino_successor((coords, poly) => {
    successor_combination_apply(normal_fun, external_fun, coords, poly)
  })
}
