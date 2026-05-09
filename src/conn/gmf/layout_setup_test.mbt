///|
test "GmfLayoutSetup supports diagram editor and graphical edit parts" {
  reset_conn_gmf_foundation_for_test()
  let setup = new_gmf_layout_setup()
  let edit_part = new_gmf_edit_part(ShapeNodeEditPart)

  debug_inspect(setup.supports(DiagramEditor), content="true")
  debug_inspect(setup.supports(GraphicalEditPart(edit_part)), content="true")
  debug_inspect(setup.supports(AdaptableWithDiagramEditor), content="true")
  debug_inspect(setup.supports(Other), content="false")
}

///|
test "GmfLayoutSetup supports collection when any graphical edit part exists" {
  let setup = new_gmf_layout_setup()
  let edit_part = new_gmf_edit_part(ShapeNodeEditPart)
  debug_inspect(
    setup.supports(Collection([Other, GraphicalEditPart(edit_part)])),
    content="true",
  )
  debug_inspect(setup.supports(Collection([Other, Other])), content="false")
}

///|
test "GmfLayoutSetup create_injector overrides connector bindings" {
  let setup = new_gmf_layout_setup()
  let defaults = new_gmf_injector(bindings={ "A": "B" })
  let injector = setup.create_injector(defaults)

  debug_inspect(injector.binding_of("A"), content="Some(\"B\")")
  debug_inspect(
    injector.binding_of("IDiagramLayoutConnector"),
    content="Some(\"GmfDiagramLayoutConnector\")",
  )
  debug_inspect(
    injector.binding_of("ILayoutConfigurationStore.Provider"),
    content="Some(\"GmfLayoutConfigurationStore.Provider\")",
  )
}
