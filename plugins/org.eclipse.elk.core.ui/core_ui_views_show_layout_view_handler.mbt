///|
pub struct CoreUiShowLayoutViewEvent {
  can_open : Bool
}

///|
pub fn new_core_ui_show_layout_view_event(
  can_open? : Bool = true,
) -> CoreUiShowLayoutViewEvent {
  { can_open, }
}

///|
pub struct ShowLayoutViewHandler {
  mut last_error : String?
}

///|
pub fn new_show_layout_view_handler() -> ShowLayoutViewHandler {
  { last_error: None }
}

///|
pub fn ShowLayoutViewHandler::execute(
  self : ShowLayoutViewHandler,
  event : CoreUiShowLayoutViewEvent,
) -> Unit {
  if event.can_open {
    ignore(layout_view_part_open())
    self.last_error = None
  } else {
    self.last_error = Some("Could not open Layout View.")
  }
}

///|
pub fn ShowLayoutViewHandler::get_last_error(
  self : ShowLayoutViewHandler,
) -> String? {
  self.last_error
}
