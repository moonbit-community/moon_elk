///|
pub struct MapPropertyHolder {
  property_map : Map[String, Json]
}

///|
pub fn new_map_property_holder() -> MapPropertyHolder {
  { property_map: {} }
}

///|
pub fn[T : ToJson] MapPropertyHolder::set_property(
  self : MapPropertyHolder,
  property : IProperty[T],
  value : T?,
) -> MapPropertyHolder {
  match value {
    Some(current_value) =>
      self.property_map[property.get_id()] = current_value.to_json()
    None => ignore(self.property_map.remove(property.get_id()))
  }
  self
}

///|
pub fn[T : FromJson] MapPropertyHolder::get_property(
  self : MapPropertyHolder,
  property : IProperty[T],
) -> T {
  match self.property_map.get(property.get_id()) {
    Some(value_json) => {
      let value : T = @json.from_json(value_json) catch {
        _ => property.get_default()
      }
      value
    }
    None => property.get_default()
  }
}

///|
pub fn[T] MapPropertyHolder::has_property(
  self : MapPropertyHolder,
  property : IProperty[T],
) -> Bool {
  self.property_map.contains(property.get_id())
}

///|
pub fn MapPropertyHolder::copy_properties(
  self : MapPropertyHolder,
  source : IPropertyHolder?,
) -> MapPropertyHolder {
  match source {
    Some(source_holder) => {
      source_holder
      .get_all_properties()
      .each((key, value) => self.property_map[key] = value)
      self
    }
    None => self
  }
}

///|
pub fn MapPropertyHolder::get_all_properties(
  self : MapPropertyHolder,
) -> Map[String, Json] {
  let properties = {}
  self.property_map.each((key, value) => properties[key] = value)
  properties
}
