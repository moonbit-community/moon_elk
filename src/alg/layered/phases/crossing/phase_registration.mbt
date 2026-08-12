///|
pub fn register_crossing_minimization_phases(
  registry : @runtime.LayeredPhaseRegistry,
) -> Unit {
  registry.register_crossing_minimization_phase("NONE", 24002, _ => {
    new_no_crossing_minimizer_layout_phase()
  })
  registry.register_crossing_minimization_phase("INTERACTIVE", 24003, _ => {
    new_interactive_crossing_minimizer_layout_phase()
  })
  registry.register_crossing_minimization_phase("MEDIAN_LAYER_SWEEP", 24001, state => {
    new_median_layer_sweep_crossing_minimizer_layout_phase(state=Some(state))
  })
  registry.register_crossing_minimization_phase("LAYER_SWEEP", 24000, state => {
    new_barycenter_layer_sweep_crossing_minimizer_layout_phase(
      state=Some(state),
    )
  })
}

///|
pub fn register_crossing_processors(
  registry : @runtime.LayeredPhaseRegistry,
) -> Unit {
  registry.register_stateful_intermediate_processor(OneSidedGreedySwitch, state => {
    crossing_greedy_switch_layout_processor(OneSidedGreedySwitch, state)
  })
  registry.register_stateful_intermediate_processor(TwoSidedGreedySwitch, state => {
    crossing_greedy_switch_layout_processor(TwoSidedGreedySwitch, state)
  })
}

///|
fn crossing_greedy_switch_layout_processor(
  cross_min_type : CrossMinType,
  state : @runtime.LayeredRunState,
) -> @core.TypedLayoutProcessor[@runtime.LGraph] {
  let minimizer = new_layer_sweep_crossing_minimizer(
    cross_min_type,
    state=Some(state),
  )
  @core.new_hierarchy_aware_layout_phase(
    (graph, monitor) => minimizer.process(graph, progress_monitor=monitor),
    graph => {
      let configuration = @core.layout_processor_configuration_create()
      ignore(
        configuration.add_before(
          @runtime.P3NodeOrdering,
          @intermediate.processor_factory(graph, LongEdgeSplitter, state~),
        ),
      )
      ignore(
        configuration.add_before(
          @runtime.P4NodePlacement,
          @intermediate.processor_factory(
            graph,
            InLayerConstraintProcessor,
            state~,
          ),
        ),
      )
      ignore(configuration.after(@runtime.P5EdgeRouting))
      ignore(
        configuration.add(
          @intermediate.processor_factory(graph, LongEdgeJoiner, state~),
        ),
      )
      ignore(
        configuration.add_before(
          @runtime.P3NodeOrdering,
          @intermediate.processor_factory(graph, PortListSorter, state~),
        ),
      )
      Some(configuration)
    },
  )
}
