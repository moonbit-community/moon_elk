///|
pub struct SporeShrinkTree {
  algorithm_assembler : @core.AlgorithmAssembler[SPOrEPhases, SporeGraph]
}

///|
pub fn new_spore_shrink_tree() -> SporeShrinkTree {
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
) -> Unit {
  ignore(self.algorithm_assembler.reset())
  ignore(
    self.algorithm_assembler.set_phase(
      SPOrEPhases::P1_STRUCTURE,
      spore_structure_extraction_strategy_phase_factory(
        SporeStructureExtractionStrategy::DELAUNAY_TRIANGULATION,
      ),
    ),
  )
  ignore(
    self.algorithm_assembler.set_phase(
      SPOrEPhases::P2_PROCESSING_ORDER,
      spore_tree_construction_strategy_phase_factory(
        graph.tree_construction_strategy,
      ),
    ),
  )
  ignore(
    self.algorithm_assembler.set_phase(
      SPOrEPhases::P3_EXECUTION,
      spore_compaction_strategy_phase_factory(graph.compaction_strategy),
    ),
  )
  let algorithm = self.algorithm_assembler.build(graph)
  ignore(
    progress_monitor.begin(
      "Compaction by shrinking a tree",
      algorithm.length().to_double(),
    ),
  )
  if graph.vertices.length() > 1 {
    for processor in algorithm {
      processor.process(graph, progress_monitor.sub_task(1.0))
    }
  }
  progress_monitor.done()
}
