///|
pub struct ElkEdgeSection {
  priv mut arena : GraphArena
  priv mut slot : Int
  priv mut generation : Int
  priv id : Int
}

///|
pub impl Eq for ElkEdgeSection with fn equal(self, other) {
  physical_equal(self, other)
}

///|
pub impl Hash for ElkEdgeSection with fn hash(self) {
  self.id
}

///|
pub impl Hash for ElkEdgeSection with fn hash_combine(self, hasher) {
  hasher.combine_int(self.id)
}

///|
pub impl @debug.Debug for ElkEdgeSection with fn to_repr(self) {
  Repr(self.id)
}

///|
pub impl Show for ElkEdgeSection with fn output(self, logger) {
  logger.write_string(self.id.to_string())
}

///|
priv struct EdgeSectionData {
  mut identifier : String
  mut start_x : Double
  mut start_y : Double
  mut end_x : Double
  mut end_y : Double
  bend_points : Array[ElkBendPoint]
  mut incoming_shape : ElkConnectableShape?
  mut outgoing_shape : ElkConnectableShape?
  incoming_sections : Array[ElkEdgeSection]
  outgoing_sections : Array[ElkEdgeSection]
}

///|
priv struct EdgeSectionSlot {
  mut generation : Int
  handle : ElkEdgeSection
  mut data : EdgeSectionData?
}

///|
fn checked_edge_section_slot(section : ElkEdgeSection) -> EdgeSectionSlot {
  let arena = section.arena
  checked_graph_arena(arena)
  if section.slot < 0 || section.slot >= arena.edge_sections.length() {
    abort("invalid or disposed edge section id")
  }
  let slot = arena.edge_sections[section.slot]
  if slot.generation != section.generation || slot.data is None {
    abort("invalid or disposed edge section id")
  }
  slot
}

///|
fn checked_edge_section(section : ElkEdgeSection) -> Unit {
  ignore(checked_edge_section_slot(section))
}

///|
fn edge_section_data(section : ElkEdgeSection) -> EdgeSectionData {
  match checked_edge_section_slot(section).data {
    Some(data) => data
    None => abort("invalid or disposed edge section id")
  }
}

///|
fn set_edge_section_data(
  section : ElkEdgeSection,
  data : EdgeSectionData,
) -> Unit {
  checked_edge_section_slot(section).data = Some(data)
}

///|
fn edge_section_graph_arena(section : ElkEdgeSection) -> GraphArena {
  checked_edge_section(section)
  section.arena
}

///|
pub fn ElkEdgeSection::graph_arena(self : ElkEdgeSection) -> GraphArena {
  edge_section_graph_arena(self)
}

///|
fn dispose_edge_section_slot(section : ElkEdgeSection) -> Unit {
  let slot = checked_edge_section_slot(section)
  slot.data = None
  slot.generation += 1
}

///|
pub fn create_edge_section(edge : ElkEdge) -> ElkEdgeSection {
  let arena = edge_graph_arena(edge)
  let slot = arena.edge_sections.length()
  let section : ElkEdgeSection = {
    arena,
    slot,
    generation: 0,
    id: arena.allocate_object_id(),
  }
  arena.edge_sections.push({
    generation: 0,
    handle: section,
    data: Some({
      identifier: "",
      start_x: 0.0,
      start_y: 0.0,
      end_x: 0.0,
      end_y: 0.0,
      bend_points: [],
      incoming_shape: None,
      outgoing_shape: None,
      incoming_sections: [],
      outgoing_sections: [],
    }),
  })
  let edge_data = edge_data(edge)
  edge_data.sections.push(section)
  set_edge_data(edge, edge_data)
  section
}

///|
pub fn edge_sections(edge : ElkEdge) -> Array[ElkEdgeSection] {
  edge_data(edge).sections.copy()
}

///|
pub fn edge_section_identifier(section : ElkEdgeSection) -> String {
  edge_section_data(section).identifier
}

///|
pub fn edge_section_set_identifier(
  section : ElkEdgeSection,
  identifier : String,
) -> Unit {
  let section_data = edge_section_data(section)
  section_data.identifier = identifier
  set_edge_section_data(section, section_data)
}

///|
pub fn edge_section_set_start(
  section : ElkEdgeSection,
  x : Double,
  y : Double,
) -> Unit {
  let section_data = edge_section_data(section)
  section_data.start_x = x
  section_data.start_y = y
  set_edge_section_data(section, section_data)
}

///|
pub fn edge_section_set_end(
  section : ElkEdgeSection,
  x : Double,
  y : Double,
) -> Unit {
  let section_data = edge_section_data(section)
  section_data.end_x = x
  section_data.end_y = y
  set_edge_section_data(section, section_data)
}

///|
pub fn edge_section_start_x(section : ElkEdgeSection) -> Double {
  edge_section_data(section).start_x
}

