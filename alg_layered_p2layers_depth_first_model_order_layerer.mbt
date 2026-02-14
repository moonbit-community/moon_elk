///|
struct DepthFirstModelOrderLayererState {
  layered_graph : LGraph
  mut current_layer : Layer
  mut current_layer_id : Int
  mut current_dummy_layer : Layer?
  nodes_to_place : Array[LNode]
  mut max_to_place : Int
}

///|
fn depth_first_model_order_layerer_layer_constraint_preprocessor_factory() -> ILayoutProcessorFactory[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor_factory(23027, 27, () => {
    new_layer_constraint_preprocessor_layout_processor()
  })
}

///|
fn depth_first_model_order_layerer_layer_constraint_postprocessor_factory() -> ILayoutProcessorFactory[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor_factory(23028, 28, () => {
    new_layer_constraint_postprocessor_layout_processor()
  })
}

///|
let depth_first_model_order_layerer_baseline_processing_configuration : LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] = layout_processor_configuration_create(layered_phase_descriptor)
  .add_before(
    LayeredPhases::P1CycleBreaking,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::EdgeAndLayerConstraintEdgeReverser,
    ),
  )
  .add_before(
    LayeredPhases::P2Layering,
    depth_first_model_order_layerer_layer_constraint_preprocessor_factory(),
  )
  .add_before(
    LayeredPhases::P3NodeOrdering,
    depth_first_model_order_layerer_layer_constraint_postprocessor_factory(),
  )

///|
fn depth_first_model_order_layerer_require_edge_source_node(
  edge : LEdge,
) -> LNode {
  let source = match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source port")
  }
  match source.get_node() {
    Some(value) => value
    None => abort("source port has no owner node")
  }
}

///|
fn depth_first_model_order_layerer_model_order(node : LNode) -> Int {
  if node.has_property_int(internal_properties_model_order) {
    node.get_property_int(internal_properties_model_order)
  } else {
    abort(
      "The DF model order layer assigner requires all real nodes to have a model order.",
    )
  }
}

///|
fn depth_first_model_order_layerer_sort_real_nodes(
  real_nodes : Array[LNode],
) -> Unit {
  let mut i = 1
  while i < real_nodes.length() {
    let current = real_nodes[i]
    let current_model_order = depth_first_model_order_layerer_model_order(
      current,
    )
    let mut j = i
    while j > 0 &&
          depth_first_model_order_layerer_model_order(real_nodes[j - 1]) >
          current_model_order {
      real_nodes[j] = real_nodes[j - 1]
      j -= 1
    }
    real_nodes[j] = current
    i += 1
  }
}

///|
fn depth_first_model_order_layerer_is_connected_to_current_layer(
  state : DepthFirstModelOrderLayererState,
  node : LNode,
) -> Bool {
  for edge in node.get_incoming_edges() {
    let source_node = depth_first_model_order_layerer_require_edge_source_node(
      edge,
    )
    let directly_connected = if state.nodes_to_place.is_empty() {
      if source_node.get_type() is NodeType::Normal {
        match source_node.get_layer() {
          Some(layer) => layer.get_id() == state.current_layer_id
          None => false
        }
      } else {
        false
      }
    } else {
      source_node.get_type() is NodeType::Normal &&
      source_node.get_id() == state.current_layer_id
    }

    let connected_via_label_dummy = if state.nodes_to_place.is_empty() {
      if source_node.get_incoming_edges().is_empty() {
        false
      } else {
        let connected_layer_via_dummy = depth_first_model_order_layerer_require_edge_source_node(
          source_node.get_incoming_edges()[0],
        ).get_layer()
        if source_node.get_type() is NodeType::LabelNode {
          match connected_layer_via_dummy {
            Some(layer) => layer.get_id() == state.current_layer_id
            None => false
          }
        } else {
          false
        }
      }
    } else if source_node.get_type() is NodeType::LabelNode {
      let incoming_edges = source_node.get_incoming_edges()
      if incoming_edges.is_empty() {
        abort("label dummy node has no incoming edges")
      }
      depth_first_model_order_layerer_require_edge_source_node(
        incoming_edges[0],
      ).get_id() ==
      state.current_layer_id
    } else {
      false
    }

    if directly_connected || connected_via_label_dummy {
      return true
    }
  }
  false
}

///|
fn depth_first_model_order_layerer_add_node_to_layer(
  state : DepthFirstModelOrderLayererState,
  layer_id : Int,
  node : LNode,
) -> Unit {
  let layers = state.layered_graph.get_layers()
  if layer_id < layers.length() {
    state.current_layer = layers[layer_id]
    state.current_dummy_layer = if layer_id > 0 {
      Some(layers[layer_id - 1])
    } else {
      None
    }
    state.current_layer_id = layer_id
  } else {
    let new_dummy_layer = new_layer(state.layered_graph)
    new_dummy_layer.set_id(layer_id - 1)
    layers.push(new_dummy_layer)
    state.current_dummy_layer = Some(new_dummy_layer)

    let new_current_layer = new_layer(state.layered_graph)
    new_current_layer.set_id(layer_id)
    layers.push(new_current_layer)
    state.current_layer = new_current_layer
    state.current_layer_id = layer_id
  }

  node.set_layer(Some(state.current_layer))
  for edge in node.get_incoming_edges() {
    let source_node = depth_first_model_order_layerer_require_edge_source_node(
      edge,
    )
    if source_node.get_layer() is None &&
      source_node.get_type() is NodeType::LabelNode {
      source_node.set_layer(state.current_dummy_layer)
    }
  }
}

