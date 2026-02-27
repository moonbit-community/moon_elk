///|
priv suberror LongEdgeSplitterException {
  UnsupportedGraphException(String)
} derive(Show, ToJson)

///|
fn[T] long_edge_splitter_raise_unsupported_graph(
  message : String,
) -> T raise LongEdgeSplitterException {
  raise LongEdgeSplitterException::UnsupportedGraphException(message)
}

///|
fn long_edge_splitter_layer_equals(left : Layer, right : Layer) -> Bool {
  layer_internal_handle(left) == layer_internal_handle(right)
}

///|
fn long_edge_splitter_node_type_equals(
  left : NodeType,
  right : NodeType,
) -> Bool {
  match (left, right) {
    (NodeType::Normal, NodeType::Normal) => true
    (NodeType::LongEdge, NodeType::LongEdge) => true
    (NodeType::ExternalPort, NodeType::ExternalPort) => true
    (NodeType::NorthSouthPort, NodeType::NorthSouthPort) => true
    (NodeType::LabelNode, NodeType::LabelNode) => true
    (NodeType::BreakingPoint, NodeType::BreakingPoint) => true
    (NodeType::Placeholder, NodeType::Placeholder) => true
    (NodeType::NonshiftingPlaceholder, NodeType::NonshiftingPlaceholder) => true
    _ => false
  }
}

///|
fn long_edge_splitter_require_source(
  edge : LEdge,
) -> LPort raise LongEdgeSplitterException {
  match edge.get_source() {
    Some(value) => value
    None => long_edge_splitter_raise_unsupported_graph("edge has no source")
  }
}

///|
fn long_edge_splitter_require_target(
  edge : LEdge,
) -> LPort raise LongEdgeSplitterException {
  match edge.get_target() {
    Some(value) => value
    None => long_edge_splitter_raise_unsupported_graph("edge has no target")
  }
}

///|
fn long_edge_splitter_require_node(
  port : LPort,
) -> LNode raise LongEdgeSplitterException {
  match port.get_node() {
    Some(value) => value
    None => long_edge_splitter_raise_unsupported_graph("port has no owner node")
  }
}

///|
fn long_edge_splitter_require_layer(
  node : LNode,
) -> Layer raise LongEdgeSplitterException {
  match node.get_layer() {
    Some(value) => value
    None => long_edge_splitter_raise_unsupported_graph("node has no layer")
  }
}

///|
fn long_edge_splitter_move_head_labels(
  old_edge : LEdge,
  new_edge : LEdge,
) -> Unit {
  let labels = old_edge.get_labels()
  let mut index = 0
  while index < labels.length() {
    let label = labels[index]
    if label.get_property_string(@core.edge_labels_placement) == "HEAD" {
      let moved = labels.remove(index)
      new_edge.get_labels().push(moved)
      if !moved.has_property_l_edge(internal_properties_end_label_edge) {
        moved.set_property_l_edge(
          internal_properties_end_label_edge,
          Some(old_edge),
        )
      }
    } else {
      index = index + 1
    }
  }
}

///|
fn long_edge_splitter_set_dummy_node_properties(
  dummy_node : LNode,
  in_edge : LEdge,
  out_edge : LEdge,
) -> Unit raise LongEdgeSplitterException {
  let in_edge_source_node = long_edge_splitter_require_node(
    long_edge_splitter_require_source(in_edge),
  )
  let out_edge_target_node = long_edge_splitter_require_node(
    long_edge_splitter_require_target(out_edge),
  )

  if long_edge_splitter_node_type_equals(
      in_edge_source_node.get_type(),
      NodeType::LongEdge,
    ) {
    dummy_node.set_property_l_port(
      internal_properties_long_edge_source,
      in_edge_source_node.get_property_l_port(
        internal_properties_long_edge_source,
      ),
    )
    dummy_node.set_property_l_port(
      internal_properties_long_edge_target,
      in_edge_source_node.get_property_l_port(
        internal_properties_long_edge_target,
      ),
    )
    dummy_node.set_property_bool(
      internal_properties_long_edge_has_label_dummies,
      in_edge_source_node.get_property_bool(
        internal_properties_long_edge_has_label_dummies,
      ),
    )
    return
  }

  if long_edge_splitter_node_type_equals(
      in_edge_source_node.get_type(),
      NodeType::LabelNode,
    ) {
    dummy_node.set_property_l_port(
      internal_properties_long_edge_source,
      in_edge_source_node.get_property_l_port(
        internal_properties_long_edge_source,
      ),
    )
    dummy_node.set_property_l_port(
      internal_properties_long_edge_target,
      in_edge_source_node.get_property_l_port(
        internal_properties_long_edge_target,
      ),
    )
    dummy_node.set_property_bool(
      internal_properties_long_edge_has_label_dummies, true,
    )
    return
  }

  if long_edge_splitter_node_type_equals(
      out_edge_target_node.get_type(),
      NodeType::LabelNode,
    ) {
    dummy_node.set_property_l_port(
      internal_properties_long_edge_source,
      out_edge_target_node.get_property_l_port(
        internal_properties_long_edge_source,
      ),
    )
    dummy_node.set_property_l_port(
      internal_properties_long_edge_target,
      out_edge_target_node.get_property_l_port(
        internal_properties_long_edge_target,
      ),
    )
    dummy_node.set_property_bool(
      internal_properties_long_edge_has_label_dummies, true,
    )
    return
  }

  dummy_node.set_property_l_port(
    internal_properties_long_edge_source,
    Some(long_edge_splitter_require_source(in_edge)),
  )
  dummy_node.set_property_l_port(
    internal_properties_long_edge_target,
    Some(long_edge_splitter_require_target(out_edge)),
  )
}

