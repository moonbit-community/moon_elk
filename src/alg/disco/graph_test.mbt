///|
fn disco_test_point(x : Double, y : Double) -> @core.KVector {
  let point = @core.new_kvector()
  ignore(point.set_xy(x, y))
  point
}

///|
fn disco_test_rect_path(
  x0 : Double,
  y0 : Double,
  x1 : Double,
  y1 : Double,
) -> @core.KVectorChain {
  let path = @core.new_kvector_chain()
  path.add_vector(disco_test_point(x0, y0))
  path.add_vector(disco_test_point(x0, y1))
  path.add_vector(disco_test_point(x1, y1))
  path.add_vector(disco_test_point(x1, y0))
  path
}

///|
fn disco_test_rectangle(
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> @core.ElkRectangle {
  let rect = @core.new_elk_rectangle()
  rect.set_rect(x, y, width, height)
  rect
}

///|
fn disco_direction_by_name(name : String) -> DCDirection {
  let directions = dc_direction_values()
  match name {
    "DCNorth" => directions[0]
    "DCEast" => directions[1]
    "DCSouth" => directions[2]
    _ => directions[3]
  }
}

///|
test "DCDirection is_horizontal" {
  assert_eq(disco_direction_by_name("DCNorth").is_horizontal(), false)
  assert_eq(disco_direction_by_name("DCEast").is_horizontal(), true)
  assert_eq(disco_direction_by_name("DCSouth").is_horizontal(), false)
  assert_eq(disco_direction_by_name("DCWest").is_horizontal(), true)
}

///|
test "DCElement basics and extension offset" {
  let elem = new_dc_element(disco_test_rect_path(10.0, 20.0, 20.0, 30.0))

  let bounds = elem.get_bounds()
  assert_eq(bounds.x, 10.0)
  assert_eq(bounds.y, 20.0)
  assert_eq(bounds.width, 10.0)
  assert_eq(bounds.height, 10.0)

  let coords = elem.get_coords()
  assert_eq(coords.length(), 8)
  assert_eq(coords[0], 10.0)
  assert_eq(coords[1], 20.0)
  assert_eq(coords[6], 20.0)
  assert_eq(coords[7], 20.0)

  assert_eq(elem.intersects(disco_test_rectangle(9.0, 22.0, 3.0, 3.0)), true)
  assert_eq(
    elem.intersects(disco_test_rectangle(100.0, 200.0, 2.0, 2.0)),
    false,
  )

  let ext = new_dc_extension(
    elem,
    disco_direction_by_name("DCEast"),
    disco_test_point(15.0, 24.0),
    4.0,
  )
  assert_eq(ext.get_direction().is_horizontal(), true)
  assert_eq(ext.get_width(), 4.0)
  assert_eq(ext.get_offset().x, 5.0)
  assert_eq(ext.get_offset().y, 2.0)
  assert_eq(elem.get_extensions().length(), 1)
}

///|
test "DCComponent update and DCGraph construction" {
  let elem = new_dc_element(disco_test_rect_path(10.0, 20.0, 20.0, 30.0))
  ignore(
    new_dc_extension(
      elem,
      disco_direction_by_name("DCNorth"),
      disco_test_point(12.0, 20.0),
      6.0,
    ),
  )

  let comp = new_dc_component()
  comp.add_element(elem)

  let dims = comp.get_dimensions_of_bounding_rectangle()
  assert_eq(dims.x, 11.0)
  assert_eq(dims.y, 10.0)

  let corner = comp.get_min_corner()
  assert_eq(corner.x, 9.0)
  assert_eq(corner.y, 20.0)

  comp.set_offset(disco_test_point(2.0, 3.0))
  let moved_corner = comp.get_min_corner()
  assert_eq(moved_corner.x, 11.0)
  assert_eq(moved_corner.y, 23.0)

  let elem2 = new_dc_element(disco_test_rect_path(100.0, 100.0, 110.0, 110.0))
  let graph = new_dc_graph([[elem], [elem2]], inset=7.5)
  assert_eq(graph.get_components().length(), 2)
  assert_eq(graph.get_inset(), 7.5)
}
