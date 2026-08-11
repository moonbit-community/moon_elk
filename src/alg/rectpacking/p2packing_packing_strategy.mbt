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
    SIMPLE
  } else if value == "NONE" {
    NONE
  } else {
    COMPACTION
  }
}

///|
pub fn rectpacking_packing_strategy_phase_factory(
  session : RectPackingSession,
  strategy : RectpackingPackingStrategy,
  graph : @graph.ElkNode,
) -> @core.LayoutProcessorFactory {
  match strategy {
    COMPACTION =>
      @core.new_layout_processor_factory(84100, 0, graph, () => {
        new_rectpacking_compactor_layout_phase(session)
      })
    SIMPLE =>
      @core.new_layout_processor_factory(84101, 1, graph, () => {
        new_rectpacking_simple_placement_layout_phase(session)
      })
    NONE =>
      @core.new_layout_processor_factory(84102, 2, graph, () => {
        new_rectpacking_no_placement_layout_phase()
      })
  }
}
