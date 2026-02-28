///|
pub let nodespacing_port_border_offset_property : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.port.borderOffset", 0.0,
)

///|
let nodespacing_default_min_width = 20.0

///|
let nodespacing_default_min_height = 20.0

///|
fn nodespacing_max(left : Double, right : Double) -> Double {
  @cmp.maximum(left, right)
}

///|
fn nodespacing_size_constraint_equals(
  left : @core.SizeConstraint,
  right : @core.SizeConstraint,
) -> Bool {
  @core.size_constraint_to_string(left) ==
  @core.size_constraint_to_string(right)
}

///|
fn nodespacing_contains_only_port_labels(
  constraints : Array[@core.SizeConstraint],
) -> Bool {
  if constraints.length() != 1 {
    return false
  }
  nodespacing_size_constraint_equals(constraints[0], PortLabels)
}

///|
fn nodespacing_parse_minimum_size(text : String) -> @core.KVector {
  let parsed = @core.new_kvector()
  parsed.parse(text)
  parsed
}

///|
pub fn nodespacing_port_border_offset_value(
  port : @core.ElkPortAdapter,
) -> Double {
  if port.has_property_double(nodespacing_port_border_offset_property) {
    port.get_property_double(nodespacing_port_border_offset_property)
  } else {
    0.0
  }
}

///|
pub fn nodespacing_port_labels_bounds(
  port : @core.ElkPortAdapter,
) -> @core.ElkRectangle {
  let labels = port.get_labels()
  if labels.is_empty() {
    return @core.new_elk_rectangle()
  }

  let first = labels[0]
  let first_pos = first.get_position()
  let first_size = first.get_size()
  let mut min_x = first_pos.x
  let mut min_y = first_pos.y
  let mut max_x = first_pos.x + first_size.x
  let mut max_y = first_pos.y + first_size.y

  for i in 1..<labels.length() {
    let label = labels[i]
    let position = label.get_position()
    let size = label.get_size()
    min_x = @cmp.minimum(min_x, position.x)
    min_y = @cmp.minimum(min_y, position.y)
    max_x = nodespacing_max(max_x, position.x + size.x)
    max_y = nodespacing_max(max_y, position.y + size.y)
  }

  @core.new_elk_rectangle_xywh(min_x, min_y, max_x - min_x, max_y - min_y)
}

///|
fn nodespacing_compute_inside_part_for_port(
  port : @core.ElkPortAdapter,
  port_border_offset : Double,
) -> Double {
  let label_bounds = nodespacing_port_labels_bounds(port)
  let label_position = @core.new_kvector_xy(label_bounds.x, label_bounds.y)
  let label_size = @core.new_kvector_xy(label_bounds.width, label_bounds.height)
  let port_size = port.get_size()

  match port.get_side() {
    North =>
      nodespacing_max(
        0.0,
        label_size.y + label_position.y - (port_size.y + port_border_offset),
      )
    South => nodespacing_max(0.0, -label_position.y - port_border_offset)
    East => nodespacing_max(0.0, -label_position.x - port_border_offset)
    West =>
      nodespacing_max(
        0.0,
        label_size.x + label_position.x - (port_size.x + port_border_offset),
      )
    SideUndefined => 0.0
  }
}

///|
pub fn node_label_and_size_utilities_setup_minimum_client_area_size(
  node_context : NodeContext,
) -> Unit {
  match
    node_label_and_size_utilities_get_minimum_client_area_size(node_context) {
    Some(min_size) =>
      grid_container_cell_set_center_cell_minimum_size(
        node_context.inside_node_label_container,
        min_size,
      )
    None => ()
  }
}

