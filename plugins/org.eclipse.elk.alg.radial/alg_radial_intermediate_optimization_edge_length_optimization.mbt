///|
fn edge_length_optimization_evaluate(root : ElkNode) -> Double {
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
pub struct EdgeLengthOptimization {
  evaluator : IEvaluation
}

///|
pub fn new_edge_length_optimization() -> EdgeLengthOptimization {
  { evaluator: new_i_evaluation(edge_length_optimization_evaluate) }
}

///|
pub fn EdgeLengthOptimization::evaluate(
  self : EdgeLengthOptimization,
  root : ElkNode,
) -> Double {
  self.evaluator.evaluate(root)
}

///|
pub fn EdgeLengthOptimization::as_i_evaluation(
  self : EdgeLengthOptimization,
) -> IEvaluation {
  self.evaluator
}
