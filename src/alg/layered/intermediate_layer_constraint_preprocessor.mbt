///|
fn layer_constraint_preprocessor_node_type_is_external_port(
  node_type : NodeType,
) -> Bool {
  match node_type {
    NodeType::ExternalPort => true
    _ => false
  }
}

///|
fn layer_constraint_preprocessor_layer_constraint(
  node : LNode,
) -> LayerConstraint {
  layer_constraint_from_string(
    node.get_property_string(layered_options_layering_layer_constraint),
  )
}

///|
fn layer_constraint_preprocessor_is_relevant_node(node : LNode) -> Bool {
  match layer_constraint_preprocessor_layer_constraint(node) {
    LayerConstraint::FirstSeparate => true
    LayerConstraint::LastSeparate => true
    _ => false
  }
}

///|
fn layer_constraint_preprocessor_require_edge_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source")
  }
}

///|
fn layer_constraint_preprocessor_require_edge_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target")
  }
}

///|
fn layer_constraint_preprocessor_require_port_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(value) => value
    None => abort("port has no owner node")
  }
}

///|
fn layer_constraint_preprocessor_hidden_connections_combine(
  current : String,
  layer_constraint : LayerConstraint,
) -> String {
  match current {
    "NONE" =>
      match layer_constraint {
        LayerConstraint::FirstSeparate => "FIRST_SEPARATE"
        _ => "LAST_SEPARATE"
      }
    "FIRST_SEPARATE" =>
      match layer_constraint {
        LayerConstraint::FirstSeparate => "FIRST_SEPARATE"
        _ => "BOTH"
      }
    "LAST_SEPARATE" =>
      match layer_constraint {
        LayerConstraint::FirstSeparate => "BOTH"
        _ => "LAST_SEPARATE"
      }
    _ => "BOTH"
  }
}

///|
let layer_constraint_preprocessor_hidden_node_connections : @graph.IProperty[
  String,
] = @graph.new_property("separateLayerConnections", "NONE")

///|
fn layer_constraint_preprocessor_update_opposite_node_layer_constraints(
  hidden_node : LNode,
  opposite_node : LNode,
) -> Unit {
  if opposite_node.has_property_string(
      layered_options_layering_layer_constraint,
    ) {
    return
  }

  let connections = layer_constraint_preprocessor_hidden_connections_combine(
    opposite_node.get_property_string(
      layer_constraint_preprocessor_hidden_node_connections,
    ),
    layer_constraint_preprocessor_layer_constraint(hidden_node),
  )
  opposite_node.set_property_string(
    layer_constraint_preprocessor_hidden_node_connections, connections,
  )

  if !opposite_node.get_connected_edges().is_empty() {
    return
  }

  if connections == "FIRST_SEPARATE" {
    opposite_node.set_property_string(
      layered_options_layering_layer_constraint,
      layer_constraint_to_string(LayerConstraint::First),
    )
  } else if connections == "LAST_SEPARATE" {
    opposite_node.set_property_string(
      layered_options_layering_layer_constraint,
      layer_constraint_to_string(LayerConstraint::Last),
    )
  }
}

///|
fn layer_constraint_preprocessor_is_acceptable_incident_edge(
  edge : LEdge,
) -> Bool {
  let source_node = layer_constraint_preprocessor_require_port_node(
    layer_constraint_preprocessor_require_edge_source(edge),
  )
  let target_node = layer_constraint_preprocessor_require_port_node(
    layer_constraint_preprocessor_require_edge_target(edge),
  )
  layer_constraint_preprocessor_node_type_is_external_port(
    source_node.get_type(),
  ) &&
  layer_constraint_preprocessor_node_type_is_external_port(
    target_node.get_type(),
  )
}

///|
fn layer_constraint_preprocessor_ensure_no_inacceptable_edges(
  node : LNode,
) -> Unit {
  let layer_constraint = layer_constraint_preprocessor_layer_constraint(node)
  match layer_constraint {
    LayerConstraint::FirstSeparate =>
      for in_edge in node.get_incoming_edges() {
        if !layer_constraint_preprocessor_is_acceptable_incident_edge(in_edge) {
          abort(
            "Node '" +
            node.to_string() +
            "' has its layer constraint set to FIRST_SEPARATE, but has at least one incoming edge. FIRST_SEPARATE nodes must not have incoming edges.",
          )
        }
      }
    LayerConstraint::LastSeparate =>
      for out_edge in node.get_outgoing_edges() {
        if !layer_constraint_preprocessor_is_acceptable_incident_edge(out_edge) {
          abort(
            "Node '" +
            node.to_string() +
            "' has its layer constraint set to LAST_SEPARATE, but has at least one outgoing edge. LAST_SEPARATE nodes must not have outgoing edges.",
          )
        }
      }
    _ => ()
  }
}

///|
fn layer_constraint_preprocessor_hide_edge(node : LNode, edge : LEdge) -> Unit {
  let source = layer_constraint_preprocessor_require_edge_source(edge)
  let target = layer_constraint_preprocessor_require_edge_target(edge)
  let source_node = layer_constraint_preprocessor_require_port_node(source)
  let is_outgoing = source_node.get_handle() == node.get_handle()
  let opposite_port = if is_outgoing { target } else { source }

  if is_outgoing {
    edge.set_target(None)
  } else {
    edge.set_source(None)
  }

  edge.set_property_l_port(
    internal_properties_original_opposite_port,
    Some(opposite_port),
  )

  layer_constraint_preprocessor_update_opposite_node_layer_constraints(
    node,
    layer_constraint_preprocessor_require_port_node(opposite_port),
  )
}

///|
fn layer_constraint_preprocessor_hide(node : LNode) -> Unit {
  layer_constraint_preprocessor_ensure_no_inacceptable_edges(node)
  for edge in node.get_connected_edges() {
    layer_constraint_preprocessor_hide_edge(node, edge)
  }
}

///|
fn layer_constraint_preprocessor_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Layer constraint preprocessing", 1.0))

  let hidden_nodes = []
  let nodes = layered_graph.get_layerless_nodes()
  let mut index = 0
  while index < nodes.length() {
    let node = nodes[index]
    if layer_constraint_preprocessor_is_relevant_node(node) {
      layer_constraint_preprocessor_hide(node)
      hidden_nodes.push(node)
      ignore(nodes.remove(index))
    } else {
      index += 1
    }
  }

  if !hidden_nodes.is_empty() {
    layered_graph.set_property_l_node_array(
      internal_properties_hidden_nodes, hidden_nodes,
    )
  }

  monitor.done()
}

///|
pub fn new_layer_constraint_preprocessor_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(layer_constraint_preprocessor_process)
}
