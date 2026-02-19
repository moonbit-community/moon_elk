///|
pub enum RadialCompactionStrategy {
  NONE
  RADIAL_COMPACTION
  WEDGE_COMPACTION
}

///|
pub fn radial_compaction_strategy_create(
  strategy : RadialCompactionStrategy,
) -> IRadialCompactor {
  match strategy {
    RadialCompactionStrategy::RADIAL_COMPACTION =>
      new_i_radial_compactor(graph => new_radial_compaction().compact(graph))
    RadialCompactionStrategy::WEDGE_COMPACTION =>
      new_i_radial_compactor(graph => {
        new_annulus_wedge_compaction().compact(graph)
      })
    RadialCompactionStrategy::NONE =>
      abort("No implementation is available for the layout option NONE")
  }
}
