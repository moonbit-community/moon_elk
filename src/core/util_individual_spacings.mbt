///|
let individual_spacings_serialized_option_separator = ";,;"

///|
pub(all) struct IndividualSpacings {
  values : Map[String, String]
}

///|
pub fn new_individual_spacings() -> IndividualSpacings {
  { values: {} }
}

///|
pub fn new_individual_spacings_from(
  other : IndividualSpacings,
) -> IndividualSpacings {
  let values : Map[String, String] = {}
  for entry in other.values.to_array() {
    let (option_id, option_value) = entry
    values[option_id] = option_value
  }
  { values, }
}

///|
pub fn IndividualSpacings::set_option(
  self : IndividualSpacings,
  option_id : String,
  option_value : String,
) -> Unit {
  self.values[option_id] = option_value
}

///|
pub fn IndividualSpacings::get_option(
  self : IndividualSpacings,
  option_id : String,
) -> String? {
  self.values.get(option_id)
}

///|
pub fn IndividualSpacings::has_option(
  self : IndividualSpacings,
  option_id : String,
) -> Bool {
  self.values.contains(option_id)
}

///|
pub fn IndividualSpacings::entries(
  self : IndividualSpacings,
) -> Array[(String, String)] {
  self.values.to_array()
}

///|
pub fn IndividualSpacings::to_string(self : IndividualSpacings) -> String {
  let entries : Array[String] = []
  for entry in self.values.to_array() {
    let (option_id, option_value) = entry
    entries.push(option_id + ":" + option_value)
  }
  entries.join(individual_spacings_serialized_option_separator)
}

///|
fn individual_spacings_parse_option(
  spacings : IndividualSpacings,
  option_string : String,
) -> Unit {
  let option = option_string.split(":").to_array()
  if option.length() < 2 {
    abort(
      "The given string does not match the expected format for individual spacings.",
    )
  }
  let option_suffix = option[0].trim().to_string()
  let option_value = option[1].to_string()
  let option_data = match
    layout_meta_data_service_get_option_data_by_suffix(option_suffix) {
    Some(value) => value
    None => abort("Invalid option id: " + option_suffix)
  }
  spacings.values[option_data.get_id()] = option_data.parse_value(option_value)
}

///|
pub fn IndividualSpacings::parse(
  self : IndividualSpacings,
  string : String,
) -> Unit {
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
    individual_spacings_parse_option(self, option_string.to_string())
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
  let parsed : Result[Double, @strconv.StrConvError] = try? @strconv.parse_double(
    value.trim(),
  )
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
    @graph.node_individual_spacing_option_string_value(node, property.get_id()) {
    Some(value) =>
      match individual_spacings_parse_double(value) {
        Some(parsed) => parsed
        None => individual_spacings_parent_or_default(node, property)
      }
    None => individual_spacings_parent_or_default(node, property)
  }
}
