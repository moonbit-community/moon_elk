///|
pub struct SporeShrinkTreeLayoutProvider {
  metadata : @core.OptionMetadata
  shrink_tree : SporeShrinkTree
}

///|
pub fn new_spore_shrink_tree_layout_provider(
  metadata : @core.OptionMetadata,
) -> SporeShrinkTreeLayoutProvider raise {
  { metadata, shrink_tree: new_spore_shrink_tree() }
}

///|
pub fn register_spore_compaction_layout_algorithm(
  runtime : @core.LayoutRuntime,
) -> Unit {
  runtime.register_layout_algorithm(spore_compaction_algorithm_id, (
    _runtime,
    _session,
    layout_graph,
    progress_monitor,
  ) => {
    new_spore_shrink_tree_layout_provider(runtime.option_metadata()).layout(
      layout_graph, progress_monitor,
    )
  })
}

///|
pub fn SporeShrinkTreeLayoutProvider::layout(
  self : SporeShrinkTreeLayoutProvider,
  layout_graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit raise {
  if @graph.node_has_string_property(
      layout_graph, spore_underlying_layout_algorithm,
    ) {
    let requested_algorithm = @graph.node_get_string_property(
      layout_graph, spore_underlying_layout_algorithm,
    )
    if !requested_algorithm.is_empty() {
      ignore(self.metadata.algorithm_data_by_suffix(requested_algorithm))
    }
  }

  let graph_importer = new_spore_elk_graph_as_igraph_importer()
  let graph = graph_importer.import_graph(layout_graph)
  let sub_monitor = match progress_monitor.sub_task(1.0) {
    Some(monitor) => monitor
    None => progress_monitor
  }
  self.shrink_tree.shrink(graph, sub_monitor)
  graph_importer.apply_positions(graph)
}

///|
pub fn spore_shrink_tree_layout_provider_as_layout_provider(
  provider : SporeShrinkTreeLayoutProvider,
) -> @core.AbstractLayoutProvider {
  @core.new_abstract_layout_provider((graph, monitor) => {
    provider.layout(graph, monitor)
  })
}
