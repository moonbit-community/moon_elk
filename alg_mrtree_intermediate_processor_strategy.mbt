///|
pub enum MrtreeIntermediateProcessorStrategy {
  RootProc
  FanProc
  LevelProc
  NeighborsProc
  LevelHeight
  DirectionProc
  NodePositionProc
  CompactionProc
  LevelCoords
  GraphBoundsProc
  DetreeifyingProc
}

///|
fn mrtree_intermediate_noop_process(
  graph : MrtreeGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  ignore(graph)
  ignore(progress_monitor)
}

///|
fn mrtree_intermediate_noop_processor() -> ILayoutProcessor[
  MrtreeTreeLayoutPhases,
  MrtreeGraph,
] {
  new_layout_processor(mrtree_intermediate_noop_process)
}

///|
fn mrtree_intermediate_strategy_ordinal(
  strategy : MrtreeIntermediateProcessorStrategy,
) -> Int {
  match strategy {
    RootProc => 0
    FanProc => 1
    LevelProc => 2
    NeighborsProc => 3
    LevelHeight => 4
    DirectionProc => 5
    NodePositionProc => 6
    CompactionProc => 7
    LevelCoords => 8
    GraphBoundsProc => 9
    DetreeifyingProc => 10
  }
}

///|
pub fn mrtree_intermediate_processor_factory(
  strategy : MrtreeIntermediateProcessorStrategy,
) -> ILayoutProcessorFactory[MrtreeTreeLayoutPhases, MrtreeGraph] {
  let order = mrtree_intermediate_strategy_ordinal(strategy)
  let id = 21200 + order
  match strategy {
    RootProc =>
      new_layout_processor_factory(id, order, () => {
        new_mrtree_root_processor_layout_processor()
      })
    FanProc =>
      new_layout_processor_factory(id, order, () => {
        new_mrtree_fan_processor_layout_processor()
      })
    LevelProc =>
      new_layout_processor_factory(id, order, () => {
        new_mrtree_level_processor_layout_processor()
      })
    DetreeifyingProc =>
      new_layout_processor_factory(id, order, () => {
        new_mrtree_untreeifyer_layout_processor()
      })
    _ =>
      new_layout_processor_factory(
        id, order, mrtree_intermediate_noop_processor,
      )
  }
}
