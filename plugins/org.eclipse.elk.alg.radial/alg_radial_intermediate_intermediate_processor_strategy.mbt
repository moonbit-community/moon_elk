///|
pub enum RadialIntermediateProcessorStrategy {
  OVERLAP_REMOVAL
  COMPACTION
  ROTATION
  GRAPH_SIZE_CALCULATION
  OUTGOING_EDGE_ANGLES
}

///|
fn radial_intermediate_strategy_ordinal(
  strategy : RadialIntermediateProcessorStrategy,
) -> Int {
  match strategy {
    OVERLAP_REMOVAL => 0
    COMPACTION => 1
    ROTATION => 2
    GRAPH_SIZE_CALCULATION => 3
    OUTGOING_EDGE_ANGLES => 4
  }
}

///|
pub fn radial_intermediate_processor_factory(
  strategy : RadialIntermediateProcessorStrategy,
) -> ILayoutProcessorFactory[RadialLayoutPhases, ElkNode] {
  let order = radial_intermediate_strategy_ordinal(strategy)
  let id = 31100 + order
  match strategy {
    OVERLAP_REMOVAL =>
      new_layout_processor_factory(id, order, () => {
        new_radius_extension_overlap_removal_layout_processor()
      })
    COMPACTION =>
      new_layout_processor_factory(id, order, () => {
        new_radial_general_compactor_layout_processor()
      })
    ROTATION =>
      new_layout_processor_factory(id, order, () => {
        new_radial_general_rotator_layout_processor()
      })
    GRAPH_SIZE_CALCULATION =>
      new_layout_processor_factory(id, order, () => {
        new_radial_calculate_graph_size_layout_processor()
      })
    OUTGOING_EDGE_ANGLES =>
      new_layout_processor_factory(id, order, () => {
        new_radial_edge_angle_calculator_layout_processor()
      })
  }
}
