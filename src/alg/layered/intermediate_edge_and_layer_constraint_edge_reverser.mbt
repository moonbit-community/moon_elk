///|
priv suberror EdgeAndLayerConstraintEdgeReverserException {
  UnsupportedGraphException(String)
} derive(Debug, ToJson)

///|
fn[T] edge_and_layer_constraint_edge_reverser_raise_unsupported_graph(
  message : String,
) -> T raise EdgeAndLayerConstraintEdgeReverserException {
  raise UnsupportedGraphException(message)
}

///|
fn edge_and_layer_constraint_edge_reverser_layer_constraint_equals(
  left : LayerConstraint,
  right : LayerConstraint,
) -> Bool {
  match (left, right) {
    (NoneType, NoneType) => true
    (First, First) => true
    (FirstSeparate, FirstSeparate) => true
    (Last, Last) => true
    (LastSeparate, LastSeparate) => true
    _ => false
  }
}

///|
fn edge_and_layer_constraint_edge_reverser_port_side_equals(
  left : @core.PortSide,
  right : @core.PortSide,
) -> Bool {
  match (left, right) {
    (North, North) => true
    (East, East) => true
    (South, South) => true
    (West, West) => true
    (SideUndefined, SideUndefined) => true
    _ => false
  }
}

///|
fn edge_and_layer_constraint_edge_reverser_port_type_equals(
  left : PortType,
  right : PortType,
) -> Bool {
  match (left, right) {
    (Undefined, Undefined) => true
    (Input, Input) => true
    (Output, Output) => true
    _ => false
  }
}

///|
fn edge_and_layer_constraint_edge_reverser_node_type_equals(
  left : NodeType,
  right : NodeType,
) -> Bool {
  match (left, right) {
    (Normal, Normal) => true
    (LongEdge, LongEdge) => true
    (ExternalPort, ExternalPort) => true
    (NorthSouthPort, NorthSouthPort) => true
    (LabelNode, LabelNode) => true
    (BreakingPoint, BreakingPoint) => true
    (Placeholder, Placeholder) => true
    (NonshiftingPlaceholder, NonshiftingPlaceholder) => true
    _ => false
  }
}

///|
fn edge_and_layer_constraint_edge_reverser_port_constraints_from_string(
  value : String,
) -> @core.PortConstraints {
  match value {
    "UNDEFINED" => Undefined
    "FREE" => Free
    "FIXED_SIDE" => FixedSide
    "FIXED_ORDER" => FixedOrder
    "FIXED_RATIO" => FixedRatio
    "FIXED_POS" => FixedPos
    _ => Undefined
  }
}

///|
fn edge_and_layer_constraint_edge_reverser_edge_source(
  edge : LEdge,
) -> LPort raise EdgeAndLayerConstraintEdgeReverserException {
  match edge.get_source() {
    Some(value) => value
    None =>
      edge_and_layer_constraint_edge_reverser_raise_unsupported_graph(
        "edge has no source",
      )
  }
}

///|
fn edge_and_layer_constraint_edge_reverser_edge_target(
  edge : LEdge,
) -> LPort raise EdgeAndLayerConstraintEdgeReverserException {
  match edge.get_target() {
    Some(value) => value
    None =>
      edge_and_layer_constraint_edge_reverser_raise_unsupported_graph(
        "edge has no target",
      )
  }
}

///|
fn edge_and_layer_constraint_edge_reverser_port_node(
  port : LPort,
) -> LNode raise EdgeAndLayerConstraintEdgeReverserException {
  match port.get_node() {
    Some(value) => value
    None =>
      edge_and_layer_constraint_edge_reverser_raise_unsupported_graph(
        "port has no owner node",
      )
  }
}

///|
fn edge_and_layer_constraint_edge_reverser_layer_constraint(
  node : LNode,
) -> LayerConstraint {
  layer_constraint_from_string(
    node.get_property_string(layered_options_layering_layer_constraint),
  )
}

///|
fn edge_and_layer_constraint_edge_reverser_reverse_edge(
  edge : LEdge,
  layered_graph : LGraph,
) -> Unit {
  edge.reverse(layered_graph, true)
}

