///|
let individual_spacings_serialized_option_separator = ";,;"

///|
priv suberror IndividualSpacingsException {
  IndividualSpacingsException(String)
} derive(Debug, ToJson)

///|
fn[T] individual_spacings_raise(
  message : String,
) -> T raise IndividualSpacingsException {
  raise IndividualSpacingsException(message)
}

///|
fn individual_spacings_exception_message(
  err : IndividualSpacingsException,
) -> String {
  match err {
    IndividualSpacingsException(message) => message
  }
}

///|
pub struct IndividualSpacings {
  priv mut entries : Array[(@graph.OptionId, String, String)]?
}

///|
pub fn new_individual_spacings() -> IndividualSpacings {
  { entries: None }
}

///|
pub fn new_individual_spacings_from(
  other : IndividualSpacings,
) -> IndividualSpacings {
  let copy = new_individual_spacings()
  match other.entries {
    Some(entries) => {
      let copied_entries = []
      for entry in entries {
        copied_entries.push(entry)
      }
      copy.entries = Some(copied_entries)
    }
    None => ()
  }
  copy
}

///|
pub fn IndividualSpacings::set_option(
  self : IndividualSpacings,
  option_id : String,
  option_value : String,
) -> Unit {
  let compact_id = @graph.option_id_from_string(option_id)
  let entries = self.entries.unwrap_or([])
  for index in 0..<entries.length() {
    if entries[index].0 == compact_id {
      entries[index] = (compact_id, option_id, option_value)
      self.entries = Some(entries)
      return
    }
  }
  entries.push((compact_id, option_id, option_value))
  self.entries = Some(entries)
}

///|
pub fn IndividualSpacings::get_option(
  self : IndividualSpacings,
  option_id : String,
) -> String? {
  let compact_id = @graph.option_id_from_string(option_id)
  match self.entries {
    Some(entries) =>
      for entry in entries {
        if entry.0 == compact_id {
          return Some(entry.2)
        }
      } nobreak {
        None
      }
    None => None
  }
}

///|
pub fn IndividualSpacings::has_option(
  self : IndividualSpacings,
  option_id : String,
) -> Bool {
  self.get_option(option_id) is Some(_)
}

///|
pub fn IndividualSpacings::entries(
  self : IndividualSpacings,
) -> Array[(String, String)] {
  let result = []
  match self.entries {
    Some(entries) =>
      for entry in entries {
        result.push((entry.1, entry.2))
      }
    None => ()
  }
  result
}

///|
pub fn IndividualSpacings::to_string(self : IndividualSpacings) -> String {
  let entries : Array[String] = []
  for entry in self.entries() {
    let (option_id, option_value) = entry
    entries.push(option_id + ":" + option_value)
  }
  entries.join(individual_spacings_serialized_option_separator)
}

///|
fn individual_spacings_parse_option(
  metadata : OptionMetadata,
  spacings : IndividualSpacings,
  option_string : String,
) -> Unit raise IndividualSpacingsException {
  let option = option_string.split(":").to_array()
  if option.length() < 2 {
    individual_spacings_raise(
      "The given string does not match the expected format for individual spacings.",
    )
  }
  let option_suffix = option[0].trim().to_owned()
  let option_value = option[1].to_owned()
  let option_data = match metadata.option_data_by_suffix(option_suffix) {
    Some(value) => value
    None => individual_spacings_raise("Invalid option id: " + option_suffix)
  }
  spacings.set_option(
    option_data.get_id(),
    option_data.parse_value(option_value),
  )
}

///|
pub fn IndividualSpacings::parse(
  self : IndividualSpacings,
  metadata : OptionMetadata,
  string : String,
) -> Unit raise {
  if string.is_empty() {
    return
  }
  for
    option_string in string.split(
      individual_spacings_serialized_option_separator,
    ) {
    if option_string.is_empty() {
      continue
    }
    try
      individual_spacings_parse_option(metadata, self, option_string.to_owned())
    catch {
      err =>
        layout_runtime_raise_unsupported_configuration(
          individual_spacings_exception_message(err),
        )
    } noraise {
      _ => ()
    }
  }
}

///|
pub fn individual_spacings_from_node(
  node : @graph.ElkNode,
) -> IndividualSpacings {
  let spacings = new_individual_spacings()
  for entry in @graph.node_individual_spacing_option_string_entries(node) {
    let (option_id, option_value) = entry
    spacings.set_option(option_id, option_value)
  }
  spacings
}

///|
pub fn individual_spacings_apply_to_node(
  spacings : IndividualSpacings,
  node : @graph.ElkNode,
) -> Unit {
  for entry in spacings.entries() {
    let (option_id, option_value) = entry
    @graph.node_set_individual_spacing_option_string_by_id(
      node, option_id, option_value,
    )
  }
}

///|
fn individual_spacings_parse_double(value : String) -> Double? {
  let parsed : Result[Double, Error] = try
    @string.parse_double(value.trim())
  catch {
    error => Err(error)
  } noraise {
    value => Ok(value)
  }
  match parsed {
    Ok(parsed) => Some(parsed)
    Err(_) => None
  }
}

///|
fn individual_spacings_parent_or_default(
  node : @graph.ElkNode,
  property : @graph.IProperty[Double],
) -> Double {
  match @graph.node_parent(node) {
    Some(parent) => @graph.node_get_double_property(parent, property)
    None => property.get_default()
  }
}

///|
pub fn individual_spacings_get_individual_or_inherited(
  node : @graph.ElkNode,
  property : @graph.IProperty[Double],
) -> Double {
  match
    @graph.node_individual_spacing_option_string_value_by_option_id(
      node,
      property.get_property_id(),
    ) {
    Some(value) =>
      match individual_spacings_parse_double(value) {
        Some(parsed) => parsed
        None => individual_spacings_parent_or_default(node, property)
      }
    None => individual_spacings_parent_or_default(node, property)
  }
}
