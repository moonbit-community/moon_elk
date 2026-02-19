///|
fn annulus_wedge_by_leafs_calculate_wedge_space(node : ElkNode) -> Double {
  radial_get_number_of_leaves(node).to_double()
}

///|
pub struct AnnulusWedgeByLeafs {
  criteria : IAnnulusWedgeCriteria
}

///|
pub fn new_annulus_wedge_by_leafs() -> AnnulusWedgeByLeafs {
  {
    criteria: new_i_annulus_wedge_criteria(
      annulus_wedge_by_leafs_calculate_wedge_space,
    ),
  }
}

///|
pub fn AnnulusWedgeByLeafs::calculate_wedge_space(
  self : AnnulusWedgeByLeafs,
  node : ElkNode,
) -> Double {
  self.criteria.calculate_wedge_space(node)
}

///|
pub fn AnnulusWedgeByLeafs::as_i_annulus_wedge_criteria(
  self : AnnulusWedgeByLeafs,
) -> IAnnulusWedgeCriteria {
  self.criteria
}
