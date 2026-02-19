///|
pub struct DisCoLayoutProvider {
  mut result : DCGraph?
  mut component_spacing : Double
}

///|
pub fn new_dis_co_layout_provider() -> DisCoLayoutProvider {
  { result: None, component_spacing: 0.0 }
}

///|
fn dis_co_compaction_strategy(layout_graph : @graph.ElkNode) -> CompactionStrategy {
  let value = @graph.node_get_string_property(
    layout_graph, disco_component_compaction_strategy,
  )
  if value == "POLYOMINO" || value == "Polyomino" {
    Polyomino
  } else {
    Polyomino
  }
}

///|
pub fn DisCoLayoutProvider::layout(
  self : DisCoLayoutProvider,
  layout_graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit {
  ignore(progress_monitor.begin("Connected Components Compaction", 1.0))
  self.component_spacing = @graph.node_get_double_property(
    layout_graph, disco_spacing_component_component,
  )

  if @graph.node_has_string_property(layout_graph, disco_component_layout_algorithm) {
    let requested_algorithm = @graph.node_get_string_property(
      layout_graph, disco_component_layout_algorithm,
    )
    if !requested_algorithm.is_empty() {
      ignore(
        @core.layout_meta_data_service_get_algorithm_data_by_suffix(
          requested_algorithm,
        ),
      )
    }
  }

  let transformer = new_elk_graph_transformer(
    component_spacing=self.component_spacing,
  )
  let transformed = transformer.import_graph(layout_graph)
  self.result = Some(transformed)

  match dis_co_compaction_strategy(layout_graph) {
    Polyomino => new_dis_co_polyomino_compactor().compact(transformed)
  }

  transformer.apply_layout()
  progress_monitor.done()
}

///|
pub fn dis_co_layout_provider_as_layout_provider(
  provider : DisCoLayoutProvider,
) -> @core.AbstractLayoutProvider {
  @core.new_abstract_layout_provider((graph, monitor) => {
    provider.layout(graph, monitor)
  })
}
