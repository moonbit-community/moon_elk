///|
fn gmf_connector_test_new_shape(
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> (GmfFigure, GmfEditPart, GmfView) {
  let figure = new_gmf_figure(bounds=new_gmf_rectangle(x~, y~, width~, height~))
  let edit_part = new_gmf_edit_part(ShapeNodeEditPart, figure~)
  let view = new_gmf_view(location_x=x, location_y=y, width~, height~)
  gmf_edit_part_set_notation_view(edit_part, Some(view))
  (figure, edit_part, view)
}

///|
test "GmfDiagramLayoutConnector hierarchy utilities follow parent chain rules" {
  reset_conn_gmf_foundation_for_test()
  let root = new_gmf_edit_part(RootEditPart)
  let diagram = new_gmf_edit_part(DiagramEditPart)
  let (_, left, _) = gmf_connector_test_new_shape(10, 20, 100, 60)
  let (_, right, _) = gmf_connector_test_new_shape(30, 40, 80, 50)

  gmf_edit_part_set_parent(diagram, Some(root))
  gmf_edit_part_set_parent(left, Some(diagram))
  gmf_edit_part_set_parent(right, Some(diagram))

  inspect(
    gmf_diagram_layout_connector_get_diagram_edit_part(left),
    content="Some(\{diagram})",
  )
  inspect(gmf_diagram_layout_connector_is_parent(diagram, left), content="true")
  inspect(
    gmf_diagram_layout_connector_common_parent(left, right),
    content="Some(\{diagram})",
  )
}

///|
test "GmfDiagramLayoutConnector build_layout_graph keeps selection offset" {
  reset_conn_gmf_foundation_for_test()
  @graph.reset_graph_model_for_test()
  let connector = new_gmf_diagram_layout_connector()

  let diagram_figure = new_gmf_figure(
    bounds=new_gmf_rectangle(x=0, y=0, width=800, height=600),
  )
  let diagram = new_gmf_edit_part(DiagramEditPart, figure=diagram_figure)
  let diagram_view = new_gmf_view(name="MyDiagram")
  gmf_edit_part_set_notation_view(diagram, Some(diagram_view))

  let (left_figure, left, _) = gmf_connector_test_new_shape(100, 200, 80, 60)
  let (right_figure, right, _) = gmf_connector_test_new_shape(250, 320, 70, 50)
  gmf_figure_set_parent(left_figure, Some(diagram_figure))
  gmf_figure_set_parent(right_figure, Some(diagram_figure))
  gmf_edit_part_set_parent(left, Some(diagram))
  gmf_edit_part_set_parent(right, Some(diagram))

  let mapping = connector.build_layout_graph(
    Some(DiagramEditorWorkbenchPart(diagram)),
    Selection([left, right]),
  )

  inspect(mapping.diagram_edit_part, content="Some(\{diagram})")
  inspect(mapping.graph_element_count() > 0, content="true")
  inspect(mapping.coordinate_offset is Some(_), content="true")
}

///|
test "GmfDiagramLayoutConnector apply_layout transfers and executes command" {
  reset_conn_gmf_foundation_for_test()
  @graph.reset_graph_model_for_test()
  let connector = new_gmf_diagram_layout_connector()

  let diagram_figure = new_gmf_figure(
    bounds=new_gmf_rectangle(x=0, y=0, width=500, height=400),
  )
  let diagram = new_gmf_edit_part(DiagramEditPart, figure=diagram_figure)
  gmf_edit_part_set_notation_view(diagram, Some(new_gmf_view(name="d")))

  let (shape_figure, shape, shape_view) = gmf_connector_test_new_shape(
    50, 60, 100, 80,
  )
  gmf_figure_set_parent(shape_figure, Some(diagram_figure))
  gmf_edit_part_set_parent(shape, Some(diagram))

  let mapping = connector.build_layout_graph(
    Some(DiagramEditorWorkbenchPart(diagram)),
    DirectEditPart(diagram),
  )
  for entry in mapping.node_map.to_array() {
    if entry.1 == shape {
      @graph.node_set_location(entry.0, 180.0, 210.0)
      @graph.node_set_dimensions(entry.0, 120.0, 90.0)
    }
  }

  let stack = new_gmf_command_stack()
  mapping.set_command_stack(Some(stack))
  connector.apply_layout(
    mapping,
    new_gmf_connector_layout_settings(
      animate=true,
      min_anim_time=10,
      max_anim_time=100,
      anim_time_factor=25,
    ),
  )

  inspect(mapping.animation_time > 0, content="true")
  inspect(stack.execution_count(), content="1")
  inspect(gmf_view_location_x(shape_view), content="180")
  inspect(gmf_view_location_y(shape_view), content="210")
}
