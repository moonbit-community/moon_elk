///|
fn splines_rectangle_test_assert_near(
  actual : Double,
  expected : Double,
) -> Unit {
  let diff = (actual - expected).abs()
  if diff > 0.0000001 {
    abort("expected=\{expected} actual=\{actual} diff=\{diff}")
  }
}

///|
fn splines_rectangle_test_port_side(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown side")
}

///|
test "splines rectangle constructors and geometry" {
  let rectangle = new_rectangle_values(2.0, 3.0, 8.0, 11.0)
  splines_rectangle_test_assert_near(rectangle.get_left(), 2.0)
  splines_rectangle_test_assert_near(rectangle.get_top(), 3.0)
  splines_rectangle_test_assert_near(rectangle.get_right(), 8.0)
  splines_rectangle_test_assert_near(rectangle.get_bottom(), 11.0)
  splines_rectangle_test_assert_near(rectangle.get_width(), 6.0)
  splines_rectangle_test_assert_near(rectangle.get_height(), 8.0)

  let copied = new_rectangle_copy(rectangle)
  splines_rectangle_test_assert_near(copied.get_left(), 2.0)
  splines_rectangle_test_assert_near(copied.get_bottom(), 11.0)

  let point_rectangle = new_rectangle_position(new_kvector_xy(5.0, -2.0))
  splines_rectangle_test_assert_near(point_rectangle.get_left(), 5.0)
  splines_rectangle_test_assert_near(point_rectangle.get_right(), 5.0)
  splines_rectangle_test_assert_near(point_rectangle.get_top(), -2.0)
  splines_rectangle_test_assert_near(point_rectangle.get_bottom(), -2.0)

  let shape = new_l_shape()
  ignore(shape.get_position().set_xy(10.0, 20.0))
  ignore(shape.get_size().set_xy(30.0, 40.0))
  let shape_rectangle = new_rectangle_shape(shape)
  splines_rectangle_test_assert_near(shape_rectangle.get_left(), 10.0)
  splines_rectangle_test_assert_near(shape_rectangle.get_top(), 20.0)
  splines_rectangle_test_assert_near(shape_rectangle.get_right(), 40.0)
  splines_rectangle_test_assert_near(shape_rectangle.get_bottom(), 60.0)

  let vector_rectangle = new_rectangle_vectors([
    new_kvector_xy(4.0, 9.0),
    new_kvector_xy(-1.0, 3.0),
    new_kvector_xy(7.0, 5.0),
  ])
  splines_rectangle_test_assert_near(vector_rectangle.get_left(), -1.0)
  splines_rectangle_test_assert_near(vector_rectangle.get_top(), 3.0)
  splines_rectangle_test_assert_near(vector_rectangle.get_right(), 7.0)
  splines_rectangle_test_assert_near(vector_rectangle.get_bottom(), 9.0)
}

///|
test "splines rectangle union and enlarge" {
  let rectangle = new_rectangle_values(1.0, 2.0, 3.0, 4.0)
  rectangle.union_vector(new_kvector_xy(-2.0, 10.0))
  splines_rectangle_test_assert_near(rectangle.get_left(), -2.0)
  splines_rectangle_test_assert_near(rectangle.get_top(), 2.0)
  splines_rectangle_test_assert_near(rectangle.get_right(), 3.0)
  splines_rectangle_test_assert_near(rectangle.get_bottom(), 10.0)

  let shape = new_l_shape()
  ignore(shape.get_position().set_xy(8.0, -2.0))
  ignore(shape.get_size().set_xy(2.0, 5.0))
  rectangle.union_shape(shape)
  splines_rectangle_test_assert_near(rectangle.get_right(), 10.0)
  splines_rectangle_test_assert_near(rectangle.get_top(), -2.0)

  rectangle.union_rectangle(new_rectangle_values(-5.0, -4.0, -1.0, 1.0))
  splines_rectangle_test_assert_near(rectangle.get_left(), -5.0)
  splines_rectangle_test_assert_near(rectangle.get_top(), -4.0)

  let merged = rectangle_union(
    new_rectangle_values(0.0, 0.0, 1.0, 1.0),
    new_rectangle_values(-2.0, -3.0, -1.0, -2.0),
  )
  splines_rectangle_test_assert_near(merged.get_left(), -2.0)
  splines_rectangle_test_assert_near(merged.get_top(), -3.0)
  splines_rectangle_test_assert_near(merged.get_right(), 1.0)
  splines_rectangle_test_assert_near(merged.get_bottom(), 1.0)

  let first = new_rectangle_values(0.0, 0.0, 1.0, 1.0)
  let second = new_rectangle_values(5.0, 5.0, 6.0, 6.0)
  let merged_collection = rectangle_union_collection([first, second])
  splines_rectangle_test_assert_near(merged_collection.get_left(), 0.0)
  splines_rectangle_test_assert_near(merged_collection.get_top(), 0.0)
  splines_rectangle_test_assert_near(merged_collection.get_right(), 1.0)
  splines_rectangle_test_assert_near(merged_collection.get_bottom(), 1.0)

  rectangle.enlarge(2.0)
  splines_rectangle_test_assert_near(rectangle.get_left(), -7.0)
  splines_rectangle_test_assert_near(rectangle.get_top(), -6.0)
  splines_rectangle_test_assert_near(rectangle.get_right(), 12.0)
  splines_rectangle_test_assert_near(rectangle.get_bottom(), 12.0)
}

///|
test "splines rectangle port side and margins" {
  let north = splines_rectangle_test_port_side("NORTH")
  let east = splines_rectangle_test_port_side("EAST")
  let south = splines_rectangle_test_port_side("SOUTH")
  let west = splines_rectangle_test_port_side("WEST")
  let undefined_side = splines_rectangle_test_port_side("UNDEFINED")

  let rectangle = new_rectangle_values(-2.0, -3.0, 25.0, 12.0)
  splines_rectangle_test_assert_near(rectangle.get_from_port_side(north), -3.0)
  splines_rectangle_test_assert_near(rectangle.get_from_port_side(east), 25.0)
  splines_rectangle_test_assert_near(rectangle.get_from_port_side(south), 12.0)
  splines_rectangle_test_assert_near(rectangle.get_from_port_side(west), -2.0)
  splines_rectangle_test_assert_near(
    rectangle.get_from_port_side(undefined_side),
    0.0,
  )

  let shape = new_l_shape()
  ignore(shape.get_size().set_xy(20.0, 10.0))
  let margins = rectangle.to_node_margins(shape)
  splines_rectangle_test_assert_near(margins.get_top(), 3.0)
  splines_rectangle_test_assert_near(margins.get_left(), 2.0)
  splines_rectangle_test_assert_near(margins.get_bottom(), 2.0)
  splines_rectangle_test_assert_near(margins.get_right(), 5.0)

  inspect(
    new_rectangle_values(1.04, 2.06, 3.0, 4.0).to_string(),
    content="[top= 2.1,left= 1.0,bottom= 4.0,right= 3.0]",
  )
}
