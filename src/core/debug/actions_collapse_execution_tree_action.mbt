///|
pub let collapse_execution_tree_action_id : String = "org.eclipse.elk.debug.actions.collapseAll"

///|
pub(all) struct CollapseExecutionTreeAction {
  view : AbstractLayoutDebugView
}

///|
pub fn new_collapse_execution_tree_action(
  view : AbstractLayoutDebugView,
) -> CollapseExecutionTreeAction {
  { view, }
}

///|
pub fn CollapseExecutionTreeAction::run(
  self : CollapseExecutionTreeAction,
) -> Unit {
  self.view.collapse_all_tree_viewer_elements()
}
