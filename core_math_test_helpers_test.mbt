///|
pub fn assert_double_eq(
  actual : Double,
  expected : Double,
  epsilon : Double,
) -> Unit raise {
  assert_true((actual - expected).abs() <= epsilon)
}
