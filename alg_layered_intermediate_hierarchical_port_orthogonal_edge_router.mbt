///|
fn hierarchical_port_orthogonal_parse_port_constraints(
  value : String,
) -> PortConstraints {
  for constraints in port_constraints_values() {
    if port_constraints_to_string(constraints) == value {
      return constraints
    }
  }
  PortConstraints::Undefined
}

///|
fn hierarchical_port_orthogonal_port_constraints_equals(
  left : PortConstraints,
  right : PortConstraints,
) -> Bool {
  match (left, right) {
    (PortConstraints::Undefined, PortConstraints::Undefined) => true
    (PortConstraints::Free, PortConstraints::Free) => true
    (PortConstraints::FixedSide, PortConstraints::FixedSide) => true
    (PortConstraints::FixedOrder, PortConstraints::FixedOrder) => true
    (PortConstraints::FixedRatio, PortConstraints::FixedRatio) => true
    (PortConstraints::FixedPos, PortConstraints::FixedPos) => true
    _ => false
  }
}

///|
fn hierarchical_port_orthogonal_add_unique_node(
  nodes : Array[LNode],
  candidate : LNode,
) -> Unit {
  for existing in nodes {
    if existing.get_handle() == candidate.get_handle() {
      return
    }
  }
  nodes.push(candidate)
}

///|
fn hierarchical_port_orthogonal_node_type_is_external_port(
  node_type : NodeType,
) -> Bool {
  match node_type {
    NodeType::ExternalPort => true
    _ => false
  }
}

///|
fn hierarchical_port_orthogonal_side_is_north(side : PortSide) -> Bool {
  match side {
    PortSide::North => true
    _ => false
  }
}

///|
fn hierarchical_port_orthogonal_side_is_south(side : PortSide) -> Bool {
  match side {
    PortSide::South => true
    _ => false
  }
}

///|
fn hierarchical_port_orthogonal_side_is_east(side : PortSide) -> Bool {
  match side {
    PortSide::East => true
    _ => false
  }
}

///|
fn hierarchical_port_orthogonal_side_is_west(side : PortSide) -> Bool {
  match side {
    PortSide::West => true
    _ => false
  }
}

///|
fn hierarchical_port_orthogonal_side_is_east_or_west(side : PortSide) -> Bool {
  hierarchical_port_orthogonal_side_is_east(side) ||
  hierarchical_port_orthogonal_side_is_west(side)
}

///|
fn hierarchical_port_orthogonal_restore_dummy(dummy : LNode) -> Unit {
  let side = dummy.get_property_port_side(internal_properties_ext_port_side)
  let ports = dummy.get_ports()
  if ports.is_empty() {
    return
  }
  let dummy_port = ports[0]
  if hierarchical_port_orthogonal_side_is_north(side) {
    dummy_port.set_side(PortSide::South)
  } else if hierarchical_port_orthogonal_side_is_south(side) {
    dummy_port.set_side(PortSide::North)
  }
}

///|
fn hierarchical_port_orthogonal_connect_node_to_dummy(
  node : LNode,
  dummy : LNode,
) -> Unit {
  let out_port = new_l_port()
  out_port.set_node(Some(node))
  out_port.set_side(
    node.get_property_port_side(internal_properties_ext_port_side),
  )

  let ports = dummy.get_ports()
  if ports.is_empty() {
    return
  }
  let in_port = ports[0]

  let edge = new_l_edge()
  edge.set_source(Some(out_port))
  edge.set_target(Some(in_port))
}

