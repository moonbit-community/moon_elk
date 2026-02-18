///|
fn annulus_wedge_by_node_space_calculate_wedge_space(node : ElkNode) -> Double {
  let successors = radial_get_successors(node)
  let height = node_height(node)
  let width = node_width(node)
  let node_size = (height * height + width * width).sqrt()

  let mut child_space = 0.0
  for child in successors {
    child_space += annulus_wedge_by_node_space_calculate_wedge_space(child)
  }
  if child_space > node_size {
    child_space
  } else {
    node_size
  }
}

///|
pub struct AnnulusWedgeByNodeSpace {
  criteria : IAnnulusWedgeCriteria
}

///|
pub fn new_annulus_wedge_by_node_space() -> AnnulusWedgeByNodeSpace {
  {
    criteria: new_i_annulus_wedge_criteria(
      annulus_wedge_by_node_space_calculate_wedge_space,
    ),
  }
}

///|
pub fn AnnulusWedgeByNodeSpace::calculate_wedge_space(
  self : AnnulusWedgeByNodeSpace,
  node : ElkNode,
) -> Double {
  self.criteria.calculate_wedge_space(node)
}

///|
pub fn AnnulusWedgeByNodeSpace::as_i_annulus_wedge_criteria(
  self : AnnulusWedgeByNodeSpace,
) -> IAnnulusWedgeCriteria {
  self.criteria
}
