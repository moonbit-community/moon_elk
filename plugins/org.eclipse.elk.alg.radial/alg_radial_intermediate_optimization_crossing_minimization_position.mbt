///|
fn crossing_minimization_position_is_crossing(
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

///|
fn crossing_minimization_position_evaluate(root : ElkNode) -> Double {
  let mut crossings = 0
  let nodes = radial_get_successors(root)
  let mut k = 0
  while k < nodes.length() {
    let node1 = nodes[k]
    let mut i = k + 1
    while i < nodes.length() {
      if crossing_minimization_position_is_crossing(root, node1, nodes[i]) {
        crossings += 1
      }
      i += 1
    }
    k += 1
  }
  crossings.to_double()
}

///|
pub struct CrossingMinimizationPosition {
  evaluator : IEvaluation
}

///|
pub fn new_crossing_minimization_position() -> CrossingMinimizationPosition {
  { evaluator: new_i_evaluation(crossing_minimization_position_evaluate) }
}

///|
pub fn CrossingMinimizationPosition::evaluate(
  self : CrossingMinimizationPosition,
  root : ElkNode,
) -> Double {
  self.evaluator.evaluate(root)
}

///|
pub fn CrossingMinimizationPosition::as_i_evaluation(
  self : CrossingMinimizationPosition,
) -> IEvaluation {
  self.evaluator
}
