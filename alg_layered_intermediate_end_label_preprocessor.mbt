///|
let end_label_preprocessor_no_incident_edge_thickness = -1.0

///|
fn end_label_preprocessor_parse_direction(value : String) -> Direction {
  match value {
    "RIGHT" => Direction::Rightward
    "LEFT" => Direction::Leftward
    "DOWN" => Direction::Downward
    "UP" => Direction::Upward
    _ => Direction::Undefined
  }
}

///|
fn end_label_preprocessor_port_option_equals(
  left : LPort?,
  right : LPort?,
) -> Bool {
  match (left, right) {
    (Some(l), Some(r)) => l.get_handle() == r.get_handle()
    (None, None) => true
    _ => false
  }
}

///|
fn end_label_preprocessor_edge_source_is_port(
  edge : LEdge,
  port : LPort,
) -> Bool {
  match edge.get_source() {
    Some(source) => source.get_handle() == port.get_handle()
    None => false
  }
}

///|
fn end_label_preprocessor_require_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(value) => value
    None => abort("port has no owner node")
  }
}

///|
fn end_label_preprocessor_max_edge_thickness(port : LPort) -> Double {
  port.get_property_double(internal_properties_max_edge_thickness)
}

///|
fn end_label_preprocessor_gather_labels_for_port(
  port : LPort,
  target_list : Array[LLabel],
) -> Double {
  let mut max_edge_thickness = end_label_preprocessor_no_incident_edge_thickness
  let labels = []

  for incident_edge in port.get_connected_edges() {
    max_edge_thickness = if max_edge_thickness >
      incident_edge.get_property_double(edge_thickness) {
      max_edge_thickness
    } else {
      incident_edge.get_property_double(edge_thickness)
    }

    if end_label_preprocessor_edge_source_is_port(incident_edge, port) {
      for label in incident_edge.get_labels() {
        if label.get_property_string(edge_labels_placement) == "TAIL" {
          labels.push(label)
        }
      }
    } else {
      for label in incident_edge.get_labels() {
        if label.get_property_string(edge_labels_placement) == "HEAD" {
          labels.push(label)
        }
      }
    }

    for label in labels {
      if !label.has_property_l_edge(internal_properties_end_label_edge) {
        label.set_property_l_edge(
          internal_properties_end_label_edge,
          Some(incident_edge),
        )
      }
      target_list.push(label)
    }
    labels.clear()
  }

  max_edge_thickness
}

///|
fn end_label_preprocessor_gather_labels(port : LPort) -> Array[LLabel]? {
  let labels = []

  let mut max_edge_thickness = end_label_preprocessor_gather_labels_for_port(
    port, labels,
  )

  match port.get_property_l_node(internal_properties_port_dummy) {
    Some(dummy_node) =>
      for dummy_port in dummy_node.get_ports() {
        if end_label_preprocessor_port_option_equals(
            dummy_port.get_property_l_port(internal_properties_origin_l_port),
            Some(port),
          ) {
          let dummy_thickness = end_label_preprocessor_gather_labels_for_port(
            dummy_port, labels,
          )
          max_edge_thickness = if max_edge_thickness > dummy_thickness {
            max_edge_thickness
          } else {
            dummy_thickness
          }
        }
      }
    None => ()
  }

  if !labels.is_empty() {
    port.set_property_double(
      internal_properties_max_edge_thickness, max_edge_thickness,
    )
  }

  if max_edge_thickness != end_label_preprocessor_no_incident_edge_thickness {
    Some(labels)
  } else {
    None
  }
}

///|
fn end_label_preprocessor_create_configured_label_cell(
  labels : Array[LLabel]?,
  label_label_spacing : Double,
  vertical_layout : Bool,
) -> EndLabelCell? {
  match labels {
    Some(actual_labels) => {
      if actual_labels.is_empty() {
        return None
      }

      let cell = new_end_label_cell(
        label_label_spacing,
        !vertical_layout,
        actual_labels[0].get_property_label_side(internal_properties_label_side),
      )

      for label in actual_labels {
        cell.add_l_label(label)
      }

      let cell_rect = cell.get_cell_rectangle()
      cell_rect.height = cell.get_minimum_height()
      cell_rect.width = cell.get_minimum_width()
      Some(cell)
    }
    None => None
  }
}

