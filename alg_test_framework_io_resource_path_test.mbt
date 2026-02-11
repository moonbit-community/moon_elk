///|
fn resource_path_test_reset() -> Unit {
  core_debug_reset_foundation_for_test()
  resource_path_clear_properties_for_test()
}

///|
fn resource_path_test_register_repo_tree() -> Unit {
  core_debug_register_directory_for_test("/repo", [
    "/repo/a.elkg", "/repo/b.txt", "/repo/sub",
  ])
  core_debug_register_regular_file_for_test("/repo/a.elkg")
  core_debug_register_regular_file_for_test("/repo/b.txt")
  core_debug_register_directory_for_test("/repo/sub", ["/repo/sub/c.elkg"])
  core_debug_register_regular_file_for_test("/repo/sub/c.elkg")
}

///|
fn absolute_path_strings(
  resources : Array[AbsoluteResourcePath],
) -> Array[String] {
  let values = []
  for resource in resources {
    values.push(resource.get_file())
  }
  values
}

///|
test "AbstractResourcePath lists directory files with extension filter" {
  resource_path_test_reset()
  resource_path_test_register_repo_tree()
  let filter = new_file_extension_filter(".elkg")
  let path = new_absolute_resource_path("/repo/**")
  path.set_filter(Some(filter.to_filter()))
  inspect(path.is_directory(), content="true")
  inspect(path.is_recursive(), content="false")
  inspect(
    absolute_path_strings(path.list_resources()),
    content="[\"/repo/a.elkg\"]",
  )
}

///|
test "AbstractResourcePath recursive directory scan works with file name filter" {
  resource_path_test_reset()
  resource_path_test_register_repo_tree()
  let filter = new_file_name_filter(".*\\.elkg")
  let path = new_absolute_resource_path("/repo/**/")
  path.set_filter(Some(filter.to_filter()))
  inspect(path.is_directory(), content="true")
  inspect(path.is_recursive(), content="true")
  inspect(
    absolute_path_strings(path.list_resources()),
    content="[\"/repo/a.elkg\", \"/repo/sub/c.elkg\"]",
  )
}

///|
test "Property-dependent resource paths resolve from test properties" {
  resource_path_test_reset()
  resource_path_set_property_for_test("ELK_REPO", "/workspace")
  resource_path_set_property_for_test("MODELS_REPO", "/models")
  resource_path_set_property_for_test("RESULTS_PATH", "/results")
  let bundle_path = new_bundle_resource_path(
    "org.eclipse.elk.alg.test", "src/**",
  )
  inspect(
    bundle_path.get_file(),
    content="/workspace/test/org.eclipse.elk.alg.test/src",
  )
  let model_path = new_model_resource_path("my.elkg")
  inspect(model_path.get_file(), content="/models/my.elkg")
  ignore(new_results_resource_path("run/report.txt"))
  ensure_results_path_exists()
  inspect(core_debug_is_directory("/results"), content="true")
}
