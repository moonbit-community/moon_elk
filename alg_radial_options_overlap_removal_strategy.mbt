///|
pub enum RadialOverlapRemovalStrategy {
  EXTENT_RADII
}

///|
pub fn radial_overlap_removal_strategy_create(
  strategy : RadialOverlapRemovalStrategy,
) -> IOverlapRemoval {
  match strategy {
    RadialOverlapRemovalStrategy::EXTENT_RADII =>
      new_radius_extension_overlap_removal().as_i_overlap_removal()
  }
}
