///|
test "grandom validator catches invalid tree-only options" {
  let configuration = new_core_debug_grandom_configuration()
    .set_form(core_debug_grandom_form_custom())
    .set_tree_limits(None, Some(3))

  let errors = core_debug_grandom_options_restrictions(configuration)
  assert_eq(errors.length(), 1)
  assert_eq(errors[0].feature, core_debug_grandom_validation_configuration_md)
}

///|
test "grandom validator catches bipartite-only option" {
  let configuration = new_core_debug_grandom_configuration()
    .set_form(core_debug_grandom_form_trees())
    .set_fraction(Some(core_debug_grandom_double_quantity_exact(0.4)))

  let errors = core_debug_grandom_options_restrictions(configuration)
  assert_eq(errors.length(), 1)
  assert_eq(errors[0].feature, core_debug_grandom_validation_configuration_pf)
}

///|
test "grandom validator accepts matching options" {
  let configuration = new_core_debug_grandom_configuration()
    .set_form(core_debug_grandom_form_trees())
    .set_tree_limits(Some(3), Some(2))

  let errors = core_debug_grandom_options_restrictions(configuration)
  assert_eq(errors.length(), 0)
}
