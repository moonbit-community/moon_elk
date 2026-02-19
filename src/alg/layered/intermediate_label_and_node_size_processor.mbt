///|
fn label_and_node_size_node_type_is_external_port(node_type : NodeType) -> Bool {
  match node_type {
    NodeType::ExternalPort => true
    _ => false
  }
}

///|
fn label_and_node_size_parse_port_label_placement(
  values : Array[String],
) -> Array[@core.PortLabelPlacement] {
  let parsed : Array[@core.PortLabelPlacement] = []
  for value in values {
    for placement in @core.port_label_placement_values() {
      if @core.port_label_placement_to_string(placement) == value {
        parsed.push(placement)
      }
    }
  }
  parsed
}

///|
fn label_and_node_size_contains_port_label_placement(
  values : Array[@core.PortLabelPlacement],
  expected : @core.PortLabelPlacement,
) -> Bool {
  let expected_name = @core.port_label_placement_to_string(expected)
  for value in values {
    if @core.port_label_placement_to_string(value) == expected_name {
      return true
    }
  }
  false
}

///|
fn label_and_node_size_graph_has_external_ports(layered_graph : LGraph) -> Bool {
  for
    property in layered_graph.get_property_graph_properties_array(
      internal_properties_graph_properties,
    ) {
    if graph_properties_to_string(property) == "EXTERNAL_PORTS" {
      return true
    }
  }
  false
}

///|
fn label_and_node_size_label_next_to_port(
  dummy_port : LPort,
  inside_labels : Bool,
  place_next_to_port_if_possible : Bool,
) -> Bool {
  if !place_next_to_port_if_possible {
    return false
  }
  if inside_labels {
    dummy_port.get_incoming_edges().is_empty() &&
    dummy_port.get_outgoing_edges().is_empty()
  } else {
    !dummy_port.is_connected_to_external_nodes()
  }
}

///|
fn label_and_node_size_compute_port_label_box(
  dummy_port : LPort,
  label_label_spacing : Double,
) -> @core.ElkRectangle? {
  if dummy_port.get_labels().is_empty() {
    return None
  }

  let mut width = 0.0
  let mut height = 0.0
  for label in dummy_port.get_labels() {
    let label_size = label.get_size()
    if label_size.x > width {
      width = label_size.x
    }
    height += label_size.y
  }

  height += (dummy_port.get_labels().length() - 1).to_double() *
    label_label_spacing
  Some(@core.new_elk_rectangle_xywh(0.0, 0.0, width, height))
}

