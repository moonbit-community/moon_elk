///|
pub enum RadialSortingStrategy {
  NONE
  POLAR_COORDINATE
  ID
}

///|
pub fn radial_sorting_strategy_create(
  strategy : RadialSortingStrategy,
) -> IRadialSorter? {
  match strategy {
    RadialSortingStrategy::NONE => None
    RadialSortingStrategy::POLAR_COORDINATE =>
      Some(new_polar_coordinate_sorter().as_i_radial_sorter())
    RadialSortingStrategy::ID => Some(new_id_sorter().as_i_radial_sorter())
  }
}
