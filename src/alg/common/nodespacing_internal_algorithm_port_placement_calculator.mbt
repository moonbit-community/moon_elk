///|
pub let port_placement_calculator_port_ratio_or_position : @graph.IProperty[
  Double,
] = @graph.new_property("portRatioOrPosition", 0.0)

///|
fn port_placement_calculator_side_equals(
  left : @core.PortSide,
  right : @core.PortSide,
) -> Bool {
  @core.port_side_to_string(left) == @core.port_side_to_string(right)
}

///|
fn port_placement_calculator_modified_port_placement_size(
  node_context : NodeContext,
  old_port_alignment : @core.PortAlignment,
  current_port_placement_size : Double,
) -> Double {
  if node_context_port_alignment_equals(old_port_alignment, @core.Distributed) {
    current_port_placement_size - 2.0 * node_context.port_port_spacing
  } else {
    current_port_placement_size
  }
}

///|
fn port_placement_calculator_horizontal_port_y_coordinate(
  port_context : PortContext,
) -> Double {
  let port = port_context.port
  let port_border_offset = nodespacing_port_border_offset_value(port)
  if port.has_property_double(nodespacing_port_border_offset_property) {
    if port_placement_calculator_side_equals(port.get_side(), North) {
      -port.get_size().y - port_border_offset
    } else {
      port_border_offset
    }
  } else if port_placement_calculator_side_equals(port.get_side(), North) {
    -port.get_size().y
  } else {
    0.0
  }
}

///|
fn port_placement_calculator_vertical_port_x_coordinate(
  port_context : PortContext,
  node_width : Double,
) -> Double {
  let port = port_context.port
  let port_border_offset = nodespacing_port_border_offset_value(port)
  if port.has_property_double(nodespacing_port_border_offset_property) {
    if port_placement_calculator_side_equals(port.get_side(), West) {
      -port.get_size().x - port_border_offset
    } else {
      node_width + port_border_offset
    }
  } else if port_placement_calculator_side_equals(port.get_side(), West) {
    -port.get_size().x
  } else {
    node_width
  }
}

///|
fn port_placement_calculator_horizontal_fixed_pos_ports(
  node_context : NodeContext,
  port_side : @core.PortSide,
) -> Unit {
  for port_context in node_context_get_port_contexts(node_context, port_side) {
    port_context.port_position.y = port_placement_calculator_horizontal_port_y_coordinate(
      port_context,
    )
  }
}

///|
fn port_placement_calculator_horizontal_fixed_ratio_ports(
  node_context : NodeContext,
  port_side : @core.PortSide,
) -> Unit {
  let node_width = node_context.node_size.x
  for port_context in node_context_get_port_contexts(node_context, port_side) {
    let ratio = if port_context.port.has_property_double(
        port_placement_calculator_port_ratio_or_position,
      ) {
      port_context.port.get_property_double(
        port_placement_calculator_port_ratio_or_position,
      )
    } else {
      0.0
    }
    port_context.port_position.x = node_width * ratio
    port_context.port_position.y = port_placement_calculator_horizontal_port_y_coordinate(
      port_context,
    )
  }
}

