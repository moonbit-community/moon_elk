///|
fn edge_and_layer_constraint_edge_reverser_layer_constraint_equals(
  left : LayerConstraint,
  right : LayerConstraint,
) -> Bool {
  match (left, right) {
    (LayerConstraint::NoneType, LayerConstraint::NoneType) => true
    (LayerConstraint::First, LayerConstraint::First) => true
    (LayerConstraint::FirstSeparate, LayerConstraint::FirstSeparate) => true
    (LayerConstraint::Last, LayerConstraint::Last) => true
    (LayerConstraint::LastSeparate, LayerConstraint::LastSeparate) => true
    _ => false
  }
}

///|
fn edge_and_layer_constraint_edge_reverser_port_side_equals(
  left : @core.PortSide,
  right : @core.PortSide,
) -> Bool {
  match (left, right) {
    (@core.PortSide::North, @core.PortSide::North) => true
    (@core.PortSide::East, @core.PortSide::East) => true
    (@core.PortSide::South, @core.PortSide::South) => true
    (@core.PortSide::West, @core.PortSide::West) => true
    (@core.PortSide::SideUndefined, @core.PortSide::SideUndefined) => true
    _ => false
  }
}

///|
fn edge_and_layer_constraint_edge_reverser_port_type_equals(
  left : PortType,
  right : PortType,
) -> Bool {
  match (left, right) {
    (PortType::Undefined, PortType::Undefined) => true
    (PortType::Input, PortType::Input) => true
    (PortType::Output, PortType::Output) => true
    _ => false
  }
}

///|
fn edge_and_layer_constraint_edge_reverser_node_type_equals(
  left : NodeType,
  right : NodeType,
) -> Bool {
  match (left, right) {
    (NodeType::Normal, NodeType::Normal) => true
    (NodeType::LongEdge, NodeType::LongEdge) => true
    (NodeType::ExternalPort, NodeType::ExternalPort) => true
    (NodeType::NorthSouthPort, NodeType::NorthSouthPort) => true
    (NodeType::LabelNode, NodeType::LabelNode) => true
    (NodeType::BreakingPoint, NodeType::BreakingPoint) => true
    (NodeType::Placeholder, NodeType::Placeholder) => true
    (NodeType::NonshiftingPlaceholder, NodeType::NonshiftingPlaceholder) => true
    _ => false
  }
}

///|
fn edge_and_layer_constraint_edge_reverser_port_constraints_from_string(
  value : String,
) -> @core.PortConstraints {
  match value {
    "UNDEFINED" => @core.PortConstraints::Undefined
    "FREE" => @core.PortConstraints::Free
    "FIXED_SIDE" => @core.PortConstraints::FixedSide
    "FIXED_ORDER" => @core.PortConstraints::FixedOrder
    "FIXED_RATIO" => @core.PortConstraints::FixedRatio
    "FIXED_POS" => @core.PortConstraints::FixedPos
    _ => @core.PortConstraints::Undefined
  }
}

///|
fn edge_and_layer_constraint_edge_reverser_edge_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source")
  }
}

///|
fn edge_and_layer_constraint_edge_reverser_edge_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target")
  }
}

///|
fn edge_and_layer_constraint_edge_reverser_port_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(value) => value
    None => abort("port has no owner node")
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
fn edge_and_layer_constraint_edge_reverser_reverse_edge(edge : LEdge) -> Unit {
  let old_source = edge.get_source()
  let old_target = edge.get_target()
  edge.set_source(None)
  edge.set_target(None)
  edge.set_source(old_target)
  edge.set_target(old_source)
  edge.set_property_bool(
    internal_properties_reversed,
    !edge.get_property_bool(internal_properties_reversed),
  )
}

///|
fn edge_and_layer_constraint_edge_reverser_can_reverse_outgoing_edge(
  source_node_layer_constraint : LayerConstraint,
  edge : LEdge,
) -> Bool {
  if edge.get_property_bool(internal_properties_reversed) {
    return false
  }

  let target_node = edge_and_layer_constraint_edge_reverser_port_node(
    edge_and_layer_constraint_edge_reverser_edge_target(edge),
  )

  if edge_and_layer_constraint_edge_reverser_layer_constraint_equals(
      source_node_layer_constraint,
      LayerConstraint::Last,
    ) &&
    edge_and_layer_constraint_edge_reverser_node_type_equals(
      target_node.get_type(),
      NodeType::LabelNode,
    ) {
    return false
  }

  let target_layer_constraint = edge_and_layer_constraint_edge_reverser_layer_constraint(
    target_node,
  )
  if edge_and_layer_constraint_edge_reverser_layer_constraint_equals(
      target_layer_constraint,
      LayerConstraint::LastSeparate,
    ) {
    return false
  }

  true
}

