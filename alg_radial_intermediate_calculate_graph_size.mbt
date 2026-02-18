///|
pub fn new_radial_calculate_graph_size_layout_processor() -> ILayoutProcessor[
  RadialLayoutPhases,
  ElkNode,
] {
  new_layout_processor((graph, progress_monitor) => {
    match progress_monitor {
      Some(monitor) => {
        ignore(monitor.begin("Calculate Graph Size", 1.0))
        monitor.log_graph("Before")
      }
      None => ()
    }
    let children = node_children(graph)

    let mut min_x_pos = @double.max_value
    let mut min_y_pos = @double.max_value
    let mut max_x_pos = -@double.max_value
    let mut max_y_pos = -@double.max_value

    for node in children {
      let pos_x = node_x(node)
      let pos_y = node_y(node)
      let width = node_width(node)
      let height = node_height(node)
      let margins = radial_internal_node_margins(node)
      min_x_pos = if pos_x - margins.left < min_x_pos {
        pos_x - margins.left
      } else {
        min_x_pos
      }
      min_y_pos = if pos_y - margins.top < min_y_pos {
        pos_y - margins.top
      } else {
        min_y_pos
      }
      max_x_pos = if pos_x + width + margins.right > max_x_pos {
        pos_x + width + margins.right
      } else {
        max_x_pos
      }
      max_y_pos = if pos_y + height + margins.bottom > max_y_pos {
        pos_y + height + margins.bottom
      } else {
        max_y_pos
      }
    }

    let padding_value = radial_internal_graph_padding(graph)
    let offset = new_kvector_xy(
      min_x_pos - padding_value.get_left(),
      min_y_pos - padding_value.get_top(),
    )

    let mut width = max_x_pos - min_x_pos + padding_value.get_horizontal()
    let mut height = max_y_pos - min_y_pos + padding_value.get_vertical()

    if node_get_bool_property(graph, radial_center_on_root) {
      let root = match radial_internal_root(graph) {
        Some(value) => value
        None => abort("radial root node is missing")
      }
      let root_margins = radial_internal_node_margins(root)
      let root_x = node_x(root) +
        node_width(root) / 2.0 +
        (root_margins.left + root_margins.right) / 2.0 -
        offset.x
      let root_y = node_y(root) +
        node_height(root) / 2.0 +
        (root_margins.top + root_margins.bottom) / 2.0 -
        offset.y

      let dx = width - root_x
      let dy = height - root_y

      if dx < width / 2.0 {
        let additional_x = dx - root_x
        width += additional_x
        offset.x -= additional_x
      } else {
        let additional_x = root_x - dx
        width += additional_x
      }

      if dy < height / 2.0 {
        let additional_y = dy - root_y
        height += additional_y
        offset.y -= additional_y
      } else {
        let additional_y = root_y - dy
        height += additional_y
      }
    }

    for node in children {
      node_set_location(node, node_x(node) - offset.x, node_y(node) - offset.y)
    }

    if !node_get_bool_property(graph, node_size_fixed_graph_size) {
      node_set_dimensions(graph, width, height)
    }
    node_set_double_property(
      graph,
      child_area_width,
      width - padding_value.get_horizontal(),
    )
    node_set_double_property(
      graph,
      child_area_height,
      height - padding_value.get_vertical(),
    )
    match progress_monitor {
      Some(monitor) => monitor.log_graph("After")
      None => ()
    }
  })
}
