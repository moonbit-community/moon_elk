///|
test "LayoutEditPolicyProvider installs layout policy on diagram edit parts" {
  reset_conn_gmf_foundation_for_test()
  let provider = new_layout_edit_policy_provider()
  let diagram = new_gmf_edit_part(DiagramEditPart)
  let shape = new_gmf_edit_part(ShapeNodeEditPart)

  provider.create_edit_policies(diagram)
  provider.create_edit_policies(shape)

  inspect(
    gmf_edit_part_get_installed_edit_policy(diagram, apply_layout_role),
    content="Some(\"GmfLayoutEditPolicy\")",
  )
  inspect(
    gmf_edit_part_get_installed_edit_policy(shape, apply_layout_role),
    content="None",
  )
}

///|
test "LayoutEditPolicyProvider provides only create-edit-policies operation" {
  let provider = new_layout_edit_policy_provider()
  inspect(provider.provides(CreateEditPoliciesOperation), content="true")
  inspect(provider.provides(LayoutNodeOperation), content="false")
}
