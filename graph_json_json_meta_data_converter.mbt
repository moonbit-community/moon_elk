///|
fn json_meta_data_create_common(data : ILayoutMetaData) -> Map[String, Json] {
  let adapter = new_json_adapter()
  let json_obj = adapter.new_json_object()
  adapter.add_json_obj_string(json_obj, "id", data.get_id())
  adapter.add_json_obj_string(json_obj, "name", data.get_name())
  adapter.add_json_obj_string(json_obj, "description", data.get_description())
  json_obj
}

///|
pub fn layout_algorithm_data_to_json(lad : LayoutAlgorithmData) -> Json {
  let adapter = new_json_adapter()
  let json_obj = json_meta_data_create_common(
    layout_meta_data_for_algorithm(lad),
  )
  if !lad.get_category_id().is_empty() {
    adapter.add_json_obj_string(json_obj, "category", lad.get_category_id())
  }
  let known_options = lad.get_known_option_ids()
  if !known_options.is_empty() {
    let json_arr = adapter.new_json_array()
    for option_id in known_options {
      adapter.add_json_arr_json(json_arr, adapter.to_json_string(option_id))
    }
    adapter.add_json_obj_json(json_obj, "knownOptions", Json::array(json_arr))
  }
  let supported_features = lad.get_supported_features()
  if !supported_features.is_empty() {
    let json_arr = adapter.new_json_array()
    for feature in supported_features {
      adapter.add_json_arr_json(
        json_arr,
        adapter.to_json_string(feature.to_string()),
      )
    }
    adapter.add_json_obj_json(
      json_obj,
      "supportedFeatures",
      Json::array(json_arr),
    )
  }
  Json::object(json_obj)
}

///|
pub fn layout_category_data_to_json(lcd : LayoutCategoryData) -> Json {
  let adapter = new_json_adapter()
  let json_obj = json_meta_data_create_common(
    layout_meta_data_for_category(lcd),
  )
  let layouters = lcd.get_layouters()
  if !layouters.is_empty() {
    let json_arr = adapter.new_json_array()
    for layouter in layouters {
      if !layouter.get_id().is_empty() {
        adapter.add_json_arr_json(
          json_arr,
          adapter.to_json_string(layouter.get_id()),
        )
      }
    }
    if !json_arr.is_empty() {
      adapter.add_json_obj_json(
        json_obj,
        "knownLayouters",
        Json::array(json_arr),
      )
    }
  }
  Json::object(json_obj)
}

///|
pub fn layout_option_data_to_json(lod : LayoutOptionData) -> Json {
  let adapter = new_json_adapter()
  let json_obj = json_meta_data_create_common(layout_meta_data_for_option(lod))
  if !lod.get_group().is_empty() {
    adapter.add_json_obj_string(json_obj, "group", lod.get_group())
  }
  adapter.add_json_obj_string(json_obj, "type", lod.get_type().to_string())
  let targets = lod.get_targets()
  if !targets.is_empty() {
    let json_arr = adapter.new_json_array()
    for target in targets {
      adapter.add_json_arr_json(
        json_arr,
        adapter.to_json_string(target.to_string()),
      )
    }
    adapter.add_json_obj_json(json_obj, "targets", Json::array(json_arr))
  }
  Json::object(json_obj)
}
