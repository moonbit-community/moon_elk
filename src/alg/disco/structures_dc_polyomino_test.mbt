///|
fn disco_poly_test_point(x : Double, y : Double) -> @core.KVector {
  let point = @core.new_kvector()
  ignore(point.set_xy(x, y))
  point
}

///|
fn disco_poly_test_diamond_path() -> @core.KVectorChain {
  let path = @core.new_kvector_chain()
  path.add_vector(disco_poly_test_point(15.0, 20.0))
  path.add_vector(disco_poly_test_point(10.0, 25.0))
  path.add_vector(disco_poly_test_point(15.0, 30.0))
  path.add_vector(disco_poly_test_point(20.0, 25.0))
  path
}

///|
test "DCPolyomino basic conversion and metadata" {
  let elem = new_dc_element(disco_poly_test_diamond_path())
  let comp = new_dc_component()
  comp.add_element(elem)

  let poly = new_dc_polyomino(comp, 4.0, 4.0)
  assert_eq(poly.width(), 3)
  assert_eq(poly.height(), 3)
  assert_true(
    poly.is_blocked(0, 0) ||
    poly.is_blocked(1, 0) ||
    poly.is_blocked(2, 0) ||
    poly.is_blocked(0, 1) ||
    poly.is_blocked(1, 1) ||
    poly.is_blocked(2, 1) ||
    poly.is_blocked(0, 2) ||
    poly.is_blocked(1, 2) ||
    poly.is_blocked(2, 2),
  )

  let offset = poly.get_offset()
  assert_eq(offset.x, 1.0)
  assert_eq(offset.y, 1.0)

  let corner = poly.get_min_corner_on_canvas()
  assert_eq(corner.x, 9.0)
  assert_eq(corner.y, 19.0)

  assert_eq(poly.get_id(), -1)
  poly.set_id(7)
  assert_eq(poly.get_id(), 7)
  assert_eq(poly.get_representee().get_id(), 7)
}
