///|
pub struct RadialLayoutProvider {
  algorithm_assembler : @core.AlgorithmAssembler[
    RadialLayoutPhases,
    @graph.ElkNode,
  ]
}

///|
priv suberror RadialLayoutProviderException {
  UnsupportedConfiguration(String)
} derive(Show, ToJson)

///|
fn radial_layout_provider_raise_unsupported_configuration(
  message : String,
) -> Unit raise RadialLayoutProviderException {
  raise RadialLayoutProviderException::UnsupportedConfiguration(message)
}

///|
fn radial_layout_provider_exception_message(
  err : RadialLayoutProviderException,
) -> String {
  match err {
    RadialLayoutProviderException::UnsupportedConfiguration(message) => message
  }
}

///|
pub fn new_radial_layout_provider() -> RadialLayoutProvider {
  {
    algorithm_assembler: @core.algorithm_assembler_create(
      radial_layout_phase_descriptor,
    ),
  }
}

///|
fn init {
  @core.recursive_graph_layout_engine_register_handler(radial_algorithm_id, (
    layout_graph,
    progress_monitor,
  ) => new_radial_layout_provider().layout(layout_graph, progress_monitor))
}

///|
fn radial_node_micro_layout_execute(layout_graph : @graph.ElkNode) -> Unit {
  ignore(layout_graph)
}

///|
fn radial_layout_provider_assemble_algorithm(
  provider : RadialLayoutProvider,
  layout_graph : @graph.ElkNode,
) -> Array[@core.ILayoutProcessor[RadialLayoutPhases, @graph.ElkNode]] {
  ignore(provider.algorithm_assembler.reset())
  ignore(
    provider.algorithm_assembler.set_phase(
      RadialLayoutPhases::P1_NODE_PLACEMENT,
      radial_layout_phase_factory(RadialLayoutPhases::P1_NODE_PLACEMENT),
    ),
  )
  ignore(
    provider.algorithm_assembler.set_phase(
      RadialLayoutPhases::P2_EDGE_ROUTING,
      radial_layout_phase_factory(RadialLayoutPhases::P2_EDGE_ROUTING),
    ),
  )

  let configuration = @core.layout_processor_configuration_create(
    radial_layout_phase_descriptor,
  )
  ignore(
    configuration.add_before(
      RadialLayoutPhases::P2_EDGE_ROUTING,
      radial_intermediate_processor_factory(
        RadialIntermediateProcessorStrategy::OVERLAP_REMOVAL,
      ),
    ),
  )
  let has_compaction = match radial_graph_compaction_strategy(layout_graph) {
    RadialCompactionStrategy::NONE => false
    _ => true
  }
  if has_compaction {
    ignore(
      configuration.add_before(
        RadialLayoutPhases::P2_EDGE_ROUTING,
        radial_intermediate_processor_factory(
          RadialIntermediateProcessorStrategy::COMPACTION,
        ),
      ),
    )
  }
  if @graph.node_get_bool_property(layout_graph, radial_rotate) {
    ignore(
      configuration.add_before(
        RadialLayoutPhases::P2_EDGE_ROUTING,
        radial_intermediate_processor_factory(
          RadialIntermediateProcessorStrategy::ROTATION,
        ),
      ),
    )
  }
  ignore(
    configuration.add_before(
      RadialLayoutPhases::P2_EDGE_ROUTING,
      radial_intermediate_processor_factory(
        RadialIntermediateProcessorStrategy::GRAPH_SIZE_CALCULATION,
      ),
    ),
  )
  if @graph.node_get_bool_property(
      layout_graph, radial_rotation_outgoing_edge_angles,
    ) {
    ignore(
      configuration.add_after(
        RadialLayoutPhases::P2_EDGE_ROUTING,
        radial_intermediate_processor_factory(
          RadialIntermediateProcessorStrategy::OUTGOING_EDGE_ANGLES,
        ),
      ),
    )
  }
  ignore(
    provider.algorithm_assembler.add_processor_configuration(configuration),
  )
  provider.algorithm_assembler.build(layout_graph)
}

///|
pub fn RadialLayoutProvider::layout(
  self : RadialLayoutProvider,
  layout_graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit {
  try
    radial_layout_provider_layout_impl(self, layout_graph, progress_monitor)
  catch {
    err => {
      @core.layout_runtime_report_unsupported_configuration(
        radial_layout_provider_exception_message(err),
      )
      if progress_monitor.is_running() {
        progress_monitor.done()
      }
    }
  } noraise {
    _ => ()
  }
}

///|
fn radial_layout_provider_layout_impl(
  provider : RadialLayoutProvider,
  layout_graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit raise RadialLayoutProviderException {
  let algorithm = radial_layout_provider_assemble_algorithm(
    provider, layout_graph,
  )
  ignore(
    progress_monitor.begin("Radial layout", algorithm.length().to_double()),
  )
  if !@graph.node_get_bool_property(layout_graph, radial_omit_node_micro_layout) {
    radial_node_micro_layout_execute(layout_graph)
  }

  let root = radial_find_root(layout_graph)
  match root {
    Some(root_node) => {
      radial_internal_set_root(layout_graph, root_node)
      let mut layout_radius = @graph.node_get_double_property(
        layout_graph, radial_radius,
      )
      if layout_radius == 0.0 {
        layout_radius = radial_find_largest_node_in_graph(layout_graph)
      }
      @graph.node_set_double_property(
        layout_graph, radial_radius, layout_radius,
      )
      for
        processor in radial_layout_provider_assemble_algorithm(
          provider, layout_graph,
        ) {
        processor.process(layout_graph, progress_monitor.sub_task(1.0))
      }
      progress_monitor.done()
    }
    None =>
      radial_layout_provider_raise_unsupported_configuration(
        "The given graph is not a tree!",
      )
  }
}
