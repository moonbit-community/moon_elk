///|
pub struct DeprecatedLayoutOptionReplacer {
  _dummy : Int
}

///|
pub fn new_deprecated_layout_option_replacer() -> DeprecatedLayoutOptionReplacer {
  { _dummy: 0 }
}

///|
fn add_unique_string(values : Array[String], value : String) -> Unit {
  for existing in values {
    if existing == value {
      return
    }
  }
  values.push(value)
}

///|
fn remove_string(values : Array[String], value : String) -> Unit {
  let mut write_index = 0
  for read_index = 0; read_index < values.length(); read_index = read_index + 1 {
    if values[read_index] != value {
      values[write_index] = values[read_index]
      write_index += 1
    }
  }
  while values.length() > write_index {
    ignore(values.pop())
  }
}

///|
fn replace_next_to_port_if_possible(element : ElkNode) -> Unit {
  let placements = node_get_string_set_property(element, port_labels_placement)
  add_unique_string(placements, "NEXT_TO_PORT_IF_POSSIBLE")
  node_set_string_set_property(element, port_labels_placement, placements)
  node_clear_bool_property(element, port_labels_next_to_port_if_possible)
}

///|
fn move_space_efficient_port_labels(element : ElkNode) -> Unit {
  let mut size_options = node_get_string_set_property(
    element, node_size_options,
  )
  let mut has_space_efficient = false
  for option in size_options {
    if option == "SPACE_EFFICIENT_PORT_LABELS" {
      has_space_efficient = true
      break
    }
  }
  if has_space_efficient {
    let placements = node_get_string_set_property(
      element, port_labels_placement,
    )
    add_unique_string(placements, "SPACE_EFFICIENT")
    node_set_string_set_property(element, port_labels_placement, placements)
    size_options = node_get_string_set_property(element, node_size_options)
    remove_string(size_options, "SPACE_EFFICIENT_PORT_LABELS")
    node_set_string_set_property(element, node_size_options, size_options)
  }
}

///|
pub fn DeprecatedLayoutOptionReplacer::visit(
  self : DeprecatedLayoutOptionReplacer,
  element : ElkNode,
) -> Unit {
  ignore(self)
  if node_has_bool_property(element, port_labels_next_to_port_if_possible) {
    replace_next_to_port_if_possible(element)
  }
  if node_has_string_set_property(element, node_size_options) {
    move_space_efficient_port_labels(element)
  }
}
