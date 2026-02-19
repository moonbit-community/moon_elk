///|
pub enum SporeCompactionStrategy {
  DEPTH_FIRST
}

///|
pub fn spore_compaction_strategy_from_string(
  value : String,
) -> SporeCompactionStrategy {
  if value == "DEPTH_FIRST" {
    SporeCompactionStrategy::DEPTH_FIRST
  } else {
    SporeCompactionStrategy::DEPTH_FIRST
  }
}

///|
pub fn spore_compaction_strategy_phase_factory(
  strategy : SporeCompactionStrategy,
) -> ILayoutPhaseFactory[SPOrEPhases, SporeGraph] {
  match strategy {
    DEPTH_FIRST =>
      new_layout_processor_factory(82003, 2, () => {
        new_spore_shrink_tree_compaction_layout_phase()
      })
  }
}
