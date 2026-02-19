///|
test "GmfLayoutEditPolicy understands apply-layout requests" {
  let policy = new_gmf_layout_edit_policy()
  inspect(policy.understands_request(req_apply_layout), content="true")
  inspect(policy.understands_request("other"), content="false")
}

///|
test "GmfLayoutEditPolicy get_command applies scaled shape bounds" {
  reset_conn_gmf_foundation_for_test()
  let policy = new_gmf_layout_edit_policy()
  let host = new_gmf_edit_part(DiagramEditPart)
  gmf_edit_part_set_notation_view(host, Some(new_gmf_view(name="diagram")))

  let shape_view = new_gmf_view(location_x=1, location_y=2, width=3, height=4)
  let shape_part = new_gmf_edit_part(ShapeNodeEditPart)
  gmf_edit_part_set_notation_view(shape_part, Some(shape_view))

  let request = new_apply_layout_request()
  request.set_scale(2.0)
  let element = 101
  gmf_set_layout_element_shape(element, 5.0, 6.0, 7.0, 8.0)
  request.add_element(element, shape_part)

  match policy.get_command(request, host) {
    Some(command) => command.execute()
    None => abort("expected command")
  }

  inspect(gmf_view_location_x(shape_view), content="10")
  inspect(gmf_view_location_y(shape_view), content="12")
  inspect(gmf_view_width(shape_view), content="14")
  inspect(gmf_view_height(shape_view), content="16")
}

///|
test "GmfLayoutEditPolicy trims bend points for connection attachments" {
  reset_conn_gmf_foundation_for_test()
  let policy = new_gmf_layout_edit_policy()
  let host = new_gmf_edit_part(DiagramEditPart)
  gmf_edit_part_set_notation_view(host, Some(new_gmf_view(name="diagram")))

  let source_edge = new_gmf_edit_part(ConnectionEditPart)
  let target_node = new_gmf_edit_part(ShapeNodeEditPart)

  let edge_view = new_gmf_view()
  let edge_part = new_gmf_edit_part(ConnectionEditPart)
  gmf_edit_part_set_notation_view(edge_part, Some(edge_view))
  gmf_edit_part_set_source(edge_part, Some(source_edge))
  gmf_edit_part_set_target(edge_part, Some(target_node))

  let bends = new_gmf_point_list(points=[
    new_gmf_point(0, 0),
    new_gmf_point(5, 5),
    new_gmf_point(10, 10),
    new_gmf_point(20, 20),
  ])
  let element = 202
  gmf_set_layout_element_edge(
    element,
    bends,
    Some("source"),
    Some("target"),
    Some("(1,2)"),
  )
  let request = new_apply_layout_request()
  request.add_element(element, edge_part)

  match policy.get_command(request, host) {
    Some(command) => command.execute()
    None => abort("expected command")
  }

  inspect(gmf_view_bendpoints(edge_view).size(), content="2")
  inspect(gmf_view_source_terminal(edge_view), content="Some(\"source\")")
  inspect(gmf_view_target_terminal(edge_view), content="Some(\"target\")")
  inspect(
    gmf_view_get_style(edge_view, junction_points_style_name),
    content="Some(\"(1,2)\")",
  )
}