///|
fn hierarchical_port_orthogonal_restore_north_south_dummies(
  layered_graph : LGraph,
) -> Array[LNode] {
  let restored_dummies = []
  let replaced = layered_graph.get_property_l_node_array(
    internal_properties_ext_port_replaced_dummies,
  )
  if replaced.is_empty() {
    return restored_dummies
  }

  for dummy in replaced {
    hierarchical_port_orthogonal_restore_dummy(dummy)
    restored_dummies.push(dummy)
  }

  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes().copy() {
      if !hierarchical_port_orthogonal_node_type_is_external_port(
          node.get_type(),
        ) {
        continue
      }
      match
        node.get_property_l_node(internal_properties_ext_port_replaced_dummy) {
        Some(replaced_dummy) =>
          hierarchical_port_orthogonal_connect_node_to_dummy(
            node, replaced_dummy,
          )
        None => ()
      }
    }
  }

  let layers = layered_graph.get_layers()
  if layers.is_empty() {
    return restored_dummies
  }
  let last_layer = layers[layers.length() - 1]
  for dummy in restored_dummies {
    dummy.set_layer(Some(last_layer))
  }

  restored_dummies
}

///|
fn hierarchical_port_orthogonal_calculate_north_south_dummy_positions(
  dummy : LNode,
) -> Unit {
  let ports = dummy.get_ports()
  if ports.is_empty() {
    return
  }
  let dummy_port = ports[0]
  if dummy_port.get_degree() == 0 {
    dummy.get_position().x = 0.0
    return
  }

  let mut pos_sum = 0.0
  for connected_port in dummy_port.get_connected_ports() {
    match connected_port.get_node() {
      Some(node) =>
        pos_sum += node.get_position().x +
          connected_port.get_position().x +
          connected_port.get_anchor().x
      None => ()
    }
  }

  let anchor = dummy.get_property_kvector(layered_options_port_anchor)
  let offset = anchor.x
  dummy.get_position().x = pos_sum / dummy_port.get_degree().to_double() -
    offset
}

///|
fn hierarchical_port_orthogonal_apply_north_south_dummy_ratio(
  dummy : LNode,
  width : Double,
) -> Unit {
  let anchor = dummy.get_property_kvector(layered_options_port_anchor)
  dummy.get_position().x = width *
    dummy.get_property_double(internal_properties_port_ratio_or_position) -
    anchor.x
}

///|
fn hierarchical_port_orthogonal_apply_north_south_dummy_position(
  dummy : LNode,
) -> Unit {
  let anchor = dummy.get_property_kvector(layered_options_port_anchor)
  dummy.get_position().x = dummy.get_property_double(
      internal_properties_port_ratio_or_position,
    ) -
    anchor.x
}

///|
fn hierarchical_port_orthogonal_sort_by_position(nodes : Array[LNode]) -> Unit {
  let mut index = 1
  while index < nodes.length() {
    let current = nodes[index]
    let mut insert_index = index
    while insert_index > 0 &&
          nodes[insert_index - 1].get_position().x > current.get_position().x {
      nodes[insert_index] = nodes[insert_index - 1]
      insert_index = insert_index - 1
    }
    nodes[insert_index] = current
    index = index + 1
  }
}

///|
fn hierarchical_port_orthogonal_sort_by_original_position(
  nodes : Array[LNode],
) -> Unit {
  let mut index = 1
  while index < nodes.length() {
    let current = nodes[index]
    let mut insert_index = index
    while insert_index > 0 &&
          nodes[insert_index - 1].get_property_double(
            internal_properties_port_ratio_or_position,
          ) >
          current.get_property_double(
            internal_properties_port_ratio_or_position,
          ) {
      nodes[insert_index] = nodes[insert_index - 1]
      insert_index = insert_index - 1
    }
    nodes[insert_index] = current
    index = index + 1
  }
}

///|
fn hierarchical_port_orthogonal_assign_ascending_coordinates(
  dummies : Array[LNode],
  graph : LGraph,
) -> Unit {
  if dummies.length() <= 1 {
    return
  }

  let spacing = graph.get_property_double(spacing_port_port)
  let first = dummies[0]
  let mut next_valid_coordinate = first.get_position().x +
    first.get_size().x +
    first.get_margin().right +
    spacing

  for index in 1..<dummies.length() {
    let dummy = dummies[index]
    let current_position = dummy.get_position()
    let current_size = dummy.get_size()
    let current_margin = dummy.get_margin()

    let delta = current_position.x - current_margin.left - next_valid_coordinate
    if delta < 0.0 {
      current_position.x = current_position.x - delta
    }

    let graph_size = graph.get_size()
    if current_position.x + current_size.x > graph_size.x {
      graph_size.x = current_position.x + current_size.x
    }

    next_valid_coordinate = current_position.x +
      current_size.x +
      current_margin.right +
      spacing
  }
}

