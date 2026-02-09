///|
fn gj_obj(entries : Array[(String, Json)]) -> Json {
  Json::object(Map::from_array(entries))
}

///|
fn gj_arr(items : Array[Json]) -> Json {
  Json::array(items)
}

///|
fn gj_num(value : Int) -> Json {
  Json::number(value.to_double())
}

///|
fn gj_str(value : String) -> Json {
  Json::string(value)
}