///|
fn end_label_preprocessor_place_labels_for_port(
  port : LPort,
  label_cell : EndLabelCell,
  edge_label_spacing : Double,
) -> Unit {
  let label_cell_rect = label_cell.get_cell_rectangle()
  let owner_node = end_label_preprocessor_require_node(port)
  let node_size = owner_node.get_size()
  let node_margin = owner_node.get_margin()
  let port_anchor = port.get_position().clone()
  ignore(port_anchor.add(port.get_anchor()))

  match port.get_side() {
    PortSide::North => {
      label_cell.set_vertical_alignment(VerticalLabelAlignment::Bottom)
      label_cell_rect.y = -node_margin.top -
        edge_label_spacing -
        label_cell_rect.height

      match label_cell.get_label_side() {
        LabelSide::Above => {
          label_cell.set_horizontal_alignment(HorizontalLabelAlignment::Right)
          label_cell_rect.x = port_anchor.x -
            end_label_preprocessor_max_edge_thickness(port) -
            edge_label_spacing -
            label_cell_rect.width
        }
        _ => {
          label_cell.set_horizontal_alignment(HorizontalLabelAlignment::Left)
          label_cell_rect.x = port_anchor.x +
            end_label_preprocessor_max_edge_thickness(port) +
            edge_label_spacing
        }
      }
    }
    PortSide::East => {
      label_cell.set_horizontal_alignment(HorizontalLabelAlignment::Left)
      label_cell_rect.x = node_size.x + node_margin.right + edge_label_spacing

      match label_cell.get_label_side() {
        LabelSide::Above => {
          label_cell.set_vertical_alignment(VerticalLabelAlignment::Bottom)
          label_cell_rect.y = port_anchor.y -
            end_label_preprocessor_max_edge_thickness(port) -
            edge_label_spacing -
            label_cell_rect.height
        }
        _ => {
          label_cell.set_vertical_alignment(VerticalLabelAlignment::Top)
          label_cell_rect.y = port_anchor.y +
            end_label_preprocessor_max_edge_thickness(port) +
            edge_label_spacing
        }
      }
    }
    PortSide::South => {
      label_cell.set_vertical_alignment(VerticalLabelAlignment::Top)
      label_cell_rect.y = node_size.y + node_margin.bottom + edge_label_spacing

      match label_cell.get_label_side() {
        LabelSide::Above => {
          label_cell.set_horizontal_alignment(HorizontalLabelAlignment::Right)
          label_cell_rect.x = port_anchor.x -
            end_label_preprocessor_max_edge_thickness(port) -
            edge_label_spacing -
            label_cell_rect.width
        }
        _ => {
          label_cell.set_horizontal_alignment(HorizontalLabelAlignment::Left)
          label_cell_rect.x = port_anchor.x +
            end_label_preprocessor_max_edge_thickness(port) +
            edge_label_spacing
        }
      }
    }
    PortSide::West => {
      label_cell.set_horizontal_alignment(HorizontalLabelAlignment::Right)
      label_cell_rect.x = -node_margin.left -
        edge_label_spacing -
        label_cell_rect.width

      match label_cell.get_label_side() {
        LabelSide::Above => {
          label_cell.set_vertical_alignment(VerticalLabelAlignment::Bottom)
          label_cell_rect.y = port_anchor.y -
            end_label_preprocessor_max_edge_thickness(port) -
            edge_label_spacing -
            label_cell_rect.height
        }
        _ => {
          label_cell.set_vertical_alignment(VerticalLabelAlignment::Top)
          label_cell_rect.y = port_anchor.y +
            end_label_preprocessor_max_edge_thickness(port) +
            edge_label_spacing
        }
      }
    }
    _ => ()
  }
}

///|
fn end_label_preprocessor_port_side_to_overlap_removal_direction(
  port_side : PortSide,
) -> Direction {
  match port_side {
    PortSide::North => Direction::Upward
    PortSide::South => Direction::Downward
    PortSide::East => Direction::Rightward
    PortSide::West => Direction::Leftward
    _ => Direction::Undefined
  }
}

///|
fn end_label_preprocessor_calculate_overlap_start_coordinate(
  node : LNode,
  port_side : PortSide,
  edge_label_spacing : Double,
) -> Double {
  let node_size = node.get_size()
  let node_margin = node.get_margin()

  match port_side {
    PortSide::North => -node_margin.top - edge_label_spacing
    PortSide::South => node_size.y + node_margin.bottom + edge_label_spacing
    PortSide::East => node_size.x + node_margin.right + edge_label_spacing
    PortSide::West => -node_margin.left - edge_label_spacing
    _ => 0.0
  }
}

///|
fn end_label_preprocessor_remove_label_overlaps(
  node : LNode,
  port_label_cells : Array[EndLabelCell?],
  port_side : PortSide,
  label_label_spacing : Double,
  edge_label_spacing : Double,
) -> Unit {
  let overlap_remover = create_rectangle_strip_overlap_remover_for_direction(
      end_label_preprocessor_port_side_to_overlap_removal_direction(port_side),
    )
    .with_gap(label_label_spacing, label_label_spacing)
    .with_start_coordinate(
      end_label_preprocessor_calculate_overlap_start_coordinate(
        node, port_side, edge_label_spacing,
      ),
    )

  for port in node.get_ports_by_side(port_side) {
    let port_id = port.get_id()
    if port_id < 0 || port_id >= port_label_cells.length() {
      continue
    }

    match port_label_cells[port_id] {
      Some(label_cell) => {
        let rect = label_cell.get_cell_rectangle()
        if rect.height > 0.0 && rect.width > 0.0 {
          ignore(overlap_remover.add_rectangle(rect))
        }
      }
      None => ()
    }
  }

  ignore(overlap_remover.remove_overlaps())
}

