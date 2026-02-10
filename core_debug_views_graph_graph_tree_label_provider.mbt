///|
pub struct GraphTreeLabelProvider {
  graph_image : String
  no_graph_image : String
}

///|
pub fn new_graph_tree_label_provider() -> GraphTreeLabelProvider {
  {
    graph_image: elk_debug_plugin_image_descriptor_from_plugin(
      core_debug_plugin_id, "/icons/log.png",
    ),
    no_graph_image: elk_debug_plugin_image_descriptor_from_plugin(
      core_debug_plugin_id, "/icons/no_log.png",
    ),
  }
}

///|
pub fn GraphTreeLabelProvider::get_text(
  _self : GraphTreeLabelProvider,
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
pub fn GraphTreeLabelProvider::get_image(
  self : GraphTreeLabelProvider,
  execution : ExecutionInfo,
) -> String {
  if execution_info_has_logged_graphs(execution) {
    self.graph_image
  } else {
    self.no_graph_image
  }
}
