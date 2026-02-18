///|
pub type ElkEdgeSection = Int

///|
priv struct EdgeSectionData {
  edge : ElkEdge
  mut identifier : String
  mut start_x : Double
  mut start_y : Double
  mut end_x : Double
  mut end_y : Double
  mut incoming_shape : ElkConnectableShape?
  mut outgoing_shape : ElkConnectableShape?
  incoming_sections : Array[ElkEdgeSection]
  outgoing_sections : Array[ElkEdgeSection]
}

///|
let edge_section_store : Ref[Array[EdgeSectionData]] = Ref::new([])

///|
fn checked_edge_section(section : ElkEdgeSection) -> Unit {
  if section < 0 || section >= edge_section_store.val.length() {
    abort("invalid edge section id")
  }
}

///|
pub fn create_edge_section(edge : ElkEdge) -> ElkEdgeSection {
  checked_edge(edge)
  let id = edge_section_store.val.length()
  edge_section_store.val.push({
    edge,
    identifier: "",
    start_x: 0.0,
    start_y: 0.0,
    end_x: 0.0,
    end_y: 0.0,
    incoming_shape: None,
    outgoing_shape: None,
    incoming_sections: [],
    outgoing_sections: [],
  })
  let edge_data = edge_store.val[edge]
  edge_data.sections.push(id)
  edge_store.val[edge] = edge_data
  id
}

///|
pub fn edge_sections(edge : ElkEdge) -> Array[ElkEdgeSection] {
  checked_edge(edge)
  edge_store.val[edge].sections
}

///|
pub fn edge_section_identifier(section : ElkEdgeSection) -> String {
  checked_edge_section(section)
  edge_section_store.val[section].identifier
}

///|
pub fn edge_section_set_identifier(
  section : ElkEdgeSection,
  identifier : String,
) -> Unit {
  checked_edge_section(section)
  let section_data = edge_section_store.val[section]
  section_data.identifier = identifier
  edge_section_store.val[section] = section_data
}

///|
pub fn edge_section_set_start(
  section : ElkEdgeSection,
  x : Double,
  y : Double,
) -> Unit {
  checked_edge_section(section)
  let section_data = edge_section_store.val[section]
  section_data.start_x = x
  section_data.start_y = y
  edge_section_store.val[section] = section_data
}

///|
pub fn edge_section_set_end(
  section : ElkEdgeSection,
  x : Double,
  y : Double,
) -> Unit {
  checked_edge_section(section)
  let section_data = edge_section_store.val[section]
  section_data.end_x = x
  section_data.end_y = y
  edge_section_store.val[section] = section_data
}

///|
pub fn edge_section_start_x(section : ElkEdgeSection) -> Double {
  checked_edge_section(section)
  edge_section_store.val[section].start_x
}

///|
pub fn edge_section_start_y(section : ElkEdgeSection) -> Double {
  checked_edge_section(section)
  edge_section_store.val[section].start_y
}

///|
pub fn edge_section_end_x(section : ElkEdgeSection) -> Double {
  checked_edge_section(section)
  edge_section_store.val[section].end_x
}

///|
pub fn edge_section_end_y(section : ElkEdgeSection) -> Double {
  checked_edge_section(section)
  edge_section_store.val[section].end_y
}

///|
pub fn edge_section_set_incoming_shape(
  section : ElkEdgeSection,
  shape : ElkConnectableShape?,
) -> Unit {
  checked_edge_section(section)
  let section_data = edge_section_store.val[section]
  section_data.incoming_shape = shape
  edge_section_store.val[section] = section_data
}

///|
pub fn edge_section_set_outgoing_shape(
  section : ElkEdgeSection,
  shape : ElkConnectableShape?,
) -> Unit {
  checked_edge_section(section)
  let section_data = edge_section_store.val[section]
  section_data.outgoing_shape = shape
  edge_section_store.val[section] = section_data
}

///|
pub fn edge_section_incoming_shape(
  section : ElkEdgeSection,
) -> ElkConnectableShape? {
  checked_edge_section(section)
  edge_section_store.val[section].incoming_shape
}

///|
pub fn edge_section_outgoing_shape(
  section : ElkEdgeSection,
) -> ElkConnectableShape? {
  checked_edge_section(section)
  edge_section_store.val[section].outgoing_shape
}

///|
pub fn edge_section_add_incoming_section(
  section : ElkEdgeSection,
  incoming_section : ElkEdgeSection,
) -> Unit {
  checked_edge_section(section)
  checked_edge_section(incoming_section)
  let section_data = edge_section_store.val[section]
  section_data.incoming_sections.push(incoming_section)
  edge_section_store.val[section] = section_data
}

///|
pub fn edge_section_add_outgoing_section(
  section : ElkEdgeSection,
  outgoing_section : ElkEdgeSection,
) -> Unit {
  checked_edge_section(section)
  checked_edge_section(outgoing_section)
  let section_data = edge_section_store.val[section]
  section_data.outgoing_sections.push(outgoing_section)
  edge_section_store.val[section] = section_data
}

///|
pub fn edge_section_incoming_sections(
  section : ElkEdgeSection,
) -> Array[ElkEdgeSection] {
  checked_edge_section(section)
  edge_section_store.val[section].incoming_sections
}

///|
pub fn edge_section_outgoing_sections(
  section : ElkEdgeSection,
) -> Array[ElkEdgeSection] {
  checked_edge_section(section)
  edge_section_store.val[section].outgoing_sections
}
