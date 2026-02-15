///|
fn vertical_port_placement_size_calculator_port_height_plus_port_port_spacing(
  node_context : NodeContext,
  port_side : PortSide,
) -> Double {
  let mut result = 0.0
  let port_contexts = node_context_get_port_contexts(node_context, port_side)
  for i in 0..<port_contexts.length() {
    let port_context = port_contexts[i]
    result += port_context.port_margin.top +
      port_context.port.get_size().y +
      port_context.port_margin.bottom
    if i + 1 < port_contexts.length() {
      result += node_context.port_port_spacing
    }
  }
  result
}

///|
fn vertical_port_placement_size_calculator_unify_port_margins(
  port_contexts : Array[PortContext],
) -> Unit {
  let mut max_top = 0.0
  let mut max_bottom = 0.0

  for port_context in port_contexts {
    max_top = @cmp.maximum(max_top, port_context.port_margin.top)
    max_bottom = @cmp.maximum(max_bottom, port_context.port_margin.bottom)
  }

  for port_context in port_contexts {
    port_context.port_margin.top = max_top
    port_context.port_margin.bottom = max_bottom
  }
}

///|
fn vertical_port_placement_size_calculator_compute_vertical_port_margins(
  node_context : NodeContext,
  port_side : PortSide,
) -> Unit {
  for port_context in node_context_get_port_contexts(node_context, port_side) {
    let label_height = match port_context.port_label_cell {
      Some(port_label_cell) => port_label_cell.get_minimum_height()
      None => 0.0
    }

    if label_height > 0.0 {
      if port_context.labels_next_to_port {
        let port_height = port_context.port.get_size().y
        if label_height > port_height {
          match port_context.port_label_cell {
            Some(port_label_cell) =>
              if node_context.port_labels_treat_as_group ||
                port_label_cell.get_labels().length() == 1 {
                let overhang = (label_height - port_height) / 2.0
                port_context.port_margin.top = overhang
                port_context.port_margin.bottom = overhang
              } else {
                let first_label_height = label_height
                let first_label_overhang = (first_label_height - port_height) /
                  2.0
                port_context.port_margin.top = @cmp.maximum(
                  0.0, first_label_overhang,
                )
                port_context.port_margin.bottom = label_height -
                  first_label_overhang -
                  port_height
              }
            None => ()
          }
        }
      } else {
        port_context.port_margin.bottom = node_context.port_label_spacing_vertical +
          label_height
      }
    } else if port_label_placement_is_fixed(node_context.port_labels_placement) {
      let labels_bounds = nodespacing_port_labels_bounds(port_context.port)
      if labels_bounds.y < 0.0 {
        port_context.port_margin.top = -labels_bounds.y
      }
      if labels_bounds.y + labels_bounds.height > port_context.port.get_size().y {
        port_context.port_margin.bottom = labels_bounds.y +
          labels_bounds.height -
          port_context.port.get_size().y
      }
    }
  }
}

///|
fn vertical_port_placement_size_calculator_setup_port_margins(
  node_context : NodeContext,
  port_side : PortSide,
) -> Unit {
  let port_contexts = node_context_get_port_contexts(node_context, port_side)
  if port_contexts.is_empty() {
    return
  }

  let port_labels_outside = node_context.has_port_label_placement(Outside)
  let always_same_side = node_context.has_port_label_placement(AlwaysSameSide)
  let always_same_side_above = node_context.has_port_label_placement(
    AlwaysOtherSameSide,
  )
  let space_efficient = node_context.has_port_label_placement(SpaceEfficient)
  let uniform_port_spacing = node_context.has_size_option(UniformPortSpacing)

  let space_efficient_port_labels = !always_same_side &&
    !always_same_side_above &&
    (space_efficient || port_contexts.length() == 2)

  vertical_port_placement_size_calculator_compute_vertical_port_margins(
    node_context, port_side,
  )

  let topmost_port_context = port_contexts[0]
  let bottommost_port_context = port_contexts[port_contexts.length() - 1]

  if port_labels_outside {
    topmost_port_context.port_margin.top = 0.0
    bottommost_port_context.port_margin.bottom = 0.0
    if space_efficient_port_labels && !topmost_port_context.labels_next_to_port {
      topmost_port_context.port_margin.bottom = 0.0
    }
  }

  if uniform_port_spacing {
    vertical_port_placement_size_calculator_unify_port_margins(port_contexts)
    if port_labels_outside {
      topmost_port_context.port_margin.top = 0.0
      bottommost_port_context.port_margin.bottom = 0.0
    }
  }
}

///|
fn vertical_port_placement_size_calculator_calculate_vertical_node_size_required_by_fixed_pos_ports(
  node_context : NodeContext,
  port_side : PortSide,
) -> Unit {
  let mut bottommost_port_border = 0.0
  for port_context in node_context_get_port_contexts(node_context, port_side) {
    bottommost_port_border = @cmp.maximum(
      bottommost_port_border,
      port_context.port_position.y + port_context.port.get_size().y,
    )
  }

  match
    node_context.inside_port_label_cells.get(
      node_context_port_side_key(port_side),
    ) {
    Some(cell) => {
      cell.get_padding().top = 0.0
      cell.get_minimum_content_area_size().y = bottommost_port_border
    }
    None => ()
  }
}

