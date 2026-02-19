///|
test "RoutingDirection values and names follow upstream order" {
  let values = routing_direction_values()
  assert_eq(values.length(), 3)
  assert_eq(routing_direction_to_string(values[0]), "WEST_TO_EAST")
  assert_eq(routing_direction_to_string(values[1]), "NORTH_TO_SOUTH")
  assert_eq(routing_direction_to_string(values[2]), "SOUTH_TO_NORTH")
}
