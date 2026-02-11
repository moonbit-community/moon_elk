///|
pub struct ElkGraphDescriptionLabelProvider {
  unit : Unit
}

///|
pub fn new_elk_graph_description_label_provider() -> ElkGraphDescriptionLabelProvider {
  { unit: () }
}

///|
pub fn ElkGraphDescriptionLabelProvider::image(
  self : ElkGraphDescriptionLabelProvider,
  class_name : String,
) -> String? {
  ignore(self)
  if class_name == "ELK_NODE" {
    return Some("elknode.gif")
  }
  if class_name == "ELK_EDGE" {
    return Some("elkedge.gif")
  }
  if class_name == "ELK_PORT" {
    return Some("elkport.gif")
  }
  if class_name == "ELK_LABEL" {
    return Some("elklabel.gif")
  }
  None
}
