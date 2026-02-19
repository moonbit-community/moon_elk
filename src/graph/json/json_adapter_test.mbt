///|
fn json_adapter_expect_object(value : Json) -> Map[String, Json] {
  match value {
    Object(obj) => obj
    _ => abort("expected object")
  }
}

///|
fn json_adapter_expect_array(value : Json) -> Array[Json] {
  match value {
    Array(values) => values
    _ => abort("expected array")
  }
}

///|
fn json_adapter_expect_string(value : Json) -> String {
  match value {
    String(text) => text
    _ => abort("expected string")
  }
}

///|
test "json adapter get id and options" {
  let adapter = new_json_adapter()
  let obj : Map[String, Json] = {
    "id": Json::string("node1"),
    "value": Json::number(7.0),
  }
  assert_eq(adapter.get_id(obj), "node1")
  assert_eq(adapter.get_id_safe(obj), Some("node1"))
  assert_eq(adapter.opt_double(obj, "value"), Some(7.0))
  assert_eq(adapter.opt_string(obj, "value"), Some("7"))
}

///|
test "json adapter accepts numeric int id" {
  let adapter = new_json_adapter()
  let obj : Map[String, Json] = { "id": Json::number(42.0) }
  assert_eq(adapter.get_id(obj), "42")
}

///|
test "json adapter object and array editing" {
  let adapter = new_json_adapter()
  let obj = adapter.new_json_object()
  adapter.add_json_obj_string(obj, "name", "elk")
  adapter.add_json_obj_bool(obj, "ok", true)
  adapter.add_json_obj_number(obj, "x", 1.5)

  let arr = adapter.new_json_array()
  adapter.add_json_arr_json(arr, Json::string("a"))
  adapter.add_json_arr_json(arr, Json::number(2.0))
  adapter.add_json_obj_json(obj, "values", Json::array(arr))
  ignore(json_adapter_expect_object(Json::object(obj)))

  let values = match adapter.get_json_obj(obj, "values") {
    Some(value) => json_adapter_expect_array(value)
    None => abort("expected values")
  }
  assert_eq(values.length(), 2)
  assert_eq(json_adapter_expect_string(values[0]), "a")
  assert_eq(adapter.opt_string_at(values, 1), Some("2"))

  adapter.remove_json_obj(obj, "ok")
  assert_eq(adapter.has_json_obj(obj, "ok"), false)
  assert_eq(adapter.has_json_obj(obj, "name"), true)
}

///|
test "panic json adapter rejects non integer id" {
  let adapter = new_json_adapter()
  let obj : Map[String, Json] = { "id": Json::number(3.14) }
  ignore(adapter.get_id(obj))
}

///|
test "panic json adapter requires id" {
  let adapter = new_json_adapter()
  let obj : Map[String, Json] = {}
  ignore(adapter.get_id(obj))
}
