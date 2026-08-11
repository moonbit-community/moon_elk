///|
pub type RadialLayoutPhases = @core.PhaseId

///|
pub const P1_NODE_PLACEMENT : RadialLayoutPhases = 0

///|
pub const P2_EDGE_ROUTING : RadialLayoutPhases = 1

///|
pub let radial_layout_phase_descriptor : @core.PhaseDescriptor = @core.new_phase_descriptor([
    P1_NODE_PLACEMENT,
    P2_EDGE_ROUTING,
  ],
)

///|
pub fn radial_layout_phase_factory(
  phase : RadialLayoutPhases,
  graph : @graph.ElkNode,
) -> @core.LayoutProcessorFactory {
  if phase == P1_NODE_PLACEMENT {
    @core.new_layout_processor_factory(31000, 0, graph, () => {
      new_radial_eades_layout_phase()
    })
  } else {
    @core.new_layout_processor_factory(31001, 1, graph, () => {
      new_radial_straight_line_edge_router_layout_phase()
    })
  }
}
