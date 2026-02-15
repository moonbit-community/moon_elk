///|
let horizontal_port_placement_size_calculator_equality_tolerance = 0.01

///|
pub fn horizontal_port_placement_size_calculator_min_size_required_to_respect_spacing(
  spacing : Double,
  first_ratio : Double,
  second_ratio : Double,
) -> Double {
  if (first_ratio - second_ratio).abs() <=
    horizontal_port_placement_size_calculator_equality_tolerance {
    0.0
  } else {
    spacing / (second_ratio - first_ratio)
  }
}

///|
fn horizontal_port_placement_size_calculator_port_width_plus_port_port_spacing(
  node_context : NodeContext,
  port_side : PortSide,
) -> Double {
  let mut result = 0.0
  let port_contexts = node_context_get_port_contexts(node_context, port_side)

  for i in 0..<port_contexts.length() {
    let port_context = port_contexts[i]
    result += port_context.port_margin.left +
      port_context.port.get_size().x +
      port_context.port_margin.right
    if i + 1 < port_contexts.length() {
      result += node_context.port_port_spacing
    }
  }

  result
}

///|
fn horizontal_port_placement_size_calculator_unify_port_margins(
  port_contexts : Array[PortContext],
) -> Unit {
  let mut max_left = 0.0
  let mut max_right = 0.0

  for port_context in port_contexts {
    max_left = @cmp.maximum(max_left, port_context.port_margin.left)
    max_right = @cmp.maximum(max_right, port_context.port_margin.right)
  }

  for port_context in port_contexts {
    port_context.port_margin.left = max_left
    port_context.port_margin.right = max_right
  }
}

///|
fn horizontal_port_placement_size_calculator_compute_horizontal_port_margins(
  node_context : NodeContext,
  port_side : PortSide,
) -> Unit {
  for port_context in node_context_get_port_contexts(node_context, port_side) {
    let label_width = match port_context.port_label_cell {
      Some(port_label_cell) => port_label_cell.get_minimum_width()
      None => 0.0
    }

    if label_width > 0.0 {
      if port_context.labels_next_to_port {
        let port_width = port_context.port.get_size().x
        if label_width > port_width {
          let overhang = (label_width - port_width) / 2.0
          port_context.port_margin.left = overhang
          port_context.port_margin.right = overhang
        }
      } else {
        port_context.port_margin.right = node_context.port_label_spacing_horizontal +
          label_width
      }
    } else if port_label_placement_is_fixed(node_context.port_labels_placement) {
      let labels_bounds = nodespacing_port_labels_bounds(port_context.port)
      if labels_bounds.x < 0.0 {
        port_context.port_margin.left = -labels_bounds.x
      }
      if labels_bounds.x + labels_bounds.width > port_context.port.get_size().x {
        port_context.port_margin.right = labels_bounds.x +
          labels_bounds.width -
          port_context.port.get_size().x
      }
    }
  }
}

///|
fn horizontal_port_placement_size_calculator_setup_port_margins(
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

  horizontal_port_placement_size_calculator_compute_horizontal_port_margins(
    node_context, port_side,
  )

  let leftmost_port_context = port_contexts[0]
  let rightmost_port_context = port_contexts[port_contexts.length() - 1]

  if port_labels_outside {
    leftmost_port_context.port_margin.left = 0.0
    rightmost_port_context.port_margin.right = 0.0
    if space_efficient_port_labels && !leftmost_port_context.labels_next_to_port {
      leftmost_port_context.port_margin.right = 0.0
    }
  }

  if uniform_port_spacing {
    horizontal_port_placement_size_calculator_unify_port_margins(port_contexts)
    if port_labels_outside {
      leftmost_port_context.port_margin.left = 0.0
      rightmost_port_context.port_margin.right = 0.0
    }
  }
}

///|
fn horizontal_port_placement_size_calculator_calculate_horizontal_node_size_required_by_fixed_pos_ports(
  node_context : NodeContext,
  port_side : PortSide,
) -> Unit {
  let mut rightmost_port_border = 0.0
  for port_context in node_context_get_port_contexts(node_context, port_side) {
    rightmost_port_border = @cmp.maximum(
      rightmost_port_border,
      port_context.port_position.x + port_context.port.get_size().x,
    )
  }

  match
    node_context.inside_port_label_cells.get(
      node_context_port_side_key(port_side),
    ) {
    Some(cell) => {
      cell.get_padding().left = 0.0
      cell.get_minimum_content_area_size().x = rightmost_port_border
    }
    None => ()
  }
}