///|
fn edge_and_layer_constraint_edge_reverser_can_reverse_outgoing_edge(
  source_node_layer_constraint : LayerConstraint,
  edge : LEdge,
) -> Bool raise EdgeAndLayerConstraintEdgeReverserException {
  if edge.get_property_bool(internal_properties_reversed) {
    return false
  }

  let target_node = edge_and_layer_constraint_edge_reverser_port_node(
    edge_and_layer_constraint_edge_reverser_edge_target(edge),
  )

  if edge_and_layer_constraint_edge_reverser_layer_constraint_equals(
      source_node_layer_constraint,
      Last,
    ) &&
    edge_and_layer_constraint_edge_reverser_node_type_equals(
      target_node.get_type(),
      LabelNode,
    ) {
    return false
  }

  let target_layer_constraint = edge_and_layer_constraint_edge_reverser_layer_constraint(
    target_node,
  )
  if edge_and_layer_constraint_edge_reverser_layer_constraint_equals(
      target_layer_constraint,
      LastSeparate,
    ) {
    return false
  }

  true
}

///|
fn edge_and_layer_constraint_edge_reverser_can_reverse_incoming_edge(
  target_node_layer_constraint : LayerConstraint,
  edge : LEdge,
) -> Bool raise EdgeAndLayerConstraintEdgeReverserException {
  if edge.get_property_bool(internal_properties_reversed) {
    return false
  }

  let source_node = edge_and_layer_constraint_edge_reverser_port_node(
    edge_and_layer_constraint_edge_reverser_edge_source(edge),
  )

  if edge_and_layer_constraint_edge_reverser_layer_constraint_equals(
      target_node_layer_constraint,
      First,
    ) &&
    edge_and_layer_constraint_edge_reverser_node_type_equals(
      source_node.get_type(),
      LabelNode,
    ) {
    return false
  }

  let source_layer_constraint = edge_and_layer_constraint_edge_reverser_layer_constraint(
    source_node,
  )
  if edge_and_layer_constraint_edge_reverser_layer_constraint_equals(
      source_layer_constraint,
      FirstSeparate,
    ) {
    return false
  }

  true
}

///|
fn edge_and_layer_constraint_edge_reverser_reverse_edges(
  layered_graph : LGraph,
  node : LNode,
  node_layer_constraint : LayerConstraint,
  target_port_type : PortType,
) -> Unit raise EdgeAndLayerConstraintEdgeReverserException {
  for port in node.get_ports().copy() {
    if edge_and_layer_constraint_edge_reverser_port_type_equals(
        target_port_type,
        Input,
      ) ||
      edge_and_layer_constraint_edge_reverser_port_type_equals(
        target_port_type,
        Undefined,
      ) {
      for edge in port.get_outgoing_edges().copy() {
        if edge_and_layer_constraint_edge_reverser_can_reverse_outgoing_edge(
            node_layer_constraint, edge,
          ) {
          edge_and_layer_constraint_edge_reverser_reverse_edge(
            edge, layered_graph,
          )
        }
      }
    }

    if edge_and_layer_constraint_edge_reverser_port_type_equals(
        target_port_type,
        Output,
      ) ||
      edge_and_layer_constraint_edge_reverser_port_type_equals(
        target_port_type,
        Undefined,
      ) {
      for edge in port.get_incoming_edges().copy() {
        if edge_and_layer_constraint_edge_reverser_can_reverse_incoming_edge(
            node_layer_constraint, edge,
          ) {
          edge_and_layer_constraint_edge_reverser_reverse_edge(
            edge, layered_graph,
          )
        }
      }
    }
  }
}

///|
fn edge_and_layer_constraint_edge_reverser_handle_outer_nodes(
  layered_graph : LGraph,
) -> Array[LNode] raise EdgeAndLayerConstraintEdgeReverserException {
  let remaining_nodes = []
  for node in layered_graph.get_layerless_nodes() {
    let layer_constraint = edge_and_layer_constraint_edge_reverser_layer_constraint(
      node,
    )
    let edge_constraint = match layer_constraint {
      First => Some(EdgeConstraint::OutgoingOnly)
      FirstSeparate => Some(OutgoingOnly)
      Last => Some(IncomingOnly)
      LastSeparate => Some(IncomingOnly)
      _ => None
    }

    match edge_constraint {
      Some(constraint) =>
        if constraint is IncomingOnly {
          edge_and_layer_constraint_edge_reverser_reverse_edges(
            layered_graph,
            node,
            layer_constraint,
            Input,
          )
        } else {
          edge_and_layer_constraint_edge_reverser_reverse_edges(
            layered_graph,
            node,
            layer_constraint,
            Output,
          )
        }
      None => remaining_nodes.push(node)
    }
  }
  remaining_nodes
}

