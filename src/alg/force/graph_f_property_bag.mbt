///|
/// Force objects keep their hot simulation state in direct fields and allocate
/// each low-frequency typed property column only when it is first written.
fn[T] force_property_bag_set(
  bag : Map[@graph.PropertyId, T]?,
  property_id : @graph.PropertyId,
  value : T,
) -> Map[@graph.PropertyId, T] {
  let values = bag.unwrap_or(Map([]))
  values[property_id] = value
  values
}

///|
fn[T] force_property_bag_get(
  bag : Map[@graph.PropertyId, T]?,
  property_id : @graph.PropertyId,
) -> T? {
  match bag {
    Some(values) => values.get(property_id)
    None => None
  }
}

///|
fn[T] force_property_bag_has(
  bag : Map[@graph.PropertyId, T]?,
  property_id : @graph.PropertyId,
) -> Bool {
  match bag {
    Some(values) => values.contains(property_id)
    None => false
  }
}
