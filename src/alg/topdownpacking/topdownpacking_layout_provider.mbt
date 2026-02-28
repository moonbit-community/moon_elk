///|
pub struct TopdownpackingLayoutProvider {
  algorithm_assembler : @core.AlgorithmAssembler[
    TopdownPackingPhases,
    GridElkNode,
  ]
}

///|
pub fn new_topdownpacking_layout_provider() -> TopdownpackingLayoutProvider {
  {
    algorithm_assembler: @core.algorithm_assembler_create(
      topdownpacking_phase_descriptor,
    ),
  }
}

///|
pub fn TopdownpackingLayoutProvider::assemble_algorithm(
  self : TopdownpackingLayoutProvider,
  graph : GridElkNode,
) -> Array[@core.ILayoutProcessor[TopdownPackingPhases, GridElkNode]] {
  ignore(self.algorithm_assembler.reset())

  let node_arrangement_strategy = topdownpacking_node_arrangement_strategy_from_string(
    graph.get_string_property(topdownpacking_node_arrangement_strategy),
  )
  ignore(
    self.algorithm_assembler.set_phase(
      TopdownPackingPhases::P1_NODE_ARRANGEMENT,
      topdownpacking_node_arrangement_strategy_phase_factory(
        node_arrangement_strategy,
      ),
    ),
  )

  let whitespace_elimination_strategy = topdownpacking_whitespace_elimination_strategy_from_string(
    graph.get_string_property(topdownpacking_whitespace_elimination_strategy),
  )
  ignore(
    self.algorithm_assembler.set_phase(
      TopdownPackingPhases::P2_WHITESPACE_ELIMINATION,
      topdownpacking_whitespace_elimination_strategy_phase_factory(
        whitespace_elimination_strategy,
      ),
    ),
  )
  self.algorithm_assembler.build(graph)
}

///|
pub fn TopdownpackingLayoutProvider::layout(
  self : TopdownpackingLayoutProvider,
  layout_graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit {
  let wrapped_graph = new_grid_elk_node(layout_graph)
  let algorithm = self.assemble_algorithm(wrapped_graph)
  ignore(
    progress_monitor.begin("Topdown Packing", algorithm.length().to_double()),
  )
  for processor in algorithm {
    processor.process(wrapped_graph, progress_monitor.sub_task(1.0))
  }
  progress_monitor.done()
}

///|
pub fn TopdownpackingLayoutProvider::get_predicted_graph_size(
  self : TopdownpackingLayoutProvider,
  graph : @graph.ElkNode,
) -> @core.KVector {
  ignore(self)
  let node_arrangement_strategy = topdownpacking_node_arrangement_strategy_from_string(
    @graph.node_get_string_property(
      graph, topdownpacking_node_arrangement_strategy,
    ),
  )
  let node_arranger = topdownpacking_node_arrangement_strategy_create_node_arranger(
    node_arrangement_strategy,
  )
  node_arranger.get_predicted_size(graph)
}

///|
pub fn topdownpacking_layout_provider_as_layout_provider(
  provider : TopdownpackingLayoutProvider,
) -> @core.AbstractLayoutProvider {
  @core.new_abstract_layout_provider((graph, monitor) => {
    provider.layout(graph, monitor)
  })
}

///|
pub fn topdownpacking_layout_provider_as_topdown_layout_provider(
  provider : TopdownpackingLayoutProvider,
) -> @core.ITopdownLayoutProvider {
  @core.new_topdown_layout_provider(graph => {
    provider.get_predicted_graph_size(graph)
  })
}
