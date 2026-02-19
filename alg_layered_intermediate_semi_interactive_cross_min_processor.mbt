///|
fn semi_interactive_cross_min_processor_node_type_is_normal(
  node : LNode,
) -> Bool {
  match node.get_type() {
    NodeType::Normal => true
    _ => false
  }
}

///|
fn semi_interactive_cross_min_processor_insert_sorted(
  nodes : Array[LNode],
  node : LNode,
) -> Unit {
  let mut insert_index = nodes.length()
  let node_position = node.get_property_kvector(layered_options_position)
  let node_y = node_position.y

  for i in 0..<nodes.length() {
    let current = nodes[i]
    let current_position = current.get_property_kvector(
      layered_options_position,
    )
    if node_y < current_position.y {
      insert_index = i
      break
    }
  }

  ignore(nodes.insert(insert_index, node))
}

///|
fn semi_interactive_cross_min_processor_collect_sorted_positioned_normals(
  layer : Layer,
) -> Array[LNode] {
  let result = []
  for node in layer.get_nodes() {
    if !semi_interactive_cross_min_processor_node_type_is_normal(node) {
      continue
    }
    if !node.has_property_kvector(layered_options_position) {
      continue
    }
    semi_interactive_cross_min_processor_insert_sorted(result, node)
  }
  result
}

///|
fn semi_interactive_cross_min_processor_apply_successor_constraints(
  nodes : Array[LNode],
) -> Bool {
  if nodes.length() < 2 {
    return false
  }

  let mut previous = nodes[0]
  for i in 1..<nodes.length() {
    let current = nodes[i]
    let successor_constraints = previous.get_property_l_node_array(
      internal_properties_in_layer_successor_constraints,
    )
    successor_constraints.push(current)
    previous.set_property_l_node_array(
      internal_properties_in_layer_successor_constraints, successor_constraints,
    )
    previous = current
  }
  true
}

///|
fn semi_interactive_cross_min_processor_process(
  layered_graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Semi-Interactive Crossing Minimization Processor", 1.0))

  let mut added_constraints = false
  for layer in layered_graph.get_layers() {
    let sorted_nodes = semi_interactive_cross_min_processor_collect_sorted_positioned_normals(
      layer,
    )
    if semi_interactive_cross_min_processor_apply_successor_constraints(
        sorted_nodes,
      ) {
      added_constraints = true
    }
  }

  if added_constraints {
    layered_graph.set_property_bool(
      internal_properties_in_layer_successor_constraints_between_non_dummies, true,
    )
  }

  monitor.done()
}

///|
pub fn new_semi_interactive_cross_min_processor_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(semi_interactive_cross_min_processor_process)
}
