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
) -> @core.ILayoutPhaseFactory[RectPackingLayoutPhases, @graph.ElkNode] {
  match strategy {
    COMPACTION =>
      @core.new_layout_processor_factory(84100, 0, () => {
        new_rectpacking_compactor_layout_phase()
      })
    SIMPLE =>
      @core.new_layout_processor_factory(84101, 1, () => {
        new_rectpacking_simple_placement_layout_phase()
      })
    NONE =>
      @core.new_layout_processor_factory(84102, 2, () => {
        new_rectpacking_no_placement_layout_phase()
      })
  }
}
