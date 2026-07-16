///|
let layered_cycle_breaking_factories : Map[
  String,
  @core.ILayoutProcessorFactory[LayeredPhases, LGraph],
] = Map([])

///|
let layered_layering_factories : Map[
  String,
  @core.ILayoutProcessorFactory[LayeredPhases, LGraph],
] = Map([])

///|
/// Registers a cycle-breaking phase at the composition seam.
///
/// Concrete phase packages depend on the shared layered model and register
/// their factories here. The shared package therefore does not need to import
/// its concrete phase implementations, which keeps the dependency direction
/// acyclic as phases are extracted into packages.
pub fn register_layered_cycle_breaking_phase(
  strategy : String,
  factory : @core.ILayoutProcessorFactory[LayeredPhases, LGraph],
) -> Unit {
  layered_cycle_breaking_factories[strategy] = factory
}

///|
pub fn register_layered_layering_phase(
  strategy : String,
  factory : @core.ILayoutProcessorFactory[LayeredPhases, LGraph],
) -> Unit {
  layered_layering_factories[strategy] = factory
}

///|
fn layered_missing_cycle_breaking_factory(
  strategy : String,
) -> @core.ILayoutProcessorFactory[LayeredPhases, LGraph] {
  @core.layout_runtime_report_unsupported_configuration(
    "Layered cycle-breaking phase is not linked for strategy " + strategy,
  )
  @core.new_layout_processor_factory(21000, 0, () => {
    @core.new_layout_processor((_, _) => ())
  })
}

///|
fn layered_cycle_breaking_phase_factory(
  strategy : String,
) -> @core.ILayoutProcessorFactory[LayeredPhases, LGraph] {
  match layered_cycle_breaking_factories.get(strategy) {
    Some(factory) => factory
    None =>
      match layered_cycle_breaking_factories.get("GREEDY") {
        Some(factory) => factory
        None => layered_missing_cycle_breaking_factory(strategy)
      }
  }
}

///|
fn layered_layering_phase_factory(
  strategy : String,
) -> @core.ILayoutProcessorFactory[LayeredPhases, LGraph] {
  match layered_layering_factories.get(strategy) {
    Some(factory) => factory
    None =>
      match layered_layering_factories.get("NETWORK_SIMPLEX") {
        Some(factory) => factory
        None => {
          @core.layout_runtime_report_unsupported_configuration(
            "Layered layering phase is not linked for strategy " + strategy,
          )
          @core.new_layout_processor_factory(22000, 1, () => {
            @core.new_layout_processor((_, _) => ())
          })
        }
      }
  }
}