///|
fn port_placement_calculator_horizontal_free_ports(
  node_context : NodeContext,
  port_side : @core.PortSide,
) -> Unit {
  let port_contexts = node_context_get_port_contexts(node_context, port_side)
  if port_contexts.is_empty() {
    return
  }

  let inside_port_label_cell = match
    node_context.inside_port_label_cells.get(
      node_context_port_side_key(port_side),
    ) {
    Some(value) => value
    None => return
  }
  let inside_port_label_cell_rectangle = inside_port_label_cell.get_cell_rectangle()
  let inside_port_label_cell_padding = inside_port_label_cell.get_padding()

  let mut port_alignment = node_context.get_port_alignment(port_side)
  let available_space = inside_port_label_cell_rectangle.width -
    inside_port_label_cell_padding.left -
    inside_port_label_cell_padding.right
  let mut calculated_port_placement_width = inside_port_label_cell.get_minimum_content_area_size().x
  let mut current_x_pos = inside_port_label_cell_rectangle.x +
    inside_port_label_cell_padding.left
  let mut space_between_ports = node_context.port_port_spacing

  if (
      node_context_port_alignment_equals(port_alignment, @core.Distributed) ||
      node_context_port_alignment_equals(port_alignment, @core.Justified)
    ) &&
    port_contexts.length() == 1 {
    calculated_port_placement_width = port_placement_calculator_modified_port_placement_size(
      node_context, port_alignment, calculated_port_placement_width,
    )
    port_alignment = Center
  }

  if available_space < calculated_port_placement_width &&
    !node_context.has_size_option(PortsOverhang) {
    if node_context_port_alignment_equals(port_alignment, @core.Distributed) {
      space_between_ports += (available_space - calculated_port_placement_width) /
        (port_contexts.length() + 1).to_double()
      current_x_pos += space_between_ports
    } else {
      space_between_ports += (available_space - calculated_port_placement_width) /
        (port_contexts.length() - 1).to_double()
    }
  } else {
    if available_space < calculated_port_placement_width {
      calculated_port_placement_width = port_placement_calculator_modified_port_placement_size(
        node_context, port_alignment, calculated_port_placement_width,
      )
      port_alignment = Center
    }

    match port_alignment {
      Begin => ()
      Center =>
        current_x_pos += (available_space - calculated_port_placement_width) /
          2.0
      End => current_x_pos += available_space - calculated_port_placement_width
      @core.Distributed => {
        let additional_space_between_ports = (
            available_space - calculated_port_placement_width
          ) /
          (port_contexts.length() + 1).to_double()
        space_between_ports += @cmp.maximum(0.0, additional_space_between_ports)
        current_x_pos += space_between_ports
      }
      @core.Justified => {
        let additional_space_between_ports = (
            available_space - calculated_port_placement_width
          ) /
          (port_contexts.length() - 1).to_double()
        space_between_ports += @cmp.maximum(0.0, additional_space_between_ports)
      }
    }
  }

  for port_context in port_contexts {
    port_context.port_position.x = current_x_pos + port_context.port_margin.left
    port_context.port_position.y = port_placement_calculator_horizontal_port_y_coordinate(
      port_context,
    )
    current_x_pos += port_context.port_margin.left +
      port_context.port.get_size().x +
      port_context.port_margin.right +
      space_between_ports
  }
}

///|
pub fn port_placement_calculator_place_horizontal_ports(
  node_context : NodeContext,
) -> Unit {
  match node_context.port_constraints {
    FixedPos => {
      port_placement_calculator_horizontal_fixed_pos_ports(node_context, North)
      port_placement_calculator_horizontal_fixed_pos_ports(node_context, South)
    }
    FixedRatio => {
      port_placement_calculator_horizontal_fixed_ratio_ports(
        node_context,
        North,
      )
      port_placement_calculator_horizontal_fixed_ratio_ports(
        node_context,
        South,
      )
    }
    _ => {
      port_placement_calculator_horizontal_free_ports(node_context, North)
      port_placement_calculator_horizontal_free_ports(node_context, South)
    }
  }
}

///|
fn port_placement_calculator_vertical_fixed_pos_ports(
  node_context : NodeContext,
  port_side : @core.PortSide,
) -> Unit {
  let node_width = node_context.node_size.x
  for port_context in node_context_get_port_contexts(node_context, port_side) {
    port_context.port_position.x = port_placement_calculator_vertical_port_x_coordinate(
      port_context, node_width,
    )
  }
}

///|
fn port_placement_calculator_vertical_fixed_ratio_ports(
  node_context : NodeContext,
  port_side : @core.PortSide,
) -> Unit {
  let node_width = node_context.node_size.x
  let node_height = node_context.node_size.y

  for port_context in node_context_get_port_contexts(node_context, port_side) {
    let ratio = if port_context.port.has_property_double(
        port_placement_calculator_port_ratio_or_position,
      ) {
      port_context.port.get_property_double(
        port_placement_calculator_port_ratio_or_position,
      )
    } else {
      0.0
    }
    port_context.port_position.x = port_placement_calculator_vertical_port_x_coordinate(
      port_context, node_width,
    )
    port_context.port_position.y = node_height * ratio
  }
}

