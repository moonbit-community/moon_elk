///|
let node_label_and_size_calculator_direction_property : @graph.IProperty[String] = @core.direction

///|
fn node_label_and_size_calculator_process_node(
  layered_graph : @graph.ElkNode,
  node : @core.ElkNodeAdapter,
  apply_stuff : Bool,
  ignore_inside_port_labels : Bool,
) -> @core.KVector {
  let node_context = new_node_context(node)
  port_context_creator_create_port_contexts(
    node_context, ignore_inside_port_labels,
  )

  let layout_direction = @core.adapt(layered_graph).get_property_string(
    node_label_and_size_calculator_direction_property,
  )
  let horizontal_layout_mode = layout_direction == "" ||
    layout_direction == @core.direction_to_string(Undefined) ||
    layout_direction == @core.direction_to_string(Rightward) ||
    layout_direction == @core.direction_to_string(Leftward)

  node_label_cell_creator_create_node_label_cells(
    node_context, false, horizontal_layout_mode,
  )
  inside_port_label_cell_creator_create_inside_port_label_cells(node_context)

  node_label_and_size_utilities_setup_minimum_client_area_size(node_context)
  node_label_and_size_utilities_setup_node_padding_for_ports_with_offset(
    node_context,
  )

  horizontal_port_placement_size_calculator_calculate_horizontal_port_placement_size(
    node_context,
  )
  vertical_port_placement_size_calculator_calculate_vertical_port_placement_size(
    node_context,
  )

  cell_system_configurator_configure_cell_system_size_contributions(
    node_context,
  )

  node_size_calculator_set_node_width(node_context)
  port_placement_calculator_place_horizontal_ports(node_context)
  port_label_placement_calculator_place_horizontal_port_labels(node_context)

  cell_system_configurator_update_vertical_inside_port_label_cell_padding(
    node_context,
  )
  node_size_calculator_set_node_height(node_context)

  if !apply_stuff {
    return node_context.node_size
  }

  node_label_and_size_utilities_offset_southern_ports_by_node_size(node_context)
  port_placement_calculator_place_vertical_ports(node_context)
  port_label_placement_calculator_place_vertical_port_labels(node_context)

  label_placer_place_labels(node_context)
  node_label_and_size_utilities_set_node_padding(node_context)
  node_label_and_size_utilities_apply_stuff(node_context)

  node_context.node_size
}

///|
pub fn node_label_and_size_calculator_process_layered_graph(
  layered_graph : @graph.ElkNode,
) -> Unit {
  let adapter = @core.adapt(layered_graph)
  for node in adapter.get_nodes() {
    ignore(
      node_label_and_size_calculator_process_node(
        layered_graph, node, true, false,
      ),
    )
  }
}

///|
pub fn node_label_and_size_calculator_process_single_node(
  layered_graph : @graph.ElkNode,
  node : @graph.ElkNode,
  apply_stuff : Bool,
  ignore_inside_port_labels : Bool,
) -> @core.KVector {
  node_label_and_size_calculator_process_node(
    layered_graph,
    @core.adapt_single_node(node),
    apply_stuff,
    ignore_inside_port_labels,
  )
}

///|
pub fn node_label_and_size_calculator_compute_inside_node_label_padding(
  node : @graph.ElkNode,
  layout_direction : @core.Direction,
) -> @core.ElkPadding {
  let node_context = new_node_context(@core.adapt_single_node(node))
  node_label_cell_creator_create_node_label_cells(
    node_context,
    true,
    !layout_direction.is_vertical(),
  )

  let label_cell_container = node_context.inside_node_label_container
  let padding = @core.new_elk_padding()

  for col in container_area_values() {
    if grid_container_cell_get_cell(label_cell_container, Begin, col)
      is Some(label_cell) {
      padding.top = @cmp.maximum(padding.top, label_cell.get_minimum_height())
    }
  }

  for col in container_area_values() {
    if grid_container_cell_get_cell(label_cell_container, End, col)
      is Some(label_cell) {
      padding.bottom = @cmp.maximum(
        padding.bottom,
        label_cell.get_minimum_height(),
      )
    }
  }

  for row in container_area_values() {
    if grid_container_cell_get_cell(label_cell_container, row, Begin)
      is Some(label_cell) {
      padding.left = @cmp.maximum(padding.left, label_cell.get_minimum_width())
    }
  }

  for row in container_area_values() {
    if grid_container_cell_get_cell(label_cell_container, row, End)
      is Some(label_cell) {
      padding.right = @cmp.maximum(
        padding.right,
        label_cell.get_minimum_width(),
      )
    }
  }

  let container_padding = label_cell_container.get_padding()
  let container_gap = grid_container_cell_get_gap(label_cell_container)

  if padding.top > 0.0 {
    padding.top = padding.top + container_padding.top + container_gap
  }
  if padding.bottom > 0.0 {
    padding.bottom = padding.bottom + container_padding.bottom + container_gap
  }
  if padding.left > 0.0 {
    padding.left = padding.left + container_padding.left + container_gap
  }
  if padding.right > 0.0 {
    padding.right = padding.right + container_padding.right + container_gap
  }

  padding
}
