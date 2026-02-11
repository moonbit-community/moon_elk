///|
pub fn quadratic_constraint_calculation(
  compactor : OneDimensionalCompactor,
) -> Unit {
  for cnode in compactor.c_graph.c_nodes {
    cnode.clear_constraints()
  }

  for cnode1 in compactor.c_graph.c_nodes {
    for cnode2 in compactor.c_graph.c_nodes {
      if cnode1 == cnode2 {
        continue
      }

      match (cnode1.group(), cnode2.group()) {
        (Some(group1), Some(group2)) => if group1 == group2 { continue }
        _ => ()
      }

      let spacing = if compactor.direction.is_horizontal() {
        (compactor.spacings_handler.get_vertical_spacing)(cnode1, cnode2)
      } else {
        (compactor.spacings_handler.get_horizontal_spacing)(cnode1, cnode2)
      }

      let hitbox1 = cnode1.hitbox()
      let hitbox2 = cnode2.hitbox()

      if (
          hitbox2.x > hitbox1.x ||
          (
            compare_fuzzy_eq(hitbox1.x, hitbox2.x) &&
            hitbox1.width < hitbox2.width
          )
        ) &&
        compare_fuzzy_gt(hitbox2.y + hitbox2.height + spacing, hitbox1.y) &&
        compare_fuzzy_lt(hitbox2.y, hitbox1.y + hitbox1.height + spacing) {
        cnode1.add_constraint(cnode2)
      }
    }
  }
}

///|
pub let one_dimensional_compactor_quadratic_constraints : IConstraintCalculationAlgorithm = quadratic_constraint_calculation
