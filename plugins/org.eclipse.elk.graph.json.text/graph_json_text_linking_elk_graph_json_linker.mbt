///|
pub let graph_json_text_opposite_ref_incoming_edges : String = "ELK_CONNECTABLE_SHAPE__INCOMING_EDGES"

///|
pub let graph_json_text_opposite_ref_outgoing_edges : String = "ELK_CONNECTABLE_SHAPE__OUTGOING_EDGES"

///|
pub let graph_json_text_opposite_ref_incoming_sections : String = "ELK_EDGE_SECTION__INCOMING_SECTIONS"

///|
pub struct ElkGraphJsonLinker {
  opposite_refs : Map[String, Unit]
}

///|
pub fn new_elk_graph_json_linker() -> ElkGraphJsonLinker {
  let opposite_refs : Map[String, Unit] = {}
  opposite_refs[graph_json_text_opposite_ref_incoming_edges] = ()
  opposite_refs[graph_json_text_opposite_ref_outgoing_edges] = ()
  opposite_refs[graph_json_text_opposite_ref_incoming_sections] = ()
  { opposite_refs, }
}

///|
pub fn ElkGraphJsonLinker::clear_reference(
  self : ElkGraphJsonLinker,
  _obj : String,
  reference : String,
) -> Bool {
  !self.opposite_refs.contains(reference)
}
