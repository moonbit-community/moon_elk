///|
pub let execution_time_view_id : String = "org.eclipse.elk.debug.executionView"

///|
let execution_time_view_col_name_width_key : String = "nameColumn.width"

///|
let execution_time_view_col_time_width_key : String = "timeColumn.width"

///|
let execution_time_view_col_local_time_width_key : String = "localTimeColumn.width"

///|
pub struct ExecutionTimeView {
  base : AbstractLayoutDebugView
  mut name_column_width : Int
  mut time_column_width : Int
  mut local_time_column_width : Int
}

///|
fn execution_time_view_filter(info : ExecutionInfo) -> Bool {
  execution_info_is_execution_time_measured(info)
}

///|
pub fn new_execution_time_view() -> ExecutionTimeView {
  {
    base: new_abstract_layout_debug_view(
      execution_time_view_id, core_debug_pref_debug_execution_time, execution_time_view_filter,
    ),
    name_column_width: 500,
    time_column_width: 100,
    local_time_column_width: 100,
  }
}

///|
pub fn ExecutionTimeView::get_base(
  self : ExecutionTimeView,
) -> AbstractLayoutDebugView {
  self.base
}

///|
pub fn ExecutionTimeView::set_column_widths_for_test(
  self : ExecutionTimeView,
  name_width : Int,
  time_width : Int,
  local_time_width : Int,
) -> Unit {
  self.name_column_width = name_width
  self.time_column_width = time_width
  self.local_time_column_width = local_time_width
}

///|
pub fn ExecutionTimeView::get_column_widths_for_test(
  self : ExecutionTimeView,
) -> (Int, Int, Int) {
  (self.name_column_width, self.time_column_width, self.local_time_column_width)
}

///|
pub fn ExecutionTimeView::load_state(self : ExecutionTimeView) -> Unit {
  let settings = self.base.retrieve_dialog_settings()
  self.base.load_state(settings)

  match settings.get_int(execution_time_view_col_name_width_key) {
    Some(value) => self.name_column_width = value
    None => ()
  }
  match settings.get_int(execution_time_view_col_time_width_key) {
    Some(value) => self.time_column_width = value
    None => ()
  }
  match settings.get_int(execution_time_view_col_local_time_width_key) {
    Some(value) => self.local_time_column_width = value
    None => ()
  }
}

///|
pub fn ExecutionTimeView::persist_state(self : ExecutionTimeView) -> Unit {
  let settings = self.base.retrieve_dialog_settings()
  self.base.persist_state(settings)
  settings.put_int(
    execution_time_view_col_name_width_key,
    self.name_column_width,
  )
  settings.put_int(
    execution_time_view_col_time_width_key,
    self.time_column_width,
  )
  settings.put_int(
    execution_time_view_col_local_time_width_key,
    self.local_time_column_width,
  )
}
