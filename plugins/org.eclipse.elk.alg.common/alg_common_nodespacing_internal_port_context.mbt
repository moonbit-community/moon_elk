///|
fn port_context_has_compound_connections(port : LPort) -> Bool {
  port.get_property_bool(internal_properties_inside_connections)
}

///|
pub struct PortContext {
  parent_node_context : NodeContext
  port : LPort
  port_position : KVector
  labels_next_to_port : Bool
  volatile_id : Int
  port_margin : ElkMargin
  mut port_label_cell : LabelCell?
}

///|
pub fn new_port_context(
  parent_node_context : NodeContext,
  port : LPort,
  volatile_id : Int,
) -> PortContext {
  let port_labels_next_to_port = parent_node_context.has_port_label_placement(
    NextToPortIfPossible,
  )

  let labels_next_to_port = if parent_node_context.has_port_label_placement(
      Inside,
    ) {
    if parent_node_context.treat_as_compound_node {
      port_labels_next_to_port && !port_context_has_compound_connections(port)
    } else {
      true
    }
  } else if parent_node_context.has_port_label_placement(Outside) {
    if port_labels_next_to_port {
      port.get_incoming_edges().is_empty() &&
      port.get_outgoing_edges().is_empty()
    } else {
      false
    }
  } else {
    false
  }

  {
    parent_node_context,
    port,
    port_position: port.get_position().clone(),
    labels_next_to_port,
    volatile_id,
    port_margin: new_elk_margin(),
    port_label_cell: None,
  }
}

///|
pub fn PortContext::apply_port_position(self : PortContext) -> Unit {
  ignore(self.port.get_position().set(self.port_position))
}