///|
fn edge_and_layer_constraint_edge_reverser_can_reverse_incoming_edge(
  target_node_layer_constraint : LayerConstraint,
  edge : LEdge,
) -> Bool {
  if edge.get_property_bool(internal_properties_reversed) {
    return false
  }

  let source_node = edge_and_layer_constraint_edge_reverser_port_node(
    edge_and_layer_constraint_edge_reverser_edge_source(edge),
  )

  if edge_and_layer_constraint_edge_reverser_layer_constraint_equals(
      target_node_layer_constraint,
      LayerConstraint::First,
    ) &&
    edge_and_layer_constraint_edge_reverser_node_type_equals(
      source_node.get_type(),
      NodeType::LabelNode,
    ) {
    return false
  }

  let source_layer_constraint = edge_and_layer_constraint_edge_reverser_layer_constraint(
    source_node,
  )
  if edge_and_layer_constraint_edge_reverser_layer_constraint_equals(
      source_layer_constraint,
      LayerConstraint::FirstSeparate,
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
) -> Unit {
  ignore(layered_graph)
  for port in node.get_ports().copy() {
    if edge_and_layer_constraint_edge_reverser_port_type_equals(
        target_port_type,
        PortType::Input,
      ) ||
      edge_and_layer_constraint_edge_reverser_port_type_equals(
        target_port_type,
        PortType::Undefined,
      ) {
      for edge in port.get_outgoing_edges().copy() {
        if edge_and_layer_constraint_edge_reverser_can_reverse_outgoing_edge(
            node_layer_constraint, edge,
          ) {
          edge_and_layer_constraint_edge_reverser_reverse_edge(edge)
        }
      }
    }

    if edge_and_layer_constraint_edge_reverser_port_type_equals(
        target_port_type,
        PortType::Output,
      ) ||
      edge_and_layer_constraint_edge_reverser_port_type_equals(
        target_port_type,
        PortType::Undefined,
      ) {
      for edge in port.get_incoming_edges().copy() {
        if edge_and_layer_constraint_edge_reverser_can_reverse_incoming_edge(
            node_layer_constraint, edge,
          ) {
          edge_and_layer_constraint_edge_reverser_reverse_edge(edge)
        }
      }
    }
  }
}

///|
fn edge_and_layer_constraint_edge_reverser_handle_outer_nodes(
  layered_graph : LGraph,
) -> Array[LNode] {
  let remaining_nodes = []
  for node in layered_graph.get_layerless_nodes() {
    let layer_constraint = edge_and_layer_constraint_edge_reverser_layer_constraint(
      node,
    )
    let edge_constraint = match layer_constraint {
      LayerConstraint::First => Some(EdgeConstraint::OutgoingOnly)
      LayerConstraint::FirstSeparate => Some(EdgeConstraint::OutgoingOnly)
      LayerConstraint::Last => Some(EdgeConstraint::IncomingOnly)
      LayerConstraint::LastSeparate => Some(EdgeConstraint::IncomingOnly)
      _ => None
    }

    match edge_constraint {
      Some(constraint) =>
        if constraint is IncomingOnly {
          edge_and_layer_constraint_edge_reverser_reverse_edges(
            layered_graph,
            node,
            layer_constraint,
            PortType::Input,
          )
        } else {
          edge_and_layer_constraint_edge_reverser_reverse_edges(
            layered_graph,
            node,
            layer_constraint,
            PortType::Output,
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
) -> Unit {
  for node in remaining_nodes {
    let layer_constraint = edge_and_layer_constraint_edge_reverser_layer_constraint(
      node,
    )
    let edge_constraint = match layer_constraint {
      LayerConstraint::First => Some(EdgeConstraint::OutgoingOnly)
      LayerConstraint::FirstSeparate => Some(EdgeConstraint::OutgoingOnly)
      LayerConstraint::Last => Some(EdgeConstraint::IncomingOnly)
      LayerConstraint::LastSeparate => Some(EdgeConstraint::IncomingOnly)
      _ => None
    }

    match edge_constraint {
      Some(constraint) =>
        if constraint is IncomingOnly {
          edge_and_layer_constraint_edge_reverser_reverse_edges(
            layered_graph,
            node,
            layer_constraint,
            PortType::Input,
          )
        } else {
          edge_and_layer_constraint_edge_reverser_reverse_edges(
            layered_graph,
            node,
            layer_constraint,
            PortType::Output,
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
                @core.PortSide::East,
              ) &&
              port.get_net_flow() > 0
            let west_reversed = edge_and_layer_constraint_edge_reverser_port_side_equals(
                port.get_side(),
                @core.PortSide::West,
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
                  LayerConstraint::Last,
                ) ||
                edge_and_layer_constraint_edge_reverser_layer_constraint_equals(
                  target_layer_constraint,
                  LayerConstraint::LastSeparate,
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
                  LayerConstraint::First,
                ) ||
                edge_and_layer_constraint_edge_reverser_layer_constraint_equals(
                  source_layer_constraint,
                  LayerConstraint::FirstSeparate,
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
              PortType::Undefined,
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

  let remaining_nodes = edge_and_layer_constraint_edge_reverser_handle_outer_nodes(
    layered_graph,
  )
  edge_and_layer_constraint_edge_reverser_handle_inner_nodes(
    layered_graph, remaining_nodes,
  )

  monitor.done()
}

///|
pub fn new_edge_and_layer_constraint_edge_reverser_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(edge_and_layer_constraint_edge_reverser_process)
}