///|
fn depth_first_model_order_layerer_get_max_connected_layer(
  layer_id : Int,
  node : LNode,
) -> Int {
  let mut max_layer = layer_id
  for edge in node.get_incoming_edges() {
    let source_node = depth_first_model_order_layerer_require_edge_source_node(
      edge,
    )
    match source_node.get_layer() {
      Some(layer) =>
        if layer.get_id() > max_layer {
          max_layer = layer.get_id()
        }
      None => ()
    }
  }
  max_layer
}

///|
fn depth_first_model_order_layerer_place_nodes_to_place(
  state : DepthFirstModelOrderLayererState,
) -> Unit {
  state.max_to_place = 0
  for node_to_place in state.nodes_to_place {
    let layers = state.layered_graph.get_layers()
    if node_to_place.get_id() >= layers.length() {
      let dummy_layer = new_layer(state.layered_graph)
      dummy_layer.set_id(node_to_place.get_id() - 1)
      layers.push(dummy_layer)

      let new_layer_value = new_layer(state.layered_graph)
      new_layer_value.set_id(node_to_place.get_id())
      layers.push(new_layer_value)
    }
    node_to_place.set_layer(
      Some(state.layered_graph.get_layers()[node_to_place.get_id()]),
    )
  }
}

///|
fn depth_first_model_order_layerer_configuration(
  graph : LGraph,
) -> LayoutProcessorConfiguration[LayeredPhases, LGraph]? {
  ignore(graph)
  Some(depth_first_model_order_layerer_baseline_processing_configuration)
}

///|
fn depth_first_model_order_layerer_process(
  layered_graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Depth first model order layering", 1.0))

  let real_nodes = []
  for node in layered_graph.get_layerless_nodes() {
    if node.get_type() is NodeType::Normal {
      real_nodes.push(node)
    }
  }
  depth_first_model_order_layerer_sort_real_nodes(real_nodes)

  let mut first_node = true
  let first_layer = new_layer(layered_graph)
  layered_graph.get_layers().push(first_layer)
  first_layer.set_id(0)

  let state : DepthFirstModelOrderLayererState = {
    layered_graph,
    current_layer: first_layer,
    current_layer_id: 0,
    current_dummy_layer: None,
    nodes_to_place: [],
    max_to_place: 0,
  }

  for node in real_nodes {
    if first_node {
      node.set_layer(Some(state.current_layer))
      first_node = false
    } else if depth_first_model_order_layerer_is_connected_to_current_layer(
        state, node,
      ) {
      let mut max_layer = state.current_layer_id
      max_layer = depth_first_model_order_layerer_get_max_connected_layer(
        max_layer, node,
      )
      let desired_layer = max_layer + 2
      let layer_diff = max_layer - state.current_layer_id

      if !state.nodes_to_place.is_empty() {
        if layer_diff > 0 {
          for to_place in state.nodes_to_place {
            to_place.set_id(to_place.get_id() + max_layer - state.max_to_place)
          }
          depth_first_model_order_layerer_place_nodes_to_place(state)
          state.nodes_to_place.clear()
          depth_first_model_order_layerer_add_node_to_layer(
            state, desired_layer, node,
          )
        } else {
          state.nodes_to_place.push(node)
          node.set_id(desired_layer)
          if desired_layer > state.max_to_place {
            state.max_to_place = desired_layer
          }
          for edge in node.get_incoming_edges() {
            let source_node = depth_first_model_order_layerer_require_edge_source_node(
              edge,
            )
            if source_node.get_layer() is None &&
              source_node.get_type() is NodeType::LabelNode {
              state.nodes_to_place.push(source_node)
              source_node.set_id(desired_layer - 1)
            }
          }
          state.current_layer_id = desired_layer
        }
      } else {
        depth_first_model_order_layerer_add_node_to_layer(
          state, desired_layer, node,
        )
      }
    } else {
      depth_first_model_order_layerer_place_nodes_to_place(state)
      state.nodes_to_place.clear()

      if node.get_incoming_edges().is_empty() {
        state.nodes_to_place.push(node)
        node.set_id(0)
        if 0 > state.max_to_place {
          state.max_to_place = 0
        }
        state.current_layer = layered_graph.get_layers()[0]
        state.current_layer_id = 0
      } else {
        let mut max_layer = 0
        max_layer = depth_first_model_order_layerer_get_max_connected_layer(
          max_layer, node,
        )
        let desired_layer = max_layer + 2
        depth_first_model_order_layerer_add_node_to_layer(
          state, desired_layer, node,
        )
      }
    }
  }

  if !state.nodes_to_place.is_empty() {
    depth_first_model_order_layerer_place_nodes_to_place(state)
  }

  layered_graph.get_layerless_nodes().clear()

  let layers = layered_graph.get_layers()
  let mut i = 0
  while i < layers.length() {
    if layers[i].get_nodes().is_empty() {
      ignore(layers.remove(i))
    } else {
      i += 1
    }
  }

  let mut layer_id = 0
  for layer in layers {
    layer.set_id(layer_id)
    layer_id += 1
  }

  monitor.done()
}

///|
pub fn new_depth_first_model_order_layerer_layout_phase() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_phase(
    depth_first_model_order_layerer_process, depth_first_model_order_layerer_configuration,
  )
}
