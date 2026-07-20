///|
fn node_size_calculator_outside_container_minimum_width(
  node_context : NodeContext,
  side : @core.PortSide,
) -> Double {
  match
    node_context.outside_node_label_containers.get(
      node_context_port_side_key(side),
    ) {
    Some(container) => container.get_minimum_width()
    None => 0.0
  }
}

///|
fn node_size_calculator_outside_container_minimum_height(
  node_context : NodeContext,
  side : @core.PortSide,
) -> Double {
  match
    node_context.outside_node_label_containers.get(
      node_context_port_side_key(side),
    ) {
    Some(container) => container.get_minimum_height()
    None => 0.0
  }
}

///|
pub fn node_size_calculator_set_node_width(node_context : NodeContext) -> Unit {
  let node_size = node_context.node_size
  let width = if node_label_and_size_utilities_are_size_constraints_fixed(
      node_context,
    ) {
    node_size.x
  } else {
    let mut computed_width = if node_context.topdown_layout {
      @cmp.maximum(node_size.x, node_context.node_container.get_minimum_width())
    } else {
      node_context.node_container.get_minimum_width()
    }

    if node_context.has_size_constraint(NodeLabels) &&
      !node_context.has_size_option(OutsideNodeLabelsOverhang) {
      computed_width = @cmp.maximum(
        computed_width,
        node_size_calculator_outside_container_minimum_width(
          node_context,
          North,
        ),
      )
      computed_width = @cmp.maximum(
        computed_width,
        node_size_calculator_outside_container_minimum_width(
          node_context,
          South,
        ),
      )
    }

    match node_label_and_size_utilities_get_minimum_node_size(node_context) {
      Some(min_node_size) =>
        computed_width = @cmp.maximum(computed_width, min_node_size.x)
      None => ()
    }
    computed_width
  }

  let fixed_graph_size = match node_context.node.get_graph() {
    Some(graph) => graph.get_property_bool(@core.node_size_fixed_graph_size)
    None => false
  }

  if fixed_graph_size {
    node_size.x = @cmp.maximum(node_size.x, width)
  } else {
    node_size.x = width
  }

  let node_cell_rectangle = node_context.node_container.get_cell_rectangle()
  node_cell_rectangle.x = 0.0
  node_cell_rectangle.width = width
  node_context.node_container.layout_children_horizontally()
}

///|
pub fn node_size_calculator_set_node_height(node_context : NodeContext) -> Unit {
  let node_size = node_context.node_size
  let height = if node_label_and_size_utilities_are_size_constraints_fixed(
      node_context,
    ) {
    node_size.y
  } else {
    let mut computed_height = if node_context.topdown_layout {
      @cmp.maximum(
        node_size.y,
        node_context.node_container.get_minimum_height(),
      )
    } else {
      node_context.node_container.get_minimum_height()
    }

    if node_context.has_size_constraint(NodeLabels) &&
      !node_context.has_size_option(OutsideNodeLabelsOverhang) {
      computed_height = @cmp.maximum(
        computed_height,
        node_size_calculator_outside_container_minimum_height(
          node_context,
          East,
        ),
      )
      computed_height = @cmp.maximum(
        computed_height,
        node_size_calculator_outside_container_minimum_height(
          node_context,
          West,
        ),
      )
    }

    match node_label_and_size_utilities_get_minimum_node_size(node_context) {
      Some(min_node_size) =>
        computed_height = @cmp.maximum(computed_height, min_node_size.y)
      None => ()
    }

    if node_context.has_size_constraint(Ports) &&
      (
        node_context_port_constraints_equals(
          node_context.port_constraints,
          FixedRatio,
        ) ||
        node_context_port_constraints_equals(
          node_context.port_constraints,
          FixedPos,
        )
      ) {
      match
        node_context.inside_port_label_cells.get(
          node_context_port_side_key(East),
        ) {
        Some(cell) =>
          computed_height = @cmp.maximum(
            computed_height,
            cell.get_minimum_height(),
          )
        None => ()
      }
      match
        node_context.inside_port_label_cells.get(
          node_context_port_side_key(West),
        ) {
        Some(cell) =>
          computed_height = @cmp.maximum(
            computed_height,
            cell.get_minimum_height(),
          )
        None => ()
      }
    }

    computed_height
  }

  let fixed_graph_size = match node_context.node.get_graph() {
    Some(graph) => graph.get_property_bool(@core.node_size_fixed_graph_size)
    None => false
  }

  if fixed_graph_size {
    node_size.y = @cmp.maximum(node_size.y, height)
  } else {
    node_size.y = height
  }

  let node_cell_rectangle = node_context.node_container.get_cell_rectangle()
  node_cell_rectangle.y = 0.0
  node_cell_rectangle.height = height
  node_context.node_container.layout_children_vertically()
}