///|
pub fn node_label_and_size_utilities_setup_node_padding_for_ports_with_offset(
  node_context : NodeContext,
) -> Unit {
  let node_cell_padding = node_context.node_container.get_padding()

  for port_context in node_context_get_all_port_contexts(node_context) {
    let port_border_offset = nodespacing_port_border_offset_value(
      port_context.port,
    )

    if port_border_offset < 0.0 {
      match port_context.port.get_side() {
        North =>
          node_cell_padding.top = nodespacing_max(
            node_cell_padding.top,
            -port_border_offset,
          )
        South =>
          node_cell_padding.bottom = nodespacing_max(
            node_cell_padding.bottom,
            -port_border_offset,
          )
        East =>
          node_cell_padding.right = nodespacing_max(
            node_cell_padding.right,
            -port_border_offset,
          )
        West =>
          node_cell_padding.left = nodespacing_max(
            node_cell_padding.left,
            -port_border_offset,
          )
        SideUndefined => ()
      }
    }

    if @core.port_label_placement_is_fixed(node_context.port_labels_placement) {
      let inside_part = nodespacing_compute_inside_part_for_port(
        port_context.port,
        port_border_offset,
      )
      let symmetry = !node_context.has_size_option(Asymmetrical)
      let mut inside_part_is_bigger = false

      match port_context.port.get_side() {
        North => {
          inside_part_is_bigger = inside_part > node_cell_padding.top
          node_cell_padding.top = nodespacing_max(
            node_cell_padding.top,
            inside_part,
          )
          if symmetry && inside_part_is_bigger {
            node_cell_padding.top = nodespacing_max(
              node_cell_padding.top,
              node_cell_padding.bottom,
            )
            node_cell_padding.bottom = node_cell_padding.top +
              port_border_offset
          }
        }
        South => {
          inside_part_is_bigger = inside_part > node_cell_padding.bottom
          node_cell_padding.bottom = nodespacing_max(
            node_cell_padding.bottom,
            inside_part,
          )
          if symmetry && inside_part_is_bigger {
            node_cell_padding.bottom = nodespacing_max(
              node_cell_padding.bottom,
              node_cell_padding.top,
            )
            node_cell_padding.top = node_cell_padding.bottom +
              port_border_offset
          }
        }
        East => {
          inside_part_is_bigger = inside_part > node_cell_padding.right
          node_cell_padding.right = nodespacing_max(
            node_cell_padding.right,
            inside_part,
          )
          if symmetry && inside_part_is_bigger {
            node_cell_padding.right = nodespacing_max(
              node_cell_padding.left,
              node_cell_padding.right,
            )
            node_cell_padding.left = node_cell_padding.right +
              port_border_offset
          }
        }
        West => {
          inside_part_is_bigger = inside_part > node_cell_padding.left
          node_cell_padding.left = nodespacing_max(
            node_cell_padding.left,
            inside_part,
          )
          if symmetry && inside_part_is_bigger {
            node_cell_padding.left = nodespacing_max(
              node_cell_padding.left,
              node_cell_padding.right,
            )
            node_cell_padding.right = node_cell_padding.left +
              port_border_offset
          }
        }
        SideUndefined => ()
      }
    }
  }
}

///|
pub fn node_label_and_size_utilities_offset_southern_ports_by_node_size(
  node_context : NodeContext,
) -> Unit {
  let node_height = node_context.node_size.y
  for port_context in node_context_get_port_contexts(node_context, South) {
    port_context.port_position.y += node_height
  }
}

///|
pub fn node_label_and_size_utilities_set_node_padding(
  node_context : NodeContext,
) -> Unit {
  if !node_context.has_size_option(ComputePadding) {
    return
  }

  let node_rect = node_context.node_container.get_cell_rectangle()
  let client_area = grid_container_cell_get_center_cell_rectangle(
    node_context.inside_node_label_container,
  )
  let node_padding = @core.new_elk_padding()

  node_padding.left = client_area.x - node_rect.x
  node_padding.top = client_area.y - node_rect.y
  node_padding.right = node_rect.x +
    node_rect.width -
    (client_area.x + client_area.width)
  node_padding.bottom = node_rect.y +
    node_rect.height -
    (client_area.y + client_area.height)
  node_context.node.set_padding(node_padding)
}

///|
pub fn node_label_and_size_utilities_apply_stuff(
  node_context : NodeContext,
) -> Unit {
  node_context.apply_node_size()
  for port_context in node_context_get_all_port_contexts(node_context) {
    port_context.apply_port_position()
  }
}

///|
pub fn node_label_and_size_utilities_get_minimum_client_area_size(
  node_context : NodeContext,
) -> @core.KVector? {
  if node_context.has_size_constraint(MinimumSize) &&
    node_context.has_size_option(MinimumSizeAccountsForPadding) {
    return Some(
      node_label_and_size_utilities_get_minimum_node_or_client_area_size(
        node_context,
      ),
    )
  }
  None
}

///|
pub fn node_label_and_size_utilities_get_minimum_node_size(
  node_context : NodeContext,
) -> @core.KVector? {
  if node_context.has_size_constraint(MinimumSize) &&
    !node_context.has_size_option(MinimumSizeAccountsForPadding) {
    return Some(
      node_label_and_size_utilities_get_minimum_node_or_client_area_size(
        node_context,
      ),
    )
  }
  None
}

///|
pub fn node_label_and_size_utilities_get_minimum_node_or_client_area_size(
  node_context : NodeContext,
) -> @core.KVector {
  let min_size = nodespacing_parse_minimum_size(
    node_context.node.get_property_string(@core.node_size_minimum),
  )

  if node_context.has_size_option(DefaultMinimumSize) {
    if min_size.x <= 0.0 {
      min_size.x = nodespacing_default_min_width
    }
    if min_size.y <= 0.0 {
      min_size.y = nodespacing_default_min_height
    }
  }

  min_size
}

///|
pub fn node_label_and_size_utilities_are_size_constraints_fixed(
  node_context : NodeContext,
) -> Bool {
  node_context.size_constraints.is_empty() ||
  nodespacing_contains_only_port_labels(node_context.size_constraints)
}

///|
pub fn node_label_and_size_utilities_is_first_outside_port_label_placed_differently(
  node_context : NodeContext,
  port_side : @core.PortSide,
) -> Bool {
  let port_contexts = node_context_get_port_contexts(node_context, port_side)
  if port_contexts.length() < 2 {
    return false
  }

  let first_port = port_contexts[0]
  let always_same_side = node_context.has_port_label_placement(AlwaysSameSide)
  let space_efficient = node_context.has_port_label_placement(SpaceEfficient)

  !first_port.labels_next_to_port &&
  !always_same_side &&
  (port_contexts.length() == 2 || space_efficient)
}
