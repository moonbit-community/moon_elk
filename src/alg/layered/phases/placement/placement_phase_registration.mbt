///|
fn register_node_placement_phase(
  strategy : String,
  id : Int,
  create : () -> @core.ILayoutProcessor[@layered.LayeredPhases, @layered.LGraph],
) -> Unit {
  @layered.register_layered_node_placement_phase(
    strategy,
    @core.new_layout_processor_factory(id, 3, create),
  )
}

///|
fn init {
  register_node_placement_phase(
    "SIMPLE", 24100, new_simple_node_placer_layout_phase,
  )
  register_node_placement_phase(
    "INTERACTIVE", 24101, new_interactive_node_placer_layout_phase,
  )
  register_node_placement_phase(
    "LINEAR_SEGMENTS", 24102, new_linear_segments_node_placer_layout_phase,
  )
  register_node_placement_phase(
    "BRANDES_KOEPF", 24103, new_bk_node_placer_layout_phase,
  )
  register_node_placement_phase(
    "NETWORK_SIMPLEX", 24104, new_network_simplex_placer_layout_phase,
  )
}

///|
pub let placement_phase_linked : Bool = true
