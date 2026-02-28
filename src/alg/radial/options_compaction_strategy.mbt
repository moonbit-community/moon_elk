///|
pub enum RadialCompactionStrategy {
  NONE
  RADIAL_COMPACTION
  WEDGE_COMPACTION
}

///|
pub(all) suberror RadialCompactionStrategyException {
  IllegalArgumentException(String)
} derive(Show, ToJson)

///|
fn[T] radial_compaction_strategy_raise_illegal_argument(
  message : String,
) -> T raise RadialCompactionStrategyException {
  raise RadialCompactionStrategyException::IllegalArgumentException(message)
}

///|
pub fn radial_compaction_strategy_create(
  strategy : RadialCompactionStrategy,
) -> IRadialCompactor raise RadialCompactionStrategyException {
  match strategy {
    RadialCompactionStrategy::RADIAL_COMPACTION =>
      new_i_radial_compactor(graph => new_radial_compaction().compact(graph))
    RadialCompactionStrategy::WEDGE_COMPACTION =>
      new_i_radial_compactor(graph => {
        new_annulus_wedge_compaction().compact(graph)
      })
    RadialCompactionStrategy::NONE =>
      radial_compaction_strategy_raise_illegal_argument(
        "No implementation is available for the layout option NONE",
      )
  }
}
