///|
let radial_two_pi : Double = 2.0 * @math.PI

///|
let radial_epsilon : Double = 0.0000000001

///|
fn radial_double_fuzzy_compare(a : Double, b : Double, eps : Double) -> Int {
  let diff = a - b
  if diff.abs() <= eps {
    0
  } else if diff < 0.0 {
    -1
  } else {
    1
  }
}

///|
pub fn radial_sort_nodes(
  nodes : Array[@graph.ElkNode],
  comparator : (@graph.ElkNode, @graph.ElkNode) -> Int,
) -> Unit {
  let mut i = 1
  while i < nodes.length() {
    let value = nodes[i]
    let mut j = i
    while j > 0 && comparator(nodes[j - 1], value) > 0 {
      nodes[j] = nodes[j - 1]
      j = j - 1
    }
    nodes[j] = value
    i += 1
  }
}

///|
fn radial_node_set(nodes : Array[@graph.ElkNode]) -> Map[@graph.ElkNode, Bool] {
  let set = {}
  for node in nodes {
    set[node] = true
  }
  set
}

///|
fn radial_contains_node(
  set : Map[@graph.ElkNode, Bool],
  node : @graph.ElkNode,
) -> Bool {
  set.contains(node)
}

///|
pub fn radial_get_successors(node : @graph.ElkNode) -> Array[@graph.ElkNode] {
  let successors = []
  let children = radial_node_set(@graph.node_children(node))
  for edge in @graph.node_outgoing_edges(node) {
    let sources = @graph.edge_sources(edge)
    if sources.is_empty() {
      continue
    }
    if @graph.connectable_shape_to_port(Some(sources[0])) is Some(_) {
      continue
    }
    let targets = @graph.edge_targets(edge)
    if targets.is_empty() {
      continue
    }
    let target = @graph.connectable_shape_to_node(Some(targets[0]))
    if !radial_contains_node(children, target) {
      successors.push(target)
    }
  }
  successors
}

///|
pub fn radial_get_successor_set(node : @graph.ElkNode) -> Array[@graph.ElkNode] {
  let unique = {}
  let successors = []
  for successor in radial_get_successors(node) {
    if !unique.contains(successor) {
      unique[successor] = true
      successors.push(successor)
    }
  }
  successors
}

///|
pub fn radial_find_root(graph : @graph.ElkNode) -> @graph.ElkNode? {
  for child in @graph.node_children(graph) {
    if @graph.node_incoming_edges(child).is_empty() {
      return Some(child)
    }
  }
  None
}

///|
pub fn radial_find_root_of_node(elk_node : @graph.ElkNode) -> @graph.ElkNode {
  match radial_get_tree_parent(elk_node) {
    Some(parent) => radial_find_root_of_node(parent)
    None => elk_node
  }
}

///|
pub fn radial_get_number_of_leaves(node : @graph.ElkNode) -> Int {
  let successors = radial_get_successors(node)
  if successors.is_empty() {
    return 1
  }
  let mut leaves = 0
  for child in successors {
    leaves += radial_get_number_of_leaves(child)
  }
  leaves
}

///|
pub fn radial_create_polar_comparator(
  radial_offset : Double,
  node_offset_y : Double,
) -> (@graph.ElkNode, @graph.ElkNode) -> Int {
  (node1, node2) => {
    let position1 = radial_internal_position(node1)
    let x_pos1 = position1.x
    let y_pos1 = position1.y + node_offset_y
    let mut arc1 = @math.atan2(y_pos1, x_pos1)
    if arc1 < 0.0 {
      arc1 += radial_two_pi
    }
    arc1 += radial_offset
    if arc1 > radial_two_pi {
      arc1 -= radial_two_pi
    }

    let position2 = radial_internal_position(node2)
    let x_pos2 = position2.x
    let y_pos2 = position2.y + node_offset_y
    let mut arc2 = @math.atan2(y_pos2, x_pos2)
    if arc2 < 0.0 {
      arc2 += radial_two_pi
    }
    arc2 += radial_offset
    if arc2 > radial_two_pi {
      arc2 -= radial_two_pi
    }

    radial_double_fuzzy_compare(arc1, arc2, radial_epsilon)
  }
}

///|
pub fn radial_find_largest_node_in_graph(graph : @graph.ElkNode) -> Double {
  let mut largest_child_size = 0.0
  for child in @graph.node_children(graph) {
    let width = @graph.node_width(child)
    let height = @graph.node_height(child)
    let diameter = (width * width + height * height).sqrt()
    largest_child_size = if diameter > largest_child_size {
      diameter
    } else {
      largest_child_size
    }
    let largest_child = radial_find_largest_node_in_graph(child)
    largest_child_size = if largest_child > largest_child_size {
      largest_child
    } else {
      largest_child_size
    }
  }
  largest_child_size
}

///|
pub fn radial_get_next_level_nodes(
  nodes : Array[@graph.ElkNode],
) -> Array[@graph.ElkNode] {
  let successors = []
  for node in nodes {
    for successor in radial_get_successors(node) {
      successors.push(successor)
    }
  }
  successors
}

///|
pub fn radial_get_next_level_node_set(
  nodes : Array[@graph.ElkNode],
) -> Array[@graph.ElkNode] {
  let unique = {}
  let successors = []
  for node in nodes {
    for next_level in radial_get_successor_set(node) {
      if !unique.contains(next_level) {
        unique[next_level] = true
        successors.push(next_level)
      }
    }
  }
  successors
}

///|
pub fn radial_get_last_level_nodes(
  nodes : Array[@graph.ElkNode],
) -> Array[@graph.ElkNode] {
  let parents = []
  for node in nodes {
    match radial_get_tree_parent(node) {
      Some(parent) => parents.push(parent)
      None => ()
    }
  }
  parents
}

///|
pub fn radial_center_nodes_on_radi(
  node : @graph.ElkNode,
  x_pos : Double,
  y_pos : Double,
) -> Unit {
  let x_position = x_pos - @graph.node_width(node) / 2.0
  let y_position = y_pos - @graph.node_height(node) / 2.0
  @graph.node_set_location(node, x_position, y_position)
}

///|
pub fn radial_shift_closest_edge_to_radi(
  node : @graph.ElkNode,
  x_pos : Double,
  y_pos : Double,
) -> Unit {
  if x_pos.abs() <= radial_epsilon && y_pos.abs() <= radial_epsilon {
    @graph.node_set_location(
      node,
      x_pos - @graph.node_width(node) / 2.0,
      y_pos - @graph.node_height(node) / 2.0,
    )
  } else if x_pos < 0.0 {
    if y_pos < 0.0 {
      @graph.node_set_location(node, x_pos - @graph.node_width(node), y_pos)
    } else {
      @graph.node_set_location(
        node,
        x_pos - @graph.node_width(node),
        y_pos + @graph.node_height(node),
      )
    }
  } else if y_pos < 0.0 {
    @graph.node_set_location(node, x_pos, y_pos)
  } else {
    @graph.node_set_location(node, x_pos, y_pos + @graph.node_height(node))
  }
}

///|
pub fn radial_get_tree_parent(node : @graph.ElkNode) -> @graph.ElkNode? {
  let incoming = @graph.node_incoming_edges(node)
  if incoming.is_empty() {
    return None
  }
  let edge_from_parent = incoming[0]
  let sources = @graph.edge_sources(edge_from_parent)
  if sources.is_empty() {
    return None
  }
  Some(@graph.connectable_shape_to_node(Some(sources[0])))
}