///|
fn label_and_node_size_place_external_port_dummy_labels(
  dummy : LNode,
  graph_port_label_placement : Array[@core.PortLabelPlacement],
  place_next_to_port_if_possible : Bool,
  treat_as_group : Bool,
) -> Unit {
  let label_port_spacing_horizontal = dummy.get_property_double(
    @core.spacing_label_port_horizontal,
  )
  let label_port_spacing_vertical = dummy.get_property_double(
    @core.spacing_label_port_vertical,
  )
  let label_label_spacing = dummy.get_property_double(@core.spacing_label_label)

  let ports = dummy.get_ports()
  if ports.is_empty() {
    return
  }
  let dummy_port = ports[0]
  let dummy_port_pos = dummy_port.get_position()
  let dummy_size = dummy.get_size()

  let port_label_box = match
    label_and_node_size_compute_port_label_box(dummy_port, label_label_spacing) {
    Some(value) => value
    None => return
  }

  if label_and_node_size_contains_port_label_placement(
      graph_port_label_placement,
      @core.PortLabelPlacement::Inside,
    ) {
    match dummy.get_property_port_side(internal_properties_ext_port_side) {
      @core.PortSide::North => {
        port_label_box.x = (dummy_size.x - port_label_box.width) / 2.0 -
          dummy_port_pos.x
        port_label_box.y = label_port_spacing_vertical
      }
      @core.PortSide::South => {
        port_label_box.x = (dummy_size.x - port_label_box.width) / 2.0 -
          dummy_port_pos.x
        port_label_box.y = -label_port_spacing_vertical - port_label_box.height
      }
      @core.PortSide::East => {
        if label_and_node_size_label_next_to_port(
            dummy_port, true, place_next_to_port_if_possible,
          ) {
          let label_height = if treat_as_group {
            port_label_box.height
          } else {
            dummy_port.get_labels()[0].get_size().y
          }
          port_label_box.y = (dummy_size.y - label_height) / 2.0 -
            dummy_port_pos.y
        } else {
          port_label_box.y = dummy_size.y +
            label_port_spacing_vertical -
            dummy_port_pos.y
        }
        port_label_box.x = -label_port_spacing_horizontal - port_label_box.width
      }
      @core.PortSide::West => {
        if label_and_node_size_label_next_to_port(
            dummy_port, true, place_next_to_port_if_possible,
          ) {
          let label_height = if treat_as_group {
            port_label_box.height
          } else {
            dummy_port.get_labels()[0].get_size().y
          }
          port_label_box.y = (dummy_size.y - label_height) / 2.0 -
            dummy_port_pos.y
        } else {
          port_label_box.y = dummy_size.y +
            label_port_spacing_vertical -
            dummy_port_pos.y
        }
        port_label_box.x = label_port_spacing_horizontal
      }
      _ => ()
    }
  } else if label_and_node_size_contains_port_label_placement(
      graph_port_label_placement,
      @core.PortLabelPlacement::Outside,
    ) {
    match dummy.get_property_port_side(internal_properties_ext_port_side) {
      @core.PortSide::North =>
        port_label_box.x = dummy_port_pos.x + label_port_spacing_horizontal
      @core.PortSide::South =>
        port_label_box.x = dummy_port_pos.x + label_port_spacing_horizontal
      @core.PortSide::East =>
        if label_and_node_size_label_next_to_port(
            dummy_port, false, place_next_to_port_if_possible,
          ) {
          let label_height = if treat_as_group {
            port_label_box.height
          } else {
            dummy_port.get_labels()[0].get_size().y
          }
          port_label_box.y = (dummy_size.y - label_height) / 2.0 -
            dummy_port_pos.y
        } else {
          port_label_box.y = dummy_port_pos.y + label_port_spacing_vertical
        }
      @core.PortSide::West =>
        if label_and_node_size_label_next_to_port(
            dummy_port, false, place_next_to_port_if_possible,
          ) {
          let label_height = if treat_as_group {
            port_label_box.height
          } else {
            dummy_port.get_labels()[0].get_size().y
          }
          port_label_box.y = (dummy_size.y - label_height) / 2.0 -
            dummy_port_pos.y
        } else {
          port_label_box.y = dummy_port_pos.y + label_port_spacing_vertical
        }
      _ => ()
    }
  }

  let mut current_y = port_label_box.y
  for label in dummy_port.get_labels() {
    let label_pos = label.get_position()
    label_pos.x = port_label_box.x
    label_pos.y = current_y
    current_y += label.get_size().y + label_label_spacing
  }
}

///|
fn label_and_node_size_processor_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(
    monitor.begin(
      "@common.Node and Port Label Placement and @common.Node Sizing", 1.0,
    ),
  )

  node_dimension_calculation_calculate_label_and_node_sizes_for_layered_graph(
    layered_graph,
  )

  if label_and_node_size_graph_has_external_ports(layered_graph) {
    let port_label_placement = label_and_node_size_parse_port_label_placement(
      layered_graph.get_property_string_array(@core.port_labels_placement),
    )
    let place_next_to_port_if_possible = label_and_node_size_contains_port_label_placement(
      port_label_placement,
      @core.PortLabelPlacement::NextToPortIfPossible,
    )
    let treat_as_group = layered_graph.get_property_bool(
      @core.port_labels_treat_as_group,
    )

    for layer in layered_graph.get_layers() {
      for node in layer.get_nodes() {
        if label_and_node_size_node_type_is_external_port(node.get_type()) {
          label_and_node_size_place_external_port_dummy_labels(
            node, port_label_placement, place_next_to_port_if_possible, treat_as_group,
          )
        }
      }
    }
  }

  monitor.done()
}

///|
pub fn new_label_and_node_size_processor_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(label_and_node_size_processor_process)
}
