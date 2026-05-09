///|
fn layout_diagram_file_handler_test_expect_ok(
  action : () -> Int raise LayoutDiagramFileHandlerException,
) -> Int {
  try action() catch {
    LayoutDiagramFileHandlerException(message) =>
      abort("unexpected LayoutDiagramFileHandlerException: \{message}")
  } noraise {
    value => value
  }
}

///|
test "LayoutDiagramFileHandler executes layout for selected diagram files" {
  reset_conn_gmf_foundation_for_test()
  gmf_layout_diagram_file_handler_reset_for_test()

  let diagram_a = new_gmf_edit_part(DiagramEditPart)
  let diagram_b = new_gmf_edit_part(DiagramEditPart)
  gmf_register_layout_diagram_file_for_test("a.notation", diagram_a)
  gmf_register_layout_diagram_file_for_test("b.notation", diagram_b)

  let handler = new_layout_diagram_file_handler()
  let processed = layout_diagram_file_handler_test_expect_ok(() => {
    handler.execute([
      OtherSelectionItem,
      DiagramFile("a.notation"),
      DiagramFile("b.notation"),
    ])
  })

  debug_inspect(processed, content="2")
  debug_inspect(
    gmf_layout_diagram_file_handler_was_processed_for_test("a.notation"),
    content="true",
  )
  debug_inspect(
    gmf_layout_diagram_file_handler_was_processed_for_test("b.notation"),
    content="true",
  )
  debug_inspect(
    gmf_last_layout_invocation_single_part(),
    content="Some(\{diagram_b})",
  )
}
