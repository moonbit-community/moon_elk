///|
pub let graph_text_opposite_ref_incoming_edges : String = "ELK_CONNECTABLE_SHAPE__INCOMING_EDGES"

///|
pub let graph_text_opposite_ref_outgoing_edges : String = "ELK_CONNECTABLE_SHAPE__OUTGOING_EDGES"

///|
pub let graph_text_opposite_ref_incoming_sections : String = "ELK_EDGE_SECTION__INCOMING_SECTIONS"

///|
pub struct ElkGraphLinker {
  opposite_refs : Map[String, Unit]
}

///|
pub fn new_elk_graph_linker() -> ElkGraphLinker {
  let opposite_refs : Map[String, Unit] = {}
  opposite_refs[graph_text_opposite_ref_incoming_edges] = ()
  opposite_refs[graph_text_opposite_ref_outgoing_edges] = ()
  opposite_refs[graph_text_opposite_ref_incoming_sections] = ()
  { opposite_refs, }
}

///|
pub fn ElkGraphLinker::clear_reference(
  self : ElkGraphLinker,
  _obj : String,
  reference : String,
) -> Bool {
  !self.opposite_refs.contains(reference)
}
