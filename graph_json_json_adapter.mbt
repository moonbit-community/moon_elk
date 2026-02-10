///|
pub struct JsonAdapter {
  unit : Unit
}

///|
pub fn new_json_adapter() -> JsonAdapter {
  { unit: () }
}

///|
fn json_adapter_format_error(msg : String) -> JsonImportException {
  new_json_import_exception_message(msg)
}

///|
pub fn JsonAdapter::get_id(self : JsonAdapter, o : Map[String, Json]) -> String {
  ignore(self)
  match o.get("id") {
    Some(id) => new_json_adapter().as_id(id)
    None => abort("Every element must have an id.")
  }
}

///|
pub fn JsonAdapter::as_id(self : JsonAdapter, id : Json) -> String {
  ignore(self)
  match id {
    String(value) => value
    Number(value, repr~) => {
      ignore(repr)
      if new_json_adapter().is_int(value) {
        value.to_int().to_string()
      } else {
        abort("Id must be a string or an integer: '" + id.to_string() + "'.")
      }
    }
    _ => abort("Id must be a string or an integer: '" + id.to_string() + "'.")
  }
}

///|
pub fn JsonAdapter::get_id_safe(
  self : JsonAdapter,
  o : Map[String, Json],
) -> String? {
  ignore(self)
  match o.get("id") {
    Some(value) => new_json_adapter().opt_string_value(value)
    None => None
  }
}

///|
pub fn JsonAdapter::implementation_error(self : JsonAdapter) -> String {
  ignore(self)
  "Severe implementation error in the Json to ElkGraph importer."
}

///|
pub fn JsonAdapter::to_json_object(
  self : JsonAdapter,
  o : Json,
) -> Map[String, Json] {
  ignore(self)
  match o {
    Object(value) => value
    _ => abort("JsonAdapter: expected object")
  }
}

///|
pub fn JsonAdapter::to_json_array(self : JsonAdapter, o : Json) -> Array[Json] {
  ignore(self)
  match o {
    Array(value) => value
    _ => abort("JsonAdapter: expected array")
  }
}

///|
pub fn JsonAdapter::opt_string_value(self : JsonAdapter, e : Json) -> String? {
  ignore(self)
  match e {
    String(value) => Some(value)
    Number(value, repr~) => {
      ignore(repr)
      Some(value.to_string())
    }
    True => Some("true")
    False => Some("false")
    _ => None
  }
}

///|
pub fn JsonAdapter::opt_string(
  self : JsonAdapter,
  o : Map[String, Json],
  element : String,
) -> String? {
  match o.get(element) {
    Some(value) => self.opt_string_value(value)
    None => None
  }
}

///|
pub fn JsonAdapter::opt_string_at(
  self : JsonAdapter,
  arr : Array[Json],
  index : Int,
) -> String? {
  if index < 0 || index >= arr.length() {
    None
  } else {
    self.opt_string_value(arr[index])
  }
}

///|
pub fn JsonAdapter::opt_double(
  self : JsonAdapter,
  o : Map[String, Json],
  element : String,
) -> Double? {
  ignore(self)
  match o.get(element) {
    Some(Number(value, repr~)) => {
      ignore(repr)
      Some(value)
    }
    _ => None
  }
}

///|
pub fn JsonAdapter::opt_json_array(
  self : JsonAdapter,
  o : Map[String, Json],
  element : String,
) -> Array[Json]? {
  ignore(self)
  match o.get(element) {
    Some(Array(value)) => Some(value)
    _ => None
  }
}

///|
pub fn JsonAdapter::opt_json_object(
  self : JsonAdapter,
  o : Map[String, Json],
  element : String,
) -> Map[String, Json]? {
  ignore(self)
  match o.get(element) {
    Some(Object(value)) => Some(value)
    _ => None
  }
}

///|
pub fn JsonAdapter::size_json_arr(self : JsonAdapter, o : Array[Json]) -> Int {
  ignore(self)
  o.length()
}

///|
pub fn JsonAdapter::has_json_obj(
  self : JsonAdapter,
  o : Map[String, Json],
  element : String,
) -> Bool {
  ignore(self)
  o.contains(element)
}

///|
pub fn JsonAdapter::keys_json_obj(
  self : JsonAdapter,
  o : Map[String, Json],
) -> Array[String] {
  ignore(self)
  let keys = []
  o.each((key, value) => {
    ignore(value)
    keys.push(key)
  })
  keys
}

///|
pub fn JsonAdapter::get_json_obj(
  self : JsonAdapter,
  o : Map[String, Json],
  element : String,
) -> Json? {
  ignore(self)
  o.get(element)
}

///|
pub fn JsonAdapter::get_json_arr(
  self : JsonAdapter,
  arr : Array[Json],
  index : Int,
) -> Json? {
  ignore(self)
  if index < 0 || index >= arr.length() {
    None
  } else {
    Some(arr[index])
  }
}

///|
pub fn JsonAdapter::new_json_object(self : JsonAdapter) -> Map[String, Json] {
  ignore(self)
  {}
}

///|
pub fn JsonAdapter::new_json_array(self : JsonAdapter) -> Array[Json] {
  ignore(self)
  []
}

///|
pub fn JsonAdapter::to_json_string(self : JsonAdapter, s : String) -> Json {
  ignore(self)
  Json::string(s)
}

///|
pub fn JsonAdapter::to_json_number(self : JsonAdapter, n : Double) -> Json {
  ignore(self)
  Json::number(n)
}

///|
pub fn JsonAdapter::add_json_obj_number(
  self : JsonAdapter,
  o : Map[String, Json],
  element : String,
  n : Double,
) -> Unit {
  ignore(self)
  o[element] = Json::number(n)
}

///|
pub fn JsonAdapter::add_json_obj_bool(
  self : JsonAdapter,
  o : Map[String, Json],
  element : String,
  b : Bool,
) -> Unit {
  ignore(self)
  o[element] = Json::boolean(b)
}

///|
pub fn JsonAdapter::add_json_obj_string(
  self : JsonAdapter,
  o : Map[String, Json],
  element : String,
  s : String,
) -> Unit {
  ignore(self)
  o[element] = Json::string(s)
}

///|
pub fn JsonAdapter::add_json_obj_json(
  self : JsonAdapter,
  o : Map[String, Json],
  element : String,
  je : Json,
) -> Unit {
  ignore(self)
  o[element] = je
}

///|
pub fn JsonAdapter::remove_json_obj(
  self : JsonAdapter,
  o : Map[String, Json],
  element : String,
) -> Unit {
  ignore(self)
  ignore(o.remove(element))
}

///|
pub fn JsonAdapter::add_json_arr_json(
  self : JsonAdapter,
  arr : Array[Json],
  je : Json,
) -> Unit {
  ignore(self)
  arr.push(je)
}

///|
pub fn JsonAdapter::is_int(self : JsonAdapter, d : Double) -> Bool {
  ignore(self)
  d % 1.0 == 0.0
}
