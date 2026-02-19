///|
enum HyperedgeCornerType {
  Upper
  Lower
}

///|
struct Hyperedge {
  id : Int
  edges : Array[LEdge]
  ports : Array[LPort]
  mut upper_left : Int
  mut lower_left : Int
  mut upper_right : Int
  mut lower_right : Int
  mut active : Bool
}

///|
struct HyperedgeCorner {
  hyperedge_id : Int
  position : Int
  opposite_position : Int
  corner_type : HyperedgeCornerType
}

///|
pub struct HyperedgeCrossingsCounter {
  port_pos : Array[Int]
}

///|
pub fn new_hyperedge_crossings_counter(
  in_layer_edge_count : Array[Int],
  has_north_south_ports : Array[Bool],
  port_pos : Array[Int],
) -> HyperedgeCrossingsCounter {
  ignore(in_layer_edge_count)
  ignore(has_north_south_ports)
  { port_pos, }
}

///|
fn hyperedge_sort_compare(left : Hyperedge, right : Hyperedge) -> Int {
  if left.upper_left < right.upper_left {
    -1
  } else if left.upper_left > right.upper_left {
    1
  } else if left.upper_right < right.upper_right {
    -1
  } else if left.upper_right > right.upper_right {
    1
  } else if left.id < right.id {
    -1
  } else if left.id > right.id {
    1
  } else {
    0
  }
}

///|
fn hyperedge_corner_sort_compare(
  left : HyperedgeCorner,
  right : HyperedgeCorner,
) -> Int {
  if left.position < right.position {
    -1
  } else if left.position > right.position {
    1
  } else if left.opposite_position < right.opposite_position {
    -1
  } else if left.opposite_position > right.opposite_position {
    1
  } else if left.hyperedge_id < right.hyperedge_id {
    -1
  } else if left.hyperedge_id > right.hyperedge_id {
    1
  } else {
    match (left.corner_type, right.corner_type) {
      (Upper, Lower) => -1
      (Lower, Upper) => 1
      _ => 0
    }
  }
}

///|
fn hyperedge_insertion_sort(hyperedges : Array[Hyperedge]) -> Unit {
  let length = hyperedges.length()
  for i in 1..<length {
    let current = hyperedges[i]
    let mut j = i
    while j > 0 && hyperedge_sort_compare(current, hyperedges[j - 1]) < 0 {
      hyperedges[j] = hyperedges[j - 1]
      j = j - 1
    }
    hyperedges[j] = current
  }
}

///|
fn hyperedge_corner_insertion_sort(corners : Array[HyperedgeCorner]) -> Unit {
  let length = corners.length()
  for i in 1..<length {
    let current = corners[i]
    let mut j = i
    while j > 0 && hyperedge_corner_sort_compare(current, corners[j - 1]) < 0 {
      corners[j] = corners[j - 1]
      j = j - 1
    }
    corners[j] = current
  }
}

///|
fn hyperedge_counter_add_port_to_hyperedge(
  hyperedges : Array[Hyperedge],
  index : Int,
  port : LPort,
) -> Unit {
  hyperedges[index].ports.push(port)
}

///|
fn hyperedge_counter_add_edge_to_hyperedge(
  hyperedges : Array[Hyperedge],
  index : Int,
  edge : LEdge,
) -> Unit {
  hyperedges[index].edges.push(edge)
}

///|
fn hyperedge_counter_port_node_layer(port : LPort) -> Layer? {
  match port.get_node() {
    Some(node) => node.get_layer()
    None => None
  }
}

///|
fn hyperedge_counter_crosses_layer(node : LNode, edge : LEdge) -> Bool {
  match edge.get_target() {
    Some(target_port) =>
      match target_port.get_node() {
        Some(target_node) =>
          match (node.get_layer(), target_node.get_layer()) {
            (Some(source_layer), Some(target_layer)) =>
              layer_internal_handle(source_layer) !=
              layer_internal_handle(target_layer)
            _ => false
          }
        None => false
      }
    None => false
  }
}

///|
fn hyperedge_counter_crosses_layer_from_right(
  node : LNode,
  edge : LEdge,
) -> Bool {
  match edge.get_source() {
    Some(source_port) =>
      match source_port.get_node() {
        Some(source_node) =>
          match (node.get_layer(), source_node.get_layer()) {
            (Some(target_layer), Some(source_layer)) =>
              layer_internal_handle(target_layer) !=
              layer_internal_handle(source_layer)
            _ => false
          }
        None => false
      }
    None => false
  }
}