///|
fn hierarchical_port_orthogonal_ensure_unique_positions(
  dummies : Array[LNode],
  graph : LGraph,
) -> Unit {
  if dummies.is_empty() {
    return
  }
  let ordered = dummies.copy()
  hierarchical_port_orthogonal_sort_by_position(ordered)
  hierarchical_port_orthogonal_assign_ascending_coordinates(ordered, graph)
}

///|
fn hierarchical_port_orthogonal_restore_proper_order(
  dummies : Array[LNode],
  graph : LGraph,
) -> Unit {
  if dummies.is_empty() {
    return
  }
  let ordered = dummies.copy()
  hierarchical_port_orthogonal_sort_by_original_position(ordered)
  hierarchical_port_orthogonal_assign_ascending_coordinates(ordered, graph)
}

///|
fn hierarchical_port_orthogonal_set_north_south_dummy_coordinates(
  layered_graph : LGraph,
  north_south_dummies : Array[LNode],
) -> Unit {
  let constraints = hierarchical_port_orthogonal_parse_port_constraints(
    layered_graph.get_property_string(port_constraints),
  )
  let graph_size = layered_graph.get_size()
  let graph_width = graph_size.x
  let north_y = 0.0 - layered_graph.get_offset().y
  let south_y = graph_size.y - layered_graph.get_offset().y

  let northern_dummies = []
  let southern_dummies = []

  for dummy in north_south_dummies {
    match constraints {
      PortConstraints::Free =>
        hierarchical_port_orthogonal_calculate_north_south_dummy_positions(
          dummy,
        )
      PortConstraints::FixedSide =>
        hierarchical_port_orthogonal_calculate_north_south_dummy_positions(
          dummy,
        )
      PortConstraints::FixedOrder =>
        hierarchical_port_orthogonal_calculate_north_south_dummy_positions(
          dummy,
        )
      PortConstraints::FixedRatio =>
        hierarchical_port_orthogonal_apply_north_south_dummy_ratio(
          dummy, graph_width,
        )
      PortConstraints::FixedPos => {
        hierarchical_port_orthogonal_apply_north_south_dummy_position(dummy)
        if dummy.get_position().x + dummy.get_size().x / 2.0 > graph_size.x {
          graph_size.x = dummy.get_position().x + dummy.get_size().x / 2.0
        }
      }
      PortConstraints::Undefined =>
        hierarchical_port_orthogonal_calculate_north_south_dummy_positions(
          dummy,
        )
    }

    let side = dummy.get_property_port_side(internal_properties_ext_port_side)
    if hierarchical_port_orthogonal_side_is_north(side) {
      dummy.get_position().y = north_y
      northern_dummies.push(dummy)
    } else if hierarchical_port_orthogonal_side_is_south(side) {
      dummy.get_position().y = south_y
      southern_dummies.push(dummy)
    }
  }

  match constraints {
    PortConstraints::Free => {
      hierarchical_port_orthogonal_ensure_unique_positions(
        northern_dummies, layered_graph,
      )
      hierarchical_port_orthogonal_ensure_unique_positions(
        southern_dummies, layered_graph,
      )
    }
    PortConstraints::FixedSide => {
      hierarchical_port_orthogonal_ensure_unique_positions(
        northern_dummies, layered_graph,
      )
      hierarchical_port_orthogonal_ensure_unique_positions(
        southern_dummies, layered_graph,
      )
    }
    PortConstraints::FixedOrder => {
      hierarchical_port_orthogonal_restore_proper_order(
        northern_dummies, layered_graph,
      )
      hierarchical_port_orthogonal_restore_proper_order(
        southern_dummies, layered_graph,
      )
    }
    _ => ()
  }
}

