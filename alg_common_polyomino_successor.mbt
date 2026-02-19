///|
pub struct PolyominoCoords {
  x : Int
  y : Int
} derive(Eq, Show)

///|
pub fn new_polyomino_coords(x : Int, y : Int) -> PolyominoCoords {
  { x, y }
}

///|
pub struct IPolyominoSuccessor {
  apply : (PolyominoCoords, Polyomino) -> PolyominoCoords
}

///|
pub fn new_ipolyomino_successor(
  apply : (PolyominoCoords, Polyomino) -> PolyominoCoords,
) -> IPolyominoSuccessor {
  { apply, }
}

///|
pub fn IPolyominoSuccessor::apply(
  self : IPolyominoSuccessor,
  coords : PolyominoCoords,
  poly : Polyomino,
) -> PolyominoCoords {
  (self.apply)(coords, poly)
}
