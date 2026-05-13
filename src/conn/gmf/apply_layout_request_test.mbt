///|
test "ApplyLayoutRequest stores mapping bounds and scale" {
  reset_conn_gmf_foundation_for_test()
  let edit_part = new_gmf_edit_part(ShapeNodeEditPart)
  let request = new_apply_layout_request()

  inspect(request.get_type(), content="apply layout")
  inspect(request.get_x_bound() > 1000000.0, content="true")
  inspect(request.get_y_bound() > 1000000.0, content="true")
  inspect(request.get_scale(), content="1")

  request.add_element(42, edit_part)
  request.set_upper_bound(100.5, 200.25)
  request.set_scale(0.75)

  let elements = request.get_elements()
  inspect(elements.length(), content="1")
  debug_inspect(elements[0].get_first(), content="Some(42)")
  debug_inspect(elements[0].get_second(), content="Some(0)")
  inspect(request.get_x_bound(), content="100.5")
  inspect(request.get_y_bound(), content="200.25")
  inspect(request.get_scale(), content="0.75")
}
