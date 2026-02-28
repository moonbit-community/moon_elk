///|
pub struct IAnnulusWedgeCriteria {
  calculate_wedge_space_fn : (@graph.ElkNode) -> Double
}

///|
pub fn new_i_annulus_wedge_criteria(
  calculate_wedge_space : (@graph.ElkNode) -> Double,
) -> IAnnulusWedgeCriteria {
  { calculate_wedge_space_fn: calculate_wedge_space }
}

///|
pub fn IAnnulusWedgeCriteria::calculate_wedge_space(
  self : IAnnulusWedgeCriteria,
  node : @graph.ElkNode,
) -> Double {
  (self.calculate_wedge_space_fn)(node)
}
