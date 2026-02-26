///|
pub struct SporeShrinkTreeLayoutProvider {
  shrink_tree : SporeShrinkTree
}

///|
pub fn new_spore_shrink_tree_layout_provider() -> SporeShrinkTreeLayoutProvider {
  { shrink_tree: new_spore_shrink_tree() }
}

///|
fn init {
  @core.recursive_graph_layout_engine_register_handler(
    spore_compaction_algorithm_id,
    (layout_graph, progress_monitor) => {
      new_spore_shrink_tree_layout_provider().layout(
        layout_graph, progress_monitor,
      )
    },
  )
}

///|
pub fn SporeShrinkTreeLayoutProvider::layout(
  self : SporeShrinkTreeLayoutProvider,
  layout_graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit {
  if @graph.node_has_string_property(
      layout_graph, spore_underlying_layout_algorithm,
    ) {
    let requested_algorithm = @graph.node_get_string_property(
      layout_graph, spore_underlying_layout_algorithm,
    )
    if !requested_algorithm.is_empty() {
      ignore(
        @core.layout_meta_data_service_get_algorithm_data_by_suffix(
          requested_algorithm,
        ),
      )
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
