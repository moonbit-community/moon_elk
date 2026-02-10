///|
pub struct Polyominoes {
  polys : Array[Polyomino]
  grid : PlanarGrid
  mut high_level_sorting_criterion : HighLevelSortingCriterion
  mut low_level_sorting_criterion : LowLevelSortingCriterion
  mut traversal_strategy : TraversalStrategy
}

///|
pub fn new_polyominoes(
  polyominoes : Array[Polyomino],
  aspect_ratio : Double,
  fill? : Bool = false,
) -> Polyominoes {
  let polys : Array[Polyomino] = []
  let mut grid_width = 0
  let mut grid_height = 0

  for poly in polyominoes {
    if fill {
      fill_polyomino(poly)
    }
    polys.push(poly)
    grid_width += poly.width()
    grid_height += poly.height()
  }

  if polys.length() > 0 {
    let poly = polys[0]
    grid_width += poly.width()
    grid_height += poly.height()
  }

  grid_width = grid_width * 2
  grid_height = grid_height * 2

  if aspect_ratio > 1.0 {
    grid_width = (grid_width.to_double() * aspect_ratio).ceil().to_int()
  } else {
    grid_height = (grid_height.to_double() / aspect_ratio).ceil().to_int()
  }

  {
    polys,
    grid: new_planar_grid(grid_width, grid_height),
    high_level_sorting_criterion: NumOfExternalSidesThanNumOfExtensionsLast,
    low_level_sorting_criterion: BySizeAndShape,
    traversal_strategy: QuadrantsJitter,
  }
}

///|
pub fn Polyominoes::get_polyominoes(self : Polyominoes) -> Array[Polyomino] {
  self.polys
}

///|
pub fn Polyominoes::get_grid(self : Polyominoes) -> PlanarGrid {
  self.grid
}

///|
pub fn Polyominoes::set_high_level_sorting_criterion(
  self : Polyominoes,
  criterion : HighLevelSortingCriterion,
) -> Polyominoes {
  self.high_level_sorting_criterion = criterion
  self
}

///|
pub fn Polyominoes::set_low_level_sorting_criterion(
  self : Polyominoes,
  criterion : LowLevelSortingCriterion,
) -> Polyominoes {
  self.low_level_sorting_criterion = criterion
  self
}

///|
pub fn Polyominoes::set_traversal_strategy(
  self : Polyominoes,
  strategy : TraversalStrategy,
) -> Polyominoes {
  self.traversal_strategy = strategy
  self
}

///|
pub fn Polyominoes::get_high_level_sorting_criterion(
  self : Polyominoes,
) -> HighLevelSortingCriterion {
  self.high_level_sorting_criterion
}

///|
pub fn Polyominoes::get_low_level_sorting_criterion(
  self : Polyominoes,
) -> LowLevelSortingCriterion {
  self.low_level_sorting_criterion
}

///|
pub fn Polyominoes::get_traversal_strategy(
  self : Polyominoes,
) -> TraversalStrategy {
  self.traversal_strategy
}
