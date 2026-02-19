///|
let hierarchical_port_constraint_dummy_input_port : Int = 0

///|
let hierarchical_port_constraint_dummy_output_port : Int = 1

///|
fn hierarchical_port_constraint_parse_port_constraints(
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
fn hierarchical_port_constraint_node_type_is_external_port(
  node_type : NodeType,
) -> Bool {
  match node_type {
    NodeType::ExternalPort => true
    _ => false
  }
}

///|
fn hierarchical_port_constraint_port_side_is_west_or_east(
  side : PortSide,
) -> Bool {
  match side {
    PortSide::West => true
    PortSide::East => true
    _ => false
  }
}

///|
fn hierarchical_port_constraint_port_side_is_north_or_south(
  side : PortSide,
) -> Bool {
  match side {
    PortSide::North => true
    PortSide::South => true
    _ => false
  }
}

///|
fn hierarchical_port_constraint_require_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source")
  }
}

///|
fn hierarchical_port_constraint_require_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target")
  }
}

///|
fn hierarchical_port_constraint_require_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(value) => value
    None => abort("port has no owner node")
  }
}

///|
fn hierarchical_port_constraint_add_successor(
  node : LNode,
  successor : LNode,
) -> Unit {
  let successors = node.get_property_l_node_array(
    internal_properties_in_layer_successor_constraints,
  )
  successors.push(successor)
  node.set_property_l_node_array(
    internal_properties_in_layer_successor_constraints, successors,
  )
}

///|
fn hierarchical_port_constraint_node_compare(
  node1 : LNode,
  node2 : LNode,
) -> Int {
  if !hierarchical_port_constraint_node_type_is_external_port(node2.get_type()) {
    return -1
  }
  if !hierarchical_port_constraint_node_type_is_external_port(node1.get_type()) {
    return 1
  }

  let pos1 = node1.get_property_double(
    internal_properties_port_ratio_or_position,
  )
  let pos2 = node2.get_property_double(
    internal_properties_port_ratio_or_position,
  )
  if pos1 == pos2 {
    0
  } else if pos1 < pos2 {
    -1
  } else {
    1
  }
}

///|
fn hierarchical_port_constraint_sort_nodes(nodes : Array[LNode]) -> Unit {
  let mut index = 1
  while index < nodes.length() {
    let current = nodes[index]
    let mut insert_index = index
    while insert_index > 0 &&
          hierarchical_port_constraint_node_compare(
            nodes[insert_index - 1],
            current,
          ) >
          0 {
      nodes[insert_index] = nodes[insert_index - 1]
      insert_index = insert_index - 1
    }
    nodes[insert_index] = current
    index = index + 1
  }
}

///|
fn hierarchical_port_constraint_process_east_west_layer(layer : Layer) -> Unit {
  let nodes = layer.get_nodes().copy()
  hierarchical_port_constraint_sort_nodes(nodes)

  let mut last_dummy : LNode? = None
  for node in nodes {
    if !hierarchical_port_constraint_node_type_is_external_port(node.get_type()) {
      break
    }

    let side = node.get_property_port_side(internal_properties_ext_port_side)
    if !hierarchical_port_constraint_port_side_is_west_or_east(side) {
      continue
    }

    match last_dummy {
      Some(value) => hierarchical_port_constraint_add_successor(value, node)
      None => ()
    }
    last_dummy = Some(node)
  }
}

///|
fn hierarchical_port_constraint_process_east_west(
  layered_graph : LGraph,
) -> Unit {
  let constraints = hierarchical_port_constraint_parse_port_constraints(
    layered_graph.get_property_string(port_constraints),
  )
  if !constraints.is_order_fixed() {
    return
  }

  let layers = layered_graph.get_layers()
  if layers.is_empty() {
    return
  }

  hierarchical_port_constraint_process_east_west_layer(layers[0])
  hierarchical_port_constraint_process_east_west_layer(
    layers[layers.length() - 1],
  )
}

///|
fn hierarchical_port_constraint_is_north_south_dummy(node : LNode) -> Bool {
  if !hierarchical_port_constraint_node_type_is_external_port(node.get_type()) {
    return false
  }
  let side = node.get_property_port_side(internal_properties_ext_port_side)
  hierarchical_port_constraint_port_side_is_north_or_south(side)
}

///|
fn hierarchical_port_constraint_create_dummy(
  layered_graph : LGraph,
  original_dummy : LNode,
) -> LNode {
  let new_dummy = new_l_node(graph=Some(layered_graph))
  new_dummy.set_property_l_node(
    internal_properties_ext_port_replaced_dummy,
    Some(original_dummy),
  )
  new_dummy.set_property_string(port_constraints, "FIXED_POS")
  new_dummy.set_property_string(alignment, "CENTER")
  new_dummy.set_type(NodeType::ExternalPort)

  new_dummy.set_property_port_side(
    internal_properties_ext_port_side,
    original_dummy.get_property_port_side(internal_properties_ext_port_side),
  )
  new_dummy.set_property_double(
    internal_properties_port_ratio_or_position,
    original_dummy.get_property_double(
      internal_properties_port_ratio_or_position,
    ),
  )
  new_dummy.set_property_l_port(
    internal_properties_origin_l_port,
    original_dummy.get_property_l_port(internal_properties_origin_l_port),
  )

  let input_port = new_l_port()
  input_port.set_node(Some(new_dummy))
  input_port.set_side(PortSide::West)

  let output_port = new_l_port()
  output_port.set_node(Some(new_dummy))
  output_port.set_side(PortSide::East)

  new_dummy
}