///|
pub fn edge_section_start_y(section : ElkEdgeSection) -> Double {
  edge_section_data(section).start_y
}

///|
pub fn edge_section_end_x(section : ElkEdgeSection) -> Double {
  edge_section_data(section).end_x
}

///|
pub fn edge_section_end_y(section : ElkEdgeSection) -> Double {
  edge_section_data(section).end_y
}

///|
pub fn edge_section_bend_points(
  section : ElkEdgeSection,
) -> Array[ElkBendPoint] {
  edge_section_data(section).bend_points.copy()
}

///|
pub fn edge_section_add_bend_point(
  section : ElkEdgeSection,
  bend_point : ElkBendPoint,
) -> Unit {
  let section_data = edge_section_data(section)
  section_data.bend_points.push(bend_point)
  set_edge_section_data(section, section_data)
}

///|
pub fn edge_section_clear_bend_points(section : ElkEdgeSection) -> Unit {
  let section_data = edge_section_data(section)
  section_data.bend_points.clear()
  set_edge_section_data(section, section_data)
}

///|
pub fn edge_section_set_incoming_shape(
  section : ElkEdgeSection,
  shape : ElkConnectableShape?,
) -> Unit {
  if shape is Some(value) {
    graph_arena_require_same(
      edge_section_graph_arena(section),
      graph_arena_for_shape(value),
    )
  }
  let section_data = edge_section_data(section)
  section_data.incoming_shape = shape
  set_edge_section_data(section, section_data)
}

///|
pub fn edge_section_set_outgoing_shape(
  section : ElkEdgeSection,
  shape : ElkConnectableShape?,
) -> Unit {
  if shape is Some(value) {
    graph_arena_require_same(
      edge_section_graph_arena(section),
      graph_arena_for_shape(value),
    )
  }
  let section_data = edge_section_data(section)
  section_data.outgoing_shape = shape
  set_edge_section_data(section, section_data)
}

///|
pub fn edge_section_incoming_shape(
  section : ElkEdgeSection,
) -> ElkConnectableShape? {
  edge_section_data(section).incoming_shape
}

///|
pub fn edge_section_outgoing_shape(
  section : ElkEdgeSection,
) -> ElkConnectableShape? {
  edge_section_data(section).outgoing_shape
}

///|
pub fn edge_section_add_incoming_section(
  section : ElkEdgeSection,
  incoming_section : ElkEdgeSection,
) -> Unit {
  checked_edge_section(incoming_section)
  graph_arena_require_same(
    edge_section_graph_arena(section),
    edge_section_graph_arena(incoming_section),
  )
  if edge_section_reaches(section, incoming_section) {
    abort("edge section relation would create a cycle")
  }
  let section_data = edge_section_data(section)
  if !section_data.incoming_sections.contains(incoming_section) {
    section_data.incoming_sections.push(incoming_section)
  }
  set_edge_section_data(section, section_data)
}

///|
pub fn edge_section_add_outgoing_section(
  section : ElkEdgeSection,
  outgoing_section : ElkEdgeSection,
) -> Unit {
  checked_edge_section(outgoing_section)
  graph_arena_require_same(
    edge_section_graph_arena(section),
    edge_section_graph_arena(outgoing_section),
  )
  if edge_section_reaches(outgoing_section, section) {
    abort("edge section relation would create a cycle")
  }
  let section_data = edge_section_data(section)
  if !section_data.outgoing_sections.contains(outgoing_section) {
    section_data.outgoing_sections.push(outgoing_section)
  }
  set_edge_section_data(section, section_data)
}

///|
fn edge_section_reaches(
  start : ElkEdgeSection,
  target : ElkEdgeSection,
) -> Bool {
  let pending = [start]
  let visited : Map[ElkEdgeSection, Unit] = Map([])
  let mut index = 0
  while index < pending.length() {
    let current = pending[index]
    index += 1
    if current == target {
      return true
    }
    if visited.contains(current) {
      continue
    }
    visited[current] = ()
    for outgoing in edge_section_outgoing_neighbors(current) {
      pending.push(outgoing)
    }
  }
  false
}

///|
fn edge_section_outgoing_neighbors(
  section : ElkEdgeSection,
) -> Array[ElkEdgeSection] {
  let neighbors = edge_section_data(section).outgoing_sections.copy()
  for slot in edge_section_graph_arena(section).edge_sections {
    if slot.data is Some(_) &&
      edge_section_data(slot.handle).incoming_sections.contains(section) {
      neighbors.push(slot.handle)
    }
  }
  neighbors
}

///|
pub fn edge_section_incoming_sections(
  section : ElkEdgeSection,
) -> Array[ElkEdgeSection] {
  edge_section_data(section).incoming_sections.copy()
}

///|
pub fn edge_section_outgoing_sections(
  section : ElkEdgeSection,
) -> Array[ElkEdgeSection] {
  edge_section_data(section).outgoing_sections.copy()
}
