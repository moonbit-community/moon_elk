///|
pub(all) enum ExecutionTimeDisplayMode {
  NameDisplay
  TimeTotalDisplay
  TimeLocalDisplay
}

///|
pub fn execution_time_display_name() -> ExecutionTimeDisplayMode {
  NameDisplay
}

///|
pub fn execution_time_display_total() -> ExecutionTimeDisplayMode {
  TimeTotalDisplay
}

///|
pub fn execution_time_display_local() -> ExecutionTimeDisplayMode {
  TimeLocalDisplay
}

///|
pub(all) struct ExecutionTimeLabelProvider {
  display_mode : ExecutionTimeDisplayMode
  element_image : String
}

///|
pub fn new_execution_time_label_provider(
  display_mode : ExecutionTimeDisplayMode,
) -> ExecutionTimeLabelProvider {
  {
    display_mode,
    element_image: elk_debug_plugin_image_descriptor_from_plugin(
      core_debug_plugin_id, "/icons/execution.gif",
    ),
  }
}

///|
pub fn ExecutionTimeLabelProvider::get_image(
  self : ExecutionTimeLabelProvider,
  _execution : ExecutionInfo,
) -> String? {
  match self.display_mode {
    NameDisplay => Some(self.element_image)
    _ => None
  }
}

///|
fn execution_time_label_provider_time_to_string(time : Double) -> String {
  let scaled = (time * 1000.0 * 1000.0).round().to_int()
  let whole = scaled / 1000
  let fraction = scaled % 1000
  let normalized_fraction = if fraction < 0 { -fraction } else { fraction }
  let fraction_text = normalized_fraction.to_string().pad_start(3, '0')
  whole.to_string() + "." + fraction_text
}

///|
pub fn ExecutionTimeLabelProvider::get_text(
  self : ExecutionTimeLabelProvider,
  execution : ExecutionInfo,
) -> String {
  match self.display_mode {
    NameDisplay => {
      let base = execution_info_get_name(execution)
      match execution_info_get_parent(execution) {
        Some(_) => base
        None =>
          base +
          " (" +
          execution_info_get_creation_tick(execution).to_string() +
          ")"
      }
    }
    TimeTotalDisplay =>
      if execution_info_is_execution_time_measured(execution) {
        execution_time_label_provider_time_to_string(
          execution_info_get_execution_time_including_children(execution),
        )
      } else {
        "–"
      }
    TimeLocalDisplay =>
      if !execution_info_is_execution_time_measured(execution) {
        ""
      } else if execution_info_get_children(execution).is_empty() {
        ""
      } else {
        execution_time_label_provider_time_to_string(
          execution_info_get_execution_time_local(execution),
        )
      }
  }
}
