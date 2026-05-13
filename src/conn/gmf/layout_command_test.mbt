///|
test "GmfLayoutCommand applies shape and edge layout updates" {
  reset_conn_gmf_foundation_for_test()
  let diagram_view = new_gmf_view(name="diagram.notation")
  let node_view = new_gmf_view(
    location_x=10,
    location_y=20,
    width=30,
    height=40,
  )
  let edge_view = new_gmf_view()
  let command = new_gmf_layout_command(diagram_view=Some(diagram_view))

  command.add_shape_layout(
    node_view,
    Some(new_gmf_point(100, 200)),
    Some(new_gmf_dimension(300, 400)),
  )
  let bends = new_gmf_point_list(points=[
    new_gmf_point(1, 2),
    new_gmf_point(3, 4),
  ])
  command.add_edge_layout(
    edge_view,
    Some(bends),
    Some("0.1,0.2"),
    Some("0.8,0.9"),
    Some("(5,6)"),
  )
  command.execute()

  debug_inspect(gmf_view_location_x(node_view), content="100")
  debug_inspect(gmf_view_location_y(node_view), content="200")
  debug_inspect(gmf_view_width(node_view), content="300")
  debug_inspect(gmf_view_height(node_view), content="400")
  debug_inspect(
    gmf_view_source_terminal(edge_view),
    content="Some(\"0.1,0.2\")",
  )
  debug_inspect(
    gmf_view_target_terminal(edge_view),
    content="Some(\"0.8,0.9\")",
  )
  debug_inspect(
    gmf_view_get_style(edge_view, junction_points_style_name),
    content="Some(\"(5,6)\")",
  )
  debug_inspect(command.get_affected_files(), content="[\"diagram.notation\"]")
}

///|
test "GmfLayoutCommand removes junction style and enforces oblique routing" {
  reset_conn_gmf_foundation_for_test()
  let edge_view = new_gmf_view()
  gmf_view_set_style(edge_view, junction_points_style_name, "old")
  let command = new_gmf_layout_command()
  command.set_oblique_routing(true)
  command.add_edge_layout(edge_view, None, None, None, None)
  command.execute()

  debug_inspect(
    gmf_view_get_style(edge_view, junction_points_style_name),
    content="None",
  )
  debug_inspect(gmf_view_is_routing_manual(edge_view), content="true")
  debug_inspect(gmf_view_is_smoothness_none(edge_view), content="true")
}
