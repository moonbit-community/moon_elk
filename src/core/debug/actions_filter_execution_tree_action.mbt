///|
pub let filter_execution_tree_action_id : String = "org.eclipse.elk.debug.actions.filter"

///|
pub(all) struct FilterExecutionTreeAction {
  view : AbstractLayoutDebugView
  mut checked : Bool
}

///|
pub fn new_filter_execution_tree_action(
  view : AbstractLayoutDebugView,
) -> FilterExecutionTreeAction {
  { view, checked: false }
}

///|
pub fn FilterExecutionTreeAction::is_checked(
  self : FilterExecutionTreeAction,
) -> Bool {
  self.checked
}

///|
pub fn FilterExecutionTreeAction::set_checked(
  self : FilterExecutionTreeAction,
  checked : Bool,
) -> Unit {
  self.checked = checked
}

///|
pub fn FilterExecutionTreeAction::run(self : FilterExecutionTreeAction) -> Unit {
  self.view.set_filter_tree(self.checked)
}
