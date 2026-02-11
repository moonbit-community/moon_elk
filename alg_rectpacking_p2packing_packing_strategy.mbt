///|
pub enum RectpackingPackingStrategy {
  COMPACTION
  SIMPLE
  NONE
}

///|
pub fn rectpacking_packing_strategy_from_string(
  value : String,
) -> RectpackingPackingStrategy {
  if value == "SIMPLE" {
    RectpackingPackingStrategy::SIMPLE
  } else if value == "NONE" {
    RectpackingPackingStrategy::NONE
  } else {
    RectpackingPackingStrategy::COMPACTION
  }
}

///|
pub fn rectpacking_packing_strategy_phase_factory(
  strategy : RectpackingPackingStrategy,
) -> ILayoutPhaseFactory[RectPackingLayoutPhases, ElkNode] {
  match strategy {
    COMPACTION =>
      new_layout_processor_factory(84100, 0, () => {
        new_rectpacking_compactor_layout_phase()
      })
    SIMPLE =>
      new_layout_processor_factory(84101, 1, () => {
        new_rectpacking_simple_placement_layout_phase()
      })
    NONE =>
      new_layout_processor_factory(84102, 2, () => {
        new_rectpacking_no_placement_layout_phase()
      })
  }
}
