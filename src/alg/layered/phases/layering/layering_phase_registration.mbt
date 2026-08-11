///|
fn register_layering_phase(
  registry : @runtime.LayeredPhaseRegistry,
  strategy : String,
  id : Int,
  create : () -> @core.ILayoutProcessor[@runtime.LayeredPhases, @runtime.LGraph] raise?,
) -> Unit {
  registry.register_layering_phase(
    strategy,
    @core.new_layout_processor_factory(id, 1, fn() raise { create() }),
  )
}

///|
pub fn register_layering_phases(
  registry : @runtime.LayeredPhaseRegistry,
) -> Unit {
  register_layering_phase(
    registry, "LONGEST_PATH", 22001, new_longest_path_layerer_layout_phase,
  )
  register_layering_phase(
    registry, "LONGEST_PATH_SOURCE", 22002, new_longest_path_source_layerer_layout_phase,
  )
  register_layering_phase(
    registry, "COFFMAN_GRAHAM", 22003, new_coffman_graham_layerer_layout_phase,
  )
  register_layering_phase(
    registry, "INTERACTIVE", 22004, new_interactive_layerer_layout_phase,
  )
  register_layering_phase(
    registry, "STRETCH_WIDTH", 22005, new_stretch_width_layerer_layout_phase,
  )
  register_layering_phase(
    registry, "MIN_WIDTH", 22006, new_min_width_layerer_layout_phase,
  )
  register_layering_phase(
    registry, "BF_MODEL_ORDER", 22007, new_breadth_first_model_order_layerer_layout_phase,
  )
  register_layering_phase(
    registry, "DF_MODEL_ORDER", 22008, new_depth_first_model_order_layerer_layout_phase,
  )
  register_layering_phase(
    registry, "NETWORK_SIMPLEX", 22000, new_network_simplex_layerer_layout_phase,
  )
}
