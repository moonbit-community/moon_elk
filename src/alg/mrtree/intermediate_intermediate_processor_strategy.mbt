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
let _mrtree_intermediate_processor_strategy_reserved : Array[
  MrtreeIntermediateProcessorStrategy,
] = [
  MrtreeIntermediateProcessorStrategy::CompactionProc,
  MrtreeIntermediateProcessorStrategy::LevelCoords,
  MrtreeIntermediateProcessorStrategy::GraphBoundsProc,
]

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
) -> @core.ILayoutProcessorFactory[MrtreeTreeLayoutPhases, MrtreeGraph] {
  let order = mrtree_intermediate_strategy_ordinal(strategy)
  let id = 21200 + order
  match strategy {
    RootProc =>
      @core.new_layout_processor_factory(id, order, () => {
        new_mrtree_root_processor_layout_processor()
      })
    FanProc =>
      @core.new_layout_processor_factory(id, order, () => {
        new_mrtree_fan_processor_layout_processor()
      })
    LevelProc =>
      @core.new_layout_processor_factory(id, order, () => {
        new_mrtree_level_processor_layout_processor()
      })
    NeighborsProc =>
      @core.new_layout_processor_factory(id, order, () => {
        new_mrtree_neighbors_processor_layout_processor()
      })
    LevelHeight =>
      @core.new_layout_processor_factory(id, order, () => {
        new_mrtree_level_height_processor_layout_processor()
      })
    DirectionProc =>
      @core.new_layout_processor_factory(id, order, () => {
        new_mrtree_direction_processor_layout_processor()
      })
    NodePositionProc =>
      @core.new_layout_processor_factory(id, order, () => {
        new_mrtree_node_position_processor_layout_processor()
      })
    CompactionProc =>
      @core.new_layout_processor_factory(id, order, () => {
        new_mrtree_compaction_processor_layout_processor()
      })
    LevelCoords =>
      @core.new_layout_processor_factory(id, order, () => {
        new_mrtree_level_coordinates_processor_layout_processor()
      })
    GraphBoundsProc =>
      @core.new_layout_processor_factory(id, order, () => {
        new_mrtree_graph_bounds_processor_layout_processor()
      })
    DetreeifyingProc =>
      @core.new_layout_processor_factory(id, order, () => {
        new_mrtree_untreeifyer_layout_processor()
      })
  }
}
