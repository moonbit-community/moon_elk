///|
pub struct SporeShrinkTree {
  algorithm_assembler : @core.AlgorithmAssembler
}

///|
pub fn new_spore_shrink_tree() -> SporeShrinkTree raise {
  {
    algorithm_assembler: @core.algorithm_assembler_create(
      spore_phase_descriptor,
    ),
  }
}

///|
pub fn SporeShrinkTree::shrink(
  self : SporeShrinkTree,
  graph : SporeGraph,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit raise {
  ignore(self.algorithm_assembler.reset())
  ignore(
    self.algorithm_assembler.set_phase(
      P1_STRUCTURE,
      spore_structure_extraction_strategy_phase_factory(
        DELAUNAY_TRIANGULATION,
        graph,
      ),
    ),
  )
  ignore(
    self.algorithm_assembler.set_phase(
      P2_PROCESSING_ORDER,
      spore_tree_construction_strategy_phase_factory(
        graph.tree_construction_strategy,
        graph,
      ),
    ),
  )
  ignore(
    self.algorithm_assembler.set_phase(
      P3_EXECUTION,
      spore_compaction_strategy_phase_factory(graph.compaction_strategy, graph),
    ),
  )
  let plan = self.algorithm_assembler.build()
  ignore(
    progress_monitor.begin(
      "Compaction by shrinking a tree",
      plan.length().to_double(),
    ),
  )
  if graph.vertices.length() > 1 {
    for processor in plan.steps() {
      processor.run(progress_monitor.sub_task(1.0))
    }
  }
  progress_monitor.done()
}
