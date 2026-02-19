///|
pub enum RadialLayoutPhases {
  P1_NODE_PLACEMENT
  P2_EDGE_ROUTING
}

///|
fn radial_layout_phase_ordinal(phase : RadialLayoutPhases) -> Int {
  match phase {
    P1_NODE_PLACEMENT => 0
    P2_EDGE_ROUTING => 1
  }
}

///|
pub let radial_layout_phase_descriptor : @core.PhaseDescriptor[
  RadialLayoutPhases,
] = @core.new_phase_descriptor(
  [RadialLayoutPhases::P1_NODE_PLACEMENT, RadialLayoutPhases::P2_EDGE_ROUTING],
  radial_layout_phase_ordinal,
)

///|
pub fn radial_layout_phase_factory(
  phase : RadialLayoutPhases,
) -> @core.ILayoutPhaseFactory[RadialLayoutPhases, @graph.ElkNode] {
  match phase {
    P1_NODE_PLACEMENT =>
      @core.new_layout_processor_factory(31000, 0, () => {
        new_radial_eades_layout_phase()
      })
    P2_EDGE_ROUTING =>
      @core.new_layout_processor_factory(31001, 1, () => {
        new_radial_straight_line_edge_router_layout_phase()
      })
  }
}
