///|
fn conn_gmf_elk_layout_provider_test_parent_with_children() -> (
  GmfEditPart,
  GmfEditPart,
  GmfEditPart,
  GmfEditPart,
) {
  let parent = new_gmf_edit_part(DiagramEditPart, notation_node="root")
  let shape = new_gmf_edit_part(ShapeNodeEditPart, notation_node="shape")
  let border = new_gmf_edit_part(
    AbstractBorderItemEditPart,
    notation_node="border",
  )
  let image = new_gmf_edit_part(AbstractImageEditPart, notation_node="image")
  gmf_edit_part_set_parent(shape, Some(parent))
  gmf_edit_part_set_parent(border, Some(parent))
  gmf_edit_part_set_parent(image, Some(parent))
  (parent, shape, border, image)
}

///|
test "ElkLayoutProvider can_layout_nodes checks children when selection is empty" {
  reset_conn_gmf_foundation_for_test()
  let provider = new_elk_layout_provider()
  let (parent, _shape, _border, _image) = conn_gmf_elk_layout_provider_test_parent_with_children()
  let hint = new_gmf_layout_hint(graphical_edit_part=Some(parent))
  debug_inspect(provider.can_layout_nodes([], false, hint), content="true")
}

///|
test "ElkLayoutProvider can_layout_nodes checks selected nodes via notation id" {
  reset_conn_gmf_foundation_for_test()
  let provider = new_elk_layout_provider()
  let (parent, _shape, _border, _image) = conn_gmf_elk_layout_provider_test_parent_with_children()
  let hint = new_gmf_layout_hint(graphical_edit_part=Some(parent))
  debug_inspect(
    provider.can_layout_nodes([new_gmf_layout_node("shape")], false, hint),
    content="true",
  )
  debug_inspect(
    provider.can_layout_nodes([new_gmf_layout_node("missing")], false, hint),
    content="false",
  )
}

///|
test "ElkLayoutProvider layout_layout_nodes invokes diagram layout engine with preferences" {
  reset_conn_gmf_foundation_for_test()
  let provider = new_elk_layout_provider()
  let (parent, _shape, _border, _image) = conn_gmf_elk_layout_provider_test_parent_with_children()
  let hint = new_gmf_layout_hint(graphical_edit_part=Some(parent))
  gmf_set_boolean_preference(
    "org.eclipse.elk.core.ui", "org.eclipse.elk.zoomToFit", true,
  )
  gmf_set_boolean_preference(
    "org.eclipse.elk.core.ui", "org.eclipse.elk.progressDialog", true,
  )

  let run_all = provider.layout_layout_nodes([], false, hint)
  run_all()
  debug_inspect(gmf_last_layout_invocation_single_part(), content="Some(0)")
  debug_inspect(
    gmf_last_layout_invocation_progress_dialog(),
    content="Some(true)",
  )
  debug_inspect(gmf_last_layout_invocation_zoom_to_fit(), content="Some(true)")

  let run_selected = provider.layout_layout_nodes(
    [new_gmf_layout_node("shape")],
    false,
    hint,
  )
  run_selected()
  debug_inspect(
    gmf_last_layout_invocation_multiple_parts(),
    content="Some([1])",
  )
}

///|
test "ElkLayoutProvider provides only layout-node operations" {
  let provider = new_elk_layout_provider()
  debug_inspect(provider.provides(LayoutNodeOperation), content="true")
  debug_inspect(provider.provides(CreateEditPoliciesOperation), content="false")
}
