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
fn force_option_bool_from_layout_options(
  node : ElkNode,
  option : ForceBoolOption,
) -> Bool {
  match node_layout_option_string_value(node, option.get_id()) {
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
  layout_graph : ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  ignore(progress_monitor.begin("ELK Stress", 1.0))
  if !force_option_bool_from_layout_options(layout_graph, stress_interactive) {
    let force_provider = new_force_layout_provider()
    let force_monitor = match progress_monitor.sub_task(1.0) {
      Some(monitor) => monitor
      None => progress_monitor
    }
    force_provider.layout(layout_graph, force_monitor)
  }
  let importer = new_elk_graph_importer()
  let graph = importer.import_graph(layout_graph)
  let components = self.components_processor.split(graph)
  for sub_graph in components {
    if sub_graph.get_nodes().length() <= 1 {
      continue
    }
    self.stress_majorization.initialize(sub_graph)
    self.stress_majorization.execute()
    for label in sub_graph.get_labels() {
      flabel_refresh_position(label)
    }
  }
  let merged = self.components_processor.recombine(components)
  importer.apply_layout(merged)
  progress_monitor.done()
}

///|
pub fn stress_layout_provider_as_layout_provider(
  provider : StressLayoutProvider,
) -> AbstractLayoutProvider {
  new_abstract_layout_provider((graph, monitor) => {
    provider.layout(graph, monitor)
  })
}
