///|
/// Layered graph objects keep hot geometry as direct fields. Low-frequency
/// typed properties use these optional columns so a column allocates its map
/// only on first write, while PropertyId keeps inner-loop lookup string-free.
fn[T] layered_property_bag_set(
  bag : Map[@graph.PropertyId, T]?,
  property_id : @graph.PropertyId,
  value : T,
) -> Map[@graph.PropertyId, T] {
  let values = bag.unwrap_or(Map([]))
  values[property_id] = value
  values
}

///|
fn[T] layered_property_bag_get(
  bag : Map[@graph.PropertyId, T]?,
  property_id : @graph.PropertyId,
) -> T? {
  match bag {
    Some(values) => values.get(property_id)
    None => None
  }
}

///|
fn[T] layered_property_bag_has(
  bag : Map[@graph.PropertyId, T]?,
  property_id : @graph.PropertyId,
) -> Bool {
  match bag {
    Some(values) => values.contains(property_id)
    None => false
  }
}

///|
fn[T] layered_property_bag_remove(
  bag : Map[@graph.PropertyId, T]?,
  property_id : @graph.PropertyId,
) -> Map[@graph.PropertyId, T]? {
  match bag {
    Some(values) => {
      ignore(values.remove(property_id))
      if values.to_array().is_empty() {
        None
      } else {
        Some(values)
      }
    }
    None => None
  }
}

///|
fn[T] layered_property_bag_copy(
  source : Map[@graph.PropertyId, T]?,
  clone_value : (T) -> T,
) -> Map[@graph.PropertyId, T]? {
  match source {
    Some(values) => {
      let copied = Map([])
      for entry in values.to_array() {
        copied[entry.0] = clone_value(entry.1)
      }
      Some(copied)
    }
    None => None
  }
}

///|
fn[T] layered_property_bag_entries(
  bag : Map[@graph.PropertyId, T]?,
) -> Array[(@graph.PropertyId, T)] {
  match bag {
    Some(values) => values.to_array()
    None => []
  }
}

///|
fn[T] layered_property_identity(value : T) -> T {
  value
}
