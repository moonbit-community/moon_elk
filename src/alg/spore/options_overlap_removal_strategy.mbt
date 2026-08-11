///|
pub enum SporeOverlapRemovalStrategy {
  GROW_TREE
}

///|
pub fn spore_overlap_removal_strategy_phase_factory(
  strategy : SporeOverlapRemovalStrategy,
  graph : SporeGraph,
) -> @core.LayoutProcessorFactory {
  match strategy {
    GROW_TREE =>
      @core.new_layout_processor_factory(82004, 2, graph, () => {
        new_spore_grow_tree_layout_phase()
      })
  }
}
