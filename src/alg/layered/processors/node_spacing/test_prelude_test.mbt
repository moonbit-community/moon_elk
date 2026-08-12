///|
fn assert_double_eq(
  actual : Double,
  expected : Double,
  epsilon : Double,
) -> Unit {
  if (actual - expected).abs() > epsilon {
    abort("expected=\{expected} actual=\{actual}")
  }
}
