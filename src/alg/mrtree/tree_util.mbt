///|
fn mrtree_direction_is_horizontal(direction_value : String) -> Bool {
  direction_value == "LEFT" || direction_value == "RIGHT"
}

///|
fn mrtree_direction_is_vertical(direction_value : String) -> Bool {
  !mrtree_direction_is_horizontal(direction_value)
}

///|
pub fn mrtree_tree_util_get_root(graph : MrtreeGraph) -> MrtreeNode? {
  for node in mrtree_graph_nodes(graph) {
    if mrtree_node_root(node) {
      return Some(node)
    }
  }
  None
}

///|
pub fn mrtree_tree_util_depth(root : MrtreeNode) -> Int {
  let children = mrtree_tree_util_get_children(root)
  if children.length() == 0 {
    1
  } else {
    let mut max_depth = 0
    for child in children {
      let child_depth = mrtree_tree_util_depth(child)
      if child_depth > max_depth {
        max_depth = child_depth
      }
    }
    max_depth + 1
  }
}

///|
pub fn mrtree_tree_util_get_children(node : MrtreeNode) -> Array[MrtreeNode] {
  let children = []
  let seen : Map[MrtreeNode, Bool] = {}
  for edge in mrtree_node_outgoing_edges(node) {
    let target = mrtree_edge_target(edge)
    if !seen.contains(target) {
      seen[target] = true
      children.push(target)
    }
  }
  children
}

///|
pub fn mrtree_tree_util_root_distance(
  node : MrtreeNode,
  root : MrtreeNode,
) -> Int {
  if node == root {
    return 0
  }
  if mrtree_node_incoming_edges(node).is_empty() {
    return 0
  }
  let parent = mrtree_edge_source(mrtree_node_incoming_edges(node)[0])
  mrtree_tree_util_root_distance(parent, root) + 1
}

///|
pub fn mrtree_tree_util_get_subtree(node : MrtreeNode) -> Array[MrtreeNode] {
  let children = mrtree_tree_util_get_children(node)
  if children.length() == 0 {
    return [node]
  }
  let subtree = []
  for child in children {
    for subtree_node in mrtree_tree_util_get_subtree(child) {
      subtree.push(subtree_node)
    }
  }
  subtree.push(node)
  subtree
}

///|
pub fn mrtree_tree_util_get_first_point(edge : MrtreeEdge) -> @core.KVector {
  let bend_points = mrtree_edge_bend_points(edge)
  if bend_points.size() == 0 {
    let target = mrtree_edge_target(edge)
    @core.new_kvector_copy(mrtree_node_position(target))
  } else {
    bend_points.get(0)
  }
}

///|
pub fn mrtree_tree_util_get_last_point(edge : MrtreeEdge) -> @core.KVector {
  let bend_points = mrtree_edge_bend_points(edge)
  if bend_points.size() == 0 {
    let source = mrtree_edge_source(edge)
    @core.new_kvector_copy(mrtree_node_position(source))
  } else {
    bend_points.get(bend_points.size() - 1)
  }
}

///|
pub fn mrtree_tree_util_get_direction(graph : MrtreeGraph) -> String {
  mrtree_graph_direction(graph)
}

///|
pub fn mrtree_tree_util_get_direction_vector(
  direction_value : String,
) -> @core.KVector {
  if direction_value == "UP" {
    @core.new_kvector_xy(0.0, -1.0)
  } else if direction_value == "RIGHT" {
    @core.new_kvector_xy(1.0, 0.0)
  } else if direction_value == "LEFT" {
    @core.new_kvector_xy(-1.0, 0.0)
  } else {
    @core.new_kvector_xy(0.0, 1.0)
  }
}

///|
pub fn mrtree_tree_util_get_node_size_in_direction(
  node : MrtreeNode,
  direction_value : String,
) -> Double {
  if direction_value == "LEFT" {
    -mrtree_node_size(node).x / 2.0
  } else if direction_value == "UP" {
    -mrtree_node_size(node).y / 2.0
  } else if direction_value == "RIGHT" {
    mrtree_node_size(node).x / 2.0
  } else {
    mrtree_node_size(node).y / 2.0
  }
}