///|
fn hierarchical_port_orthogonal_route_edges(
  monitor : IElkProgressMonitor,
  layered_graph : LGraph,
  north_south_dummies : Array[LNode],
) -> Double {
  let northern_source_layer = []
  let northern_target_layer = []
  let southern_source_layer = []
  let southern_target_layer = []

  let node_spacing = layered_graph.get_property_double(spacing_node_node)
  let edge_spacing = layered_graph.get_property_double(spacing_edge_edge)

  for hierarchical_port_dummy in north_south_dummies {
    let side = hierarchical_port_dummy.get_property_port_side(
      internal_properties_ext_port_side,
    )
    if hierarchical_port_orthogonal_side_is_north(side) {
      hierarchical_port_orthogonal_add_unique_node(
        northern_target_layer, hierarchical_port_dummy,
      )
      for edge in hierarchical_port_dummy.get_incoming_edges() {
        match edge.get_source() {
          Some(source_port) =>
            match source_port.get_node() {
              Some(source_node) =>
                hierarchical_port_orthogonal_add_unique_node(
                  northern_source_layer, source_node,
                )
              None => ()
            }
          None => ()
        }
      }
    } else if hierarchical_port_orthogonal_side_is_south(side) {
      hierarchical_port_orthogonal_add_unique_node(
        southern_target_layer, hierarchical_port_dummy,
      )
      for edge in hierarchical_port_dummy.get_incoming_edges() {
        match edge.get_source() {
          Some(source_port) =>
            match source_port.get_node() {
              Some(source_node) =>
                hierarchical_port_orthogonal_add_unique_node(
                  southern_source_layer, source_node,
                )
              None => ()
            }
          None => ()
        }
      }
    }
  }

  let mut northern_routing_height = 0.0

  if !northern_source_layer.is_empty() {
    let routing_generator = new_orthogonal_routing_generator(
      RoutingDirection::SouthToNorth,
      edge_spacing,
      Some("extnorth"),
    )
    let slots = routing_generator.route_edges(
      monitor,
      layered_graph,
      Some(northern_source_layer),
      0,
      Some(northern_target_layer),
      -node_spacing - layered_graph.get_offset().y,
    )
    if slots > 0 {
      northern_routing_height = node_spacing +
        (slots - 1).to_double() * edge_spacing
      layered_graph.get_offset().y += northern_routing_height
      layered_graph.get_size().y += northern_routing_height
    }
  }

  if !southern_source_layer.is_empty() {
    let routing_generator = new_orthogonal_routing_generator(
      RoutingDirection::NorthToSouth,
      edge_spacing,
      Some("extsouth"),
    )
    let slots = routing_generator.route_edges(
      monitor,
      layered_graph,
      Some(southern_source_layer),
      0,
      Some(southern_target_layer),
      layered_graph.get_size().y + node_spacing - layered_graph.get_offset().y,
    )
    if slots > 0 {
      layered_graph.get_size().y += node_spacing +
        (slots - 1).to_double() * edge_spacing
    }
  }

  northern_routing_height
}

