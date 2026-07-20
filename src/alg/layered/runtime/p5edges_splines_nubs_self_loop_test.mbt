///|
let nubs_self_loop_test_tolerance : Double = 0.0001

///|
fn nubs_self_loop_test_assert_close(actual : Double, expected : Double) -> Unit {
  let diff = (actual - expected).abs()
  if diff > nubs_self_loop_test_tolerance {
    abort("expected=\{expected} actual=\{actual} diff=\{diff}")
  }
}

///|
fn nubs_self_loop_test_port_side_by_name(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn nubs_self_loop_test_new_port(
  x : Double,
  y : Double,
  side : @core.PortSide,
) -> LPort {
  let port = new_l_port()
  port.set_side(side)
  ignore(port.get_position().set_xy(x, y))
  port
}

///|
test "nubs side self loop creates expected endpoint and first control point positions" {
  let east = nubs_self_loop_test_port_side_by_name("EAST")
  let source = nubs_self_loop_test_new_port(0.0, 0.0, east)
  let target = nubs_self_loop_test_new_port(20.0, 0.0, east)

  let nubs = nubs_self_loop_create_side_self_loop(source, target, 10.0)
  let cps = nubs.get_control_points()

  assert_eq(nubs.get_dim(), 3)
  assert_eq(cps.size(), 5)
  nubs_self_loop_test_assert_close(cps.get(0).x, 0.0)
  nubs_self_loop_test_assert_close(cps.get(1).x, 10.0)
  nubs_self_loop_test_assert_close(cps.get(4).x, 20.0)
}

///|
test "nubs corner self loop and multi-side builders preserve control point count" {
  let north = nubs_self_loop_test_port_side_by_name("NORTH")
  let east = nubs_self_loop_test_port_side_by_name("EAST")
  let west = nubs_self_loop_test_port_side_by_name("WEST")

  let source = nubs_self_loop_test_new_port(0.0, 0.0, north)
  let target = nubs_self_loop_test_new_port(10.0, 10.0, east)
  let corner = nubs_self_loop_create_corner_self_loop(source, target, 4.0, 6.0)
  assert_eq(corner.get_control_points().size(), 5)

  let source2 = nubs_self_loop_test_new_port(0.0, 0.0, west)
  let target2 = nubs_self_loop_test_new_port(20.0, 0.0, east)
  let source_bend = @core.new_kvector_xy(2.0, -5.0)
  let target_bend = @core.new_kvector_xy(18.0, -5.0)

  let across = nubs_self_loop_create_across_self_loop(
    source2,
    target2,
    source_bend,
    [@core.new_kvector_xy(5.0, -10.0), @core.new_kvector_xy(15.0, -10.0)],
    target_bend,
  )
  assert_eq(across.get_control_points().size(), 7)

  let three_side = nubs_self_loop_create_three_side_self_loop(
    source2,
    target2,
    source_bend,
    [
      @core.new_kvector_xy(5.0, -10.0),
      @core.new_kvector_xy(10.0, -15.0),
      @core.new_kvector_xy(15.0, -10.0),
    ],
    target_bend,
  )
  assert_eq(three_side.get_control_points().size(), 7)

  let four_side = nubs_self_loop_create_four_side_self_loop(
    source2,
    target2,
    source_bend,
    [
      @core.new_kvector_xy(3.0, -10.0),
      @core.new_kvector_xy(7.0, -15.0),
      @core.new_kvector_xy(13.0, -15.0),
      @core.new_kvector_xy(17.0, -10.0),
    ],
    target_bend,
  )
  assert_eq(four_side.get_control_points().size(), 8)
}
