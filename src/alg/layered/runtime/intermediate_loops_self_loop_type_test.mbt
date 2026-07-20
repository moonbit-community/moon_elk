///|
fn sl_side_undefined() -> @core.PortSide {
  @core.port_side_values()[0]
}

///|
fn sl_side_north() -> @core.PortSide {
  @core.port_side_values()[1]
}

///|
fn sl_side_east() -> @core.PortSide {
  @core.port_side_values()[2]
}

///|
fn sl_side_south() -> @core.PortSide {
  @core.port_side_values()[3]
}

///|
fn sl_side_west() -> @core.PortSide {
  @core.port_side_values()[4]
}

///|
test "self loop type derives from involved port sides" {
  inspect(
    self_loop_type_option_to_string(
      self_loop_type_from_port_sides([sl_side_north()]),
    ),
    content="ONE_SIDE",
  )
  inspect(
    self_loop_type_option_to_string(
      self_loop_type_from_port_sides([sl_side_north(), sl_side_east()]),
    ),
    content="TWO_SIDES_CORNER",
  )
  inspect(
    self_loop_type_option_to_string(
      self_loop_type_from_port_sides([sl_side_east(), sl_side_west()]),
    ),
    content="TWO_SIDES_OPPOSING",
  )
  inspect(
    self_loop_type_option_to_string(
      self_loop_type_from_port_sides([
        sl_side_north(),
        sl_side_east(),
        sl_side_south(),
      ]),
    ),
    content="THREE_SIDES",
  )
  inspect(
    self_loop_type_option_to_string(
      self_loop_type_from_port_sides([
        sl_side_north(),
        sl_side_east(),
        sl_side_south(),
        sl_side_west(),
      ]),
    ),
    content="FOUR_SIDES",
  )
}

///|
test "self loop type handles duplicates and empty sets" {
  inspect(
    self_loop_type_option_to_string(
      self_loop_type_from_port_sides([
        sl_side_north(),
        sl_side_north(),
        sl_side_north(),
      ]),
    ),
    content="ONE_SIDE",
  )
  inspect(
    self_loop_type_option_to_string(self_loop_type_from_port_sides([])),
    content="NONE",
  )
}

///|
test "panic self loop type rejects undefined side" {
  ignore(self_loop_type_from_port_sides([sl_side_undefined()]))
}
