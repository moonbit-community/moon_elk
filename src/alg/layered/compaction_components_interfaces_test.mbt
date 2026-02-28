///|
fn compaction_rect_to_tuple(
  rect : @core.ElkRectangle,
) -> (Double, Double, Double, Double) {
  (rect.x, rect.y, rect.width, rect.height)
}

///|
fn compaction_rect_opt_to_tuple(
  rect : @core.ElkRectangle?,
) -> (Double, Double, Double, Double)? {
  match rect {
    Some(value) => Some(compaction_rect_to_tuple(value))
    None => None
  }
}

///|
fn compaction_direction_at(index : Int) -> @core.Direction {
  @core.direction_values()[index]
}

///|
fn compaction_port_side_at(index : Int) -> @core.PortSide {
  @core.port_side_values()[index]
}

///|
fn port_sides_to_strings(sides : Array[@core.PortSide]) -> Array[String] {
  let result : Array[String] = []
  for side in sides {
    result.push(@core.port_side_to_string(side))
  }
  result
}

///|
test "IExternalExtension default placeholder is none and accessors delegate" {
  let representor = @core.new_elk_rectangle_xywh(1.0, 2.0, 3.0, 4.0)
  let parent = @core.new_elk_rectangle_xywh(5.0, 6.0, 7.0, 8.0)
  let ext = new_external_extension(
    () => "edge-1",
    () => representor,
    () => parent,
    () => compaction_direction_at(1),
  )

  assert_eq(ext.get_representative(), "edge-1")
  assert_eq(
    compaction_rect_to_tuple(ext.get_representor()),
    (1.0, 2.0, 3.0, 4.0),
  )
  assert_eq(compaction_rect_to_tuple(ext.get_parent()), (5.0, 6.0, 7.0, 8.0))
  assert_eq(@core.direction_to_string(ext.get_direction()), "RIGHT")
  assert_eq(compaction_rect_opt_to_tuple(ext.get_placeholder()), None)
}

///|
test "IComponent and IConnectedComponents mirror configured providers" {
  let ext = new_external_extension(
    () => 42,
    () => @core.new_elk_rectangle_xywh(9.0, 9.0, 1.0, 1.0),
    () => @core.new_elk_rectangle_xywh(0.0, 0.0, 2.0, 2.0),
    () => compaction_direction_at(3),
    get_placeholder=() => Some(@core.new_elk_rectangle_xywh(3.0, 3.0, 1.0, 1.0)),
  )

  let component : IComponent[Unit, Int] = new_component(
    () => [@core.new_elk_rectangle_xywh(0.0, 1.0, 2.0, 3.0)],
    () => [ext],
    () => [compaction_port_side_at(1), compaction_port_side_at(2)],
  )
  let components : IConnectedComponents[Unit, Int] = new_connected_components(
    () => [component],
    () => true,
  )

  assert_eq(components.is_contains_external_extensions(), true)
  assert_eq(components.get_components().length(), 1)
  assert_eq(
    compaction_rect_to_tuple(components.get_components()[0].get_hull()[0]),
    (0.0, 1.0, 2.0, 3.0),
  )
  assert_eq(
    port_sides_to_strings(
      components.get_components()[0].get_external_extension_sides(),
    ),
    ["NORTH", "EAST"],
  )
  assert_eq(
    compaction_rect_opt_to_tuple(
      components.get_components()[0].get_external_extensions()[0].get_placeholder(),
    ),
    Some((3.0, 3.0, 1.0, 1.0)),
  )
}