///|
fn hyperedge_counter_port_side_equals(
  left : @core.PortSide,
  right : @core.PortSide,
) -> Bool {
  match (left, right) {
    (@core.PortSide::North, @core.PortSide::North) => true
    (@core.PortSide::East, @core.PortSide::East) => true
    (@core.PortSide::South, @core.PortSide::South) => true
    (@core.PortSide::West, @core.PortSide::West) => true
    (@core.PortSide::SideUndefined, @core.PortSide::SideUndefined) => true
    _ => false
  }
}

///|
pub fn HyperedgeCrossingsCounter::count_crossings(
  self : HyperedgeCrossingsCounter,
  left_layer : Array[LNode],
  right_layer : Array[LNode],
) -> Int {
  if left_layer.is_empty() || right_layer.is_empty() {
    return 0
  }

  let mut source_count = 0
  for node in left_layer {
    for port in node.get_ports() {
      let mut port_edges = 0
      for edge in port.get_outgoing_edges() {
        if hyperedge_counter_crosses_layer(node, edge) {
          port_edges = port_edges + 1
        }
      }
      if port_edges > 0 {
        self.port_pos[port.get_id()] = source_count
        source_count = source_count + 1
      }
    }
  }

  let mut target_count = 0
  for node in right_layer {
    let mut north_input_ports = 0
    for port in node.get_ports() {
      if hyperedge_counter_port_side_equals(port.get_side(), @core.PortSide::North) {
        for edge in port.get_incoming_edges() {
          if hyperedge_counter_crosses_layer_from_right(node, edge) {
            north_input_ports = north_input_ports + 1
            break
          }
        }
      } else {
        break
      }
    }

    let mut other_input_ports = 0
    let ports = node.get_ports()
    let mut i = ports.length()
    while i > 0 {
      i = i - 1
      let port = ports[i]
      let mut port_edges = 0
      for edge in port.get_incoming_edges() {
        if hyperedge_counter_crosses_layer_from_right(node, edge) {
          port_edges = port_edges + 1
        }
      }

      if port_edges > 0 {
        if hyperedge_counter_port_side_equals(port.get_side(), @core.PortSide::North) {
          self.port_pos[port.get_id()] = target_count
          target_count = target_count + 1
        } else {
          self.port_pos[port.get_id()] = target_count +
            north_input_ports +
            other_input_ports
          other_input_ports = other_input_ports + 1
        }
      }
    }

    target_count = target_count + other_input_ports
  }

  let port_to_hyperedge : Map[Int, Int] = {}
  let hyperedges = []

  for node in left_layer {
    for source_port in node.get_ports() {
      for edge in source_port.get_outgoing_edges() {
        let target_port = match edge.get_target() {
          Some(port) => port
          None => continue
        }

        if !hyperedge_counter_crosses_layer(node, edge) {
          continue
        }

        let source_handle = lport_internal_handle(source_port)
        let target_handle = lport_internal_handle(target_port)

        let source_he = port_to_hyperedge.get(source_handle)
        let target_he = port_to_hyperedge.get(target_handle)

        match (source_he, target_he) {
          (None, None) => {
            let hyperedge_index = hyperedges.length()
            hyperedges.push({
              id: hyperedge_index,
              edges: [edge],
              ports: [source_port, target_port],
              upper_left: 0,
              lower_left: 0,
              upper_right: 0,
              lower_right: 0,
              active: true,
            })
            port_to_hyperedge[source_handle] = hyperedge_index
            port_to_hyperedge[target_handle] = hyperedge_index
          }
          (None, Some(target_idx)) => {
            hyperedge_counter_add_edge_to_hyperedge(
              hyperedges, target_idx, edge,
            )
            hyperedge_counter_add_port_to_hyperedge(
              hyperedges, target_idx, source_port,
            )
            port_to_hyperedge[source_handle] = target_idx
          }
          (Some(source_idx), None) => {
            hyperedge_counter_add_edge_to_hyperedge(
              hyperedges, source_idx, edge,
            )
            hyperedge_counter_add_port_to_hyperedge(
              hyperedges, source_idx, target_port,
            )
            port_to_hyperedge[target_handle] = source_idx
          }
          (Some(source_idx), Some(target_idx)) =>
            if source_idx == target_idx {
              hyperedge_counter_add_edge_to_hyperedge(
                hyperedges, source_idx, edge,
              )
            } else {
              hyperedge_counter_add_edge_to_hyperedge(
                hyperedges, source_idx, edge,
              )

              for p in hyperedges[target_idx].ports {
                port_to_hyperedge[lport_internal_handle(p)] = source_idx
              }
              for target_edge in hyperedges[target_idx].edges {
                hyperedges[source_idx].edges.push(target_edge)
              }
              for p in hyperedges[target_idx].ports {
                hyperedges[source_idx].ports.push(p)
              }
              hyperedges[target_idx].active = false
            }
        }
      }
    }
  }

  let active_hyperedges = []
  for hyperedge in hyperedges {
    if hyperedge.active {
      active_hyperedges.push(hyperedge)
    }
  }

  if active_hyperedges.is_empty() {
    return 0
  }

  let left_layer_ref = match left_layer[0].get_layer() {
    Some(layer) => layer
    None => return 0
  }
  let right_layer_ref = match right_layer[0].get_layer() {
    Some(layer) => layer
    None => return 0
  }

  for hyperedge in active_hyperedges {
    hyperedge.upper_left = source_count
    hyperedge.upper_right = target_count

    for port in hyperedge.ports {
      let pos = self.port_pos[port.get_id()]
      match hyperedge_counter_port_node_layer(port) {
        Some(layer) =>
          if layer_internal_handle(layer) ==
            layer_internal_handle(left_layer_ref) {
            if pos < hyperedge.upper_left {
              hyperedge.upper_left = pos
            }
            if pos > hyperedge.lower_left {
              hyperedge.lower_left = pos
            }
          } else if layer_internal_handle(layer) ==
            layer_internal_handle(right_layer_ref) {
            if pos < hyperedge.upper_right {
              hyperedge.upper_right = pos
            }
            if pos > hyperedge.lower_right {
              hyperedge.lower_right = pos
            }
          }
        None => ()
      }
    }
  }

  hyperedge_insertion_sort(active_hyperedges)

  let south_sequence = Array::make(active_hyperedges.length(), 0)
  let compress_deltas = Array::make(target_count + 1, 0)

  for i in 0..<active_hyperedges.length() {
    south_sequence[i] = active_hyperedges[i].upper_right
    compress_deltas[south_sequence[i]] = 1
  }

  let mut delta = 0
  for i in 0..<compress_deltas.length() {
    if compress_deltas[i] == 1 {
      compress_deltas[i] = delta
    } else {
      delta = delta - 1
    }
  }

  let mut q = 0
  for i in 0..<south_sequence.length() {
    south_sequence[i] = south_sequence[i] + compress_deltas[south_sequence[i]]
    if south_sequence[i] + 1 > q {
      q = south_sequence[i] + 1
    }
  }

  let mut first_index = 1
  while first_index < q {
    first_index = first_index * 2
  }

  let tree_size = 2 * first_index - 1
  first_index = first_index - 1
  let tree = Array::make(tree_size, 0)

  let mut crossings = 0
  for k in 0..<south_sequence.length() {
    let mut index = south_sequence[k] + first_index
    tree[index] = tree[index] + 1
    while index > 0 {
      if index % 2 > 0 {
        crossings = crossings + tree[index + 1]
      }
      index = (index - 1) / 2
      tree[index] = tree[index] + 1
    }
  }

  let left_corners = []
  for hyperedge in active_hyperedges {
    left_corners.push({
      hyperedge_id: hyperedge.id,
      position: hyperedge.upper_left,
      opposite_position: hyperedge.lower_left,
      corner_type: Upper,
    })
    left_corners.push({
      hyperedge_id: hyperedge.id,
      position: hyperedge.lower_left,
      opposite_position: hyperedge.upper_left,
      corner_type: Lower,
    })
  }

  hyperedge_corner_insertion_sort(left_corners)

  let mut open_hyperedges = 0
  for corner in left_corners {
    match corner.corner_type {
      Upper => open_hyperedges = open_hyperedges + 1
      Lower => {
        open_hyperedges = open_hyperedges - 1
        crossings = crossings + open_hyperedges
      }
    }
  }

  let right_corners = []
  for hyperedge in active_hyperedges {
    right_corners.push({
      hyperedge_id: hyperedge.id,
      position: hyperedge.upper_right,
      opposite_position: hyperedge.lower_right,
      corner_type: Upper,
    })
    right_corners.push({
      hyperedge_id: hyperedge.id,
      position: hyperedge.lower_right,
      opposite_position: hyperedge.upper_right,
      corner_type: Lower,
    })
  }

  hyperedge_corner_insertion_sort(right_corners)

  open_hyperedges = 0
  for corner in right_corners {
    match corner.corner_type {
      Upper => open_hyperedges = open_hyperedges + 1
      Lower => {
        open_hyperedges = open_hyperedges - 1
        crossings = crossings + open_hyperedges
      }
    }
  }

  crossings
}
