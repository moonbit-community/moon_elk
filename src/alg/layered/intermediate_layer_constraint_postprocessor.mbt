///|
fn layer_constraint_postprocessor_node_type_is_label(
  node_type : NodeType,
) -> Bool {
  match node_type {
    NodeType::LabelNode => true
    _ => false
  }
}

///|
fn layer_constraint_postprocessor_layer_constraint(
  node : LNode,
) -> LayerConstraint {
  layer_constraint_from_string(
    node.get_property_string(layered_options_layering_layer_constraint),
  )
}

///|
fn layer_constraint_postprocessor_require_edge_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source")
  }
}

///|
fn layer_constraint_postprocessor_require_edge_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target")
  }
}

///|
fn layer_constraint_postprocessor_require_port_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(value) => value
    None => abort("port has no owner node")
  }
}

///|
fn layer_constraint_postprocessor_move_labels_to_label_layer(
  node : LNode,
  incoming : Bool,
  label_layer : Layer,
) -> Unit {
  let edges = if incoming {
    node.get_incoming_edges()
  } else {
    node.get_outgoing_edges()
  }

  for edge in edges {
    let possible_label_dummy = if incoming {
      layer_constraint_postprocessor_require_port_node(
        layer_constraint_postprocessor_require_edge_source(edge),
      )
    } else {
      layer_constraint_postprocessor_require_port_node(
        layer_constraint_postprocessor_require_edge_target(edge),
      )
    }

    if layer_constraint_postprocessor_node_type_is_label(
        possible_label_dummy.get_type(),
      ) {
      possible_label_dummy.set_layer(Some(label_layer))
    }
  }
}

///|
fn layer_constraint_postprocessor_throw_up_unless_no_incoming_edges(
  node : LNode,
) -> Unit {
  for incoming in node.get_incoming_edges() {
    let source_node = layer_constraint_postprocessor_require_port_node(
      layer_constraint_postprocessor_require_edge_source(incoming),
    )
    if !layer_constraint_postprocessor_node_type_is_label(
        source_node.get_type(),
      ) {
      abort(
        "Node '" +
        node.to_string() +
        "' has its layer constraint set to FIRST, but has at least one incoming edge that  does not come from a FIRST_SEPARATE node. That must not happen.",
      )
    }
  }
}

///|
fn layer_constraint_postprocessor_throw_up_unless_no_outgoing_edges(
  node : LNode,
) -> Unit {
  for outgoing in node.get_outgoing_edges() {
    let target_node = layer_constraint_postprocessor_require_port_node(
      layer_constraint_postprocessor_require_edge_target(outgoing),
    )
    if !layer_constraint_postprocessor_node_type_is_label(
        target_node.get_type(),
      ) {
      abort(
        "Node '" +
        node.to_string() +
        "' has its layer constraint set to LAST, but has at least one outgoing edge that  does not go to a LAST_SEPARATE node. That must not happen.",
      )
    }
  }
}

///|
fn layer_constraint_postprocessor_move_first_and_last_nodes(
  layered_graph : LGraph,
  first_layer : Layer,
  last_layer : Layer,
  first_label_layer : Layer,
  last_label_layer : Layer,
) -> Unit {
  for layer in layered_graph.get_layers() {
    let nodes = layer.get_nodes().copy()
    for node in nodes {
      match layer_constraint_postprocessor_layer_constraint(node) {
        LayerConstraint::First => {
          layer_constraint_postprocessor_throw_up_unless_no_incoming_edges(node)
          node.set_layer(Some(first_layer))
          layer_constraint_postprocessor_move_labels_to_label_layer(
            node, true, first_label_layer,
          )
        }
        LayerConstraint::Last => {
          layer_constraint_postprocessor_throw_up_unless_no_outgoing_edges(node)
          node.set_layer(Some(last_layer))
          layer_constraint_postprocessor_move_labels_to_label_layer(
            node, false, last_label_layer,
          )
        }
        _ => ()
      }
    }
  }

  let layers = layered_graph.get_layers()
  let mut index = 0
  while index < layers.length() {
    if layers[index].get_nodes().is_empty() {
      ignore(layers.remove(index))
    } else {
      index += 1
    }
  }
}

///|
fn layer_constraint_postprocessor_restore_hidden_nodes(
  layered_graph : LGraph,
  first_separate_layer : Layer,
  last_separate_layer : Layer,
) -> Unit {
  for
    hidden_node in layered_graph.get_property_l_node_array(
      internal_properties_hidden_nodes,
    ) {
    match layer_constraint_postprocessor_layer_constraint(hidden_node) {
      LayerConstraint::FirstSeparate =>
        hidden_node.set_layer(Some(first_separate_layer))
      LayerConstraint::LastSeparate =>
        hidden_node.set_layer(Some(last_separate_layer))
      _ => abort("Only *_SEPARATE nodes should be hidden.")
    }

    for hidden_edge in hidden_node.get_connected_edges() {
      match (hidden_edge.get_source(), hidden_edge.get_target()) {
        (Some(_), Some(_)) => continue
        _ => ()
      }

      let is_outgoing = match hidden_edge.get_target() {
        None => true
        Some(_) => false
      }

      let original_opposite_port = match
        hidden_edge.get_property_l_port(
          internal_properties_original_opposite_port,
        ) {
        Some(value) => value
        None => abort("hidden edge missing ORIGINAL_OPPOSITE_PORT")
      }
      if is_outgoing {
        hidden_edge.set_target(Some(original_opposite_port))
      } else {
        hidden_edge.set_source(Some(original_opposite_port))
      }
    }
  }
}

///|
fn layer_constraint_postprocessor_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Layer constraint postprocessing", 1.0))

  let layers = layered_graph.get_layers()
  if !layers.is_empty() {
    let first_layer = layers[0]
    let last_layer = layers[layers.length() - 1]
    let first_label_layer = new_layer(layered_graph)
    let last_label_layer = new_layer(layered_graph)

    layer_constraint_postprocessor_move_first_and_last_nodes(
      layered_graph, first_layer, last_layer, first_label_layer, last_label_layer,
    )

    if !first_label_layer.get_nodes().is_empty() {
      ignore(layers.insert(0, first_label_layer))
    }
    if !last_label_layer.get_nodes().is_empty() {
      layers.push(last_label_layer)
    }
  }

  if layered_graph.has_property_l_node_array(internal_properties_hidden_nodes) {
    let first_separate_layer = new_layer(layered_graph)
    let last_separate_layer = new_layer(layered_graph)
    layer_constraint_postprocessor_restore_hidden_nodes(
      layered_graph, first_separate_layer, last_separate_layer,
    )

    if !first_separate_layer.get_nodes().is_empty() {
      ignore(layers.insert(0, first_separate_layer))
    }
    if !last_separate_layer.get_nodes().is_empty() {
      layers.push(last_separate_layer)
    }
  }

  monitor.done()
}

///|
pub fn new_layer_constraint_postprocessor_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(layer_constraint_postprocessor_process)
}
