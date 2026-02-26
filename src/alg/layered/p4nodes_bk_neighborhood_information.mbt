///|
pub struct NeighborhoodInformation {
  mut node_count : Int
  mut layer_index : Array[Int]
  mut node_index : Array[Int]
  mut left_neighbors : Array[Array[(LNode, LEdge)]]
  mut right_neighbors : Array[Array[(LNode, LEdge)]]
}

///|
fn bk_neighbor_lists_with_capacity(count : Int) -> Array[Array[(LNode, LEdge)]] {
  let lists : Array[Array[(LNode, LEdge)]] = []
  for i = 0; i < count; i = i + 1 {
    ignore(i)
    lists.push([])
  }
  lists
}

///|
fn new_neighborhood_information() -> NeighborhoodInformation {
  {
    node_count: 0,
    layer_index: [],
    node_index: [],
    left_neighbors: [],
    right_neighbors: [],
  }
}

///|
pub fn NeighborhoodInformation::cleanup(self : NeighborhoodInformation) -> Unit {
  self.layer_index.clear()
  self.node_index.clear()
  self.left_neighbors.clear()
  self.right_neighbors.clear()
}

///|
fn neighborhood_information_sort_neighbors(
  ni : NeighborhoodInformation,
  neighbors : Array[(LNode, LEdge)],
) -> Unit {
  let mut i = 1
  while i < neighbors.length() {
    let current = neighbors[i]
    let current_index = ni.node_index[current.0.get_id()]
    let mut j = i
    while j > 0 {
      let previous = neighbors[j - 1]
      let previous_index = ni.node_index[previous.0.get_id()]
      if previous_index <= current_index {
        break
      }
      neighbors[j] = previous
      j -= 1
    }
    neighbors[j] = current
    i += 1
  }
}

///|
fn neighborhood_information_determine_all_right_neighbors(
  ni : NeighborhoodInformation,
  graph : LGraph,
) -> Unit {
  for layer in graph.get_layers() {
    for node in layer.get_nodes() {
      let result : Array[(LNode, LEdge)] = []
      let mut max_priority = 0

      for edge in node.get_outgoing_edges() {
        if edge.is_self_loop() || edge.is_in_layer_edge() {
          continue
        }

        let edge_priority = edge.get_property_int(
          layered_options_priority_straightness,
        )
        if edge_priority > max_priority {
          max_priority = edge_priority
          result.clear()
        }
        if edge_priority == max_priority {
          let target_port = match edge.get_target() {
            Some(value) => value
            None => continue
          }
          let target_node = match target_port.get_node() {
            Some(value) => value
            None => continue
          }
          let target_id = target_node.get_id()
          if target_id < 0 || target_id >= ni.node_index.length() {
            continue
          }
          result.push((target_node, edge))
        }
      }

      neighborhood_information_sort_neighbors(ni, result)
      ni.right_neighbors[node.get_id()] = result
    }
  }
}

///|
fn neighborhood_information_determine_all_left_neighbors(
  ni : NeighborhoodInformation,
  graph : LGraph,
) -> Unit {
  for layer in graph.get_layers() {
    for node in layer.get_nodes() {
      let result : Array[(LNode, LEdge)] = []
      let mut max_priority = 0

      for edge in node.get_incoming_edges() {
        if edge.is_self_loop() || edge.is_in_layer_edge() {
          continue
        }

        let edge_priority = edge.get_property_int(
          layered_options_priority_straightness,
        )
        if edge_priority > max_priority {
          max_priority = edge_priority
          result.clear()
        }
        if edge_priority == max_priority {
          let source_port = match edge.get_source() {
            Some(value) => value
            None => continue
          }
          let source_node = match source_port.get_node() {
            Some(value) => value
            None => continue
          }
          let source_id = source_node.get_id()
          if source_id < 0 || source_id >= ni.node_index.length() {
            continue
          }
          result.push((source_node, edge))
        }
      }

      neighborhood_information_sort_neighbors(ni, result)
      ni.left_neighbors[node.get_id()] = result
    }
  }
}

///|
pub fn neighborhood_information_build_for(
  graph : LGraph,
) -> NeighborhoodInformation {
  let ni = new_neighborhood_information()

  ni.node_count = 0
  for layer in graph.get_layers() {
    ni.node_count += layer.get_nodes().length()
  }

  ni.layer_index = Array::make(graph.get_layers().length(), 0)
  ni.node_index = Array::make(ni.node_count, 0)

  let mut layer_id = 0
  let mut layer_pos = 0
  let mut node_id = 0
  for layer in graph.get_layers() {
    layer.set_id(layer_id)
    ni.layer_index[layer_id] = layer_pos
    layer_id += 1
    layer_pos += 1

    let mut node_pos = 0
    for node in layer.get_nodes() {
      node.set_id(node_id)
      ni.node_index[node_id] = node_pos
      node_id += 1
      node_pos += 1
    }
  }

  ni.left_neighbors = bk_neighbor_lists_with_capacity(ni.node_count)
  ni.right_neighbors = bk_neighbor_lists_with_capacity(ni.node_count)

  neighborhood_information_determine_all_left_neighbors(ni, graph)
  neighborhood_information_determine_all_right_neighbors(ni, graph)

  ni
}