///|
fn hierarchical_port_orthogonal_remove_temporary_north_south_dummies(
  layered_graph : LGraph,
) -> Unit {
  let nodes_to_remove = []

  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes().copy() {
      if !hierarchical_port_orthogonal_node_type_is_external_port(
          node.get_type(),
        ) {
        continue
      }
      if node.get_property_l_node(internal_properties_ext_port_replaced_dummy)
        is None {
        continue
      }

      let mut node_in_port : LPort? = None
      let mut node_out_port : LPort? = None
      let mut node_origin_port : LPort? = None

      for port in node.get_ports() {
        match port.get_side() {
          PortSide::West => node_in_port = Some(port)
          PortSide::East => node_out_port = Some(port)
          _ => node_origin_port = Some(port)
        }
      }

      let origin_port = match node_origin_port {
        Some(value) => value
        None => continue
      }
      if origin_port.get_outgoing_edges().is_empty() {
        continue
      }
      let node_to_origin_edge = origin_port.get_outgoing_edges()[0]

      let incoming_edge_bend_points = new_kvector_chain_copy(
        node_to_origin_edge.get_bend_points(),
      )
      let first_bend = new_kvector_copy(origin_port.get_position())
      ignore(first_bend.add(node.get_position()))
      incoming_edge_bend_points.add_first_vector(first_bend)

      let outgoing_edge_bend_points = kvector_chain_reverse(
        node_to_origin_edge.get_bend_points(),
      )
      let last_bend = new_kvector_copy(origin_port.get_position())
      ignore(last_bend.add(node.get_position()))
      outgoing_edge_bend_points.add_last_vector(last_bend)

      let replaced_dummy = match
        node.get_property_l_node(internal_properties_ext_port_replaced_dummy) {
        Some(value) => value
        None => continue
      }
      if replaced_dummy.get_ports().is_empty() {
        continue
      }
      let replaced_dummy_port = replaced_dummy.get_ports()[0]

      match node_in_port {
        Some(in_port) =>
          for edge in in_port.get_incoming_edges().copy() {
            edge.set_target(Some(replaced_dummy_port))
            edge
            .get_bend_points()
            .add_all_as_copies(
              edge.get_bend_points().size(),
              incoming_edge_bend_points,
            )
          }
        None => ()
      }

      match node_out_port {
        Some(out_port) =>
          for edge in out_port.get_outgoing_edges().copy() {
            edge.set_source(Some(replaced_dummy_port))
            edge
            .get_bend_points()
            .add_all_as_copies(0, outgoing_edge_bend_points)
          }
        None => ()
      }

      node_to_origin_edge.set_source(None)
      node_to_origin_edge.set_target(None)
      nodes_to_remove.push(node)
    }
  }

  for node in nodes_to_remove {
    node.set_layer(None)
  }
}

///|
fn hierarchical_port_orthogonal_fix_coordinates_layer(
  layer : Layer,
  constraints : PortConstraints,
  graph : LGraph,
) -> Unit {
  let offset = graph.get_offset()
  let graph_actual_size_y = graph.get_size().y
  let mut new_actual_graph_height = graph_actual_size_y

  for node in layer.get_nodes() {
    if !hierarchical_port_orthogonal_node_type_is_external_port(node.get_type()) {
      continue
    }

    let side = node.get_property_port_side(internal_properties_ext_port_side)
    let node_position = node.get_position()

    if hierarchical_port_orthogonal_side_is_east(side) {
      node_position.x = graph.get_size().x - offset.x
    } else if hierarchical_port_orthogonal_side_is_west(side) {
      node_position.x = -offset.x
    }

    let mut required_actual_graph_height = 0.0
    if hierarchical_port_orthogonal_side_is_east_or_west(side) {
      let anchor = node.get_property_kvector(layered_options_port_anchor)
      if hierarchical_port_orthogonal_port_constraints_equals(
          constraints,
          PortConstraints::FixedRatio,
        ) {
        let ratio = node.get_property_double(
          internal_properties_port_ratio_or_position,
        )
        node_position.y = graph_actual_size_y * ratio - anchor.y
        let ext_port_size = node.get_property_kvector(
          internal_properties_ext_port_size,
        )
        let ext_port_height = if ext_port_size.y > 0.0 {
          ext_port_size.y
        } else {
          node.get_size().y
        }
        required_actual_graph_height = node_position.y + ext_port_height
      } else if hierarchical_port_orthogonal_port_constraints_equals(
          constraints,
          PortConstraints::FixedPos,
        ) {
        node_position.y = node.get_property_double(
            internal_properties_port_ratio_or_position,
          ) -
          anchor.y
        let ext_port_size = node.get_property_kvector(
          internal_properties_ext_port_size,
        )
        let ext_port_height = if ext_port_size.y > 0.0 {
          ext_port_size.y
        } else {
          node.get_size().y
        }
        required_actual_graph_height = node_position.y + ext_port_height
      }
    }

    if required_actual_graph_height > new_actual_graph_height {
      new_actual_graph_height = required_actual_graph_height
    }
  }

  graph.get_size().y += new_actual_graph_height - graph_actual_size_y

  for node in layer.get_nodes() {
    if !hierarchical_port_orthogonal_node_type_is_external_port(node.get_type()) {
      continue
    }
    let side = node.get_property_port_side(internal_properties_ext_port_side)
    let node_position = node.get_position()
    if hierarchical_port_orthogonal_side_is_north(side) {
      node_position.y = -offset.y
    } else if hierarchical_port_orthogonal_side_is_south(side) {
      node_position.y = graph.get_size().y - offset.y
    }
  }
}