///|
fn edge_and_layer_constraint_edge_reverser_handle_inner_nodes(
  layered_graph : LGraph,
  remaining_nodes : Array[LNode],
) -> Unit raise EdgeAndLayerConstraintEdgeReverserException {
  for node in remaining_nodes {
    let layer_constraint = edge_and_layer_constraint_edge_reverser_layer_constraint(
      node,
    )
    let edge_constraint = match layer_constraint {
      First => Some(EdgeConstraint::OutgoingOnly)
      FirstSeparate => Some(OutgoingOnly)
      Last => Some(IncomingOnly)
      LastSeparate => Some(IncomingOnly)
      _ => None
    }

    match edge_constraint {
      Some(constraint) =>
        if constraint is IncomingOnly {
          edge_and_layer_constraint_edge_reverser_reverse_edges(
            layered_graph,
            node,
            layer_constraint,
            Input,
          )
        } else {
          edge_and_layer_constraint_edge_reverser_reverse_edges(
            layered_graph,
            node,
            layer_constraint,
            Output,
          )
        }
      None => {
        let port_constraints_value = if node.has_property_string(
            @core.port_constraints,
          ) {
          node.get_property_string(@core.port_constraints)
        } else {
          @core.port_constraints.get_default()
        }
        let constraints = edge_and_layer_constraint_edge_reverser_port_constraints_from_string(
          port_constraints_value,
        )
        if constraints.is_side_fixed() && !node.get_ports().is_empty() {
          let mut all_ports_reversed = true
          for port in node.get_ports() {
            let east_reversed = edge_and_layer_constraint_edge_reverser_port_side_equals(
                port.get_side(),
                East,
              ) &&
              port.get_net_flow() > 0
            let west_reversed = edge_and_layer_constraint_edge_reverser_port_side_equals(
                port.get_side(),
                West,
              ) &&
              port.get_net_flow() < 0
            if !(east_reversed || west_reversed) {
              all_ports_reversed = false
              break
            }

            for edge in port.get_outgoing_edges() {
              let target_layer_constraint = edge_and_layer_constraint_edge_reverser_layer_constraint(
                edge_and_layer_constraint_edge_reverser_port_node(
                  edge_and_layer_constraint_edge_reverser_edge_target(edge),
                ),
              )
              if edge_and_layer_constraint_edge_reverser_layer_constraint_equals(
                  target_layer_constraint,
                  Last,
                ) ||
                edge_and_layer_constraint_edge_reverser_layer_constraint_equals(
                  target_layer_constraint,
                  LastSeparate,
                ) {
                all_ports_reversed = false
                break
              }
            }
            if !all_ports_reversed {
              break
            }

            for edge in port.get_incoming_edges() {
              let source_layer_constraint = edge_and_layer_constraint_edge_reverser_layer_constraint(
                edge_and_layer_constraint_edge_reverser_port_node(
                  edge_and_layer_constraint_edge_reverser_edge_source(edge),
                ),
              )
              if edge_and_layer_constraint_edge_reverser_layer_constraint_equals(
                  source_layer_constraint,
                  First,
                ) ||
                edge_and_layer_constraint_edge_reverser_layer_constraint_equals(
                  source_layer_constraint,
                  FirstSeparate,
                ) {
                all_ports_reversed = false
                break
              }
            }
            if !all_ports_reversed {
              break
            }
          }

          if all_ports_reversed {
            edge_and_layer_constraint_edge_reverser_reverse_edges(
              layered_graph,
              node,
              layer_constraint,
              Undefined,
            )
          }
        }
      }
    }
  }
}

///|
fn edge_and_layer_constraint_edge_reverser_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Edge and layer constraint edge reversal", 1.0))

  try {
    let remaining_nodes = edge_and_layer_constraint_edge_reverser_handle_outer_nodes(
      layered_graph,
    )
    edge_and_layer_constraint_edge_reverser_handle_inner_nodes(
      layered_graph, remaining_nodes,
    )
  } catch {
    UnsupportedGraphException(message) => {
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
pub fn new_edge_and_layer_constraint_edge_reverser_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(edge_and_layer_constraint_edge_reverser_process)
}
