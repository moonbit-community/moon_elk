///|
fn json_meta_expect_object(value : Json) -> Map[String, Json] {
  match value {
    Object(obj) => obj
    _ => abort("expected object")
  }
}

///|
fn json_meta_expect_array(value : Json) -> Array[Json] {
  match value {
    Array(items) => items
    _ => abort("expected array")
  }
}

///|
fn json_meta_expect_string(value : Json) -> String {
  match value {
    String(text) => text
    _ => abort("expected string")
  }
}

///|
fn json_meta_array_contains_string(
  items : Array[Json],
  target : String,
) -> Bool {
  for item in items {
    match item {
      String(text) => if text == target { return true }
      _ => ()
    }
  }
  false
}

///|
test "layout algorithm metadata converts to json with known options and features" {
  let lad = @core.new_layout_algorithm_data(
    "org.eclipse.elk.layered",
    name="Layered",
    description="Layered layout",
  )
  lad.set_category_id("org.eclipse.elk.category")
  lad.add_known_option("org.eclipse.elk.direction")
  let features = @graph.graph_feature_values()
  lad.add_supported_feature(features[0])
  lad.add_supported_feature(features[4])

  let obj = json_meta_expect_object(layout_algorithm_data_to_json(lad))
  assert_eq(json_meta_expect_string(obj["id"]), "org.eclipse.elk.layered")
  assert_eq(json_meta_expect_string(obj["name"]), "Layered")
  assert_eq(json_meta_expect_string(obj["description"]), "Layered layout")
  assert_eq(
    json_meta_expect_string(obj["category"]),
    "org.eclipse.elk.category",
  )

  let known_options = json_meta_expect_array(obj["knownOptions"])
  assert_eq(
    json_meta_array_contains_string(known_options, "org.eclipse.elk.direction"),
    true,
  )

  let supported_features = json_meta_expect_array(obj["supportedFeatures"])
  assert_eq(
    json_meta_array_contains_string(supported_features, "SELF_LOOPS"),
    true,
  )
  assert_eq(json_meta_array_contains_string(supported_features, "PORTS"), true)
}

///|
test "layout category metadata converts only layouters with ids" {
  let category = @core.new_layout_category_data(
    "org.eclipse.elk.categories.default",
    name="Default",
    description="Category",
  )
  category.add_layouter(
    @core.new_layout_algorithm_data("org.eclipse.elk.alg.a"),
  )
  category.add_layouter(@core.new_layout_algorithm_data(""))

  let obj = json_meta_expect_object(layout_category_data_to_json(category))
  assert_eq(
    json_meta_expect_string(obj["id"]),
    "org.eclipse.elk.categories.default",
  )
  let layouters = json_meta_expect_array(obj["knownLayouters"])
  assert_eq(layouters.length(), 1)
  assert_eq(json_meta_expect_string(layouters[0]), "org.eclipse.elk.alg.a")
}

///|
test "layout option metadata converts enum type and targets" {
  @core.layout_meta_data_service_reset_for_test()
  @core.layout_meta_data_service_register_default_options()
  let option = @core.layout_meta_data_service_get_option_data(
    @core.no_layout.get_id(),
  )
  let obj = json_meta_expect_object(layout_option_data_to_json(option))
  assert_eq(json_meta_expect_string(obj["id"]), @core.no_layout.get_id())
  assert_eq(json_meta_expect_string(obj["group"]), "algorithm")
  assert_eq(json_meta_expect_string(obj["type"]), "BOOLEAN")

  let targets = json_meta_expect_array(obj["targets"])
  assert_eq(json_meta_array_contains_string(targets, "PARENTS"), true)
  assert_eq(json_meta_array_contains_string(targets, "NODES"), true)
}