///|
fn hierarchical_port_constraint_add_dummy_to_layer(
  layered_graph : LGraph,
  layers : Array[Layer],
  index : Int,
  map_count : Int,
  node_list : Array[LNode],
) -> Unit {
  let layer = if index == 0 {
    let created = new_layer(layered_graph)
    layers.insert(0, created)
    created
  } else if index == map_count - 1 {
    let created = new_layer(layered_graph)
    layers.push(created)
    created
  } else {
    layers[index - 1]
  }

  for dummy in node_list {
    dummy.set_layer(Some(layer))
  }
}

///|
fn hierarchical_port_constraint_process_north_south(
  layered_graph : LGraph,
) -> Unit {
  let constraints = hierarchical_port_constraint_parse_port_constraints(
    layered_graph.get_property_string(port_constraints),
  )
  if !constraints.is_side_fixed() {
    return
  }

  let layers = layered_graph.get_layers()
  let layer_count = layers.length()

  let ext_port_to_dummy_map : Array[Map[Int, LNode]] = [{}, {}]
  let new_dummy_nodes : Array[Array[LNode]] = [[], []]
  let original_dummies : Array[LNode] = []

  let mut curr_layer_idx = 0
  while curr_layer_idx < layer_count {
    let current_layer = layers[curr_layer_idx]

    let prev_map = ext_port_to_dummy_map[curr_layer_idx]
    let next_map : Map[Int, LNode] = {}
    ext_port_to_dummy_map.push(next_map)

    let prev_new_nodes = new_dummy_nodes[curr_layer_idx]
    let next_new_nodes : Array[LNode] = []
    new_dummy_nodes.push(next_new_nodes)

    for current_node in current_layer.get_nodes().copy() {
      if hierarchical_port_constraint_is_north_south_dummy(current_node) {
        original_dummies.push(current_node)
        continue
      }

      for edge in current_node.get_incoming_edges().copy() {
        let source_node = hierarchical_port_constraint_require_node(
          hierarchical_port_constraint_require_source(edge),
        )
        if !hierarchical_port_constraint_is_north_south_dummy(source_node) {
          continue
        }

        let key = source_node.get_handle()
        let prev_dummy = match prev_map.get(key) {
          Some(value) => value
          None => {
            let created = hierarchical_port_constraint_create_dummy(
              layered_graph, source_node,
            )
            prev_map[key] = created
            prev_new_nodes.push(created)
            created
          }
        }
        edge.set_source(
          Some(
            prev_dummy.get_ports()[hierarchical_port_constraint_dummy_output_port],
          ),
        )
      }

      for edge in current_node.get_outgoing_edges().copy() {
        let target_node = hierarchical_port_constraint_require_node(
          hierarchical_port_constraint_require_target(edge),
        )
        if !hierarchical_port_constraint_is_north_south_dummy(target_node) {
          continue
        }

        let key = target_node.get_handle()
        let next_dummy = match next_map.get(key) {
          Some(value) => value
          None => {
            let created = hierarchical_port_constraint_create_dummy(
              layered_graph, target_node,
            )
            next_map[key] = created
            next_new_nodes.push(created)
            created
          }
        }
        edge.set_target(
          Some(
            next_dummy.get_ports()[hierarchical_port_constraint_dummy_input_port],
          ),
        )
      }
    }

    curr_layer_idx = curr_layer_idx + 1
  }

  let map_count = ext_port_to_dummy_map.length()
  for index in 0..<new_dummy_nodes.length() {
    let node_list = new_dummy_nodes[index]
    if node_list.is_empty() {
      continue
    }
    hierarchical_port_constraint_add_dummy_to_layer(
      layered_graph, layers, index, map_count, node_list,
    )
  }

  for original_dummy in original_dummies {
    original_dummy.set_layer(None)
  }

  layered_graph.set_property_l_node_array(
    internal_properties_ext_port_replaced_dummies, original_dummies,
  )
}

///|
fn hierarchical_port_constraint_process(
  layered_graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Hierarchical port constraint processing", 1.0))

  hierarchical_port_constraint_process_east_west(layered_graph)
  hierarchical_port_constraint_process_north_south(layered_graph)

  monitor.done()
}

///|
pub fn new_hierarchical_port_constraint_processor_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(hierarchical_port_constraint_process)
}
