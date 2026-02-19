///|
fn in_layer_constraint_processor_parse_constraint(
  value : String,
) -> InLayerConstraint {
  if value == "TOP" {
    return InLayerConstraint::Top
  }
  if value == "BOTTOM" {
    return InLayerConstraint::Bottom
  }
  InLayerConstraint::NoneType
}

///|
fn in_layer_constraint_processor_is_top(constraint : InLayerConstraint) -> Bool {
  match constraint {
    InLayerConstraint::Top => true
    _ => false
  }
}

///|
fn in_layer_constraint_processor_is_bottom(
  constraint : InLayerConstraint,
) -> Bool {
  match constraint {
    InLayerConstraint::Bottom => true
    _ => false
  }
}

///|
fn in_layer_constraint_processor_find_index(layer : Layer, node : LNode) -> Int {
  let nodes = layer.get_nodes()
  for i in 0..<nodes.length() {
    if lnode_internal_handle(nodes[i]) == lnode_internal_handle(node) {
      return i
    }
  }
  -1
}

///|
fn in_layer_constraint_processor_move_to_index(
  layer : Layer,
  node : LNode,
  index : Int,
) -> Unit {
  let nodes = layer.get_nodes()
  let node_index = in_layer_constraint_processor_find_index(layer, node)
  if node_index < 0 {
    return
  }

  let moved = nodes.remove(node_index)
  let insert_index = if index < 0 {
    0
  } else if index > nodes.length() {
    nodes.length()
  } else {
    index
  }
  ignore(nodes.insert(insert_index, moved))
}

///|
fn in_layer_constraint_processor_move_to_end(
  layer : Layer,
  node : LNode,
) -> Unit {
  let nodes = layer.get_nodes()
  let node_index = in_layer_constraint_processor_find_index(layer, node)
  if node_index < 0 {
    return
  }

  let moved = nodes.remove(node_index)
  nodes.push(moved)
}

///|
fn in_layer_constraint_processor_process(
  layered_graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Layer constraint edge reversal", 1.0))

  for layer in layered_graph.get_layers() {
    let mut top_insertion_index = -1
    let bottom_constrained_nodes = []
    let nodes_snapshot = []
    for node in layer.get_nodes() {
      nodes_snapshot.push(node)
    }

    for i in 0..<nodes_snapshot.length() {
      let node = nodes_snapshot[i]
      let constraint = in_layer_constraint_processor_parse_constraint(
        node.get_property_string(internal_properties_in_layer_constraint),
      )

      if top_insertion_index == -1 {
        if !in_layer_constraint_processor_is_top(constraint) {
          top_insertion_index = i
        }
      } else if in_layer_constraint_processor_is_top(constraint) {
        in_layer_constraint_processor_move_to_index(
          layer, node, top_insertion_index,
        )
        top_insertion_index = top_insertion_index + 1
      }

      if in_layer_constraint_processor_is_bottom(constraint) {
        bottom_constrained_nodes.push(node)
      }
    }

    for node in bottom_constrained_nodes {
      in_layer_constraint_processor_move_to_end(layer, node)
    }
  }

  monitor.done()
}

///|
pub fn new_in_layer_constraint_processor_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(in_layer_constraint_processor_process)
}
