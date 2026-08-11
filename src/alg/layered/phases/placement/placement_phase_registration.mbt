///|
fn register_node_placement_phase(
  registry : @runtime.LayeredPhaseRegistry,
  strategy : String,
  id : Int,
  create : () -> @core.ILayoutProcessor[@runtime.LayeredPhases, @runtime.LGraph] raise?,
) -> Unit {
  registry.register_node_placement_phase(
    strategy,
    @core.new_layout_processor_factory(id, 3, fn() raise { create() }),
  )
}

///|
pub fn register_node_placement_phases(
  registry : @runtime.LayeredPhaseRegistry,
) -> Unit {
  register_node_placement_phase(
    registry, "SIMPLE", 24100, new_simple_node_placer_layout_phase,
  )
  register_node_placement_phase(
    registry, "INTERACTIVE", 24101, new_interactive_node_placer_layout_phase,
  )
  register_node_placement_phase(
    registry, "LINEAR_SEGMENTS", 24102, new_linear_segments_node_placer_layout_phase,
  )
  register_node_placement_phase(
    registry, "BRANDES_KOEPF", 24103, new_bk_node_placer_layout_phase,
  )
  register_node_placement_phase(
    registry, "NETWORK_SIMPLEX", 24104, new_network_simplex_placer_layout_phase,
  )
}
