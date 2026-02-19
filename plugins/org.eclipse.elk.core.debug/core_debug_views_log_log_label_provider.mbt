///|
pub struct LogLabelProvider {
  log_image : String
  no_log_image : String
}

///|
pub fn new_log_label_provider() -> LogLabelProvider {
  {
    log_image: elk_debug_plugin_image_descriptor_from_plugin(
      core_debug_plugin_id, "/icons/log.png",
    ),
    no_log_image: elk_debug_plugin_image_descriptor_from_plugin(
      core_debug_plugin_id, "/icons/no_log.png",
    ),
  }
}

///|
pub fn LogLabelProvider::get_text(
  _self : LogLabelProvider,
  execution : ExecutionInfo,
) -> String {
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

///|
pub fn LogLabelProvider::get_image(
  self : LogLabelProvider,
  execution : ExecutionInfo,
) -> String {
  if execution_info_has_log_messages(execution) {
    self.log_image
  } else {
    self.no_log_image
  }
}
