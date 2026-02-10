///|
pub fn radial_evaluate_translation(
  strategy : RadialTranslationStrategy,
  root : ElkNode,
) -> Double {
  match strategy {
    RadialTranslationStrategy::NONE => 0.0
    RadialTranslationStrategy::EDGE_LENGTH => radial_evaluate_edge_length(root)
    RadialTranslationStrategy::EDGE_LENGTH_BY_POSITION =>
      radial_evaluate_edge_length_by_position(root)
    RadialTranslationStrategy::CROSSING_MINIMIZATION_BY_POSITION =>
      radial_evaluate_crossing_minimization_by_position(root).to_double()
  }
}

///|
fn radial_evaluate_edge_length(root : ElkNode) -> Double {
  let mut edge_length = 0.0
  for edge in node_outgoing_edges(root) {
    let targets = edge_targets(edge)
    if targets.is_empty() {
      continue
    }
    let target = connectable_shape_to_node(Some(targets[0]))
    let mut target_x = node_x(target) + node_width(target) / 2.0
    let mut target_y = node_y(target) + node_height(target) / 2.0
    let mut root_x = node_x(root) + node_width(root) / 2.0
    let mut root_y = node_y(root) + node_height(root) / 2.0

    let vector = new_kvector_xy(target_x - root_x, target_y - root_y)
    let source_clip = new_kvector_copy(vector)
    ignore(clip_vector(source_clip, node_width(root), node_height(root)))
    vector.x -= source_clip.x
    vector.y -= source_clip.y

    root_x = target_x - vector.x
    root_y = target_y - vector.y

    let target_clip = new_kvector_copy(vector)
    ignore(clip_vector(target_clip, node_width(target), node_height(target)))
    vector.x -= target_clip.x
    vector.y -= target_clip.y

    target_x = root_x + vector.x
    target_y = root_y + vector.y

    let vector_x = target_x - root_x
    let vector_y = target_y - root_y
    edge_length += (vector_x * vector_x + vector_y * vector_y).sqrt()
  }
  edge_length
}

///|
fn radial_evaluate_edge_length_by_position(root : ElkNode) -> Double {
  let mut edge_length = 0.0
  for edge in node_outgoing_edges(root) {
    let targets = edge_targets(edge)
    if targets.is_empty() {
      continue
    }
    let target = connectable_shape_to_node(Some(targets[0]))
    let target_x = node_x(target) + node_width(target) / 2.0
    let target_y = node_y(target) + node_height(target) / 2.0

    let position = radial_internal_position(target)
    let root_x = node_x(root) + position.x + node_width(root) / 2.0
    let root_y = node_y(root) + position.y + node_height(root)

    let vector_x = target_x - root_x
    let vector_y = target_y - root_y
    edge_length += (vector_x * vector_x + vector_y * vector_y).sqrt()
  }
  edge_length
}

///|
fn radial_evaluate_crossing_minimization_by_position(root : ElkNode) -> Int {
  let mut crossings = 0
  let nodes = radial_get_successors(root)
  let mut k = 0
  while k < nodes.length() {
    let node1 = nodes[k]
    let mut i = k + 1
    while i < nodes.length() {
      if radial_is_crossing_by_position(root, node1, nodes[i]) {
        crossings += 1
      }
      i += 1
    }
    k += 1
  }
  crossings
}

///|
fn radial_is_crossing_by_position(
  root : ElkNode,
  node1 : ElkNode,
  node2 : ElkNode,
) -> Bool {
  let root_x = node_x(root) + node_width(root) / 2.0
  let root_y = node_x(root) + node_width(root) / 2.0

  let x_pos1 = node_x(node1) + node_width(node1) / 2.0
  let y_pos1 = node_y(node1) + node_height(node1) / 2.0
  let node1_vector = new_kvector_xy(x_pos1, y_pos1)

  let position1 = radial_internal_position(node1)
  position1.x = position1.x + root_x
  position1.y = position1.y + root_y

  let m1 = (node1_vector.y - position1.y) / (node1_vector.x - position1.x)
  let b1 = node1_vector.y - m1 * node1_vector.x

  let x_pos2 = node_x(node2) + node_width(node2) / 2.0
  let y_pos2 = node_y(node2) + node_height(node2) / 2.0
  let node2_vector = new_kvector_xy(x_pos2, y_pos2)

  let position2 = radial_internal_position(node2)
  position2.x = position2.x + root_x
  position2.y = position2.y + root_y

  let m2 = (node2_vector.y - position2.y) / (node2_vector.x - position2.x)
  let b2 = node2_vector.y - m2 * node2_vector.x

  let x_cut = (b1 - b2) / (m2 - m1)
  if (position1.x < x_cut && node1_vector.x < x_cut) ||
    (x_cut < position1.x && x_cut < node1_vector.x) {
    return false
  }
  if (position2.x < x_cut && node2_vector.x < x_cut) ||
    (x_cut < position2.x && x_cut < node2_vector.x) {
    return false
  }
  true
}