///|
fn long_edge_splitter_create_dummy_node(
  layered_graph : LGraph,
  target_layer : Layer,
  edge_to_split : LEdge,
) -> LNode {
  let dummy_node = new_l_node(graph=Some(layered_graph))
  dummy_node.set_type(NodeType::LongEdge)
  dummy_node.set_property_l_edge(
    internal_properties_origin_l_edge,
    Some(edge_to_split),
  )
  dummy_node.set_property_string(@core.port_constraints, "FIXED_POS")
  dummy_node.set_layer(Some(target_layer))
  dummy_node
}

///|
pub fn long_edge_splitter_split_edge(edge : LEdge, dummy_node : LNode) -> LEdge {
  try {
    let old_edge_target = long_edge_splitter_require_target(edge)

    let mut thickness = edge.get_property_double(@core.edge_thickness)
    if thickness < 0.0 {
      thickness = 0.0
      edge.set_property_double(@core.edge_thickness, thickness)
    }
    dummy_node.get_size().y = thickness
    let port_pos = (thickness / 2.0).floor()

    let dummy_input = new_l_port()
    dummy_input.set_side(@core.PortSide::West)
    dummy_input.set_node(Some(dummy_node))
    dummy_input.get_position().y = port_pos

    let dummy_output = new_l_port()
    dummy_output.set_side(@core.PortSide::East)
    dummy_output.set_node(Some(dummy_node))
    dummy_output.get_position().y = port_pos

    edge.set_target(Some(dummy_input))

    let dummy_edge = new_l_edge()
    dummy_edge.copy_properties(edge)
    dummy_edge.set_property_kvector_chain(
      layered_options_junction_points,
      @core.new_kvector_chain(),
    )
    dummy_edge.set_source(Some(dummy_output))
    dummy_edge.set_target(Some(old_edge_target))

    long_edge_splitter_set_dummy_node_properties(dummy_node, edge, dummy_edge)
    long_edge_splitter_move_head_labels(edge, dummy_edge)

    dummy_edge
  } catch {
    LongEdgeSplitterException::UnsupportedGraphException(message) => {
      @core.layout_runtime_report_unsupported_configuration(message)
      edge
    }
  } noraise {
    value => value
  }
}

///|
fn long_edge_splitter_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Edge splitting", 1.0))

  let layers = layered_graph.get_layers()
  if layers.length() <= 2 {
    monitor.done()
    return
  }

  try {
    let mut next_layer = layers[0]
    let mut index = 1

    while index < layers.length() {
      let layer = next_layer
      next_layer = layers[index]
      index = index + 1

      for node in layer.get_nodes().copy() {
        for port in node.get_ports().copy() {
          for edge in port.get_outgoing_edges().copy() {
            let target_port = long_edge_splitter_require_target(edge)
            let target_node = long_edge_splitter_require_node(target_port)
            let target_layer = long_edge_splitter_require_layer(target_node)

            if !long_edge_splitter_layer_equals(target_layer, layer) &&
              !long_edge_splitter_layer_equals(target_layer, next_layer) {
              ignore(
                long_edge_splitter_split_edge(
                  edge,
                  long_edge_splitter_create_dummy_node(
                    layered_graph, next_layer, edge,
                  ),
                ),
              )
            }
          }
        }
      }
    }
  } catch {
    LongEdgeSplitterException::UnsupportedGraphException(message) => {
      @core.layout_runtime_report_unsupported_configuration(message)
      monitor.done()
      return
    }
  } noraise {
    _ => ()
  }

  monitor.done()
}

///|
pub fn new_long_edge_splitter_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(long_edge_splitter_process)
}
