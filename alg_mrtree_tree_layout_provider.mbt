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
pub fn MrtreeTreeLayoutProvider::layout(
  self : MrtreeTreeLayoutProvider,
  layout_graph : ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  let importer = new_mrtree_elk_graph_importer()
  let graph = importer.import_graph(layout_graph)
  let components = self.components_processor.split(graph)
  for component in components {
    ignore(self.tree.do_layout(component, progress_monitor))
  }
  let packed = self.components_processor.pack(components)
  importer.apply_layout(packed)
}
