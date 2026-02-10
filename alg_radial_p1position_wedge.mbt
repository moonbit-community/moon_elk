///|
pub fn radial_calculate_wedge_space(
  criteria : RadialAnnulusWedgeCriteria,
  node : ElkNode,
) -> Double {
  match criteria {
    RadialAnnulusWedgeCriteria::LEAF_NUMBER =>
      radial_get_number_of_leaves(node).to_double()
    RadialAnnulusWedgeCriteria::NODE_SIZE => {
      let successors = radial_get_successors(node)
      let height = node_height(node)
      let width = node_width(node)
      let node_size = (height * height + width * width).sqrt()
      let mut child_space = 0.0
      for child in successors {
        child_space += radial_calculate_wedge_space(criteria, child)
      }
      if child_space > node_size {
        child_space
      } else {
        node_size
      }
    }
  }
}
