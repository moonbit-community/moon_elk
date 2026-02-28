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
fn init {
  @core.recursive_graph_layout_engine_register_handler(stress_algorithm_id, (
    layout_graph,
    progress_monitor,
  ) => new_stress_layout_provider().layout(layout_graph, progress_monitor))
}

///|
fn stress_option_bool_from_layout_options(
  node : @graph.ElkNode,
  option : ForceBoolOption,
) -> Bool {
  match @graph.node_layout_option_string_value(node, option.get_id()) {
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
) -> Unit {
  try
    stress_layout_provider_layout_impl(self, layout_graph, progress_monitor)
  catch {
    err => {
      @core.layout_runtime_report_unsupported_graph(
        force_import_exception_message(err),
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
fn stress_layout_provider_layout_impl(
  provider : StressLayoutProvider,
  layout_graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit raise ForceImportException {
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
    @common.node_micro_layout_for_graph(layout_graph).execute()
  }
  let importer = new_elk_graph_importer()
  let graph = importer.import_graph(layout_graph)
  let components = provider.components_processor.split(graph)
  for sub_graph in components {
    if sub_graph.get_nodes().length() <= 1 {
      continue
    }
    try provider.stress_majorization.initialize(sub_graph) catch {
      err => {
        @core.layout_runtime_report_unsupported_configuration(
          stress_majorization_exception_message(err),
        )
        progress_monitor.done()
        return
      }
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
