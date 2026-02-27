///|
priv suberror InvertedPortProcessorException {
  UnsupportedGraphException(String)
} derive(Show, ToJson)

///|
fn[T] inverted_port_processor_raise_unsupported_graph(
  message : String,
) -> T raise InvertedPortProcessorException {
  raise InvertedPortProcessorException::UnsupportedGraphException(message)
}

///|
fn inverted_port_processor_port_constraints_from_string(
  value : String,
) -> @core.PortConstraints {
  match value {
    "UNDEFINED" => @core.PortConstraints::Undefined
    "FREE" => @core.PortConstraints::Free
    "FIXED_SIDE" => @core.PortConstraints::FixedSide
    "FIXED_ORDER" => @core.PortConstraints::FixedOrder
    "FIXED_RATIO" => @core.PortConstraints::FixedRatio
    "FIXED_POS" => @core.PortConstraints::FixedPos
    _ => @core.PortConstraints::Undefined
  }
}

///|
fn inverted_port_processor_move_head_labels(
  edge : LEdge,
  dummy_edge : LEdge,
) -> Unit {
  let labels = edge.get_labels()
  let mut index = 0
  while index < labels.length() {
    let label = labels[index]
    if label.get_property_string(@core.edge_labels_placement) == "HEAD" {
      if !label.has_property_l_edge(internal_properties_end_label_edge) {
        label.set_property_l_edge(
          internal_properties_end_label_edge,
          Some(edge),
        )
      }
      let moved = labels.remove(index)
      dummy_edge.get_labels().push(moved)
    } else {
      index = index + 1
    }
  }
}

///|
fn inverted_port_processor_require_source(
  edge : LEdge,
) -> LPort raise InvertedPortProcessorException {
  match edge.get_source() {
    Some(value) => value
    None =>
      inverted_port_processor_raise_unsupported_graph("edge has no source")
  }
}

///|
fn inverted_port_processor_require_target(
  edge : LEdge,
) -> LPort raise InvertedPortProcessorException {
  match edge.get_target() {
    Some(value) => value
    None =>
      inverted_port_processor_raise_unsupported_graph("edge has no target")
  }
}

///|
fn inverted_port_processor_require_node(
  port : LPort,
) -> LNode raise InvertedPortProcessorException {
  match port.get_node() {
    Some(value) => value
    None =>
      inverted_port_processor_raise_unsupported_graph("port has no owner node")
  }
}

///|
fn inverted_port_processor_set_long_edge_source_and_target(
  long_edge_dummy : LNode,
  dummy_input_port : LPort,
  dummy_output_port : LPort,
  odd_port : LPort,
) -> Unit raise InvertedPortProcessorException {
  ignore(odd_port)
  let source_port = inverted_port_processor_require_source(
    dummy_input_port.get_incoming_edges()[0],
  )
  let source_node = inverted_port_processor_require_node(source_port)
  let source_node_type = source_node.get_type()

  let target_port = inverted_port_processor_require_target(
    dummy_output_port.get_outgoing_edges()[0],
  )
  let target_node = inverted_port_processor_require_node(target_port)
  let target_node_type = target_node.get_type()

  match source_node_type {
    NodeType::LongEdge =>
      long_edge_dummy.set_property_l_port(
        internal_properties_long_edge_source,
        source_node.get_property_l_port(internal_properties_long_edge_source),
      )
    _ =>
      long_edge_dummy.set_property_l_port(
        internal_properties_long_edge_source,
        Some(source_port),
      )
  }

  match target_node_type {
    NodeType::LongEdge =>
      long_edge_dummy.set_property_l_port(
        internal_properties_long_edge_target,
        target_node.get_property_l_port(internal_properties_long_edge_target),
      )
    _ =>
      long_edge_dummy.set_property_l_port(
        internal_properties_long_edge_target,
        Some(target_port),
      )
  }
}

///|
fn inverted_port_processor_create_east_port_side_dummies(
  layered_graph : LGraph,
  eastward_port : LPort,
  edge : LEdge,
  layer_node_list : Array[LNode],
) -> Unit raise InvertedPortProcessorException {
  if lport_internal_handle(inverted_port_processor_require_target(edge)) !=
    lport_internal_handle(eastward_port) {
    return
  }

  if lnode_internal_handle(
      inverted_port_processor_require_node(
        inverted_port_processor_require_source(edge),
      ),
    ) ==
    lnode_internal_handle(inverted_port_processor_require_node(eastward_port)) {
    return
  }

  let dummy = new_l_node(graph=Some(layered_graph))
  dummy.set_type(NodeType::LongEdge)
  dummy.set_property_string(@core.port_constraints, "FIXED_POS")
  layer_node_list.push(dummy)

  let dummy_input = new_l_port()
  dummy_input.set_node(Some(dummy))
  dummy_input.set_side(@core.PortSide::West)

  let dummy_output = new_l_port()
  dummy_output.set_node(Some(dummy))
  dummy_output.set_side(@core.PortSide::East)

  edge.set_target(Some(dummy_input))

  let dummy_edge = new_l_edge()
  dummy_edge.copy_properties(edge)
  dummy_edge.set_property_kvector_chain(
    layered_options_junction_points,
    @core.new_kvector_chain(),
  )
  dummy_edge.set_source(Some(dummy_output))
  dummy_edge.set_target(Some(eastward_port))

  inverted_port_processor_set_long_edge_source_and_target(
    dummy, dummy_input, dummy_output, eastward_port,
  )
  inverted_port_processor_move_head_labels(edge, dummy_edge)
}

