///|
let interactive_external_port_positioner_arbitrary_spacing = 10.0

///|
priv suberror InteractiveExternalPortPositionerException {
  InteractiveExternalPortPositionerException(String)
} derive(Show, ToJson)

///|
fn[T] interactive_external_port_positioner_raise(
  message : String,
) -> T raise InteractiveExternalPortPositionerException {
  raise InteractiveExternalPortPositionerException(message)
}

///|
fn interactive_external_port_positioner_exception_message(
  err : InteractiveExternalPortPositionerException,
) -> String {
  match err {
    InteractiveExternalPortPositionerException(message) => message
  }
}

///|
fn interactive_external_port_positioner_min(
  left : Double,
  right : Double,
) -> Double {
  if left < right {
    left
  } else {
    right
  }
}

///|
fn interactive_external_port_positioner_max(
  left : Double,
  right : Double,
) -> Double {
  if left > right {
    left
  } else {
    right
  }
}

///|
fn interactive_external_port_positioner_node_type_equals(
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
fn interactive_external_port_positioner_layer_constraint_is_first_separate(
  constraint : LayerConstraint,
) -> Bool {
  match constraint {
    LayerConstraint::FirstSeparate => true
    _ => false
  }
}

///|
fn interactive_external_port_positioner_layer_constraint_is_last_separate(
  constraint : LayerConstraint,
) -> Bool {
  match constraint {
    LayerConstraint::LastSeparate => true
    _ => false
  }
}

///|
fn interactive_external_port_positioner_in_layer_constraint_is_top(
  constraint : InLayerConstraint,
) -> Bool {
  match constraint {
    InLayerConstraint::Top => true
    _ => false
  }
}

///|
fn interactive_external_port_positioner_in_layer_constraint_is_bottom(
  constraint : InLayerConstraint,
) -> Bool {
  match constraint {
    InLayerConstraint::Bottom => true
    _ => false
  }
}

///|
fn interactive_external_port_positioner_graph_property_equals(
  left : GraphProperties,
  right : GraphProperties,
) -> Bool {
  match (left, right) {
    (Comments, Comments) => true
    (ExternalPorts, ExternalPorts) => true
    (Hyperedges, Hyperedges) => true
    (Hypernodes, Hypernodes) => true
    (NonFreePorts, NonFreePorts) => true
    (NorthSouthPorts, NorthSouthPorts) => true
    (SelfLoops, SelfLoops) => true
    (CenterLabels, CenterLabels) => true
    (EndLabels, EndLabels) => true
    (Partitions, Partitions) => true
    _ => false
  }
}

///|
fn interactive_external_port_positioner_graph_properties_contain(
  properties : Array[GraphProperties],
  property : GraphProperties,
) -> Bool {
  for candidate in properties {
    if interactive_external_port_positioner_graph_property_equals(
        candidate, property,
      ) {
      return true
    }
  }
  false
}

///|
fn interactive_external_port_positioner_parse_in_layer_constraint(
  value : String,
) -> InLayerConstraint {
  if value == "TOP" {
    return InLayerConstraint::Top
  }
  if value == "BOTTOM" {
    return InLayerConstraint::Bottom
  }
  InLayerConstraint::NoneType
}

///|
fn interactive_external_port_positioner_find_y_by_target(
  dummy : LNode,
) -> Double? {
  for edge in dummy.get_connected_edges() {
    match edge.get_target() {
      Some(target_port) =>
        match target_port.get_node() {
          Some(other) =>
            return Some(other.get_position().y + other.get_size().y / 2.0)
          None => ()
        }
      None => ()
    }
  }
  None
}

///|
fn interactive_external_port_positioner_find_y_by_source(
  dummy : LNode,
) -> Double? {
  for edge in dummy.get_connected_edges() {
    match edge.get_source() {
      Some(source_port) =>
        match source_port.get_node() {
          Some(other) =>
            return Some(other.get_position().y + other.get_size().y / 2.0)
          None => ()
        }
      None => ()
    }
  }
  None
}

///|
fn interactive_external_port_positioner_find_north_south_port_x_coordinate(
  dummy : LNode,
) -> Double? raise InteractiveExternalPortPositionerException {
  let ports = dummy.get_ports()
  if ports.length() != 1 {
    interactive_external_port_positioner_raise(
      "external port dummies must have exactly one port",
    )
  }

  let port = ports[0]
  let outgoing_edges = port.get_outgoing_edges()
  let incoming_edges = port.get_incoming_edges()

  if !outgoing_edges.is_empty() && !incoming_edges.is_empty() {
    interactive_external_port_positioner_raise(
      "Interactive layout does not support NORTH/SOUTH ports with incoming _and_ outgoing edges.",
    )
  }

  if !outgoing_edges.is_empty() {
    let mut min = @double.infinity
    for edge in outgoing_edges {
      match edge.get_target() {
        Some(target_port) =>
          match target_port.get_node() {
            Some(node) => {
              let margin = node.get_margin()
              min = interactive_external_port_positioner_min(
                min,
                node.get_position().x - margin.left,
              )
            }
            None => ()
          }
        None => ()
      }
    }
    if min == @double.infinity {
      return None
    }
    return Some(min)
  }

  if !incoming_edges.is_empty() {
    let mut max = -@double.infinity
    for edge in incoming_edges {
      match edge.get_source() {
        Some(source_port) =>
          match source_port.get_node() {
            Some(node) => {
              let margin = node.get_margin()
              max = interactive_external_port_positioner_max(
                max,
                node.get_position().x + node.get_size().x + margin.right,
              )
            }
            None => ()
          }
        None => ()
      }
    }
    if max == -@double.infinity {
      return None
    }
    return Some(max)
  }

  None
}

///|
fn interactive_external_port_positioner_process_impl(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit raise InteractiveExternalPortPositionerException {
  ignore(progress_monitor)

  let graph_properties = layered_graph.get_property_graph_properties_array(
    internal_properties_graph_properties,
  )
  if !interactive_external_port_positioner_graph_properties_contain(
      graph_properties,
      GraphProperties::ExternalPorts,
    ) {
    return
  }

  let mut min_x = @double.infinity
  let mut max_x = -@double.infinity
  let mut min_y = @double.infinity
  let mut max_y = -@double.infinity

  for node in layered_graph.get_layerless_nodes() {
    if interactive_external_port_positioner_node_type_equals(
        node.get_type(),
        NodeType::Normal,
      ) {
      let margin = node.get_margin()
      min_x = interactive_external_port_positioner_min(
        min_x,
        node.get_position().x - margin.left,
      )
      max_x = interactive_external_port_positioner_max(
        max_x,
        node.get_position().x + node.get_size().x + margin.right,
      )
      min_y = interactive_external_port_positioner_min(
        min_y,
        node.get_position().y - margin.top,
      )
      max_y = interactive_external_port_positioner_max(
        max_y,
        node.get_position().y + node.get_size().y + margin.bottom,
      )
    }
  }

  for node in layered_graph.get_layerless_nodes() {
    if interactive_external_port_positioner_node_type_equals(
        node.get_type(),
        NodeType::Normal,
      ) {
      continue
    }

    match node.get_type() {
      NodeType::ExternalPort => {
        let layer_constraint = layer_constraint_from_string(
          node.get_property_string(layered_options_layering_layer_constraint),
        )

        if interactive_external_port_positioner_layer_constraint_is_first_separate(
            layer_constraint,
          ) {
          node.get_position().x = min_x -
            interactive_external_port_positioner_arbitrary_spacing

          match interactive_external_port_positioner_find_y_by_target(node) {
            Some(y) => node.get_position().y = y
            None => ()
          }
          continue
        }

        if interactive_external_port_positioner_layer_constraint_is_last_separate(
            layer_constraint,
          ) {
          node.get_position().x = max_x +
            interactive_external_port_positioner_arbitrary_spacing

          match interactive_external_port_positioner_find_y_by_source(node) {
            Some(y) => node.get_position().y = y
            None => ()
          }
          continue
        }

        let in_layer_constraint = interactive_external_port_positioner_parse_in_layer_constraint(
          node.get_property_string(internal_properties_in_layer_constraint),
        )

        if interactive_external_port_positioner_in_layer_constraint_is_top(
            in_layer_constraint,
          ) {
          match
            interactive_external_port_positioner_find_north_south_port_x_coordinate(
              node,
            ) {
            Some(x) =>
              node.get_position().x = x +
                interactive_external_port_positioner_arbitrary_spacing
            None => ()
          }
          node.get_position().y = min_y -
            interactive_external_port_positioner_arbitrary_spacing
          continue
        }

        if interactive_external_port_positioner_in_layer_constraint_is_bottom(
            in_layer_constraint,
          ) {
          match
            interactive_external_port_positioner_find_north_south_port_x_coordinate(
              node,
            ) {
            Some(x) =>
              node.get_position().x = x +
                interactive_external_port_positioner_arbitrary_spacing
            None => ()
          }
          node.get_position().y = max_y +
            interactive_external_port_positioner_arbitrary_spacing
          continue
        }
      }
      _ =>
        interactive_external_port_positioner_raise(
          "The node type is not supported by the InteractiveExternalPortPositioner",
        )
    }
  }
}

///|
fn interactive_external_port_positioner_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  try
    interactive_external_port_positioner_process_impl(
      layered_graph, progress_monitor,
    )
  catch {
    err =>
      @core.layout_runtime_report_unsupported_configuration(
        interactive_external_port_positioner_exception_message(err),
      )
  } noraise {
    _ => ()
  }
}

///|
pub fn new_interactive_external_port_positioner_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(interactive_external_port_positioner_process)
}
