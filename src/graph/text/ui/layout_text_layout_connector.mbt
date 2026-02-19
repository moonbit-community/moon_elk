///|
pub struct TextLayoutMapping {
  workbench_part : String
  parent_element : @graph.ElkNode
  layout_graph : @graph.ElkNode
}

///|
pub fn new_text_layout_mapping(
  workbench_part : String,
  parent_element : @graph.ElkNode,
  layout_graph : @graph.ElkNode,
) -> TextLayoutMapping {
  { workbench_part, parent_element, layout_graph }
}

///|
pub fn TextLayoutMapping::get_parent_element(
  self : TextLayoutMapping,
) -> @graph.ElkNode {
  self.parent_element
}

///|
pub fn TextLayoutMapping::get_layout_graph(
  self : TextLayoutMapping,
) -> @graph.ElkNode {
  self.layout_graph
}

///|
pub struct TextLayoutConnector {
  unit : Unit
}

///|
pub fn new_text_layout_connector() -> TextLayoutConnector {
  { unit: () }
}

///|
pub fn TextLayoutConnector::build_layout_graph(
  self : TextLayoutConnector,
  workbench_part : String,
  root_node : @graph.ElkNode?,
) -> Result[TextLayoutMapping, String] {
  ignore(self)
  match root_node {
    Some(root) => Ok(new_text_layout_mapping(workbench_part, root, root))
    None => Err("Not supported by this layout connector: empty graph")
  }
}

///|
pub fn TextLayoutConnector::apply_layout(
  self : TextLayoutConnector,
  mapping : TextLayoutMapping,
  settings : Map[String, String],
) -> String {
  ignore(self)
  ignore(settings)
  "layout-dialog:" + mapping.workbench_part
}
