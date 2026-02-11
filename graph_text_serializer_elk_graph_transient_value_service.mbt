///|
pub struct ElkGraphTransientValueService {
  marker : Unit
}

///|
pub fn new_elk_graph_transient_value_service() -> ElkGraphTransientValueService {
  { marker: () }
}

///|
pub fn ElkGraphTransientValueService::is_list_transient(
  self : ElkGraphTransientValueService,
  _semantic_object : String,
  feature : String,
) -> GraphTextListTransient {
  ignore(self)
  if feature == graph_text_opposite_ref_incoming_edges ||
    feature == graph_text_opposite_ref_outgoing_edges ||
    feature == graph_text_opposite_ref_incoming_sections {
    ListTransientYes
  } else {
    ListTransientNo
  }
}
