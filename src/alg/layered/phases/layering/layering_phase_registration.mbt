///|
fn register_layering_phase(
  strategy : String,
  id : Int,
  create : () -> @core.ILayoutProcessor[@layered.LayeredPhases, @layered.LGraph],
) -> Unit {
  @layered.register_layered_layering_phase(
    strategy,
    @core.new_layout_processor_factory(id, 1, create),
  )
}

///|
fn init {
  register_layering_phase(
    "LONGEST_PATH", 22001, new_longest_path_layerer_layout_phase,
  )
  register_layering_phase(
    "LONGEST_PATH_SOURCE", 22002, new_longest_path_source_layerer_layout_phase,
  )
  register_layering_phase(
    "COFFMAN_GRAHAM", 22003, new_coffman_graham_layerer_layout_phase,
  )
  register_layering_phase(
    "INTERACTIVE", 22004, new_interactive_layerer_layout_phase,
  )
  register_layering_phase(
    "STRETCH_WIDTH", 22005, new_stretch_width_layerer_layout_phase,
  )
  register_layering_phase(
    "MIN_WIDTH", 22006, new_min_width_layerer_layout_phase,
  )
  register_layering_phase(
    "BF_MODEL_ORDER", 22007, new_breadth_first_model_order_layerer_layout_phase,
  )
  register_layering_phase(
    "DF_MODEL_ORDER", 22008, new_depth_first_model_order_layerer_layout_phase,
  )
  register_layering_phase(
    "NETWORK_SIMPLEX", 22000, new_network_simplex_layerer_layout_phase,
  )
}

///|
pub let layering_phase_linked : Bool = true