///|
pub fn mrtree_tree_util_get_node_size_vector_in_direction(
  node : MrtreeNode,
  direction_value : String,
) -> @core.KVector {
  if direction_value == "LEFT" {
    @core.new_kvector_xy(-mrtree_node_size(node).x / 2.0, 0.0)
  } else if direction_value == "UP" {
    @core.new_kvector_xy(0.0, -mrtree_node_size(node).y / 2.0)
  } else if direction_value == "RIGHT" {
    @core.new_kvector_xy(mrtree_node_size(node).x / 2.0, 0.0)
  } else {
    @core.new_kvector_xy(0.0, mrtree_node_size(node).y / 2.0)
  }
}

///|
pub fn mrtree_tree_util_turn_right(direction_value : String) -> String {
  if direction_value == "LEFT" {
    "UP"
  } else if direction_value == "UP" {
    "RIGHT"
  } else if direction_value == "RIGHT" {
    "DOWN"
  } else {
    "LEFT"
  }
}

///|
pub fn mrtree_tree_util_turn_left(direction_value : String) -> String {
  if direction_value == "RIGHT" {
    "UP"
  } else if direction_value == "UP" {
    "LEFT"
  } else if direction_value == "LEFT" {
    "DOWN"
  } else {
    "RIGHT"
  }
}

///|
pub fn mrtree_tree_util_to_node_border(
  center : @core.KVector,
  next : @core.KVector,
  size : @core.KVector,
) -> Unit {
  let wh = size.x / 2.0
  let hh = size.y / 2.0
  let absx = (next.x - center.x).abs()
  let absy = (next.y - center.y).abs()
  let mut xscale = 1.0
  let mut yscale = 1.0
  if absx > wh {
    xscale = wh / absx
  }
  if absy > hh {
    yscale = hh / absy
  }
  let scale = if xscale < yscale { xscale } else { yscale }
  center.x = center.x + scale * (next.x - center.x)
  center.y = center.y + scale * (next.y - center.y)
}

///|
pub fn mrtree_tree_util_is_cycle_inducing(
  edge : MrtreeEdge,
  graph : MrtreeGraph,
) -> Bool {
  let direction_value = mrtree_graph_direction(graph)
  let direction_vector = mrtree_tree_util_get_direction_vector(direction_value)
  let source = mrtree_edge_source(edge)
  let target = mrtree_edge_target(edge)
  let source_position = mrtree_node_position(source)
  let target_position = mrtree_node_position(target)
  let edge_vector = @core.new_kvector_xy(
    target_position.x - source_position.x,
    target_position.y - source_position.y,
  )
  direction_vector.dot_product(edge_vector) <= 0.0
}

///|
pub fn mrtree_tree_util_get_unique_long(a : Int, b : Int) -> Int64 {
  (Int64::from_int(a) << 32) | (Int64::from_int(b) & 4294967295L)
}

///|
fn mrtree_tree_util_edge_signature(edge : MrtreeEdge) -> String {
  let source = mrtree_edge_source(edge)
  let target = mrtree_edge_target(edge)
  "\{mrtree_node_id(source).to_string()}->\{mrtree_node_id(target).to_string()}"
}

///|
fn mrtree_tree_util_sort_edges_by_source_x(edges : Array[MrtreeEdge]) -> Unit {
  let length = edges.length()
  for i in 1..<length {
    let current = edges[i]
    let current_x = mrtree_node_position(mrtree_edge_source(current)).x
    let mut j = i
    while j > 0 &&
          current_x < mrtree_node_position(mrtree_edge_source(edges[j - 1])).x {
      edges[j] = edges[j - 1]
      j -= 1
    }
    edges[j] = current
  }
}

///|
fn mrtree_tree_util_sort_edges_by_target_x(edges : Array[MrtreeEdge]) -> Unit {
  let length = edges.length()
  for i in 1..<length {
    let current = edges[i]
    let current_x = mrtree_node_position(mrtree_edge_target(current)).x
    let mut j = i
    while j > 0 &&
          current_x < mrtree_node_position(mrtree_edge_target(edges[j - 1])).x {
      edges[j] = edges[j - 1]
      j -= 1
    }
    edges[j] = current
  }
}

