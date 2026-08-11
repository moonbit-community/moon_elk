///|
pub enum SporeCompactionStrategy {
  DEPTH_FIRST
}

///|
pub fn spore_compaction_strategy_from_string(
  value : String,
) -> SporeCompactionStrategy {
  if value == "DEPTH_FIRST" {
    DEPTH_FIRST
  } else {
    DEPTH_FIRST
  }
}

///|
pub fn spore_compaction_strategy_phase_factory(
  strategy : SporeCompactionStrategy,
  graph : SporeGraph,
) -> @core.LayoutProcessorFactory {
  match strategy {
    DEPTH_FIRST =>
      @core.new_layout_processor_factory(82003, 2, graph, () => {
        new_spore_shrink_tree_compaction_layout_phase()
      })
  }
}
