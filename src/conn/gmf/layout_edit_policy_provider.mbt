///|
pub let apply_layout_role : String = "ApplyLayoutEditPolicy"

///|
pub struct LayoutEditPolicyProvider {
  unit : Unit
}

///|
pub fn new_layout_edit_policy_provider() -> LayoutEditPolicyProvider {
  { unit: () }
}

///|
pub fn LayoutEditPolicyProvider::create_edit_policies(
  _self : LayoutEditPolicyProvider,
  edit_part : GmfEditPart,
) -> Unit {
  if gmf_edit_part_kind(edit_part) == DiagramEditPart {
    gmf_edit_part_install_edit_policy(
      edit_part, apply_layout_role, "GmfLayoutEditPolicy",
    )
  }
}

///|
pub fn LayoutEditPolicyProvider::provides(
  _self : LayoutEditPolicyProvider,
  operation : GmfOperation,
) -> Bool {
  operation == CreateEditPoliciesOperation
}
