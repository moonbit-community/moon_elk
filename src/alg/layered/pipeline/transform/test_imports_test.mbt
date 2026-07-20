///|
using @runtime {
  type LGraph,
  internal_properties_original_port_constraints,
  internal_properties_spacings,
  new_l_graph,
  new_l_node,
  new_layer,
}

///|
fn assert_double_eq(
  actual : Double,
  expected : Double,
  tolerance : Double,
) -> Unit {
  if (actual - expected).abs() > tolerance {
    abort("expected=\{expected} actual=\{actual}")
  }
}
