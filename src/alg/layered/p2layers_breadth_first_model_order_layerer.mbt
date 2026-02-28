///|
fn breadth_first_model_order_layerer_layer_constraint_preprocessor_factory() -> @core.ILayoutProcessorFactory[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor_factory(23007, 7, () => {
    new_layer_constraint_preprocessor_layout_processor()
  })
}

///|
fn breadth_first_model_order_layerer_layer_constraint_postprocessor_factory() -> @core.ILayoutProcessorFactory[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor_factory(23011, 11, () => {
    new_layer_constraint_postprocessor_layout_processor()
  })
}

///|
let breadth_first_model_order_layerer_baseline_processing_configuration : @core.LayoutProcessorConfiguration[
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
    breadth_first_model_order_layerer_layer_constraint_preprocessor_factory(),
  )
  .add_before(
    LayeredPhases::P3NodeOrdering,
    breadth_first_model_order_layerer_layer_constraint_postprocessor_factory(),
  )

///|
pub(all) suberror BreadthFirstModelOrderLayererException {
  UnsupportedGraphException(String)
} derive(Show, ToJson)

///|
fn[T] breadth_first_model_order_layerer_raise_unsupported_graph(
  message : String,
) -> T raise BreadthFirstModelOrderLayererException {
  raise BreadthFirstModelOrderLayererException::UnsupportedGraphException(
    message,
  )
}

///|
fn breadth_first_model_order_layerer_require_edge_source_node(
  edge : LEdge,
) -> LNode raise BreadthFirstModelOrderLayererException {
  let source = match edge.get_source() {
    Some(value) => value
    None =>
      breadth_first_model_order_layerer_raise_unsupported_graph(
        "edge has no source port",
      )
  }
  match source.get_node() {
    Some(value) => value
    None =>
      breadth_first_model_order_layerer_raise_unsupported_graph(
        "source port has no owner node",
      )
  }
}

///|
fn breadth_first_model_order_layerer_layer_equals(
  layer : Layer?,
  target : Layer,
) -> Bool {
  match layer {
    Some(value) => layer_internal_handle(value) == layer_internal_handle(target)
    None => false
  }
}

///|
fn breadth_first_model_order_layerer_label_connects_to_current_layer(
  label_dummy : LNode,
  current_layer : Layer,
) -> Bool raise BreadthFirstModelOrderLayererException {
  let incoming_edges = label_dummy.get_incoming_edges()
  if incoming_edges.is_empty() {
    breadth_first_model_order_layerer_raise_unsupported_graph(
      "label dummy node has no incoming edges",
    )
  }
  let source = breadth_first_model_order_layerer_require_edge_source_node(
    incoming_edges[0],
  )
  breadth_first_model_order_layerer_layer_equals(
    source.get_layer(),
    current_layer,
  )
}

///|
fn breadth_first_model_order_layerer_incoming_edge_connects_to_current_layer(
  edge : LEdge,
  current_layer : Layer,
) -> Bool raise BreadthFirstModelOrderLayererException {
  let source_node = breadth_first_model_order_layerer_require_edge_source_node(
    edge,
  )
  if source_node.get_type() is NodeType::Normal {
    return breadth_first_model_order_layerer_layer_equals(
      source_node.get_layer(),
      current_layer,
    )
  }
  if source_node.get_type() is NodeType::LabelNode {
    return breadth_first_model_order_layerer_label_connects_to_current_layer(
      source_node, current_layer,
    )
  }
  false
}

///|
fn breadth_first_model_order_layerer_model_order(
  node : LNode,
) -> Int raise BreadthFirstModelOrderLayererException {
  if node.has_property_int(internal_properties_model_order) {
    node.get_property_int(internal_properties_model_order)
  } else {
    breadth_first_model_order_layerer_raise_unsupported_graph(
      "The BF model order layer assigner requires all real nodes to have a model order.",
    )
  }
}

///|
fn breadth_first_model_order_layerer_sort_real_nodes(
  real_nodes : Array[LNode],
) -> Unit raise BreadthFirstModelOrderLayererException {
  let mut i = 1
  while i < real_nodes.length() {
    let current = real_nodes[i]
    let current_model_order = breadth_first_model_order_layerer_model_order(
      current,
    )
    let mut j = i
    while j > 0 &&
          breadth_first_model_order_layerer_model_order(real_nodes[j - 1]) >
          current_model_order {
      real_nodes[j] = real_nodes[j - 1]
      j -= 1
    }
    real_nodes[j] = current
    i += 1
  }
}

///|
fn breadth_first_model_order_layerer_remove_layer(
  layered_graph : LGraph,
  target : Layer,
) -> Unit {
  let layers = layered_graph.get_layers()
  for i in 0..<layers.length() {
    if layer_internal_handle(layers[i]) == layer_internal_handle(target) {
      ignore(layers.remove(i))
      return
    }
  }
}

///|
fn breadth_first_model_order_layerer_configuration(
  graph : LGraph,
) -> @core.LayoutProcessorConfiguration[LayeredPhases, LGraph]? {
  ignore(graph)
  Some(breadth_first_model_order_layerer_baseline_processing_configuration)
}

///|
fn breadth_first_model_order_layerer_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Breadth first model order layering", 1.0))

  let real_nodes = []
  for node in layered_graph.get_layerless_nodes() {
    if node.get_type() is NodeType::Normal {
      real_nodes.push(node)
    }
  }
  try {
    breadth_first_model_order_layerer_sort_real_nodes(real_nodes)

    let mut first_node = true
    let mut current_layer = new_layer(layered_graph)
    let mut current_dummy_layer : Layer? = None
    layered_graph.get_layers().push(current_layer)

    for node in real_nodes {
      if first_node {
        node.set_layer(Some(current_layer))
        first_node = false
      } else {
        for edge in node.get_incoming_edges() {
          if breadth_first_model_order_layerer_incoming_edge_connects_to_current_layer(
              edge, current_layer,
            ) {
            let new_dummy_layer = new_layer(layered_graph)
            layered_graph.get_layers().push(new_dummy_layer)
            current_dummy_layer = Some(new_dummy_layer)

            let new_current_layer = new_layer(layered_graph)
            layered_graph.get_layers().push(new_current_layer)
            current_layer = new_current_layer
          }
        }

        for edge in node.get_incoming_edges() {
          let source_node = breadth_first_model_order_layerer_require_edge_source_node(
            edge,
          )
          if source_node.get_type() is NodeType::LabelNode &&
            source_node.get_layer() is None {
            source_node.set_layer(current_dummy_layer)
          }
        }

        node.set_layer(Some(current_layer))
      }
    }

    layered_graph.get_layerless_nodes().clear()

    let to_delete = []
    for layer in layered_graph.get_layers() {
      if layer.get_nodes().is_empty() {
        to_delete.push(layer)
      }
    }
    for layer in to_delete {
      breadth_first_model_order_layerer_remove_layer(layered_graph, layer)
    }

    let mut layer_id = 0
    for layer in layered_graph.get_layers() {
      layer.set_id(layer_id)
      layer_id += 1
    }
  } catch {
    BreadthFirstModelOrderLayererException::UnsupportedGraphException(message) => {
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
pub fn new_breadth_first_model_order_layerer_layout_phase() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_phase(
    breadth_first_model_order_layerer_process, breadth_first_model_order_layerer_configuration,
  )
}
