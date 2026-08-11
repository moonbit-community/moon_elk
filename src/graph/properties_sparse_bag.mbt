///|
priv enum NodePropertyValue {
  NodeIntValue(Int)
  NodeDoubleValue(Double)
  NodeBoolValue(Bool)
  NodeStringValue(String)
  NodeStringSetValue(Array[String])
}

///|
priv struct NodePropertyEntry {
  property_id : PropertyId
  external_id : String
  mut value : NodePropertyValue
}

///|
/// Low-frequency graph properties share one lazily allocated heterogeneous bag;
/// geometry and containment remain direct arena fields.
priv struct NodePropertyBag {
  entries : Array[NodePropertyEntry]
}

///|
fn node_property_value_same_kind(
  first : NodePropertyValue,
  second : NodePropertyValue,
) -> Bool {
  match (first, second) {
    (NodeIntValue(_), NodeIntValue(_)) => true
    (NodeDoubleValue(_), NodeDoubleValue(_)) => true
    (NodeBoolValue(_), NodeBoolValue(_)) => true
    (NodeStringValue(_), NodeStringValue(_)) => true
    (NodeStringSetValue(_), NodeStringSetValue(_)) => true
    _ => false
  }
}

///|
fn node_property_bag_set(
  bag : NodePropertyBag?,
  property_id : PropertyId,
  external_id : String,
  value : NodePropertyValue,
) -> NodePropertyBag {
  let result = bag.unwrap_or({ entries: [] })
  for entry in result.entries {
    if entry.property_id == property_id &&
      node_property_value_same_kind(entry.value, value) {
      entry.value = value
      return result
    }
  }
  result.entries.push({ property_id, external_id, value })
  result
}

///|
fn node_property_bag_get(
  bag : NodePropertyBag?,
  property_id : PropertyId,
  kind : NodePropertyValue,
) -> NodePropertyValue? {
  match bag {
    Some(values) =>
      for entry in values.entries {
        if entry.property_id == property_id &&
          node_property_value_same_kind(entry.value, kind) {
          return Some(entry.value)
        }
      } nobreak {
        None
      }
    None => None
  }
}

///|
fn node_property_bag_has(
  bag : NodePropertyBag?,
  property_id : PropertyId,
  kind : NodePropertyValue,
) -> Bool {
  node_property_bag_get(bag, property_id, kind) is Some(_)
}

///|
fn node_property_bag_remove(
  bag : NodePropertyBag?,
  property_id : PropertyId,
  kind : NodePropertyValue,
) -> NodePropertyBag? {
  match bag {
    Some(values) => {
      let retained = []
      for entry in values.entries {
        if entry.property_id != property_id ||
          !node_property_value_same_kind(entry.value, kind) {
          retained.push(entry)
        }
      }
      values.entries.clear()
      for entry in retained {
        values.entries.push(entry)
      }
      if values.entries.is_empty() {
        None
      } else {
        Some(values)
      }
    }
    None => None
  }
}

///|
fn clone_node_property_value(value : NodePropertyValue) -> NodePropertyValue {
  match value {
    NodeStringSetValue(values) => NodeStringSetValue(values.copy())
    other => other
  }
}

///|
fn clone_node_property_bag(source : NodePropertyBag?) -> NodePropertyBag? {
  match source {
    Some(source_bag) => {
      let entries : Array[NodePropertyEntry] = []
      for entry in source_bag.entries {
        entries.push({
          property_id: entry.property_id,
          external_id: entry.external_id,
          value: clone_node_property_value(entry.value),
        })
      }
      Some({ entries, })
    }
    None => None
  }
}

///|
priv struct OptionEntry {
  option_id : OptionId
  external_id : String
  mut value : String
}

///|
priv struct OptionBag {
  entries : Array[OptionEntry]
}

///|
fn option_bag_set(
  bag : OptionBag?,
  option_id : OptionId,
  external_id : String,
  value : String,
) -> OptionBag {
  let result = bag.unwrap_or({ entries: [] })
  for entry in result.entries {
    if entry.option_id == option_id {
      entry.value = value
      return result
    }
  }
  result.entries.push({ option_id, external_id, value })
  result
}

///|
fn option_bag_get(bag : OptionBag?, option_id : OptionId) -> String? {
  match bag {
    Some(values) =>
      for entry in values.entries {
        if entry.option_id == option_id {
          return Some(entry.value)
        }
      } nobreak {
        None
      }
    None => None
  }
}

///|
fn option_bag_entries(bag : OptionBag?) -> Array[(String, String)] {
  let result = []
  match bag {
    Some(values) =>
      for entry in values.entries {
        result.push((entry.external_id, entry.value))
      }
    None => ()
  }
  result
}

///|
fn clone_option_bag(source : OptionBag?) -> OptionBag? {
  match source {
    Some(source_bag) => {
      let entries : Array[OptionEntry] = []
      for entry in source_bag.entries {
        entries.push({
          option_id: entry.option_id,
          external_id: entry.external_id,
          value: entry.value,
        })
      }
      Some({ entries, })
    }
    None => None
  }
}
