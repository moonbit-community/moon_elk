///|
pub struct LayeredLayoutProvider {
  elk_layered : ElkLayered
}

///|
pub fn new_layered_layout_provider(
  runtime : @core.LayoutRuntime,
  session : @core.LayoutSession,
  phase_registry : LayeredPhaseRegistry,
) -> LayeredLayoutProvider {
  { elk_layered: new_elk_layered(runtime, session, phase_registry) }
}

///|
pub fn register_layered_layout_algorithm(
  runtime : @core.LayoutRuntime,
  phase_registry : LayeredPhaseRegistry,
) -> Unit {
  runtime.register_layout_algorithm(@options.layered_algorithm_id, (
    runtime,
    session,
    layout_graph,
    progress_monitor,
  ) => {
    new_layered_layout_provider(runtime, session, phase_registry).layout(
      layout_graph, progress_monitor,
    )
  })
}

///|
/// Linking this package installs the layered layout handler. Composition roots
/// reference this marker explicitly so registration is never an accidental
/// side effect of a compatibility import.
pub let layered_pipeline_linked : Bool = true

///|
pub fn LayeredLayoutProvider::layout(
  self : LayeredLayoutProvider,
  elk_graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit raise {
  let graph_transformer = @transform.new_layered_elk_graph_transformer()
  let layered_graph = graph_transformer.import_graph(elk_graph)

  if @graph.node_get_string_property(
      elk_graph, @options.layered_options_hierarchy_handling,
    ) ==
    "INCLUDE_CHILDREN" {
    self.elk_layered.do_compound_layout(layered_graph, Some(progress_monitor))
  } else {
    self.elk_layered.do_layout(layered_graph, Some(progress_monitor))
  }

  if !progress_monitor.is_canceled() {
    graph_transformer.apply_layout(layered_graph)
  } else {
    dispose_layered_graph(layered_graph)
    graph_transformer.clear()
  }
}

///|
pub fn LayeredLayoutProvider::start_layout_test(
  self : LayeredLayoutProvider,
  elk_graph : @graph.ElkNode,
) -> ElkLayeredTestExecutionState raise {
  let graph_importer = @transform.new_layered_elk_graph_transformer()
  let layered_graph = graph_importer.import_graph(elk_graph)
  self.elk_layered.prepare_layout_test(layered_graph)
}

///|
pub fn LayeredLayoutProvider::get_layout_algorithm(
  self : LayeredLayoutProvider,
) -> ElkLayered {
  self.elk_layered
}

///|
pub fn LayeredLayoutProvider::set_test_controller(
  self : LayeredLayoutProvider,
  controller : @core.TestController[LGraph]?,
) -> Unit {
  self.elk_layered.set_test_controller(controller)
}

///|
pub fn layered_layout_provider_as_layout_provider(
  provider : LayeredLayoutProvider,
) -> @core.AbstractLayoutProvider {
  @core.new_abstract_layout_provider((graph, monitor) => {
    provider.layout(graph, monitor)
  })
}
