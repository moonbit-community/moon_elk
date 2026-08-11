///|
pub struct MapPropertyHolder {
  priv mut entries : Array[JsonPropertyEntry]?
}

///|
priv struct JsonPropertyEntry {
  property_id : PropertyId
  external_id : String
  mut value : Json
}

///|
pub fn new_map_property_holder() -> MapPropertyHolder {
  { entries: None }
}

///|
pub fn[T : ToJson] MapPropertyHolder::set_property(
  self : MapPropertyHolder,
  property : IProperty[T],
  value : T?,
) -> MapPropertyHolder {
  match value {
    Some(current_value) => {
      let entries = self.entries.unwrap_or([])
      let property_id = property.get_property_id()
      let mut replaced = false
      for entry in entries {
        if entry.property_id == property_id {
          entry.value = current_value.to_json()
          replaced = true
          break
        }
      }
      if !replaced {
        entries.push({
          property_id,
          external_id: property.get_id(),
          value: current_value.to_json(),
        })
      }
      self.entries = Some(entries)
    }
    None => {
      let retained : Array[JsonPropertyEntry] = []
      match self.entries {
        Some(entries) =>
          for entry in entries {
            if entry.property_id != property.get_property_id() {
              retained.push(entry)
            }
          }
        None => ()
      }
      self.entries = if retained.is_empty() { None } else { Some(retained) }
    }
  }
  self
}

///|
pub fn[T : FromJson] MapPropertyHolder::get_property(
  self : MapPropertyHolder,
  property : IProperty[T],
) -> T {
  match self.entries {
    Some(entries) =>
      for entry in entries {
        if entry.property_id == property.get_property_id() {
          let value : T = @json.from_json(entry.value) catch {
            _ => return property.get_default()
          }
          return value
        }
      } nobreak {
        property.get_default()
      }
    None => property.get_default()
  }
}

///|
pub fn[T] MapPropertyHolder::has_property(
  self : MapPropertyHolder,
  property : IProperty[T],
) -> Bool {
  match self.entries {
    Some(entries) =>
      for entry in entries {
        if entry.property_id == property.get_property_id() {
          return true
        }
      } nobreak {
        false
      }
    None => false
  }
}

///|
pub fn MapPropertyHolder::copy_properties(
  self : MapPropertyHolder,
  source : IPropertyHolder?,
) -> MapPropertyHolder {
  match source {
    Some(source_holder) => {
      match source_holder.entries {
        Some(source_entries) => {
          let entries = self.entries.unwrap_or([])
          for source_entry in source_entries {
            let mut replaced = false
            for entry in entries {
              if entry.property_id == source_entry.property_id {
                entry.value = source_entry.value
                replaced = true
                break
              }
            }
            if !replaced {
              entries.push({
                property_id: source_entry.property_id,
                external_id: source_entry.external_id,
                value: source_entry.value,
              })
            }
          }
          self.entries = Some(entries)
        }
        None => ()
      }
      self
    }
    None => self
  }
}

///|
pub fn MapPropertyHolder::get_all_properties(
  self : MapPropertyHolder,
) -> Map[String, Json] {
  let properties = Map([])
  match self.entries {
    Some(entries) =>
      for entry in entries {
        properties[entry.external_id] = entry.value
      }
    None => ()
  }
  properties
}
