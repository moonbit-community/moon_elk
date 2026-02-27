///|
fn edge_length_position_optimization_evaluate(root : @graph.ElkNode) -> Double {
  let mut edge_length = 0.0
  for edge in @graph.node_outgoing_edges(root) {
    let targets = @graph.edge_targets(edge)
    if targets.is_empty() {
      continue
    }

    let target = try @graph.connectable_shape_to_node(Some(targets[0])) catch {
      _ => continue
    } noraise {
      value => value
    }
    let target_x = @graph.node_x(target) + @graph.node_width(target) / 2.0
    let target_y = @graph.node_y(target) + @graph.node_height(target) / 2.0

    let position = radial_internal_position(target)
    let root_x = @graph.node_x(root) +
      position.x +
      @graph.node_width(root) / 2.0
    let root_y = @graph.node_y(root) + position.y + @graph.node_height(root)

    let vector_x = target_x - root_x
    let vector_y = target_y - root_y
    edge_length += (vector_x * vector_x + vector_y * vector_y).sqrt()
  }
  edge_length
}

///|
pub struct EdgeLengthPositionOptimization {
  evaluator : IEvaluation
}

///|
pub fn new_edge_length_position_optimization() -> EdgeLengthPositionOptimization {
  { evaluator: new_i_evaluation(edge_length_position_optimization_evaluate) }
}

///|
pub fn EdgeLengthPositionOptimization::evaluate(
  self : EdgeLengthPositionOptimization,
  root : @graph.ElkNode,
) -> Double {
  self.evaluator.evaluate(root)
}

///|
pub fn EdgeLengthPositionOptimization::as_i_evaluation(
  self : EdgeLengthPositionOptimization,
) -> IEvaluation {
  self.evaluator
}
