///|
fn conn_gmf_layout_configuration_store_test_filter() -> IEditPartFilter {
  new_i_edit_part_filter_default_impl()
}

///|
test "GmfLayoutConfigurationStore reads writes and removes options in notation styles" {
  reset_conn_gmf_foundation_for_test()
  let view = new_gmf_view()
  let edit_part = new_gmf_edit_part(ShapeNodeEditPart)
  gmf_edit_part_set_notation_view(edit_part, Some(view))
  let store = new_gmf_layout_configuration_store(
    edit_part,
    conn_gmf_layout_configuration_store_test_filter(),
  )

  debug_inspect(store.get_option_value("x"), content="None")
  store.set_option_value("x", Some("42"))
  debug_inspect(store.get_option_value("x"), content="Some(\"42\")")
  store.set_option_value("x", None)
  debug_inspect(store.get_option_value("x"), content="None")
}

///|
test "GmfLayoutConfigurationStore exposes note default comment-box option" {
  reset_conn_gmf_foundation_for_test()
  let note = new_gmf_edit_part(NoteEditPart)
  let store = new_gmf_layout_configuration_store(
    note,
    conn_gmf_layout_configuration_store_test_filter(),
  )
  debug_inspect(
    store.get_option_value(gmf_core_option_comment_box_id),
    content="Some(\"true\")",
  )
}

///|
test "GmfLayoutConfigurationStore computes affected options from styles and defaults" {
  reset_conn_gmf_foundation_for_test()
  let view = new_gmf_view()
  let note = new_gmf_edit_part(NoteEditPart)
  gmf_edit_part_set_notation_view(note, Some(view))
  gmf_view_set_style(view, "layout:alpha", "1")
  gmf_view_set_style(view, "layout:beta", "2")
  let store = new_gmf_layout_configuration_store(
    note,
    conn_gmf_layout_configuration_store_test_filter(),
  )
  let affected = store.get_affected_options()
  debug_inspect(affected.length(), content="3")
}

///|
test "GmfLayoutConfigurationStore maps edit-part kinds to option targets" {
  reset_conn_gmf_foundation_for_test()
  let border = new_gmf_edit_part(AbstractBorderItemEditPart)
  let node = new_gmf_edit_part(ShapeNodeEditPart)
  let child = new_gmf_edit_part(ShapeNodeEditPart)
  gmf_edit_part_set_parent(child, Some(node))
  let edge = new_gmf_edit_part(ConnectionEditPart)
  let label = new_gmf_edit_part(LabelEditPart)
  let diagram = new_gmf_edit_part(DiagramEditPart)

  debug_inspect(
    new_gmf_layout_configuration_store(
      border,
      conn_gmf_layout_configuration_store_test_filter(),
    ).get_option_targets(),
    content="[Ports]",
  )
  debug_inspect(
    new_gmf_layout_configuration_store(
      node,
      conn_gmf_layout_configuration_store_test_filter(),
    ).get_option_targets(),
    content="[Nodes, Parents]",
  )
  debug_inspect(
    new_gmf_layout_configuration_store(
      edge,
      conn_gmf_layout_configuration_store_test_filter(),
    ).get_option_targets(),
    content="[Edges]",
  )
  debug_inspect(
    new_gmf_layout_configuration_store(
      label,
      conn_gmf_layout_configuration_store_test_filter(),
    ).get_option_targets(),
    content="[Labels]",
  )
  debug_inspect(
    new_gmf_layout_configuration_store(
      diagram,
      conn_gmf_layout_configuration_store_test_filter(),
    ).get_option_targets(),
    content="[Parents]",
  )
}

///|
test "GmfLayoutConfigurationStore parent resolution follows edge and label container rules" {
  reset_conn_gmf_foundation_for_test()
  let source_parent = new_gmf_edit_part(ShapeNodeEditPart)
  let source = new_gmf_edit_part(ShapeNodeEditPart)
  let edge = new_gmf_edit_part(ConnectionEditPart)
  let label = new_gmf_edit_part(LabelEditPart)
  gmf_edit_part_set_parent(source, Some(source_parent))
  gmf_edit_part_set_source(edge, Some(source))
  gmf_edit_part_set_parent(label, Some(edge))

  let edge_store = new_gmf_layout_configuration_store(
    edge,
    conn_gmf_layout_configuration_store_test_filter(),
  )
  let label_store = new_gmf_layout_configuration_store(
    label,
    conn_gmf_layout_configuration_store_test_filter(),
  )
  debug_inspect(
    match edge_store.get_parent() {
      Some(parent_store) => parent_store.get_editing_domain()
      None => -1
    },
    content="0",
  )
  debug_inspect(
    match label_store.get_parent() {
      Some(parent_store) => parent_store.get_editing_domain()
      None => -1
    },
    content="0",
  )
}
