///|
fn clone_string_int_map(source : Map[String, Int]) -> Map[String, Int] {
  let result = {}
  source.each((key, value) => result[key] = value)
  result
}

///|
fn clone_string_double_map(source : Map[String, Double]) -> Map[String, Double] {
  let result = {}
  source.each((key, value) => result[key] = value)
  result
}

///|
fn clone_string_kvector_map(
  source : Map[String, KVector],
) -> Map[String, KVector] {
  let result = {}
  source.each((key, value) => result[key] = value.clone())
  result
}

///|
fn clone_string_bool_map(source : Map[String, Bool]) -> Map[String, Bool] {
  let result = {}
  source.each((key, value) => result[key] = value)
  result
}

///|
fn clone_string_string_map(source : Map[String, String]) -> Map[String, String] {
  let result = {}
  source.each((key, value) => result[key] = value)
  result
}

///|
fn clone_string_string_array_map(
  source : Map[String, Array[String]],
) -> Map[String, Array[String]] {
  let result = {}
  source.each((key, value) => result[key] = value.copy())
  result
}

///|
pub fn reset_graph_model_for_test() -> Unit {
  node_store.val.clear()
  port_store.val.clear()
  edge_store.val.clear()
  edge_section_store.val.clear()
  label_store.val.clear()
}