///|
fn hierarchical_port_orthogonal_fix_coordinates(layered_graph : LGraph) -> Unit {
  let constraints = hierarchical_port_orthogonal_parse_port_constraints(
    layered_graph.get_property_string(port_constraints),
  )
  let layers = layered_graph.get_layers()
  if layers.is_empty() {
    return
  }
  hierarchical_port_orthogonal_fix_coordinates_layer(
    layers[0],
    constraints,
    layered_graph,
  )
  if layers.length() > 1 {
    hierarchical_port_orthogonal_fix_coordinates_layer(
      layers[layers.length() - 1],
      constraints,
      layered_graph,
    )
  }
}

///|
fn hierarchical_port_orthogonal_correct_slanted_edge_segments_layer(
  layer : Layer,
) -> Unit {
  for node in layer.get_nodes() {
    if !hierarchical_port_orthogonal_node_type_is_external_port(node.get_type()) {
      continue
    }

    let side = node.get_property_port_side(internal_properties_ext_port_side)
    if !hierarchical_port_orthogonal_side_is_east_or_west(side) {
      continue
    }

    for edge in node.get_connected_edges() {
      let bend_points = edge.get_bend_points()
      if bend_points.is_empty() {
        continue
      }

      match edge.get_source() {
        Some(source_port) =>
          match source_port.get_node() {
            Some(source_node) =>
              if source_node.get_handle() == node.get_handle() {
                bend_points.get(0).y = source_port.get_absolute_anchor().y
              }
            None => ()
          }
        None => ()
      }

      match edge.get_target() {
        Some(target_port) =>
          match target_port.get_node() {
            Some(target_node) =>
              if target_node.get_handle() == node.get_handle() {
                bend_points.get(bend_points.size() - 1).y = target_port.get_absolute_anchor().y
              }
            None => ()
          }
        None => ()
      }
    }
  }
}

///|
fn hierarchical_port_orthogonal_correct_slanted_edge_segments(
  layered_graph : LGraph,
) -> Unit {
  let layers = layered_graph.get_layers()
  if layers.is_empty() {
    return
  }
  hierarchical_port_orthogonal_correct_slanted_edge_segments_layer(layers[0])
  if layers.length() > 1 {
    hierarchical_port_orthogonal_correct_slanted_edge_segments_layer(
      layers[layers.length() - 1],
    )
  }
}

///|
fn hierarchical_port_orthogonal_edge_router_process(
  layered_graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Orthogonally routing hierarchical port edges", 1.0))

  let north_south_dummies = hierarchical_port_orthogonal_restore_north_south_dummies(
    layered_graph,
  )
  hierarchical_port_orthogonal_set_north_south_dummy_coordinates(
    layered_graph, north_south_dummies,
  )
  ignore(
    hierarchical_port_orthogonal_route_edges(
      monitor, layered_graph, north_south_dummies,
    ),
  )
  hierarchical_port_orthogonal_remove_temporary_north_south_dummies(
    layered_graph,
  )
  hierarchical_port_orthogonal_fix_coordinates(layered_graph)
  hierarchical_port_orthogonal_correct_slanted_edge_segments(layered_graph)

  monitor.done()
}

///|
pub fn new_hierarchical_port_orthogonal_edge_router_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(hierarchical_port_orthogonal_edge_router_process)
}
