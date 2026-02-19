///|
fn label_dummy_inserter_parse_direction(value : String) -> @core.Direction {
  match value {
    "RIGHT" => @core.Direction::Rightward
    "LEFT" => @core.Direction::Leftward
    "DOWN" => @core.Direction::Downward
    "UP" => @core.Direction::Upward
    _ => @core.Direction::Undefined
  }
}

///|
fn label_dummy_inserter_require_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source")
  }
}

///|
fn label_dummy_inserter_require_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target")
  }
}

///|
fn label_dummy_inserter_require_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(value) => value
    None => abort("port has no owner node")
  }
}

///|
fn label_dummy_inserter_edge_needs_to_be_processed(edge : LEdge) -> Bool {
  let source_node = label_dummy_inserter_require_node(
    label_dummy_inserter_require_source(edge),
  )
  let target_node = label_dummy_inserter_require_node(
    label_dummy_inserter_require_target(edge),
  )
  if lnode_internal_handle(source_node) == lnode_internal_handle(target_node) {
    return false
  }

  for label in edge.get_labels() {
    if label.get_property_string(@core.edge_labels_placement) == "CENTER" {
      return true
    }
  }
  false
}

///|
fn label_dummy_inserter_retrieve_thickness(edge : LEdge) -> Double {
  let mut thickness = edge.get_property_double(@core.edge_thickness)
  if thickness < 0.0 {
    thickness = 0.0
    edge.set_property_double(@core.edge_thickness, thickness)
  }
  thickness
}

///|
fn label_dummy_inserter_create_label_dummy(
  layered_graph : LGraph,
  edge : LEdge,
  thickness : Double,
) -> LNode {
  let dummy_node = new_l_node(graph=Some(layered_graph))
  dummy_node.set_type(NodeType::LabelNode)
  dummy_node.set_property_l_edge(internal_properties_origin_l_edge, Some(edge))
  dummy_node.set_property_l_label_array(
    internal_properties_represented_labels,
    [],
  )
  dummy_node.set_property_string(@core.port_constraints, "FIXED_POS")
  dummy_node.set_property_l_port(
    internal_properties_long_edge_source,
    edge.get_source(),
  )
  dummy_node.set_property_l_port(
    internal_properties_long_edge_target,
    edge.get_target(),
  )

  ignore(long_edge_splitter_split_edge(edge, dummy_node))

  let port_pos = (thickness / 2.0).floor()
  for dummy_port in dummy_node.get_ports() {
    dummy_port.get_position().y = port_pos
  }

  dummy_node
}

///|
fn label_dummy_inserter_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Label dummy insertions", 1.0))

  let new_dummy_nodes = []

  let edge_label_spacing = layered_graph.get_property_double(@core.spacing_edge_label)
  let label_label_spacing = layered_graph.get_property_double(
    @core.spacing_label_label,
  )
  let layout_direction = label_dummy_inserter_parse_direction(
    layered_graph.get_property_string(@core.direction),
  )

  for node in layered_graph.get_layerless_nodes() {
    for edge in node.get_outgoing_edges() {
      if !label_dummy_inserter_edge_needs_to_be_processed(edge) {
        continue
      }

      let thickness = label_dummy_inserter_retrieve_thickness(edge)
      let represented_labels : Array[LLabel] = []
      let dummy_node = label_dummy_inserter_create_label_dummy(
        layered_graph, edge, thickness,
      )
      new_dummy_nodes.push(dummy_node)

      let dummy_size = dummy_node.get_size()
      let labels = edge.get_labels()
      let mut label_index = 0
      while label_index < labels.length() {
        let label = labels[label_index]
        if label.get_property_string(@core.edge_labels_placement) == "CENTER" {
          if layout_direction.is_vertical() {
            dummy_size.x = dummy_size.x +
              label.get_size().x +
              label_label_spacing
            if label.get_size().y > dummy_size.y {
              dummy_size.y = label.get_size().y
            }
          } else {
            if label.get_size().x > dummy_size.x {
              dummy_size.x = label.get_size().x
            }
            dummy_size.y = dummy_size.y +
              label.get_size().y +
              label_label_spacing
          }

          represented_labels.push(label)
          ignore(labels.remove(label_index))
        } else {
          label_index = label_index + 1
        }
      }

      if layout_direction.is_vertical() {
        dummy_size.x = dummy_size.x - label_label_spacing
        dummy_size.y = dummy_size.y + edge_label_spacing + thickness
      } else {
        dummy_size.y = dummy_size.y +
          edge_label_spacing -
          label_label_spacing +
          thickness
      }

      // LNode currently stores label arrays by copy, so write back after we populate it.
      dummy_node.set_property_l_label_array(
        internal_properties_represented_labels, represented_labels,
      )
    }
  }

  for dummy_node in new_dummy_nodes {
    layered_graph.get_layerless_nodes().push(dummy_node)
  }

  monitor.done()
}

///|
pub fn new_label_dummy_inserter_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(label_dummy_inserter_process)
}
