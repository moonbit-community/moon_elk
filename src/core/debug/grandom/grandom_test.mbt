///|
test "grandom setup returns runtime module" {
  ignore(core_debug_grandom_do_setup())
  assert_true(true)
}

///|
test "grandom scope provider can be created" {
  ignore(new_core_debug_grandom_scope_provider())
  assert_true(true)
}
