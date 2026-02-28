///|
pub let expand_execution_tree_action_id : String = "org.eclipse.elk.debug.actions.expandAll"

///|
pub(all) struct ExpandExecutionTreeAction {
  view : AbstractLayoutDebugView
}

///|
pub fn new_expand_execution_tree_action(
  view : AbstractLayoutDebugView,
) -> ExpandExecutionTreeAction {
  { view, }
}

///|
pub fn ExpandExecutionTreeAction::run(self : ExpandExecutionTreeAction) -> Unit {
  self.view.expand_all_tree_viewer_elements()
}