///|
fn inverted_port_processor_create_west_port_side_dummies(
  layered_graph : LGraph,
  westward_port : LPort,
  edge : LEdge,
  layer_node_list : Array[LNode],
) -> Unit raise InvertedPortProcessorException {
  if lport_internal_handle(inverted_port_processor_require_source(edge)) !=
    lport_internal_handle(westward_port) {
    return
  }

  if lnode_internal_handle(
      inverted_port_processor_require_node(
        inverted_port_processor_require_target(edge),
      ),
    ) ==
    lnode_internal_handle(inverted_port_processor_require_node(westward_port)) {
    return
  }

  let dummy = new_l_node(graph=Some(layered_graph))
  dummy.set_type(NodeType::LongEdge)
  dummy.set_property_string(@core.port_constraints, "FIXED_POS")
  layer_node_list.push(dummy)

  let dummy_input = new_l_port()
  dummy_input.set_node(Some(dummy))
  dummy_input.set_side(@core.PortSide::West)

  let dummy_output = new_l_port()
  dummy_output.set_node(Some(dummy))
  dummy_output.set_side(@core.PortSide::East)

  let original_target = inverted_port_processor_require_target(edge)
  edge.set_target(Some(dummy_input))

  let dummy_edge = new_l_edge()
  dummy_edge.copy_properties(edge)
  dummy_edge.set_property_kvector_chain(
    layered_options_junction_points,
    @core.new_kvector_chain(),
  )
  dummy_edge.set_source(Some(dummy_output))
  dummy_edge.set_target(Some(original_target))

  inverted_port_processor_move_head_labels(edge, dummy_edge)
  inverted_port_processor_set_long_edge_source_and_target(
    dummy, dummy_input, dummy_output, westward_port,
  )
}

///|
fn inverted_port_processor_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Inverted port preprocessing", 1.0))

  let layers = layered_graph.get_layers()
  let unassigned_nodes : Array[LNode] = []
  let mut current_layer : Layer? = None

  try {
    for layer in layers {
      match current_layer {
        Some(previous_layer) => {
          for node in unassigned_nodes {
            node.set_layer(Some(previous_layer))
          }
          unassigned_nodes.clear()
        }
        None => ()
      }
      current_layer = Some(layer)

      for node in layer.get_nodes().copy() {
        match node.get_type() {
          NodeType::Normal => ()
          _ => continue
        }

        let constraints_value = if node.has_property_string(
            @core.port_constraints,
          ) {
          node.get_property_string(@core.port_constraints)
        } else {
          @core.port_constraints.get_default()
        }
        let constraints = inverted_port_processor_port_constraints_from_string(
          constraints_value,
        )
        if !constraints.is_side_fixed() {
          continue
        }

        for
          port in node.get_ports_by_type_and_side(
            PortType::Input,
            @core.PortSide::East,
          ) {
          for edge in port.get_incoming_edges().copy() {
            inverted_port_processor_create_east_port_side_dummies(
              layered_graph, port, edge, unassigned_nodes,
            )
          }
        }

        for
          port in node.get_ports_by_type_and_side(
            PortType::Output,
            @core.PortSide::West,
          ) {
          for edge in port.get_outgoing_edges().copy() {
            inverted_port_processor_create_west_port_side_dummies(
              layered_graph, port, edge, unassigned_nodes,
            )
          }
        }
      }
    }
  } catch {
    InvertedPortProcessorException::UnsupportedGraphException(message) => {
      @core.layout_runtime_report_unsupported_configuration(message)
      monitor.done()
      return
    }
  } noraise {
    _ => ()
  }

  match current_layer {
    Some(last_layer) =>
      for node in unassigned_nodes {
        node.set_layer(Some(last_layer))
      }
    None => ()
  }

  monitor.done()
}

///|
pub fn new_inverted_port_processor_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(inverted_port_processor_process)
}
