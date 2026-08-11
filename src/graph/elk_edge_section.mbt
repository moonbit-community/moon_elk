///|
pub struct ElkEdgeSection {
  priv mut data : EdgeSectionData
  priv mut arena : GraphArena?
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
fn checked_edge_section(section : ElkEdgeSection) -> Unit {
  match section.arena {
    Some(arena) => checked_graph_arena(arena)
    None => abort("invalid or disposed edge section id")
  }
}

///|
fn edge_section_graph_arena(section : ElkEdgeSection) -> GraphArena {
  checked_edge_section(section)
  match section.arena {
    Some(arena) => arena
    None => abort("invalid or disposed edge section id")
  }
}

///|
pub fn ElkEdgeSection::graph_arena(self : ElkEdgeSection) -> GraphArena {
  edge_section_graph_arena(self)
}

///|
let disposed_edge_section_data : EdgeSectionData = {
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
}

///|
fn dispose_edge_section_slot(section : ElkEdgeSection) -> Unit {
  checked_edge_section(section)
  section.data = disposed_edge_section_data
  section.arena = None
}

///|
pub fn create_edge_section(edge : ElkEdge) -> ElkEdgeSection {
  checked_edge(edge)
  let arena = edge_graph_arena(edge)
  let section : ElkEdgeSection = {
    data: {
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
    },
    arena: Some(arena),
    id: arena.allocate_object_id(),
  }
  graph_arena_register_edge_section(arena, section)
  let edge_data = edge.data
  edge_data.sections.push(section)
  edge.data = edge_data
  section
}

///|
pub fn edge_sections(edge : ElkEdge) -> Array[ElkEdgeSection] {
  checked_edge(edge)
  edge.data.sections.copy()
}

///|
pub fn edge_section_identifier(section : ElkEdgeSection) -> String {
  checked_edge_section(section)
  section.data.identifier
}

///|
pub fn edge_section_set_identifier(
  section : ElkEdgeSection,
  identifier : String,
) -> Unit {
  checked_edge_section(section)
  let section_data = section.data
  section_data.identifier = identifier
  section.data = section_data
}

///|
pub fn edge_section_set_start(
  section : ElkEdgeSection,
  x : Double,
  y : Double,
) -> Unit {
  checked_edge_section(section)
  let section_data = section.data
  section_data.start_x = x
  section_data.start_y = y
  section.data = section_data
}

///|
pub fn edge_section_set_end(
  section : ElkEdgeSection,
  x : Double,
  y : Double,
) -> Unit {
  checked_edge_section(section)
  let section_data = section.data
  section_data.end_x = x
  section_data.end_y = y
  section.data = section_data
}

///|
pub fn edge_section_start_x(section : ElkEdgeSection) -> Double {
  checked_edge_section(section)
  section.data.start_x
}

///|
pub fn edge_section_start_y(section : ElkEdgeSection) -> Double {
  checked_edge_section(section)
  section.data.start_y
}

///|
pub fn edge_section_end_x(section : ElkEdgeSection) -> Double {
  checked_edge_section(section)
  section.data.end_x
}

///|
pub fn edge_section_end_y(section : ElkEdgeSection) -> Double {
  checked_edge_section(section)
  section.data.end_y
}

///|
pub fn edge_section_bend_points(
  section : ElkEdgeSection,
) -> Array[ElkBendPoint] {
  checked_edge_section(section)
  section.data.bend_points.copy()
}

///|
pub fn edge_section_add_bend_point(
  section : ElkEdgeSection,
  bend_point : ElkBendPoint,
) -> Unit {
  checked_edge_section(section)
  let section_data = section.data
  section_data.bend_points.push(bend_point)
  section.data = section_data
}

///|
pub fn edge_section_clear_bend_points(section : ElkEdgeSection) -> Unit {
  checked_edge_section(section)
  let section_data = section.data
  section_data.bend_points.clear()
  section.data = section_data
}

///|
pub fn edge_section_set_incoming_shape(
  section : ElkEdgeSection,
  shape : ElkConnectableShape?,
) -> Unit {
  checked_edge_section(section)
  if shape is Some(value) {
    graph_arena_require_same(
      edge_section_graph_arena(section),
      graph_arena_for_shape(value),
    )
  }
  let section_data = section.data
  section_data.incoming_shape = shape
  section.data = section_data
}

///|
pub fn edge_section_set_outgoing_shape(
  section : ElkEdgeSection,
  shape : ElkConnectableShape?,
) -> Unit {
  checked_edge_section(section)
  if shape is Some(value) {
    graph_arena_require_same(
      edge_section_graph_arena(section),
      graph_arena_for_shape(value),
    )
  }
  let section_data = section.data
  section_data.outgoing_shape = shape
  section.data = section_data
}

///|
pub fn edge_section_incoming_shape(
  section : ElkEdgeSection,
) -> ElkConnectableShape? {
  checked_edge_section(section)
  section.data.incoming_shape
}

///|
pub fn edge_section_outgoing_shape(
  section : ElkEdgeSection,
) -> ElkConnectableShape? {
  checked_edge_section(section)
  section.data.outgoing_shape
}

///|
pub fn edge_section_add_incoming_section(
  section : ElkEdgeSection,
  incoming_section : ElkEdgeSection,
) -> Unit {
  checked_edge_section(section)
  checked_edge_section(incoming_section)
  graph_arena_require_same(
    edge_section_graph_arena(section),
    edge_section_graph_arena(incoming_section),
  )
  if edge_section_reaches(section, incoming_section) {
    abort("edge section relation would create a cycle")
  }
  let section_data = section.data
  if !section_data.incoming_sections.contains(incoming_section) {
    section_data.incoming_sections.push(incoming_section)
  }
  section.data = section_data
}

///|
pub fn edge_section_add_outgoing_section(
  section : ElkEdgeSection,
  outgoing_section : ElkEdgeSection,
) -> Unit {
  checked_edge_section(section)
  checked_edge_section(outgoing_section)
  graph_arena_require_same(
    edge_section_graph_arena(section),
    edge_section_graph_arena(outgoing_section),
  )
  if edge_section_reaches(outgoing_section, section) {
    abort("edge section relation would create a cycle")
  }
  let section_data = section.data
  if !section_data.outgoing_sections.contains(outgoing_section) {
    section_data.outgoing_sections.push(outgoing_section)
  }
  section.data = section_data
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
  let neighbors = section.data.outgoing_sections.copy()
  for candidate in edge_section_graph_arena(section).edge_sections {
    if candidate.data.incoming_sections.contains(section) {
      neighbors.push(candidate)
    }
  }
  neighbors
}

///|
pub fn edge_section_incoming_sections(
  section : ElkEdgeSection,
) -> Array[ElkEdgeSection] {
  checked_edge_section(section)
  section.data.incoming_sections.copy()
}

///|
pub fn edge_section_outgoing_sections(
  section : ElkEdgeSection,
) -> Array[ElkEdgeSection] {
  checked_edge_section(section)
  section.data.outgoing_sections.copy()
}
