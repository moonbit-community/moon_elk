///|
pub struct MrtreeTreeLayoutProvider {
  tree : Mrtree
  components_processor : MrtreeComponentsProcessor
}

///|
pub fn new_mrtree_tree_layout_provider() -> MrtreeTreeLayoutProvider {
  {
    tree: new_mrtree(),
    components_processor: new_mrtree_components_processor(),
  }
}

///|
fn mrtree_node_micro_layout_execute(layout_graph : ElkNode) -> Unit {
  ignore(layout_graph)
}

///|
pub fn MrtreeTreeLayoutProvider::layout(
  self : MrtreeTreeLayoutProvider,
  layout_graph : ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  let default_work = 0.1
  if !node_get_bool_property(layout_graph, mrtree_omit_node_micro_layout) {
    mrtree_node_micro_layout_execute(layout_graph)
  }

  let mut pm = match progress_monitor.sub_task(default_work) {
    Some(monitor) => monitor
    None => new_null_elk_progress_monitor()
  }
  ignore(pm.begin("build tGraph", 1.0))
  let importer = new_mrtree_elk_graph_as_igraph_importer()
  let graph = importer.import_graph(layout_graph)
  pm.done()

  pm = match progress_monitor.sub_task(default_work) {
    Some(monitor) => monitor
    None => new_null_elk_progress_monitor()
  }
  ignore(pm.begin("Split graph", 1.0))
  let components = self.components_processor.split(graph)
  pm.done()

  for component in components {
    let component_monitor = match
      progress_monitor.sub_task(
        (1.0 - default_work * 4.0) / components.length().to_double(),
      ) {
      Some(monitor) => monitor
      None => new_null_elk_progress_monitor()
    }
    ignore(self.tree.do_layout(component, component_monitor))
  }

  pm = match progress_monitor.sub_task(default_work) {
    Some(monitor) => monitor
    None => new_null_elk_progress_monitor()
  }
  ignore(pm.begin("Pack components", 1.0))
  let packed = self.components_processor.pack(components)
  pm.done()

  pm = match progress_monitor.sub_task(default_work) {
    Some(monitor) => monitor
    None => new_null_elk_progress_monitor()
  }
  ignore(pm.begin("Apply layout results", 1.0))
  importer.apply_layout(packed)
  pm.done()
}
