///|
pub enum ForceModel {
  EadesModelValue(EadesModel)
  FruchtermanReingoldModelValue(FruchtermanReingoldModel)
}

///|
fn force_model_layout(
  model : ForceModel,
  graph : FGraph,
  monitor : @core.IElkProgressMonitor,
) -> Unit {
  match model {
    EadesModelValue(eades_model) => eades_model.layout(graph, monitor)
    FruchtermanReingoldModelValue(fr_model) => fr_model.layout(graph, monitor)
  }
}

///|
pub struct ForceLayoutProvider {
  mut force_model : ForceModel?
  components_processor : ComponentsProcessor
}

///|
pub fn new_force_layout_provider() -> ForceLayoutProvider {
  { force_model: None, components_processor: new_components_processor() }
}

///|
fn init {
  @core.recursive_graph_layout_engine_register_handler(force_algorithm_id, (
    layout_graph,
    progress_monitor,
  ) => new_force_layout_provider().layout(layout_graph, progress_monitor))
}

///|
fn force_set_options(graph : FGraph, parent : @graph.ElkNode) -> Unit {
  ignore(parent)
  let random_seed = graph.get_int_property(force_random_seed)
  let random_generator = if random_seed == 0 {
    @core.new_java_random()
  } else {
    @core.new_java_random_seeded_int(random_seed)
  }
  graph.set_internal_random_property(force_internal_random, random_generator)
}

///|
fn force_option_bool_from_layout_options(
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
fn force_update_model(
  provider : ForceLayoutProvider,
  strategy : ForceModelStrategy,
) -> Unit {
  match strategy {
    Eades =>
      match provider.force_model {
        Some(EadesModelValue(_)) => ()
        _ => provider.force_model = Some(EadesModelValue(new_eades_model()))
      }
    FruchtermanReingold =>
      match provider.force_model {
        Some(FruchtermanReingoldModelValue(_)) => ()
        _ =>
          provider.force_model = Some(
            FruchtermanReingoldModelValue(new_fruchterman_reingold_model()),
          )
      }
  }
}

///|
pub fn ForceLayoutProvider::layout(
  self : ForceLayoutProvider,
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit {
  try force_layout_provider_layout_impl(self, graph, progress_monitor) catch {
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
fn force_layout_provider_layout_impl(
  provider : ForceLayoutProvider,
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit raise ForceImportException {
  ignore(progress_monitor.begin("ELK Force", 1.0))
  if !force_option_bool_from_layout_options(graph, force_omit_node_micro_layout) {
    @common.node_micro_layout_for_graph(graph).execute()
  }
  let importer = new_elk_graph_importer()
  let force_graph = importer.import_graph(graph)
  force_set_options(force_graph, graph)
  force_update_model(provider, force_graph.get_model_property(force_model))
  let components = provider.components_processor.split(force_graph)
  let component_count = components.length()
  for component in components {
    match provider.force_model {
      Some(model) => {
        let sub_monitor = match
          progress_monitor.sub_task(1.0 / component_count.to_double()) {
          Some(monitor) => monitor
          None => progress_monitor
        }
        force_model_layout(model, component, sub_monitor)
      }
      None => ()
    }
  }
  let merged_graph = provider.components_processor.recombine(components)
  importer.apply_layout(merged_graph)
  progress_monitor.done()
}

///|
pub fn force_layout_provider_as_layout_provider(
  provider : ForceLayoutProvider,
) -> @core.AbstractLayoutProvider {
  @core.new_abstract_layout_provider((graph, monitor) => {
    provider.layout(graph, monitor)
  })
}
