///|
fn label_dummy_remover_parse_direction(value : String) -> @core.Direction {
  match value {
    "RIGHT" => @core.Direction::Rightward
    "LEFT" => @core.Direction::Leftward
    "DOWN" => @core.Direction::Downward
    "UP" => @core.Direction::Upward
    _ => @core.Direction::Undefined
  }
}

///|
fn label_dummy_remover_parse_edge_routing(value : String) -> @core.EdgeRouting {
  match value {
    "POLYLINE" => @core.EdgeRouting::Polyline
    "SPLINES" => @core.EdgeRouting::Splines
    "ORTHOGONAL" => @core.EdgeRouting::Orthogonal
    _ => @core.EdgeRouting::RoutingUndefined
  }
}

///|
fn label_dummy_remover_direction_is_vertical(
  direction : @core.Direction,
) -> Bool {
  match direction {
    @core.Direction::Upward => true
    @core.Direction::Downward => true
    _ => false
  }
}

///|
fn label_dummy_remover_direction_is_up(direction : @core.Direction) -> Bool {
  match direction {
    @core.Direction::Upward => true
    _ => false
  }
}

///|
fn label_dummy_remover_node_type_is_label(node_type : NodeType) -> Bool {
  match node_type {
    NodeType::LabelNode => true
    _ => false
  }
}

///|
fn label_dummy_remover_label_side_is_below(side : @core.LabelSide) -> Bool {
  match side {
    @core.LabelSide::Below => true
    _ => false
  }
}

///|
fn label_dummy_remover_edge_routing_is_polyline(
  edge_routing_value : String,
) -> Bool {
  match label_dummy_remover_parse_edge_routing(edge_routing_value) {
    @core.EdgeRouting::Polyline => true
    _ => false
  }
}

///|
fn label_dummy_remover_require_origin_edge(node : LNode) -> LEdge {
  match node.get_property_l_edge(internal_properties_origin_l_edge) {
    Some(value) => value
    None => {
      @core.layout_runtime_report_unsupported_configuration(
        "label dummy has no origin edge",
      )
      new_l_edge()
    }
  }
}

///|
fn label_dummy_remover_reversed_labels(labels : Array[LLabel]) -> Array[LLabel] {
  let reversed = []
  let mut index = labels.length()
  while index > 0 {
    index = index - 1
    reversed.push(labels[index])
  }
  reversed
}

///|
fn label_dummy_remover_place_labels_for_horizontal_layout(
  labels : Array[LLabel],
  label_pos : @core.KVector,
  label_spacing : Double,
  label_space : @core.KVector,
) -> Unit {
  for label in labels {
    label.get_position().x = label_pos.x +
      (label_space.x - label.get_size().x) / 2.0
    label.get_position().y = label_pos.y
    label_pos.y = label_pos.y + label.get_size().y + label_spacing
  }
}

///|
fn label_dummy_remover_place_labels_for_vertical_layout(
  labels : Array[LLabel],
  label_pos : @core.KVector,
  label_spacing : Double,
  label_space : @core.KVector,
  left_aligned : Bool,
  layout_direction : @core.Direction,
) -> Unit {
  let mut inline = !labels.is_empty()
  for label in labels {
    if !label.get_property_bool(@core.edge_labels_inline) {
      inline = false
    }
  }

  let effective_labels = if label_dummy_remover_direction_is_up(
      layout_direction,
    ) {
    label_dummy_remover_reversed_labels(labels)
  } else {
    labels
  }

  for label in effective_labels {
    label.get_position().x = label_pos.x

    if inline {
      label.get_position().y = label_pos.y +
        (label_space.y - label.get_size().y) / 2.0
    } else if left_aligned {
      label.get_position().y = label_pos.y
    } else {
      label.get_position().y = label_pos.y + label_space.y - label.get_size().y
    }

    label_pos.x = label_pos.x + label.get_size().x + label_spacing
  }
}

///|
fn label_dummy_remover_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Label dummy removal", 1.0))

  let edge_label_spacing = layered_graph.get_property_double(
    @core.spacing_edge_label,
  )
  let label_label_spacing = layered_graph.get_property_double(
    @core.spacing_label_label,
  )
  let layout_direction = label_dummy_remover_parse_direction(
    layered_graph.get_property_string(@core.direction),
  )
  let add_unnecessary_bendpoints = label_dummy_remover_edge_routing_is_polyline(
    layered_graph.get_property_string(@core.edge_routing),
  )

  for layer in layered_graph.get_layers() {
    let layer_nodes = layer.get_nodes()
    let mut node_index = 0

    while node_index < layer_nodes.length() {
      let node = layer_nodes[node_index]
      if !label_dummy_remover_node_type_is_label(node.get_type()) {
        node_index = node_index + 1
        continue
      }

      let origin_edge = label_dummy_remover_require_origin_edge(node)
      let thickness = origin_edge.get_property_double(@core.edge_thickness)
      let labels_below_edge = label_dummy_remover_label_side_is_below(
        node.get_property_label_side(internal_properties_label_side),
      )

      let curr_label_pos = @core.new_kvector_copy(node.get_position())
      if labels_below_edge {
        curr_label_pos.y = curr_label_pos.y + thickness + edge_label_spacing
      }

      let label_space = @core.new_kvector_xy(
        node.get_size().x,
        node.get_size().y - thickness - edge_label_spacing,
      )

      let represented_labels = node.get_property_l_label_array(
        internal_properties_represented_labels,
      )
      if label_dummy_remover_direction_is_vertical(layout_direction) {
        label_dummy_remover_place_labels_for_vertical_layout(
          represented_labels, curr_label_pos, label_label_spacing, label_space, labels_below_edge,
          layout_direction,
        )
      } else {
        label_dummy_remover_place_labels_for_horizontal_layout(
          represented_labels, curr_label_pos, label_label_spacing, label_space,
        )
      }

      for label in represented_labels {
        origin_edge.get_labels().push(label)
      }

      long_edge_joiner_join_at(node, add_unnecessary_bendpoints)
      ignore(layer_nodes.remove(node_index))
    }
  }

  monitor.done()
}

///|
pub fn new_label_dummy_remover_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(label_dummy_remover_process)
}
