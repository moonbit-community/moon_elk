///|
pub struct ElkGraphJsonDescriptionLabelProvider {
  unit : Unit
}

///|
pub fn new_elk_graph_json_description_label_provider() -> ElkGraphJsonDescriptionLabelProvider {
  { unit: () }
}

///|
pub fn ElkGraphJsonDescriptionLabelProvider::image(
  self : ElkGraphJsonDescriptionLabelProvider,
  class_name : String,
) -> String? {
  ignore(self)
  ignore(class_name)
  None
}
