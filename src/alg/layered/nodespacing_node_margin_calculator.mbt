///|
fn node_margin_calculator_max(a : Double, b : Double) -> Double {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn node_margin_calculator_process_edge_head_tail_labels(
  bounding_box : @core.ElkRectangle,
  outgoing_edges : Array[LEdgeAdapter],
  incoming_edges : Array[LEdgeAdapter],
  node : LNodeAdapter,
  port : LPortAdapter?,
  port_label_space : @core.KVector?,
  label_spacing : Double,
) -> Unit {
  let label_box = @core.new_elk_rectangle()

  for edge in outgoing_edges {
    for label in edge.get_labels() {
      if label.get_property_string(@core.edge_labels_placement) ==
        @core.edge_label_placement_to_string(@core.EdgeLabelPlacement::Tail) {
        node_margin_calculator_compute_label_box(
          label_box, label, false, node, port, port_label_space, label_spacing,
        )
        bounding_box.union(label_box)
      }
    }
  }

  for edge in incoming_edges {
    for label in edge.get_labels() {
      if label.get_property_string(@core.edge_labels_placement) ==
        @core.edge_label_placement_to_string(@core.EdgeLabelPlacement::Head) {
        node_margin_calculator_compute_label_box(
          label_box, label, true, node, port, port_label_space, label_spacing,
        )
        bounding_box.union(label_box)
      }
    }
  }
}

///|
fn node_margin_calculator_compute_label_box(
  label_box : @core.ElkRectangle,
  label : LLabelAdapter,
  incoming_edge : Bool,
  node : LNodeAdapter,
  port : LPortAdapter?,
  port_label_space : @core.KVector?,
  label_spacing : Double,
) -> Unit {
  let node_position = node.get_position()
  label_box.x = node_position.x
  label_box.y = node_position.y

  if port is Some(port_value) {
    let port_position = port_value.get_position()
    label_box.x += port_position.x
    label_box.y += port_position.y
  }

  let label_size = label.get_size()
  label_box.width = label_size.x
  label_box.height = label_size.y

  if port is Some(port_value) {
    let required_port_label_space = match port_label_space {
      Some(value) => value
      None => @core.new_kvector()
    }
    let port_size = port_value.get_size()
    match port_value.get_side() {
      @core.PortSide::SideUndefined =>
        label_box.x += port_size.x +
          label_spacing +
          required_port_label_space.x +
          label_spacing
      @core.PortSide::East =>
        label_box.x += port_size.x +
          label_spacing +
          required_port_label_space.x +
          label_spacing
      @core.PortSide::West =>
        label_box.x -= label_spacing +
          required_port_label_space.x +
          label_spacing +
          label_size.x
      @core.PortSide::North => {
        label_box.x += port_size.x + label_spacing
        label_box.y -= label_spacing +
          required_port_label_space.y +
          label_spacing +
          label_size.y
      }
      @core.PortSide::South => {
        label_box.x += port_size.x + label_spacing
        label_box.y += port_size.y +
          label_spacing +
          required_port_label_space.y +
          label_spacing
      }
    }
  } else if incoming_edge {
    label_box.x -= label_spacing + label_size.x
  } else {
    label_box.x += node.get_size().x + label_spacing
  }
}

///|
fn node_margin_calculator_process_node(
  calculator : NodeMarginCalculator,
  node : LNodeAdapter,
  label_spacing : Double,
) -> Unit {
  let node_position = node.get_position()
  let node_size = node.get_size()

  let bounding_box = @core.new_elk_rectangle_xywh(
    node_position.x,
    node_position.y,
    node_size.x,
    node_size.y,
  )

  let element_box = @core.new_elk_rectangle()

  if calculator.include_labels {
    for label in node.get_labels() {
      let label_position = label.get_position()
      let label_size = label.get_size()
      element_box.x = label_position.x + node_position.x
      element_box.y = label_position.y + node_position.y
      element_box.width = label_size.x
      element_box.height = label_size.y

      bounding_box.union(element_box)
    }
  }

  for port in node.get_ports() {
    let port_position = port.get_position()
    let port_size = port.get_size()
    let port_x = port_position.x + node_position.x
    let port_y = port_position.y + node_position.y

    if calculator.include_ports {
      element_box.x = port_x
      element_box.y = port_y
      element_box.width = port_size.x
      element_box.height = port_size.y

      bounding_box.union(element_box)
    }

    if calculator.include_port_labels {
      for label in port.get_labels() {
        let label_position = label.get_position()
        let label_size = label.get_size()
        element_box.x = label_position.x + port_x
        element_box.y = label_position.y + port_y
        element_box.width = label_size.x
        element_box.height = label_size.y

        bounding_box.union(element_box)
      }
    }

    if calculator.include_edge_head_tail_labels {
      let required_port_label_space = @core.new_kvector_xy(
        -label_spacing,
        -label_spacing,
      )

      if node
        .get_property_string_array(@core.port_labels_placement)
        .contains(@core.port_label_placement_to_string(@core.PortLabelPlacement::Outside)) {
        for label in port.get_labels() {
          let label_size = label.get_size()
          required_port_label_space.x += label_size.x + label_spacing
          required_port_label_space.y += label_size.y + label_spacing
        }
      }

      required_port_label_space.x = node_margin_calculator_max(
        required_port_label_space.x,
        0.0,
      )
      required_port_label_space.y = node_margin_calculator_max(
        required_port_label_space.y,
        0.0,
      )

      node_margin_calculator_process_edge_head_tail_labels(
        bounding_box,
        port.get_outgoing_edges(),
        port.get_incoming_edges(),
        node,
        Some(port),
        Some(required_port_label_space),
        label_spacing,
      )
    }
  }

  if calculator.include_edge_head_tail_labels {
    node_margin_calculator_process_edge_head_tail_labels(
      bounding_box,
      node.get_outgoing_edges(),
      node.get_incoming_edges(),
      node,
      None,
      None,
      label_spacing,
    )
  }

  let margin = @core.new_elk_margin_copy(node.get_margin())
  margin.top = node_margin_calculator_max(0.0, node_position.y - bounding_box.y)
  margin.bottom = node_margin_calculator_max(
    0.0,
    bounding_box.y + bounding_box.height - (node_position.y + node_size.y),
  )
  margin.left = node_margin_calculator_max(
    0.0,
    node_position.x - bounding_box.x,
  )
  margin.right = node_margin_calculator_max(
    0.0,
    bounding_box.x + bounding_box.width - (node_position.x + node_size.x),
  )
  node.set_margin(margin)
}

///|
pub struct NodeMarginCalculator {
  mut include_labels : Bool
  mut include_ports : Bool
  mut include_port_labels : Bool
  mut include_edge_head_tail_labels : Bool
  adapter : LGraphAdapter
}

///|
pub fn new_node_margin_calculator(
  adapter : LGraphAdapter,
) -> NodeMarginCalculator {
  {
    include_labels: true,
    include_ports: true,
    include_port_labels: true,
    include_edge_head_tail_labels: true,
    adapter,
  }
}

///|
pub fn NodeMarginCalculator::exclude_labels(
  self : NodeMarginCalculator,
) -> NodeMarginCalculator {
  self.include_labels = false
  self
}

///|
pub fn NodeMarginCalculator::exclude_ports(
  self : NodeMarginCalculator,
) -> NodeMarginCalculator {
  self.include_ports = false
  self
}

///|
pub fn NodeMarginCalculator::exclude_port_labels(
  self : NodeMarginCalculator,
) -> NodeMarginCalculator {
  self.include_port_labels = false
  self
}

///|
pub fn NodeMarginCalculator::exclude_edge_head_tail_labels(
  self : NodeMarginCalculator,
) -> NodeMarginCalculator {
  self.include_edge_head_tail_labels = false
  self
}

///|
pub fn NodeMarginCalculator::process(self : NodeMarginCalculator) -> Unit {
  let label_spacing = self.adapter.get_property_double(@core.spacing_label_node)

  for node in self.adapter.get_nodes() {
    node_margin_calculator_process_node(self, node, label_spacing)
  }
}

///|
pub fn NodeMarginCalculator::process_node(
  self : NodeMarginCalculator,
  node : LNodeAdapter,
) -> Unit {
  let label_spacing = self.adapter.get_property_double(@core.spacing_label_node)
  node_margin_calculator_process_node(self, node, label_spacing)
}
