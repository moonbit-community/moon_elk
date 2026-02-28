///|
pub struct LayeredLayoutProvider {
  elk_layered : ElkLayered
}

///|
pub fn new_layered_layout_provider() -> LayeredLayoutProvider {
  { elk_layered: new_elk_layered() }
}

///|
fn init {
  @core.recursive_graph_layout_engine_register_handler(layered_algorithm_id, (
    layout_graph,
    progress_monitor,
  ) => new_layered_layout_provider().layout(layout_graph, progress_monitor))
}

///|
pub fn LayeredLayoutProvider::layout(
  self : LayeredLayoutProvider,
  elk_graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit {
  let graph_transformer = new_layered_elk_graph_transformer()
  let layered_graph = graph_transformer.import_graph(elk_graph)

  if @graph.node_get_string_property(
      elk_graph, layered_options_hierarchy_handling,
    ) ==
    "INCLUDE_CHILDREN" {
    self.elk_layered.do_compound_layout(layered_graph, Some(progress_monitor))
  } else {
    self.elk_layered.do_layout(layered_graph, Some(progress_monitor))
  }

  if !progress_monitor.is_canceled() {
    graph_transformer.apply_layout(layered_graph)
  }
}

///|
pub fn LayeredLayoutProvider::start_layout_test(
  self : LayeredLayoutProvider,
  elk_graph : @graph.ElkNode,
) -> ElkLayeredTestExecutionState {
  let graph_importer = new_layered_elk_graph_transformer()
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
