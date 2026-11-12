///|
#derive(Eq, Debug)
pub struct PolyominoCoords {
  x : Int32
  y : Int32
}

///|
pub fn new_polyomino_coords(x : Int32, y : Int32) -> PolyominoCoords {
  { x, y, }
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

///|
pub extend PolyominoCoords with Debug::{to_repr}

///|
pub extend PolyominoCoords with Eq::{not_equal, equal}
