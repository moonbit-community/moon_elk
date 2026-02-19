///|
struct AlternatingLayerUnzipperPendingLayer {
  layer : Layer
  insertion_index : Int
}

///|
fn alternating_layer_unzipper_node_type_equals(
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
fn alternating_layer_unzipper_max_double(
  left : Double,
  right : Double,
) -> Double {
  if left >= right {
    left
  } else {
    right
  }
}

///|
fn alternating_layer_unzipper_set_layer_with_index(
  node : LNode,
  layer : Layer,
  index : Int,
) -> Unit {
  node.set_layer(Some(layer))

  let nodes = layer.get_nodes()
  let mut node_index = -1
  for i in 0..<nodes.length() {
    if lnode_internal_handle(nodes[i]) == lnode_internal_handle(node) {
      node_index = i
      break
    }
  }
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
fn alternating_layer_unzipper_get_layer_split_property(layer : Layer) -> Int {
  let mut layer_split = @int.max_value
  let mut property_unset = true

  for node in layer.get_nodes() {
    if node.has_property_int(layered_options_layer_unzipping_layer_split) {
      property_unset = false
      let node_value = node.get_property_int(
        layered_options_layer_unzipping_layer_split,
      )
      if layer_split > node_value {
        layer_split = node_value
      }
    }
  }

  if property_unset {
    layer_split = layered_options_layer_unzipping_layer_split.get_default()
  }

  layer_split
}

///|
fn alternating_layer_unzipper_get_reset_on_long_edges_property(
  layer : Layer,
) -> Bool {
  for node in layer.get_nodes() {
    if node.has_property_bool(
        layered_options_layer_unzipping_reset_on_long_edges,
      ) {
      if !node.get_property_bool(
          layered_options_layer_unzipping_reset_on_long_edges,
        ) {
        return false
      }
    }
  }
  true
}

///|
fn alternating_layer_unzipper_get_minimize_edge_length_property(
  layer : Layer,
) -> Bool {
  for node in layer.get_nodes() {
    if node.has_property_bool(
        layered_options_layer_unzipping_minimize_edge_length,
      ) {
      if node.get_property_bool(
          layered_options_layer_unzipping_minimize_edge_length,
        ) {
        return true
      }
    }
  }
  false
}

///|
fn alternating_layer_unzipper_create_dummy_node(
  graph : LGraph,
  edge_to_split : LEdge,
) -> LNode {
  let dummy_node = new_l_node(graph=Some(graph))
  dummy_node.set_type(NodeType::LongEdge)
  dummy_node.set_property_l_edge(
    internal_properties_origin_l_edge,
    Some(edge_to_split),
  )
  dummy_node.set_property_string(port_constraints, "FIXED_POS")
  dummy_node
}

///|
fn alternating_layer_unzipper_shift_node(
  graph : LGraph,
  sub_layers : Array[Layer],
  target_layer : Int,
  node_index : Int,
) -> Int {
  let node = sub_layers[0].get_nodes()[node_index]
  if target_layer > 0 {
    node.set_layer(Some(sub_layers[target_layer]))
  }

  let mut edge_count = 0
  let mut no_incoming_edges = true
  let incoming_edges = node.get_incoming_edges().copy()
  let mut reverse_index = incoming_edges.length() - 1
  while reverse_index >= 0 {
    no_incoming_edges = false
    let mut next_edge_to_split = incoming_edges[reverse_index]

    let mut layer_index = 0
    while layer_index < target_layer {
      let dummy_node = alternating_layer_unzipper_create_dummy_node(
        graph, next_edge_to_split,
      )
      if node_index + edge_count > sub_layers[layer_index].get_nodes().length() {
        dummy_node.set_layer(Some(sub_layers[layer_index]))
      } else {
        alternating_layer_unzipper_set_layer_with_index(
          dummy_node,
          sub_layers[layer_index],
          node_index + edge_count,
        )
      }
      next_edge_to_split = long_edge_splitter_split_edge(
        next_edge_to_split, dummy_node,
      )

      layer_index += 1
    }

    if target_layer > 0 {
      edge_count += 1
    }

    reverse_index -= 1
  }

  if no_incoming_edges {
    let mut layer_index = 0
    while layer_index < target_layer {
      let dummy_node = new_l_node(graph=Some(graph))
      dummy_node.set_type(NodeType::Placeholder)

      if node_index + edge_count > sub_layers[layer_index].get_nodes().length() {
        dummy_node.set_layer(Some(sub_layers[layer_index]))
      } else {
        alternating_layer_unzipper_set_layer_with_index(
          dummy_node,
          sub_layers[layer_index],
          node_index + edge_count,
        )
      }

      layer_index += 1
    }

    if target_layer > 0 {
      edge_count += 1
    }
  }

  let mut extra_edge = false
  let outgoing_edges = node.get_outgoing_edges().copy()
  for outgoing_edge in outgoing_edges {
    let mut next_edge_to_split = outgoing_edge
    let mut layer_index = target_layer + 1
    while layer_index < sub_layers.length() {
      let dummy_node = alternating_layer_unzipper_create_dummy_node(
        graph, next_edge_to_split,
      )
      dummy_node.set_layer(Some(sub_layers[layer_index]))
      next_edge_to_split = long_edge_splitter_split_edge(
        next_edge_to_split, dummy_node,
      )
      layer_index += 1
    }

    layer_index = 0
    while layer_index <= target_layer {
      if extra_edge {
        let placeholder = new_l_node(graph=Some(graph))
        placeholder.set_type(NodeType::NonshiftingPlaceholder)
        if node_index + 1 > sub_layers[layer_index].get_nodes().length() {
          placeholder.set_layer(Some(sub_layers[layer_index]))
        } else {
          alternating_layer_unzipper_set_layer_with_index(
            placeholder,
            sub_layers[layer_index],
            node_index + 1,
          )
        }
      }
      layer_index += 1
    }

    if extra_edge {
      edge_count += 1
    }
    extra_edge = true
  }

  if edge_count > 0 {
    edge_count - 1
  } else {
    0
  }
}

///|
fn alternating_layer_unzipper_process(
  graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  ignore(progress_monitor)

  let mut insertion_layer_offset = 1
  let new_layers : Array[AlternatingLayerUnzipperPendingLayer] = []
  let layers = graph.get_layers()
  let mut layer_index = 0

  while layer_index < layers.length() {
    let current_layer = layers[layer_index]
    let layer_split = alternating_layer_unzipper_get_layer_split_property(
      current_layer,
    )
    let reset_on_long_edges = alternating_layer_unzipper_get_reset_on_long_edges_property(
      current_layer,
    )
    let minimize_edge_length = alternating_layer_unzipper_get_minimize_edge_length_property(
      current_layer,
    )

    if minimize_edge_length {
      let mut max_width = 0.0
      let mut average_height = 0.0
      for node in current_layer.get_nodes() {
        max_width = alternating_layer_unzipper_max_double(
          max_width,
          node.get_size().x,
        )
        average_height += node.get_size().y
      }

      average_height = average_height /
        current_layer.get_nodes().length().to_double()

      max_width += alternating_layer_unzipper_max_double(
        2.0 *
        graph.get_property_double(
          layered_options_spacing_edge_node_between_layers,
        ),
        alternating_layer_unzipper_max_double(
          current_layer.get_nodes().length().to_double() *
          graph.get_property_double(
            layered_options_spacing_edge_edge_between_layers,
          ),
          graph.get_property_double(
            layered_options_spacing_node_node_between_layers,
          ),
        ),
      )
      average_height += alternating_layer_unzipper_max_double(
        graph.get_property_double(spacing_node_node),
        graph.get_property_double(spacing_edge_node),
      )

      if max_width / average_height >=
        current_layer.get_nodes().length().to_double() / 4.0 {
        layer_index += 1
        continue
      }
    }

    if current_layer.get_nodes().length() > layer_split {
      let sub_layers : Array[Layer] = [current_layer]
      for j in 0..<(layer_split - 1) {
        let next_layer = new_layer(graph)
        new_layers.push({
          layer: next_layer,
          insertion_index: layer_index + j + insertion_layer_offset,
        })
        sub_layers.push(next_layer)
      }
      insertion_layer_offset += layer_split - 1

      let nodes_in_layer = sub_layers[0].get_nodes().length()
      let mut i = 0
      let mut node_index = 0
      let mut target_sub_layer = 0
      while i < nodes_in_layer {
        let node = sub_layers[0].get_nodes()[node_index]
        if !alternating_layer_unzipper_node_type_equals(
            node.get_type(),
            NodeType::NonshiftingPlaceholder,
          ) {
          node_index += alternating_layer_unzipper_shift_node(
            graph,
            sub_layers,
            target_sub_layer % layer_split,
            node_index,
          )
        } else {
          i -= 1
          target_sub_layer -= 1
        }

        if reset_on_long_edges &&
          alternating_layer_unzipper_node_type_equals(
            node.get_type(),
            NodeType::LongEdge,
          ) {
          target_sub_layer = -1
        }

        i += 1
        node_index += 1
        target_sub_layer += 1
      }
    }

    layer_index += 1
  }

  for pending_layer in new_layers {
    ignore(
      graph
      .get_layers()
      .insert(pending_layer.insertion_index, pending_layer.layer),
    )
  }

  for layer in graph.get_layers() {
    let nodes = layer.get_nodes()
    let mut i = 0
    while i < nodes.length() {
      let node_type = nodes[i].get_type()
      if alternating_layer_unzipper_node_type_equals(
          node_type,
          NodeType::Placeholder,
        ) ||
        alternating_layer_unzipper_node_type_equals(
          node_type,
          NodeType::NonshiftingPlaceholder,
        ) {
        ignore(nodes.remove(i))
      } else {
        i += 1
      }
    }
  }
}

///|
pub fn new_alternating_layer_unzipper_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(alternating_layer_unzipper_process)
}
