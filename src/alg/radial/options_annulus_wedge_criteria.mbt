///|
pub enum RadialAnnulusWedgeCriteria {
  LEAF_NUMBER
  NODE_SIZE
}

///|
pub fn radial_annulus_wedge_criteria_create(
  criteria : RadialAnnulusWedgeCriteria,
) -> IAnnulusWedgeCriteria {
  match criteria {
    LEAF_NUMBER => new_annulus_wedge_by_leafs().as_i_annulus_wedge_criteria()
    NODE_SIZE => new_annulus_wedge_by_node_space().as_i_annulus_wedge_criteria()
  }
}