///|
fn end_label_preprocessor_place_labels(
  node : LNode,
  port_label_cells : Array[EndLabelCell?],
  label_label_spacing : Double,
  edge_label_spacing : Double,
  vertical_layout : Bool,
) -> Unit {
  for port in node.get_ports() {
    let port_id = port.get_id()
    if port_id < 0 || port_id >= port_label_cells.length() {
      continue
    }

    match port_label_cells[port_id] {
      Some(label_cell) =>
        end_label_preprocessor_place_labels_for_port(
          port, label_cell, edge_label_spacing,
        )
      None => ()
    }
  }

  if vertical_layout {
    end_label_preprocessor_remove_label_overlaps(
      node,
      port_label_cells,
      PortSide::East,
      2.0 * label_label_spacing,
      edge_label_spacing,
    )
    end_label_preprocessor_remove_label_overlaps(
      node,
      port_label_cells,
      PortSide::West,
      2.0 * label_label_spacing,
      edge_label_spacing,
    )
  } else {
    end_label_preprocessor_remove_label_overlaps(
      node,
      port_label_cells,
      PortSide::North,
      2.0 * label_label_spacing,
      edge_label_spacing,
    )
    end_label_preprocessor_remove_label_overlaps(
      node,
      port_label_cells,
      PortSide::South,
      2.0 * label_label_spacing,
      edge_label_spacing,
    )
  }
}

///|
fn end_label_preprocessor_update_node_margins(
  node : LNode,
  label_cells : Array[EndLabelCell?],
) -> Unit {
  let node_margin = node.get_margin()
  let node_size = node.get_size()
  let node_margin_rectangle = new_elk_rectangle_xywh(
    -node_margin.left,
    -node_margin.top,
    node_margin.left + node_size.x + node_margin.right,
    node_margin.top + node_size.y + node_margin.bottom,
  )

  for label_cell in label_cells {
    match label_cell {
      Some(cell) => node_margin_rectangle.union(cell.get_cell_rectangle())
      None => ()
    }
  }

  node_margin.left = -node_margin_rectangle.x
  node_margin.top = -node_margin_rectangle.y
  node_margin.right = node_margin_rectangle.width -
    node_margin.left -
    node_size.x
  node_margin.bottom = node_margin_rectangle.height -
    node_margin.top -
    node_size.y
}

///|
fn end_label_preprocessor_process_node(
  node : LNode,
  edge_label_spacing : Double,
  label_label_spacing : Double,
  vertical_layout : Bool,
) -> Unit {
  let port_count = node.get_ports().length()
  let port_label_cells : Array[EndLabelCell?] = []

  for _ in 0..<port_count {
    port_label_cells.push(None)
  }

  for port_index in 0..<port_count {
    let port = node.get_ports()[port_index]
    port.set_id(port_index)
    port_label_cells[port_index] = end_label_preprocessor_create_configured_label_cell(
      end_label_preprocessor_gather_labels(port),
      label_label_spacing,
      vertical_layout,
    )
  }

  end_label_preprocessor_place_labels(
    node, port_label_cells, label_label_spacing, edge_label_spacing, vertical_layout,
  )

  let stored_cells = []
  for index in 0..<port_label_cells.length() {
    match port_label_cells[index] {
      Some(label_cell) => stored_cells.push(label_cell)
      None => ()
    }
  }

  if !stored_cells.is_empty() {
    node.set_property_end_label_cell_array(
      internal_properties_end_labels, stored_cells,
    )
    end_label_preprocessor_update_node_margins(node, port_label_cells)
  }
}

///|
fn end_label_preprocessor_process(
  layered_graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("End label pre-processing", 1.0))

  let edge_label_spacing = layered_graph.get_property_double(spacing_edge_label)
  let label_label_spacing = layered_graph.get_property_double(
    spacing_label_label,
  )
  let vertical_layout = Direction::is_vertical(
    end_label_preprocessor_parse_direction(
      layered_graph.get_property_string(direction),
    ),
  )

  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      end_label_preprocessor_process_node(
        node, edge_label_spacing, label_label_spacing, vertical_layout,
      )
    }
  }

  monitor.done()
}

///|
pub fn new_end_label_preprocessor_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(end_label_preprocessor_process)
}
