///|
pub struct StressLayoutProvider {
  components_processor : ComponentsProcessor
  stress_majorization : StressMajorization
}

///|
pub fn new_stress_layout_provider() -> StressLayoutProvider {
  {
    components_processor: new_components_processor(),
    stress_majorization: new_stress_majorization(),
  }
}

///|
pub fn register_stress_layout_algorithm(runtime : @core.LayoutRuntime) -> Unit {
  runtime.register_layout_algorithm(stress_algorithm_id, (
    _runtime,
    _session,
    layout_graph,
    progress_monitor,
  ) => new_stress_layout_provider().layout(layout_graph, progress_monitor))
}

///|
fn stress_option_bool_from_layout_options(
  node : @graph.ElkNode,
  option : ForceBoolOption,
) -> Bool {
  match
    @graph.node_layout_option_string_value_by_option_id(
      node,
      option.get_property_id(),
    ) {
    Some(value) =>
      if value == "true" {
        true
      } else if value == "false" {
        false
      } else {
        option.get_default()
      }
    None => option.get_default()
  }
}

///|
pub fn StressLayoutProvider::layout(
  self : StressLayoutProvider,
  layout_graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit raise {
  try
    stress_layout_provider_layout_impl(self, layout_graph, progress_monitor)
  catch {
    ForceImportException::UnsupportedGraph(message) => {
      @core.layout_runtime_raise_unsupported_graph(message)
      if progress_monitor.is_running() {
        progress_monitor.done()
      }
    }
    err => {
      if progress_monitor.is_running() {
        progress_monitor.done()
      }
      raise err
    }
  } noraise {
    _ => ()
  }
}

///|
fn stress_layout_provider_layout_impl(
  provider : StressLayoutProvider,
  layout_graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit raise {
  ignore(progress_monitor.begin("ELK Stress", 1.0))
  if !stress_option_bool_from_layout_options(layout_graph, stress_interactive) {
    let force_provider = new_force_layout_provider()
    let force_monitor = match progress_monitor.sub_task(1.0) {
      Some(monitor) => monitor
      None => progress_monitor
    }
    force_provider.layout(layout_graph, force_monitor)
  } else if !stress_option_bool_from_layout_options(
      layout_graph, stress_omit_node_micro_layout,
    ) {
    @nodespacing.node_micro_layout_for_graph(layout_graph).execute()
  }
  let importer = new_elk_graph_importer()
  let graph = importer.import_graph(layout_graph)
  let components = provider.components_processor.split(graph)
  for sub_graph in components {
    if sub_graph.get_nodes().length() <= 1 {
      continue
    }
    try provider.stress_majorization.initialize(sub_graph) catch {
      StressMajorizationException::StressMajorizationException(message) => {
        @core.layout_runtime_raise_unsupported_configuration(message)
        progress_monitor.done()
        return
      }
      err => raise err
    } noraise {
      _ => ()
    }
    provider.stress_majorization.execute()
    for label in sub_graph.get_labels() {
      flabel_refresh_position(label)
    }
  }
  let merged = provider.components_processor.recombine(components)
  importer.apply_layout(merged)
  progress_monitor.done()
}

///|
pub fn stress_layout_provider_as_layout_provider(
  provider : StressLayoutProvider,
) -> @core.AbstractLayoutProvider {
  @core.new_abstract_layout_provider((graph, monitor) => {
    provider.layout(graph, monitor)
  })
}
