///|
fn splines_math_test_port_side(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown side")
}

///|
fn splines_math_test_assert_near(
  actual : Double,
  expected : Double,
  tolerance? : Double = 0.000001,
) -> Unit raise {
  assert_true((actual - expected).abs() <= tolerance)
}

///|
test "SplinesMath computes line intersection and parallel case" {
  let crossing = splines_math_intersect(
    new_kvector_xy(0.0, 0.0),
    new_kvector_xy(1.0, 1.0),
    new_kvector_xy(0.0, 1.0),
    new_kvector_xy(1.0, 0.0),
  )
  match crossing {
    Some(point) => {
      splines_math_test_assert_near(point.x, 0.5)
      splines_math_test_assert_near(point.y, 0.5)
    }
    None => fail("expected intersection point")
  }

  let parallel = splines_math_intersect(
    new_kvector_xy(0.0, 0.0),
    new_kvector_xy(1.0, 1.0),
    new_kvector_xy(0.0, 1.0),
    new_kvector_xy(1.0, 2.0),
  )
  assert_true(parallel.is_empty())
}

///|
test "SplinesMath supports direction-based intersection and angle helpers" {
  let intersection = splines_math_intersect_by_directions(
    new_kvector_xy(0.0, 0.0),
    new_kvector_xy(0.0, 1.0),
    0.0,
    splines_math_half_pi,
  )
  match intersection {
    Some(point) => {
      splines_math_test_assert_near(point.x, 0.0)
      splines_math_test_assert_near(point.y, 0.0)
    }
    None => fail("expected direction intersection")
  }

  let right_angle = splines_math_inner_angle_vectors(
    new_kvector_xy(1.0, 0.0),
    new_kvector_xy(0.0, 1.0),
  )
  splines_math_test_assert_near(right_angle, splines_math_half_pi)

  let direction_angle = splines_math_inner_angle_directions(0.0, splines_math_half_pi)
  splines_math_test_assert_near(direction_angle, splines_math_half_pi)
}

///|
test "SplinesMath port-side helpers and between checks match upstream formulas" {
  let north = splines_math_test_port_side("NORTH")
  let east = splines_math_test_port_side("EAST")
  let south = splines_math_test_port_side("SOUTH")
  let west = splines_math_test_port_side("WEST")

  splines_math_test_assert_near(
    splines_math_port_side_to_direction(north),
    splines_math_three_half_pi,
  )
  splines_math_test_assert_near(splines_math_port_side_to_direction(east), 0.0)
  splines_math_test_assert_near(
    splines_math_port_side_to_direction(south),
    splines_math_half_pi,
  )
  splines_math_test_assert_near(splines_math_port_side_to_direction(west), @math.PI)

  let node = new_l_node()
  ignore(node.get_size().set_xy(20.0, 30.0))
  node.get_margin().set_top(1.0)
  node.get_margin().set_right(2.0)
  node.get_margin().set_bottom(3.0)
  node.get_margin().set_left(4.0)

  let port = new_l_port()
  port.set_node(Some(node))
  ignore(port.get_position().set_xy(5.0, 7.0))
  ignore(port.get_anchor().set_xy(2.0, 3.0))

  splines_math_test_assert_near(splines_math_dist_port_to_node_edge(port, north), -10.0)
  splines_math_test_assert_near(splines_math_dist_port_to_node_edge(port, east), 13.0)
  splines_math_test_assert_near(splines_math_dist_port_to_node_edge(port, south), 20.0)
  splines_math_test_assert_near(splines_math_dist_port_to_node_edge(port, west), -7.0)

  assert_eq(splines_math_get_margin_on_port_side(node, north), 1.0)
  assert_eq(splines_math_get_margin_on_port_side(node, east), 2.0)
  assert_eq(splines_math_get_margin_on_port_side(node, south), 3.0)
  assert_eq(splines_math_get_margin_on_port_side(node, west), 4.0)

  assert_true(splines_math_is_between_int(5, 10, 0))
  assert_false(splines_math_is_between_int(11, 10, 0))
  assert_true(splines_math_is_between_double(5.0, 10.0, 0.0))
  assert_false(splines_math_is_between_double(11.0, 10.0, 0.0))
}
