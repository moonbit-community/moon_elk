///|
pub struct GraphListLabelProvider {
  elk_image : String
  json_image : String
  dot_image : String
}

///|
pub fn new_graph_list_label_provider() -> GraphListLabelProvider {
  {
    elk_image: elk_debug_plugin_image_descriptor_from_plugin(
      core_debug_plugin_id, "/icons/graph.gif",
    ),
    json_image: elk_debug_plugin_image_descriptor_from_plugin(
      core_debug_plugin_id, "/icons/graph_json.png",
    ),
    dot_image: elk_debug_plugin_image_descriptor_from_plugin(
      core_debug_plugin_id, "/icons/graph_dot.png",
    ),
  }
}

///|
pub fn GraphListLabelProvider::get_text(
  _self : GraphListLabelProvider,
  graph : LoggedGraph,
) -> String {
  graph.tag
}

///|
pub fn GraphListLabelProvider::get_image(
  self : GraphListLabelProvider,
  graph : LoggedGraph,
) -> String {
  match graph.graph_type {
    ElkGraph => self.elk_image
    LGraph => self.json_image
  }
}
