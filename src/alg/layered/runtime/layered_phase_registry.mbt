///|
/// Runtime-owned registry for the concrete phases linked into one layered
/// engine. Keeping the maps on this object makes independent runtimes
/// reentrant and prevents package initialization from mutating process state.
pub struct LayeredPhaseRegistry {
  cycle_breaking_factories : Map[
    String,
    @core.ILayoutProcessorFactory[LayeredPhases, LGraph],
  ]
  layering_factories : Map[
    String,
    @core.ILayoutProcessorFactory[LayeredPhases, LGraph],
  ]
  node_placement_factories : Map[
    String,
    @core.ILayoutProcessorFactory[LayeredPhases, LGraph],
  ]
  intermediate_processor_factories : Map[
    Int,
    @core.ILayoutProcessorFactory[LayeredPhases, LGraph],
  ]
}

///|
pub fn new_layered_phase_registry() -> LayeredPhaseRegistry {
  {
    cycle_breaking_factories: Map([]),
    layering_factories: Map([]),
    node_placement_factories: Map([]),
    intermediate_processor_factories: Map([]),
  }
}

///|
pub fn LayeredPhaseRegistry::register_cycle_breaking_phase(
  self : LayeredPhaseRegistry,
  strategy : String,
  factory : @core.ILayoutProcessorFactory[LayeredPhases, LGraph],
) -> Unit {
  self.cycle_breaking_factories[strategy] = factory
}

///|
pub fn LayeredPhaseRegistry::register_layering_phase(
  self : LayeredPhaseRegistry,
  strategy : String,
  factory : @core.ILayoutProcessorFactory[LayeredPhases, LGraph],
) -> Unit {
  self.layering_factories[strategy] = factory
}

///|
pub fn LayeredPhaseRegistry::register_node_placement_phase(
  self : LayeredPhaseRegistry,
  strategy : String,
  factory : @core.ILayoutProcessorFactory[LayeredPhases, LGraph],
) -> Unit {
  self.node_placement_factories[strategy] = factory
}

///|
pub fn LayeredPhaseRegistry::register_intermediate_processor(
  self : LayeredPhaseRegistry,
  strategy : IntermediateProcessorStrategy,
  factory : @core.ILayoutProcessorFactory[LayeredPhases, LGraph],
) -> Unit {
  self.intermediate_processor_factories[intermediate_processor_strategy_ordinal(
    strategy,
  )] = factory
}

///|
fn layered_missing_cycle_breaking_factory(
  strategy : String,
) -> @core.ILayoutProcessorFactory[LayeredPhases, LGraph] raise {
  @core.layout_runtime_raise_unsupported_configuration(
    "Layered cycle-breaking phase is not linked for strategy " + strategy,
  )
  @core.new_layout_processor_factory(21000, 0, () => {
    @core.new_layout_processor((_, _) => ())
  })
}

///|
pub fn LayeredPhaseRegistry::cycle_breaking_phase_factory(
  self : LayeredPhaseRegistry,
  strategy : String,
) -> @core.ILayoutProcessorFactory[LayeredPhases, LGraph] raise {
  match self.cycle_breaking_factories.get(strategy) {
    Some(factory) => factory
    None =>
      match self.cycle_breaking_factories.get("GREEDY") {
        Some(factory) => factory
        None => layered_missing_cycle_breaking_factory(strategy)
      }
  }
}

///|
pub fn LayeredPhaseRegistry::layering_phase_factory(
  self : LayeredPhaseRegistry,
  strategy : String,
) -> @core.ILayoutProcessorFactory[LayeredPhases, LGraph] raise {
  match self.layering_factories.get(strategy) {
    Some(factory) => factory
    None =>
      match self.layering_factories.get("NETWORK_SIMPLEX") {
        Some(factory) => factory
        None => {
          @core.layout_runtime_raise_unsupported_configuration(
            "Layered layering phase is not linked for strategy " + strategy,
          )
          @core.new_layout_processor_factory(22000, 1, () => {
            @core.new_layout_processor((_, _) => ())
          })
        }
      }
  }
}

///|
pub fn LayeredPhaseRegistry::node_placement_phase_factory(
  self : LayeredPhaseRegistry,
  strategy : String,
) -> @core.ILayoutProcessorFactory[LayeredPhases, LGraph] raise {
  match self.node_placement_factories.get(strategy) {
    Some(factory) => factory
    None =>
      match self.node_placement_factories.get("BRANDES_KOEPF") {
        Some(factory) => factory
        None => {
          @core.layout_runtime_raise_unsupported_configuration(
            "Layered node-placement phase is not linked for strategy " +
            strategy,
          )
          @core.new_layout_processor_factory(24103, 3, () => {
            @core.new_layout_processor((_, _) => ())
          })
        }
      }
  }
}

///|
pub fn LayeredPhaseRegistry::intermediate_processor_factory(
  self : LayeredPhaseRegistry,
  strategy : IntermediateProcessorStrategy,
) -> @core.ILayoutProcessorFactory[LayeredPhases, LGraph] {
  let ordinal = intermediate_processor_strategy_ordinal(strategy)
  @core.new_layout_processor_factory(23000 + ordinal, ordinal, fn() raise {
    match self.intermediate_processor_factories.get(ordinal) {
      Some(factory) => factory.create()
      None => intermediate_processor_create(strategy)
    }
  })
}
