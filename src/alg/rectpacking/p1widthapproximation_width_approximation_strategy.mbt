///|
pub enum RectpackingWidthApproximationStrategy {
  GREEDY
  TARGET_WIDTH
}

///|
pub fn rectpacking_width_approximation_strategy_from_string(
  value : String,
) -> RectpackingWidthApproximationStrategy {
  if value == "TARGET_WIDTH" {
    RectpackingWidthApproximationStrategy::TARGET_WIDTH
  } else {
    RectpackingWidthApproximationStrategy::GREEDY
  }
}

///|
pub fn rectpacking_width_approximation_strategy_phase_factory(
  strategy : RectpackingWidthApproximationStrategy,
) -> @core.ILayoutPhaseFactory[RectPackingLayoutPhases, @graph.ElkNode] {
  match strategy {
    GREEDY =>
      @core.new_layout_processor_factory(84000, 0, () => {
        new_rectpacking_greedy_width_approximator_layout_phase()
      })
    TARGET_WIDTH =>
      @core.new_layout_processor_factory(84001, 1, () => {
        new_rectpacking_target_width_approximator_layout_phase()
      })
  }
}
