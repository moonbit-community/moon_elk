///|
fn label_management_processor_parse_direction(
  value : String,
) -> @core.Direction {
  match value {
    "RIGHT" => @core.Direction::Rightward
    "LEFT" => @core.Direction::Leftward
    "DOWN" => @core.Direction::Downward
    "UP" => @core.Direction::Upward
    _ => @core.Direction::Undefined
  }
}

///|
fn label_management_processor_node_type_is_normal(node_type : NodeType) -> Bool {
  match node_type {
    NodeType::Normal => true
    _ => false
  }
}

///|
fn label_management_processor_node_type_is_label_node(
  node_type : NodeType,
) -> Bool {
  match node_type {
    NodeType::LabelNode => true
    _ => false
  }
}

///|
fn label_management_processor_require_first_connected_edge(
  node : LNode,
) -> LEdge {
  let connected_edges = node.get_connected_edges()
  if connected_edges.is_empty() {
    @core.layout_runtime_report_unsupported_configuration(
      "label dummy node has no connected edge",
    )
    return new_l_edge()
  }
  connected_edges[0]
}

///|
fn label_management_processor_find_max_non_dummy_node_width(
  layer : Layer,
  respect_node_margins : Bool,
) -> Double {
  if label_management_processor_parse_direction(
      layer.get_graph().get_property_string(@core.direction),
    ).is_vertical() {
    return 0.0
  }

  let mut max_width = 0.0
  for node in layer.get_nodes() {
    if !label_management_processor_node_type_is_normal(node.get_type()) {
      continue
    }

    let mut width = node.get_size().x
    if respect_node_margins {
      width = width + node.get_margin().left + node.get_margin().right
    }
    if width > max_width {
      max_width = width
    }
  }

  max_width
}

///|
let label_management_processor_min_width_port_labels = 20.0

///|
let label_management_processor_min_width_node_labels = 40.0

///|
pub let label_management_processor_min_width_edge_labels = 60.0

///|
pub struct LabelManagementProcessor {
  center_labels : Bool
}

///|
pub fn new_label_management_processor(
  center_labels : Bool,
) -> LabelManagementProcessor {
  { center_labels, }
}

///|
fn label_management_processor_manage_attached_comment_labels(
  label_manager : @core.ILabelManager,
  comment_nodes : Array[LNode],
  min_width_node_labels : Double,
  vertical_layout : Bool,
) -> Unit {
  for comment_node in comment_nodes {
    if comment_node.get_labels().is_empty() {
      continue
    }

    ignore(
      label_management_processor_do_manage_labels(
        label_manager,
        comment_node.get_labels(),
        min_width_node_labels,
        0.0,
        vertical_layout,
      ),
    )
  }
}

///|
fn label_management_processor_manage_non_center_labels(
  graph : LGraph,
  label_manager : @core.ILabelManager,
  label_label_spacing : Double,
) -> Unit {
  let vertical_layout = label_management_processor_parse_direction(
    graph.get_property_string(@core.direction),
  ).is_vertical()

  for layer in graph.get_layers() {
    for node in layer.get_nodes() {
      if label_management_processor_node_type_is_normal(node.get_type()) {
        ignore(
          label_management_processor_do_manage_labels(
            label_manager,
            node.get_labels(),
            label_management_processor_min_width_node_labels,
            label_label_spacing,
            vertical_layout,
          ),
        )

        for port in node.get_ports() {
          ignore(
            label_management_processor_do_manage_labels(
              label_manager,
              port.get_labels(),
              label_management_processor_min_width_port_labels,
              label_label_spacing,
              vertical_layout,
            ),
          )
        }

        if node.has_property_l_node_array(internal_properties_top_comments) {
          label_management_processor_manage_attached_comment_labels(
            label_manager,
            node.get_property_l_node_array(internal_properties_top_comments),
            label_management_processor_min_width_node_labels,
            vertical_layout,
          )
        }

        if node.has_property_l_node_array(internal_properties_bottom_comments) {
          label_management_processor_manage_attached_comment_labels(
            label_manager,
            node.get_property_l_node_array(internal_properties_bottom_comments),
            label_management_processor_min_width_node_labels,
            vertical_layout,
          )
        }
      }

      for edge in node.get_outgoing_edges() {
        ignore(
          label_management_processor_do_manage_labels(
            label_manager,
            edge.get_labels(),
            label_management_processor_min_width_edge_labels,
            0.0,
            vertical_layout,
          ),
        )
      }
    }
  }
}

