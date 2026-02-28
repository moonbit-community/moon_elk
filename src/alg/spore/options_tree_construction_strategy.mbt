///|
pub enum SporeTreeConstructionStrategy {
  MINIMUM_SPANNING_TREE
  MAXIMUM_SPANNING_TREE
}

///|
pub fn spore_tree_construction_strategy_from_string(
  value : String,
) -> SporeTreeConstructionStrategy {
  if value == "MAXIMUM_SPANNING_TREE" {
    SporeTreeConstructionStrategy::MAXIMUM_SPANNING_TREE
  } else {
    SporeTreeConstructionStrategy::MINIMUM_SPANNING_TREE
  }
}

///|
pub fn spore_tree_construction_strategy_phase_factory(
  strategy : SporeTreeConstructionStrategy,
) -> @core.ILayoutPhaseFactory[SPOrEPhases, SporeGraph] {
  match strategy {
    MINIMUM_SPANNING_TREE =>
      @core.new_layout_processor_factory(82001, 1, () => {
        new_spore_min_st_layout_phase()
      })
    MAXIMUM_SPANNING_TREE =>
      @core.new_layout_processor_factory(82002, 1, () => {
        new_spore_max_st_layout_phase()
      })
  }
}
