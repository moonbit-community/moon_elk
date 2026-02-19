///|
pub struct ElkGraphJsonTransientValueService {
  marker : Unit
}

///|
pub fn new_elk_graph_json_transient_value_service() -> ElkGraphJsonTransientValueService {
  { marker: () }
}

///|
pub fn ElkGraphJsonTransientValueService::is_list_transient(
  self : ElkGraphJsonTransientValueService,
  _semantic_object : String,
  feature : String,
) -> GraphJsonTextListTransient {
  ignore(self)
  if feature == graph_json_text_opposite_ref_incoming_edges ||
    feature == graph_json_text_opposite_ref_outgoing_edges ||
    feature == graph_json_text_opposite_ref_incoming_sections {
    GraphJsonTextListTransientYes
  } else {
    GraphJsonTextListTransientNo
  }
}