///|
pub fn mrtree_tree_util_get_all_incoming_edges(
  node : MrtreeNode,
  graph : MrtreeGraph,
) -> Array[MrtreeEdge] {
  let result = []
  let signatures : Map[String, Bool] = {}
  for edge in mrtree_graph_edges(graph) {
    let source = mrtree_edge_source(edge)
    let target = mrtree_edge_target(edge)
    if mrtree_node_id(target) == mrtree_node_id(node) &&
      mrtree_node_tree_level(source) != mrtree_node_tree_level(target) {
      let signature = mrtree_tree_util_edge_signature(edge)
      if !signatures.contains(signature) {
        signatures[signature] = true
        result.push(edge)
      }
    }
  }
  mrtree_tree_util_sort_edges_by_source_x(result)
  result
}

///|
pub fn mrtree_tree_util_get_all_outgoing_edges(
  node : MrtreeNode,
  graph : MrtreeGraph,
) -> Array[MrtreeEdge] {
  let result = []
  let signatures : Map[String, Bool] = {}
  for edge in mrtree_graph_edges(graph) {
    let source = mrtree_edge_source(edge)
    let target = mrtree_edge_target(edge)
    if mrtree_node_id(source) == mrtree_node_id(node) &&
      mrtree_node_label(source) != "SUPER_ROOT" &&
      mrtree_node_tree_level(source) != mrtree_node_tree_level(target) {
      let signature = mrtree_tree_util_edge_signature(edge)
      if !signatures.contains(signature) {
        signatures[signature] = true
        result.push(edge)
      }
    }
  }
  mrtree_tree_util_sort_edges_by_target_x(result)
  result
}

///|
pub fn mrtree_tree_util_get_lowest_parent(
  node : MrtreeNode,
  graph : MrtreeGraph,
) -> MrtreeNode? {
  if mrtree_node_incoming_edges(node).is_empty() {
    return None
  }
  let direction_value = mrtree_graph_direction(graph)
  let direction_vector = mrtree_tree_util_get_direction_vector(direction_value)
  let mut best_parent : MrtreeNode? = None
  let mut best_projection = -1.0e20
  for edge in mrtree_node_incoming_edges(node) {
    let parent = mrtree_edge_source(edge)
    let parent_position = mrtree_node_position(parent)
    let parent_size = mrtree_node_size(parent)
    let center = @core.new_kvector_xy(
      parent_position.x + parent_size.x / 2.0,
      parent_position.y + parent_size.y / 2.0,
    )
    let projection = center.dot_product(direction_vector)
    if best_parent == None || projection > best_projection {
      best_parent = Some(parent)
      best_projection = projection
    }
  }
  best_parent
}

///|
pub fn mrtree_tree_util_get_left_most(
  current_level : Array[MrtreeNode],
  depth? : Int = -1,
) -> MrtreeNode? {
  if current_level.is_empty() {
    return None
  }
  let mut local_depth = depth
  if local_depth > 1 {
    local_depth -= 1
    let next_level = []
    for node in current_level {
      for child in mrtree_node_children_copy(node) {
        next_level.push(child)
      }
    }
    return mrtree_tree_util_get_left_most(next_level, depth=local_depth)
  }
  if local_depth < 0 {
    let next_level = []
    for node in current_level {
      for child in mrtree_node_children_copy(node) {
        next_level.push(child)
      }
    }
    if !next_level.is_empty() {
      return mrtree_tree_util_get_left_most(next_level, depth=local_depth)
    }
  }
  Some(current_level[0])
}

///|
pub fn mrtree_tree_util_direction_is_horizontal(
  direction_value : String,
) -> Bool {
  mrtree_direction_is_horizontal(direction_value)
}

///|
pub fn mrtree_tree_util_direction_is_vertical(direction_value : String) -> Bool {
  mrtree_direction_is_vertical(direction_value)
}
