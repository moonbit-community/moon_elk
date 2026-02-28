///|
suberror CuttingUtilsException {
  CuttingUtilsException(String)
} derive(Show, ToJson)

///|
fn[T] cutting_utils_raise(message : String) -> T raise CuttingUtilsException {
  raise CuttingUtilsException(message)
}

///|
fn cutting_utils_require_edge_source(
  edge : LEdge,
) -> LPort raise CuttingUtilsException {
  match edge.get_source() {
    Some(value) => value
    None => cutting_utils_raise("edge has no source port")
  }
}

///|
fn cutting_utils_require_edge_target(
  edge : LEdge,
) -> LPort raise CuttingUtilsException {
  match edge.get_target() {
    Some(value) => value
    None => cutting_utils_raise("edge has no target port")
  }
}

///|
fn cutting_utils_require_port_node(
  port : LPort,
) -> LNode raise CuttingUtilsException {
  match port.get_node() {
    Some(value) => value
    None => cutting_utils_raise("port has no owner node")
  }
}

///|
fn cutting_utils_node_type_equals(left : NodeType, right : NodeType) -> Bool {
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
fn cutting_utils_port_side_from_string(
  value : String,
) -> @core.PortSide raise CuttingUtilsException {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == value {
      return side
    }
  }
  cutting_utils_raise("unknown port side")
}

///|
fn cutting_utils_set_layer_with_index(
  node : LNode,
  target_layer : Layer,
  insert_index : Int,
) -> Unit {
  node.set_layer(Some(target_layer))
  let nodes = target_layer.get_nodes()

  let mut current_idx = -1
  for i in 0..<nodes.length() {
    if nodes[i].get_handle() == node.get_handle() {
      current_idx = i
      break
    }
  }
  if current_idx < 0 {
    return
  }

  let mut target_idx = insert_index
  if target_idx < 0 {
    target_idx = 0
  }
  if target_idx > nodes.length() - 1 {
    return
  }
  if target_idx == current_idx {
    return
  }

  let moved = nodes[current_idx]
  ignore(nodes.remove(current_idx))
  ignore(nodes.insert(target_idx, moved))
}

///|
fn cutting_utils_set_dummy_properties(
  dummy : LNode,
  in_edge : LEdge,
  out_edge : LEdge,
) -> Unit raise CuttingUtilsException {
  let in_edge_source_node = cutting_utils_require_port_node(
    cutting_utils_require_edge_source(in_edge),
  )

  if cutting_utils_node_type_equals(
      in_edge_source_node.get_type(),
      NodeType::LongEdge,
    ) {
    dummy.set_property_l_port(
      internal_properties_long_edge_source,
      in_edge_source_node.get_property_l_port(
        internal_properties_long_edge_source,
      ),
    )
    dummy.set_property_l_port(
      internal_properties_long_edge_target,
      in_edge_source_node.get_property_l_port(
        internal_properties_long_edge_target,
      ),
    )
  } else {
    dummy.set_property_l_port(
      internal_properties_long_edge_source,
      Some(cutting_utils_require_edge_source(in_edge)),
    )
    dummy.set_property_l_port(
      internal_properties_long_edge_target,
      Some(cutting_utils_require_edge_target(out_edge)),
    )
  }
}

///|
pub fn cutting_utils_insert_dummies(
  layered_graph : LGraph,
  original_edge : LEdge,
  offset_first_in_layer_dummy : Int,
) -> Array[LEdge] raise CuttingUtilsException {
  let edge_node_spacing = layered_graph.get_property_double(
    @core.spacing_edge_node,
  )
  let additional_spacing = layered_graph.get_property_double(
    layered_options_wrapping_additional_edge_spacing,
  )
  let dummy_edge_node_spacing = edge_node_spacing + additional_spacing

  let mut edge = original_edge
  let target_port = cutting_utils_require_edge_target(edge)
  let source_node = cutting_utils_require_port_node(
    cutting_utils_require_edge_source(edge),
  )
  let target_node = cutting_utils_require_port_node(target_port)

  let source_layer = match source_node.get_layer() {
    Some(value) => value
    None => cutting_utils_raise("source node has no layer")
  }
  let target_layer = match target_node.get_layer() {
    Some(value) => value
    None => cutting_utils_raise("target node has no layer")
  }
  let source_index = source_layer.get_index()
  let target_index = target_layer.get_index()

  let created_edges = []

  let mut i = source_index
  while i <= target_index {
    let dummy_node = new_l_node(graph=Some(layered_graph))
    dummy_node.set_type(NodeType::LongEdge)
    dummy_node.set_property_l_edge(
      internal_properties_origin_l_edge,
      Some(edge),
    )
    dummy_node.set_property_string(@core.port_constraints, "FIXED_POS")
    dummy_node.set_property_double(
      @core.spacing_edge_node, dummy_edge_node_spacing,
    )

    let next_layer = layered_graph.get_layers()[i]
    if i == source_index {
      cutting_utils_set_layer_with_index(
        dummy_node,
        next_layer,
        next_layer.get_nodes().length() - offset_first_in_layer_dummy,
      )
    } else {
      dummy_node.set_layer(Some(next_layer))
    }

    let mut thickness = edge.get_property_double(@core.edge_thickness)
    if thickness < 0.0 {
      thickness = 0.0
      edge.set_property_double(@core.edge_thickness, thickness)
    }
    dummy_node.get_size().y = thickness
    let port_pos = (thickness / 2.0).floor()

    let dummy_input = new_l_port()
    dummy_input.set_side(cutting_utils_port_side_from_string("WEST"))
    dummy_input.set_node(Some(dummy_node))
    dummy_input.get_position().y = port_pos

    let dummy_output = new_l_port()
    dummy_output.set_side(cutting_utils_port_side_from_string("EAST"))
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
    dummy_edge.set_target(Some(target_port))

    cutting_utils_set_dummy_properties(dummy_node, edge, dummy_edge)
    created_edges.push(dummy_edge)
    edge = dummy_edge
    i = i + 1
  }

  created_edges
}
