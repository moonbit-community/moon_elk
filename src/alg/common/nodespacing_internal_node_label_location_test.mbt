///|
test "NodeLabelLocation values and enum helpers" {
  inspect(horizontal_label_alignment_values().length(), content="3")
  inspect(vertical_label_alignment_values().length(), content="3")
  inspect(container_area_values().length(), content="3")
  inspect(node_label_location_values().length(), content="22")
}

///|
test "NodeLabelLocation from placement accepts any order" {
  let h_priority = node_label_placement_value_of(8)
  let h_left = node_label_placement_value_of(0)
  let v_center = node_label_placement_value_of(4)
  let outside = node_label_placement_value_of(7)

  let location = node_label_location_from_node_label_placement([
    h_priority, h_left, v_center, outside,
  ])
  inspect(node_label_location_to_string(location), content="OUT_L_C")
  inspect(port_side_to_string(location.outside_side()), content="WEST")
}

///|
test "NodeLabelLocation exposes alignment and container areas" {
  let inside = node_label_placement_value_of(6)
  let v_bottom = node_label_placement_value_of(5)
  let h_center = node_label_placement_value_of(1)

  let location = node_label_location_from_node_label_placement([
    inside, v_bottom, h_center,
  ])

  inspect(node_label_location_to_string(location), content="IN_B_C")
  inspect(location.is_inside_location(), content="true")
  inspect(
    match location.horizontal_alignment() {
      Some(value) => horizontal_label_alignment_to_string(value)
      None => "NONE"
    },
    content="CENTER",
  )
  inspect(
    match location.vertical_alignment() {
      Some(value) => vertical_label_alignment_to_string(value)
      None => "NONE"
    },
    content="BOTTOM",
  )
  inspect(
    match location.container_row() {
      Some(value) => container_area_to_string(value)
      None => "NONE"
    },
    content="END",
  )
  inspect(
    match location.container_column() {
      Some(value) => container_area_to_string(value)
      None => "NONE"
    },
    content="CENTER",
  )
}

///|
test "NodeLabelLocation returns undefined for invalid placement" {
  let inside = node_label_placement_value_of(6)
  let outside = node_label_placement_value_of(7)

  let invalid = node_label_location_from_node_label_placement([inside, outside])

  inspect(node_label_location_to_string(invalid), content="UNDEFINED")
  inspect(invalid.is_inside_location(), content="false")
  inspect(port_side_to_string(invalid.outside_side()), content="UNDEFINED")
}
