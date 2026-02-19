///|
pub struct RadialLayoutProvider {
  algorithm_assembler : @core.AlgorithmAssembler[RadialLayoutPhases, @graph.ElkNode]
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
  if @graph.node_get_bool_property(layout_graph, radial_rotation_outgoing_edge_angles) {
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
  let algorithm = radial_layout_provider_assemble_algorithm(self, layout_graph)
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
      @graph.node_set_double_property(layout_graph, radial_radius, layout_radius)
      for
        processor in radial_layout_provider_assemble_algorithm(
          self, layout_graph,
        ) {
        processor.process(layout_graph, progress_monitor.sub_task(1.0))
      }
      progress_monitor.done()
    }
    None => abort("The given graph is not a tree!")
  }
}
