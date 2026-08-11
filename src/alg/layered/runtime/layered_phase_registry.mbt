///|
/// Runtime-owned registry for the concrete phases linked into one layered
/// engine. Keeping the maps on this object makes independent runtimes
/// reentrant and prevents package initialization from mutating process state.
pub struct LayeredPhaseRegistry {
  cycle_breaking_factories : Map[
    String,
    (Int, Int, () -> @core.TypedLayoutProcessor[LGraph]),
  ]
  layering_factories : Map[
    String,
    (Int, Int, () -> @core.TypedLayoutProcessor[LGraph]),
  ]
  node_placement_factories : Map[
    String,
    (Int, Int, () -> @core.TypedLayoutProcessor[LGraph]),
  ]
  intermediate_processor_factories : Map[
    Int,
    (Int, Int, () -> @core.TypedLayoutProcessor[LGraph]),
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
  id : Int,
  create : () -> @core.TypedLayoutProcessor[LGraph],
) -> Unit {
  self.cycle_breaking_factories[strategy] = (id, 0, create)
}

///|
pub fn LayeredPhaseRegistry::register_layering_phase(
  self : LayeredPhaseRegistry,
  strategy : String,
  id : Int,
  create : () -> @core.TypedLayoutProcessor[LGraph],
) -> Unit {
  self.layering_factories[strategy] = (id, 1, create)
}

///|
pub fn LayeredPhaseRegistry::register_node_placement_phase(
  self : LayeredPhaseRegistry,
  strategy : String,
  id : Int,
  create : () -> @core.TypedLayoutProcessor[LGraph],
) -> Unit {
  self.node_placement_factories[strategy] = (id, 3, create)
}

///|
pub fn LayeredPhaseRegistry::register_intermediate_processor(
  self : LayeredPhaseRegistry,
  strategy : IntermediateProcessorStrategy,
  create : () -> @core.TypedLayoutProcessor[LGraph],
) -> Unit {
  let ordinal = intermediate_processor_strategy_ordinal(strategy)
  self.intermediate_processor_factories[ordinal] = (
    23000 + ordinal,
    ordinal,
    create,
  )
}

///|
fn layered_bind_processor_factory(
  graph : LGraph,
  spec : (Int, Int, () -> @core.TypedLayoutProcessor[LGraph]),
) -> @core.LayoutProcessorFactory {
  let (id, order, create) = spec
  @core.new_layout_processor_factory(id, order, graph, () => create())
}

///|
fn layered_missing_cycle_breaking_factory(
  strategy : String,
  graph : LGraph,
) -> @core.LayoutProcessorFactory raise {
  @core.layout_runtime_raise_unsupported_configuration(
    "Layered cycle-breaking phase is not linked for strategy " + strategy,
  )
  @core.new_layout_processor_factory(21000, 0, graph, () => {
    @core.new_layout_processor((_, _) => ())
  })
}

///|
pub fn LayeredPhaseRegistry::cycle_breaking_phase_factory(
  self : LayeredPhaseRegistry,
  graph : LGraph,
  strategy : String,
) -> @core.LayoutProcessorFactory raise {
  match self.cycle_breaking_factories.get(strategy) {
    Some(spec) => layered_bind_processor_factory(graph, spec)
    None =>
      match self.cycle_breaking_factories.get("GREEDY") {
        Some(spec) => layered_bind_processor_factory(graph, spec)
        None => layered_missing_cycle_breaking_factory(strategy, graph)
      }
  }
}

///|
pub fn LayeredPhaseRegistry::layering_phase_factory(
  self : LayeredPhaseRegistry,
  graph : LGraph,
  strategy : String,
) -> @core.LayoutProcessorFactory raise {
  match self.layering_factories.get(strategy) {
    Some(spec) => layered_bind_processor_factory(graph, spec)
    None =>
      match self.layering_factories.get("NETWORK_SIMPLEX") {
        Some(spec) => layered_bind_processor_factory(graph, spec)
        None => {
          @core.layout_runtime_raise_unsupported_configuration(
            "Layered layering phase is not linked for strategy " + strategy,
          )
          @core.new_layout_processor_factory(22000, 1, graph, () => {
            @core.new_layout_processor((_, _) => ())
          })
        }
      }
  }
}

///|
pub fn LayeredPhaseRegistry::node_placement_phase_factory(
  self : LayeredPhaseRegistry,
  graph : LGraph,
  strategy : String,
) -> @core.LayoutProcessorFactory raise {
  match self.node_placement_factories.get(strategy) {
    Some(spec) => layered_bind_processor_factory(graph, spec)
    None =>
      match self.node_placement_factories.get("BRANDES_KOEPF") {
        Some(spec) => layered_bind_processor_factory(graph, spec)
        None => {
          @core.layout_runtime_raise_unsupported_configuration(
            "Layered node-placement phase is not linked for strategy " +
            strategy,
          )
          @core.new_layout_processor_factory(24103, 3, graph, () => {
            @core.new_layout_processor((_, _) => ())
          })
        }
      }
  }
}

///|
pub fn LayeredPhaseRegistry::intermediate_processor_factory(
  self : LayeredPhaseRegistry,
  graph : LGraph,
  strategy : IntermediateProcessorStrategy,
) -> @core.LayoutProcessorFactory {
  let ordinal = intermediate_processor_strategy_ordinal(strategy)
  match self.intermediate_processor_factories.get(ordinal) {
    Some(spec) => layered_bind_processor_factory(graph, spec)
    None =>
      @core.new_layout_processor_factory(23000 + ordinal, ordinal, graph, () => {
        intermediate_processor_create(strategy)
      })
  }
}