///|
fn label_management_processor_manage_center_labels(
  graph : LGraph,
  label_manager : @core.ILabelManager,
  edge_label_spacing : Double,
  label_label_spacing : Double,
) -> Unit {
  let vertical_layout = label_management_processor_parse_direction(
    graph.get_property_string(@core.direction),
  ).is_vertical()

  for layer in graph.get_layers() {
    let max_width = label_management_processor_find_max_non_dummy_node_width(
      layer, false,
    )
    let target_width = if max_width >
      label_management_processor_min_width_edge_labels {
      max_width
    } else {
      label_management_processor_min_width_edge_labels
    }

    for node in layer.get_nodes() {
      if !label_management_processor_node_type_is_label_node(node.get_type()) {
        continue
      }

      let edge = label_management_processor_require_first_connected_edge(node)
      let edge_thickness_value = edge.get_property_double(@core.edge_thickness)
      let represented_labels = node.get_property_l_label_array(
        internal_properties_represented_labels,
      )
      let space_required_for_labels = label_management_processor_do_manage_labels(
        label_manager, represented_labels, target_width, label_label_spacing, vertical_layout,
      )

      node.get_size().x = space_required_for_labels.x
      node.get_size().y = space_required_for_labels.y +
        edge_thickness_value +
        edge_label_spacing
    }
  }
}

///|
pub fn label_management_processor_do_manage_labels(
  label_manager : @core.ILabelManager,
  labels : Array[LLabel],
  target_width : Double,
  label_label_spacing : Double,
  vertical_layout : Bool,
) -> @core.KVector {
  let required_label_space = @core.new_kvector()

  if labels.is_empty() {
    return required_label_space
  }

  for label in labels {
    let label_size = label.get_size()

    match label.get_origin_identifier() {
      Some(origin) =>
        match label_manager.manage_label_size(origin, target_width) {
          Some(new_size) =>
            if vertical_layout {
              label_size.x = new_size.y
              label_size.y = new_size.x
            } else {
              label_size.x = new_size.x
              label_size.y = new_size.y
            }
          None => ()
        }
      None => ()
    }

    if vertical_layout {
      required_label_space.x = required_label_space.x +
        label_label_spacing +
        label.get_size().x
      if label_size.y > required_label_space.y {
        required_label_space.y = label_size.y
      }
    } else {
      if label_size.x > required_label_space.x {
        required_label_space.x = label_size.x
      }
      required_label_space.y = required_label_space.y +
        label_label_spacing +
        label.get_size().y
    }
  }

  if vertical_layout {
    required_label_space.x = required_label_space.x - label_label_spacing
  } else {
    required_label_space.y = required_label_space.y - label_label_spacing
  }

  required_label_space
}

///|
pub fn LabelManagementProcessor::process(
  self : LabelManagementProcessor,
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Label management", 1.0))

  match
    layered_graph.get_property_i_label_manager(
      @core.label_management_options_label_manager,
    ) {
    Some(label_manager) => {
      let edge_label_spacing = layered_graph.get_property_double(
        @core.spacing_edge_label,
      )
      let label_label_spacing = layered_graph.get_property_double(
        @core.spacing_label_label,
      )

      if self.center_labels {
        label_management_processor_manage_center_labels(
          layered_graph, label_manager, edge_label_spacing, label_label_spacing,
        )
      } else {
        label_management_processor_manage_non_center_labels(
          layered_graph, label_manager, label_label_spacing,
        )
      }
    }
    None => ()
  }

  monitor.done()
}

///|
pub fn new_label_management_processor_layout_processor(
  center_labels : Bool,
) -> @core.ILayoutProcessor[LayeredPhases, LGraph] {
  let processor = new_label_management_processor(center_labels)
  @core.new_layout_processor((layered_graph, progress_monitor) => {
    processor.process(layered_graph, progress_monitor)
  })
}
