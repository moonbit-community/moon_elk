///|
/// Runtime-owned registry for the concrete phases linked into one layered
/// engine. Keeping the maps on this object makes independent runtimes
/// reentrant and prevents package initialization from mutating process state.
pub struct LayeredPhaseRegistry {
  cycle_breaking_factories : Map[
    String,
    (Int, Int, (LayeredRunState) -> @core.TypedLayoutProcessor[LGraph]),
  ]
  layering_factories : Map[
    String,
    (Int, Int, (LayeredRunState) -> @core.TypedLayoutProcessor[LGraph]),
  ]
  crossing_minimization_factories : Map[
    String,
    (Int, Int, (LayeredRunState) -> @core.TypedLayoutProcessor[LGraph]),
  ]
  node_placement_factories : Map[
    String,
    (Int, Int, (LayeredRunState) -> @core.TypedLayoutProcessor[LGraph]),
  ]
  edge_routing_factories : Map[
    String,
    (Int, Int, (LayeredRunState) -> @core.TypedLayoutProcessor[LGraph]),
  ]
  intermediate_processor_factories : Map[
    Int,
    (Int, Int, (LayeredRunState) -> @core.TypedLayoutProcessor[LGraph]),
  ]
}

///|
pub fn new_layered_phase_registry() -> LayeredPhaseRegistry {
  {
    cycle_breaking_factories: Map([]),
    layering_factories: Map([]),
    crossing_minimization_factories: Map([]),
    node_placement_factories: Map([]),
    edge_routing_factories: Map([]),
    intermediate_processor_factories: Map([]),
  }
}

///|
pub fn LayeredPhaseRegistry::register_crossing_minimization_phase(
  self : LayeredPhaseRegistry,
  strategy : String,
  id : Int,
  create : (LayeredRunState) -> @core.TypedLayoutProcessor[LGraph],
) -> Unit {
  self.crossing_minimization_factories[strategy] = (id, 2, create)
}

///|
pub fn LayeredPhaseRegistry::register_edge_routing_phase(
  self : LayeredPhaseRegistry,
  strategy : String,
  id : Int,
  create : (LayeredRunState) -> @core.TypedLayoutProcessor[LGraph],
) -> Unit {
  self.edge_routing_factories[strategy] = (id, id - 24000, create)
}

///|
pub fn LayeredPhaseRegistry::register_cycle_breaking_phase(
  self : LayeredPhaseRegistry,
  strategy : String,
  id : Int,
  create : () -> @core.TypedLayoutProcessor[LGraph],
) -> Unit {
  self.cycle_breaking_factories[strategy] = (id, 0, _ => create())
}

///|
pub fn LayeredPhaseRegistry::register_stateful_cycle_breaking_phase(
  self : LayeredPhaseRegistry,
  strategy : String,
  id : Int,
  create : (LayeredRunState) -> @core.TypedLayoutProcessor[LGraph],
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
  self.layering_factories[strategy] = (id, 1, _ => create())
}

///|
pub fn LayeredPhaseRegistry::register_node_placement_phase(
  self : LayeredPhaseRegistry,
  strategy : String,
  id : Int,
  create : () -> @core.TypedLayoutProcessor[LGraph],
) -> Unit {
  self.node_placement_factories[strategy] = (id, 3, _ => create())
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
    _ => create(),
  )
}

///|
pub fn LayeredPhaseRegistry::register_stateful_intermediate_processor(
  self : LayeredPhaseRegistry,
  strategy : IntermediateProcessorStrategy,
  create : (LayeredRunState) -> @core.TypedLayoutProcessor[LGraph],
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
  state : LayeredRunState,
  spec : (Int, Int, (LayeredRunState) -> @core.TypedLayoutProcessor[LGraph]),
) -> @core.LayoutProcessorFactory {
  let (id, order, create) = spec
  @core.new_layout_processor_factory(id, order, graph, () => create(state))
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
  state? : LayeredRunState = new_layered_run_state(),
) -> @core.LayoutProcessorFactory raise {
  match self.cycle_breaking_factories.get(strategy) {
    Some(spec) => layered_bind_processor_factory(graph, state, spec)
    None =>
      match self.cycle_breaking_factories.get("GREEDY") {
        Some(spec) => layered_bind_processor_factory(graph, state, spec)
        None => layered_missing_cycle_breaking_factory(strategy, graph)
      }
  }
}

///|
pub fn LayeredPhaseRegistry::layering_phase_factory(
  self : LayeredPhaseRegistry,
  graph : LGraph,
  strategy : String,
  state? : LayeredRunState = new_layered_run_state(),
) -> @core.LayoutProcessorFactory raise {
  match self.layering_factories.get(strategy) {
    Some(spec) => layered_bind_processor_factory(graph, state, spec)
    None =>
      match self.layering_factories.get("NETWORK_SIMPLEX") {
        Some(spec) => layered_bind_processor_factory(graph, state, spec)
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
  state? : LayeredRunState = new_layered_run_state(),
) -> @core.LayoutProcessorFactory raise {
  match self.node_placement_factories.get(strategy) {
    Some(spec) => layered_bind_processor_factory(graph, state, spec)
    None =>
      match self.node_placement_factories.get("BRANDES_KOEPF") {
        Some(spec) => layered_bind_processor_factory(graph, state, spec)
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
pub fn LayeredPhaseRegistry::crossing_minimization_phase_factory(
  self : LayeredPhaseRegistry,
  graph : LGraph,
  strategy : String,
  state? : LayeredRunState = new_layered_run_state(),
) -> @core.LayoutProcessorFactory raise {
  match self.crossing_minimization_factories.get(strategy) {
    Some(spec) => layered_bind_processor_factory(graph, state, spec)
    None =>
      match self.crossing_minimization_factories.get("LAYER_SWEEP") {
        Some(spec) => layered_bind_processor_factory(graph, state, spec)
        None => {
          @core.layout_runtime_raise_unsupported_configuration(
            "Layered crossing-minimization phase is not linked for strategy " +
            strategy,
          )
          @core.new_layout_processor_factory(24000, 2, graph, () => {
            @core.new_layout_processor((_, _) => ())
          })
        }
      }
  }
}

///|
pub fn LayeredPhaseRegistry::edge_routing_phase_factory(
  self : LayeredPhaseRegistry,
  graph : LGraph,
  strategy : String,
  state? : LayeredRunState = new_layered_run_state(),
) -> @core.LayoutProcessorFactory raise {
  match self.edge_routing_factories.get(strategy) {
    Some(spec) => layered_bind_processor_factory(graph, state, spec)
    None =>
      match self.edge_routing_factories.get("ORTHOGONAL") {
        Some(spec) => layered_bind_processor_factory(graph, state, spec)
        None => {
          @core.layout_runtime_raise_unsupported_configuration(
            "Layered edge-routing phase is not linked for strategy " + strategy,
          )
          @core.new_layout_processor_factory(24003, 4, graph, () => {
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
  state? : LayeredRunState = new_layered_run_state(),
) -> @core.LayoutProcessorFactory raise {
  let ordinal = intermediate_processor_strategy_ordinal(strategy)
  match self.intermediate_processor_factories.get(ordinal) {
    Some(spec) => layered_bind_processor_factory(graph, state, spec)
    None => {
      @core.layout_runtime_raise_unsupported_configuration(
        "Layered intermediate processor is not linked for strategy " +
        intermediate_processor_strategy_to_string(strategy),
      )
      @core.new_layout_processor_factory(23000 + ordinal, ordinal, graph, () => {
        @core.new_layout_processor((_, _) => ())
      })
    }
  }
}