///|
fn horizontal_port_placement_size_calculator_calculate_horizontal_node_size_required_by_fixed_ratio_ports(
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
    cell.get_padding().left = 0.0
    cell.get_padding().right = 0.0
    return
  }

  if node_context.has_size_constraint(PortLabels) {
    horizontal_port_placement_size_calculator_setup_port_margins(
      node_context, port_side,
    )
  }

  let port_labels_inside = node_context.has_port_label_placement(Inside)
  let mut min_width = 0.0
  let mut previous_port_context : PortContext? = None
  let mut previous_port_ratio = 0.0
  let mut previous_port_width = 0.0

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
    let current_port_width = current_port_context.port.get_size().x

    match previous_port_context {
      None =>
        if node_context.surrounding_port_margins.left > 0.0 {
          min_width = @cmp.maximum(
            min_width,
            horizontal_port_placement_size_calculator_min_size_required_to_respect_spacing(
              node_context.surrounding_port_margins.left +
              current_port_context.port_margin.left,
              0.0,
              current_port_ratio,
            ),
          )
        }
      Some(previous_context) => {
        let required_space = previous_port_width +
          previous_context.port_margin.right +
          node_context.port_port_spacing +
          current_port_context.port_margin.left
        min_width = @cmp.maximum(
          min_width,
          horizontal_port_placement_size_calculator_min_size_required_to_respect_spacing(
            required_space, previous_port_ratio, current_port_ratio,
          ),
        )
      }
    }

    previous_port_context = Some(current_port_context)
    previous_port_ratio = current_port_ratio
    previous_port_width = current_port_width
  }

  if node_context.surrounding_port_margins.right > 0.0 {
    let previous_context = match previous_port_context {
      Some(value) => value
      None => {
        cell.get_padding().left = 0.0
        cell.get_minimum_content_area_size().x = min_width
        return
      }
    }
    let mut required_space = previous_port_width +
      node_context.surrounding_port_margins.right
    if port_labels_inside {
      required_space += previous_context.port_margin.right
    }
    min_width = @cmp.maximum(
      min_width,
      horizontal_port_placement_size_calculator_min_size_required_to_respect_spacing(
        required_space, previous_port_ratio, 1.0,
      ),
    )
  }

  cell.get_padding().left = 0.0
  cell.get_minimum_content_area_size().x = min_width
}

///|
fn horizontal_port_placement_size_calculator_calculate_horizontal_node_size_required_by_free_ports(
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
    cell.get_padding().left = 0.0
    cell.get_padding().right = 0.0
    return
  }

  cell.get_padding().left = node_context.surrounding_port_margins.left
  cell.get_padding().right = node_context.surrounding_port_margins.right

  if node_context.has_size_constraint(PortLabels) {
    horizontal_port_placement_size_calculator_setup_port_margins(
      node_context, port_side,
    )
  }

  let mut width = horizontal_port_placement_size_calculator_port_width_plus_port_port_spacing(
    node_context, port_side,
  )
  if node_context_port_alignment_equals(
      node_context.get_port_alignment(port_side),
      Distributed,
    ) {
    width += 2.0 * node_context.port_port_spacing
  }

  cell.get_minimum_content_area_size().x = width
}

///|
pub fn horizontal_port_placement_size_calculator_calculate_horizontal_port_placement_size(
  node_context : NodeContext,
) -> Unit {
  match node_context.port_constraints {
    FixedPos => {
      horizontal_port_placement_size_calculator_calculate_horizontal_node_size_required_by_fixed_pos_ports(
        node_context,
        North,
      )
      horizontal_port_placement_size_calculator_calculate_horizontal_node_size_required_by_fixed_pos_ports(
        node_context,
        South,
      )
    }
    FixedRatio => {
      horizontal_port_placement_size_calculator_calculate_horizontal_node_size_required_by_fixed_ratio_ports(
        node_context,
        North,
      )
      horizontal_port_placement_size_calculator_calculate_horizontal_node_size_required_by_fixed_ratio_ports(
        node_context,
        South,
      )
    }
    _ => {
      horizontal_port_placement_size_calculator_calculate_horizontal_node_size_required_by_free_ports(
        node_context,
        North,
      )
      horizontal_port_placement_size_calculator_calculate_horizontal_node_size_required_by_free_ports(
        node_context,
        South,
      )
    }
  }
}
