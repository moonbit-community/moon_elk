///|
fn longest_path_source_layerer_layer_constraint_preprocessor_factory() -> @core.ILayoutProcessorFactory[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor_factory(23007, 7, () => {
    new_layer_constraint_preprocessor_layout_processor()
  })
}

///|
fn longest_path_source_layerer_layer_constraint_postprocessor_factory() -> @core.ILayoutProcessorFactory[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor_factory(23011, 11, () => {
    new_layer_constraint_postprocessor_layout_processor()
  })
}

///|
let longest_path_source_layerer_baseline_processing_configuration : @core.LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] = @core.layout_processor_configuration_create(layered_phase_descriptor)
  .add_before(
    LayeredPhases::P1CycleBreaking,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::EdgeAndLayerConstraintEdgeReverser,
    ),
  )
  .add_before(
    LayeredPhases::P2Layering,
    longest_path_source_layerer_layer_constraint_preprocessor_factory(),
  )
  .add_before(
    LayeredPhases::P3NodeOrdering,
    longest_path_source_layerer_layer_constraint_postprocessor_factory(),
  )

///|
pub(all) suberror LongestPathSourceLayererException {
  UnsupportedGraphException(String)
} derive(Show, ToJson)

///|
fn[T] longest_path_source_layerer_raise_unsupported_graph(
  message : String,
) -> T raise LongestPathSourceLayererException {
  raise LongestPathSourceLayererException::UnsupportedGraphException(message)
}

///|
fn longest_path_source_layerer_require_edge_source_node(
  edge : LEdge,
) -> LNode raise LongestPathSourceLayererException {
  let source = match edge.get_source() {
    Some(value) => value
    None =>
      longest_path_source_layerer_raise_unsupported_graph(
        "edge has no source port",
      )
  }
  match source.get_node() {
    Some(value) => value
    None =>
      longest_path_source_layerer_raise_unsupported_graph(
        "source port has no owner node",
      )
  }
}

///|
fn longest_path_source_layerer_put_node(
  layered_graph : LGraph,
  node_heights : Array[Int],
  node : LNode,
  height : Int,
) -> Unit {
  let layers = layered_graph.get_layers()
  let mut layer_count = layers.length()
  while layer_count < height {
    layers.push(new_layer(layered_graph))
    layer_count += 1
  }

  node.set_layer(Some(layers[height - 1]))
  node_heights[node.get_id()] = height
}

///|
fn longest_path_source_layerer_visit(
  layered_graph : LGraph,
  node_heights : Array[Int],
  node : LNode,
) -> Int raise LongestPathSourceLayererException {
  let height = node_heights[node.get_id()]
  if height >= 0 {
    return height
  }

  let mut max_height = 1
  for port in node.get_ports() {
    for edge in port.get_incoming_edges() {
      let source_node = longest_path_source_layerer_require_edge_source_node(
        edge,
      )
      if lnode_internal_handle(node) != lnode_internal_handle(source_node) {
        let source_height = longest_path_source_layerer_visit(
          layered_graph, node_heights, source_node,
        )
        let candidate_height = source_height + 1
        if candidate_height > max_height {
          max_height = candidate_height
        }
      }
    }
  }

  longest_path_source_layerer_put_node(
    layered_graph, node_heights, node, max_height,
  )
  max_height
}

///|
fn longest_path_source_layerer_configuration(
  graph : LGraph,
) -> @core.LayoutProcessorConfiguration[LayeredPhases, LGraph]? {
  ignore(graph)
  Some(
    @core.layout_processor_configuration_create_from(
      longest_path_source_layerer_baseline_processing_configuration,
    ),
  )
}

///|
fn longest_path_source_layerer_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Longest path to source layering", 1.0))

  let nodes = layered_graph.get_layerless_nodes()
  let node_heights = []

  let mut index = 0
  for node in nodes {
    node.set_id(index)
    node_heights.push(-1)
    index += 1
  }

  try {
    for node in nodes {
      ignore(
        longest_path_source_layerer_visit(layered_graph, node_heights, node),
      )
    }
    nodes.clear()
  } catch {
    LongestPathSourceLayererException::UnsupportedGraphException(message) => {
      @core.layout_runtime_report_unsupported_configuration(message)
      monitor.done()
      return
    }
  } noraise {
    _ => ()
  }
  monitor.done()
}

///|
pub fn new_longest_path_source_layerer_layout_phase() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_phase(
    longest_path_source_layerer_process, longest_path_source_layerer_configuration,
  )
}