///|
fn vertical_port_placement_size_calculator_calculate_vertical_node_size_required_by_fixed_ratio_ports(
  node_context : NodeContext,
  port_side : PortSide,
) -> Unit {
  let cell = match
    node_context.inside_port_label_cells.get(
      node_context_port_side_key(port_side),
    ) {
    Some(value) => value
    None => return
  }

  let port_contexts = node_context_get_port_contexts(node_context, port_side)
  if port_contexts.is_empty() {
    cell.get_padding().top = 0.0
    cell.get_padding().bottom = 0.0
    return
  }

  if node_context.has_size_constraint(PortLabels) {
    vertical_port_placement_size_calculator_setup_port_margins(
      node_context, port_side,
    )
  }

  let port_labels_inside = node_context.has_port_label_placement(Inside)
  let mut min_height = 0.0
  let mut previous_port_context : PortContext? = None
  let mut previous_port_ratio = 0.0
  let mut previous_port_height = 0.0

  for current_port_context in port_contexts {
    let current_port_ratio = if current_port_context.port.has_property_double(
        port_placement_calculator_port_ratio_or_position,
      ) {
      current_port_context.port.get_property_double(
        port_placement_calculator_port_ratio_or_position,
      )
    } else {
      0.0
    }
    let current_port_height = current_port_context.port.get_size().y

    match previous_port_context {
      None =>
        if node_context.surrounding_port_margins.top > 0.0 {
          min_height = @cmp.maximum(
            min_height,
            horizontal_port_placement_size_calculator_min_size_required_to_respect_spacing(
              node_context.surrounding_port_margins.top +
              current_port_context.port_margin.top,
              0.0,
              current_port_ratio,
            ),
          )
        }
      Some(previous_context) => {
        let required_space = previous_port_height +
          previous_context.port_margin.bottom +
          node_context.port_port_spacing +
          current_port_context.port_margin.top
        min_height = @cmp.maximum(
          min_height,
          horizontal_port_placement_size_calculator_min_size_required_to_respect_spacing(
            required_space, previous_port_ratio, current_port_ratio,
          ),
        )
      }
    }

    previous_port_context = Some(current_port_context)
    previous_port_ratio = current_port_ratio
    previous_port_height = current_port_height
  }

  if node_context.surrounding_port_margins.bottom > 0.0 {
    let previous_context = match previous_port_context {
      Some(value) => value
      None => {
        cell.get_padding().top = 0.0
        cell.get_minimum_content_area_size().y = min_height
        return
      }
    }
    let mut required_space = previous_port_height +
      node_context.surrounding_port_margins.bottom
    if port_labels_inside {
      required_space += previous_context.port_margin.bottom
    }
    min_height = @cmp.maximum(
      min_height,
      horizontal_port_placement_size_calculator_min_size_required_to_respect_spacing(
        required_space, previous_port_ratio, 1.0,
      ),
    )
  }

  cell.get_padding().top = 0.0
  cell.get_minimum_content_area_size().y = min_height
}

///|
fn vertical_port_placement_size_calculator_calculate_vertical_node_size_required_by_free_ports(
  node_context : NodeContext,
  port_side : PortSide,
) -> Unit {
  let cell = match
    node_context.inside_port_label_cells.get(
      node_context_port_side_key(port_side),
    ) {
    Some(value) => value
    None => return
  }
  let port_contexts = node_context_get_port_contexts(node_context, port_side)
  if port_contexts.is_empty() {
    cell.get_padding().top = 0.0
    cell.get_padding().bottom = 0.0
    return
  }

  cell.get_padding().top = node_context.surrounding_port_margins.top
  cell.get_padding().bottom = node_context.surrounding_port_margins.bottom

  if node_context.has_size_constraint(PortLabels) {
    vertical_port_placement_size_calculator_setup_port_margins(
      node_context, port_side,
    )
  }

  let mut height = vertical_port_placement_size_calculator_port_height_plus_port_port_spacing(
    node_context, port_side,
  )
  if node_context_port_alignment_equals(
      node_context.get_port_alignment(port_side),
      Distributed,
    ) {
    height += 2.0 * node_context.port_port_spacing
  }

  cell.get_minimum_content_area_size().y = height
}

///|
pub fn vertical_port_placement_size_calculator_calculate_vertical_port_placement_size(
  node_context : NodeContext,
) -> Unit {
  match node_context.port_constraints {
    FixedPos => {
      vertical_port_placement_size_calculator_calculate_vertical_node_size_required_by_fixed_pos_ports(
        node_context,
        East,
      )
      vertical_port_placement_size_calculator_calculate_vertical_node_size_required_by_fixed_pos_ports(
        node_context,
        West,
      )
    }
    FixedRatio => {
      vertical_port_placement_size_calculator_calculate_vertical_node_size_required_by_fixed_ratio_ports(
        node_context,
        East,
      )
      vertical_port_placement_size_calculator_calculate_vertical_node_size_required_by_fixed_ratio_ports(
        node_context,
        West,
      )
    }
    _ => {
      vertical_port_placement_size_calculator_calculate_vertical_node_size_required_by_free_ports(
        node_context,
        East,
      )
      vertical_port_placement_size_calculator_calculate_vertical_node_size_required_by_free_ports(
        node_context,
        West,
      )
    }
  }
}