///|
fn port_placement_calculator_vertical_free_ports(
  node_context : NodeContext,
  port_side : @core.PortSide,
) -> Unit {
  let port_contexts = node_context_get_port_contexts(node_context, port_side)
  if port_contexts.is_empty() {
    return
  }

  let inside_port_label_cell = match
    node_context.inside_port_label_cells.get(
      node_context_port_side_key(port_side),
    ) {
    Some(value) => value
    None => return
  }
  let inside_port_label_cell_rectangle = inside_port_label_cell.get_cell_rectangle()
  let inside_port_label_cell_padding = inside_port_label_cell.get_padding()

  let mut port_alignment = node_context.get_port_alignment(port_side)
  let available_space = inside_port_label_cell_rectangle.height -
    inside_port_label_cell_padding.top -
    inside_port_label_cell_padding.bottom
  let mut calculated_port_placement_height = inside_port_label_cell.get_minimum_content_area_size().y
  let mut current_y_pos = inside_port_label_cell_rectangle.y +
    inside_port_label_cell_padding.top
  let mut space_between_ports = node_context.port_port_spacing
  let node_width = node_context.node_size.x

  if (
      node_context_port_alignment_equals(port_alignment, @core.Distributed) ||
      node_context_port_alignment_equals(port_alignment, @core.Justified)
    ) &&
    port_contexts.length() == 1 {
    calculated_port_placement_height = port_placement_calculator_modified_port_placement_size(
      node_context, port_alignment, calculated_port_placement_height,
    )
    port_alignment = Center
  }

  if available_space < calculated_port_placement_height &&
    !node_context.has_size_option(PortsOverhang) {
    if node_context_port_alignment_equals(port_alignment, @core.Distributed) {
      space_between_ports += (
          available_space - calculated_port_placement_height
        ) /
        (port_contexts.length() + 1).to_double()
      current_y_pos += space_between_ports
    } else {
      space_between_ports += (
          available_space - calculated_port_placement_height
        ) /
        (port_contexts.length() - 1).to_double()
    }
  } else {
    if available_space < calculated_port_placement_height {
      calculated_port_placement_height = port_placement_calculator_modified_port_placement_size(
        node_context, port_alignment, calculated_port_placement_height,
      )
      port_alignment = Center
    }

    match port_alignment {
      Begin => ()
      Center =>
        current_y_pos += (available_space - calculated_port_placement_height) /
          2.0
      End => current_y_pos += available_space - calculated_port_placement_height
      @core.Distributed => {
        let additional_space_between_ports = (
            available_space - calculated_port_placement_height
          ) /
          (port_contexts.length() + 1).to_double()
        space_between_ports += @cmp.maximum(0.0, additional_space_between_ports)
        current_y_pos += space_between_ports
      }
      @core.Justified => {
        let additional_space_between_ports = (
            available_space - calculated_port_placement_height
          ) /
          (port_contexts.length() - 1).to_double()
        space_between_ports += @cmp.maximum(0.0, additional_space_between_ports)
      }
    }
  }

  for port_context in port_contexts {
    port_context.port_position.x = port_placement_calculator_vertical_port_x_coordinate(
      port_context, node_width,
    )
    port_context.port_position.y = current_y_pos + port_context.port_margin.top
    current_y_pos += port_context.port_margin.top +
      port_context.port.get_size().y +
      port_context.port_margin.bottom +
      space_between_ports
  }
}

///|
pub fn port_placement_calculator_place_vertical_ports(
  node_context : NodeContext,
) -> Unit {
  match node_context.port_constraints {
    FixedPos => {
      port_placement_calculator_vertical_fixed_pos_ports(node_context, East)
      port_placement_calculator_vertical_fixed_pos_ports(node_context, West)
    }
    FixedRatio => {
      port_placement_calculator_vertical_fixed_ratio_ports(node_context, East)
      port_placement_calculator_vertical_fixed_ratio_ports(node_context, West)
    }
    _ => {
      port_placement_calculator_vertical_free_ports(node_context, East)
      port_placement_calculator_vertical_free_ports(node_context, West)
    }
  }
}
