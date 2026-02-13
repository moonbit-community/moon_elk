///|
fn vertical_segment_test_port_id(port : LPort?) -> Int {
  match port {
    Some(value) => value.get_id()
    None => -1
  }
}

///|
test "vertical segment constructor keeps geometry and matching junction points" {
  let edge = new_l_edge()
  edge.set_id(10)

  let junction_points = new_kvector_chain()
  junction_points.add_last_vector(new_kvector_xy(5.0, 2.0))
  junction_points.add_last_vector(new_kvector_xy(4.0, 3.0))
  junction_points.add_last_vector(new_kvector_xy(5.0, 6.0))
  edge.set_property_kvector_chain(
    layered_options_junction_points, junction_points,
  )

  let segment = new_vertical_segment(
    new_kvector_xy(5.0, 1.0),
    new_kvector_xy(5.0, 7.0),
    None,
    edge,
  )

  assert_eq(
    (
      segment.hitbox.x,
      segment.hitbox.y,
      segment.hitbox.width,
      segment.hitbox.height,
    ),
    (5.0, 1.0, 0.0, 6.0),
  )
  assert_eq(segment.represented_l_edges.length(), 1)
  assert_eq(segment.affected_bends.length(), 2)
  assert_eq(segment.junction_points.size(), 2)
  assert_eq(segment.junction_points.get(0).y, 2.0)
  assert_eq(segment.junction_points.get(1).y, 6.0)
}

///|
test "vertical segment join_with merges fields and expands hitbox" {
  let edge1 = new_l_edge()
  edge1.set_id(1)
  let edge2 = new_l_edge()
  edge2.set_id(2)
  let edge3 = new_l_edge()
  edge3.set_id(3)

  let segment1 = new_vertical_segment(
    new_kvector_xy(5.0, 1.0),
    new_kvector_xy(5.0, 7.0),
    None,
    edge1,
  )
  let segment2 = new_vertical_segment(
    new_kvector_xy(7.0, 0.0),
    new_kvector_xy(7.0, 4.0),
    None,
    edge2,
  )
  let extra = new_vertical_segment(
    new_kvector_xy(9.0, 1.0),
    new_kvector_xy(9.0, 2.0),
    None,
    edge3,
  )

  segment1.ignore_spacing.set(true, false, false, false)
  segment2.ignore_spacing.set(false, true, false, false)
  segment2.constraints.push(extra)
  segment2.joined.push(extra)

  let port = new_l_port()
  port.set_id(77)
  segment2.set_a_port(Some(port))

  let merged = segment1.join_with(segment2)

  assert_eq(
    (
      merged.hitbox.x,
      merged.hitbox.y,
      merged.hitbox.width,
      merged.hitbox.height,
    ),
    (5.0, 0.0, 2.0, 7.0),
  )
  assert_eq(merged.represented_l_edges.length(), 2)
  assert_eq(merged.affected_bends.length(), 4)
  assert_eq(merged.constraints.length(), 1)
  assert_eq(merged.joined.length(), 2)
  assert_true(merged.ignore_spacing.left)
  assert_true(merged.ignore_spacing.right)
  assert_eq(vertical_segment_test_port_id(merged.get_a_port()), 77)
}

///|
test "vertical segment intersects and compare_to follow upstream rules" {
  let edge1 = new_l_edge()
  let edge2 = new_l_edge()
  let edge3 = new_l_edge()
  let edge4 = new_l_edge()

  let a = new_vertical_segment(
    new_kvector_xy(5.0, 1.0),
    new_kvector_xy(5.0, 4.0),
    None,
    edge1,
  )
  let b = new_vertical_segment(
    new_kvector_xy(5.0, 4.0),
    new_kvector_xy(5.0, 8.0),
    None,
    edge2,
  )
  let c = new_vertical_segment(
    new_kvector_xy(6.0, 1.0),
    new_kvector_xy(6.0, 4.0),
    None,
    edge3,
  )
  let d = new_vertical_segment(
    new_kvector_xy(5.0, 0.0),
    new_kvector_xy(5.0, 2.0),
    None,
    edge4,
  )

  assert_true(a.intersects(b))
  assert_false(a.intersects(c))
  assert_eq(a.compare_to(c), -1)
  assert_eq(c.compare_to(a), 1)
  assert_eq(a.compare_to(d), 1)
  assert_true(a.to_string().has_prefix("VerticalSegment "))
}
