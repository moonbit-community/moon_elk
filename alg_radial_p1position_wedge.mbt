///|
pub fn radial_calculate_wedge_space(
  criteria : RadialAnnulusWedgeCriteria,
  node : ElkNode,
) -> Double {
  radial_annulus_wedge_criteria_create(criteria).calculate_wedge_space(node)
}
