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
fn force_set_options(graph : FGraph, parent : @graph.ElkNode) -> Unit {
  ignore(parent)
  let random_seed = graph.get_int_property(force_random_seed)
  let random_generator = if random_seed == 0 {
    @random.Rand::new()
  } else {
    let seed_buffer = @buffer.new()
    seed_buffer.write_int64_le(random_seed.to_int64())
    @random.Rand::chacha8(seed=seed_buffer.to_bytes())
  }
  graph.set_internal_random_property(force_internal_random, random_generator)
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
  ignore(progress_monitor.begin("ELK Force", 1.0))
  let importer = new_elk_graph_importer()
  let force_graph = importer.import_graph(graph)
  force_set_options(force_graph, graph)
  force_update_model(self, force_graph.get_model_property(force_model))
  let components = self.components_processor.split(force_graph)
  let component_count = components.length()
  for component in components {
    match self.force_model {
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
  let merged_graph = self.components_processor.recombine(components)
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
