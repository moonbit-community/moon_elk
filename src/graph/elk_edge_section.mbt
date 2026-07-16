///|
pub type ElkEdgeSection = Int

///|
priv struct EdgeSectionData {
  _edge : ElkEdge
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
let edge_section_store : Ref[Array[EdgeSectionData]] = Ref([])

///|
let edge_section_next_handle : Ref[Int] = Ref(0)

///|
let edge_section_free_slots : Ref[Array[Int]] = Ref([])

///|
let edge_section_handle_slots : Ref[Map[Int, Int]] = Ref(Map([]))

///|
let edge_section_slot_handles : Ref[Array[Int]] = Ref([])

///|
fn edge_section_allocated_slot(section : ElkEdgeSection) -> Int {
  match edge_section_handle_slots.val.get(section) {
    Some(slot) => slot
    None => abort("invalid or disposed edge section id")
  }
}

///|
fn edge_section_slot(section : ElkEdgeSection) -> Int {
  let slot = edge_section_allocated_slot(section)
  if edge_section_arena_store.val[slot] < 0 {
    abort("invalid or disposed edge section id")
  }
  slot
}

///|
fn checked_edge_section(section : ElkEdgeSection) -> Unit {
  ignore(edge_section_slot(section))
}

///|
let disposed_edge_section_data : EdgeSectionData = {
  _edge: -1,
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
  let slot = edge_section_slot(section)
  edge_section_store.val[slot] = disposed_edge_section_data
  edge_section_arena_store.val[slot] = -1
  graph_handle_release(
    section,
    slot,
    edge_section_handle_slots.val,
    edge_section_slot_handles.val,
    edge_section_free_slots.val,
  )
}

///|
pub fn create_edge_section(edge : ElkEdge) -> ElkEdgeSection {
  checked_edge(edge)
  let slot = match edge_section_free_slots.val.pop() {
    Some(reused) => reused
    None => {
      let fresh = edge_section_store.val.length()
      edge_section_store.val.push(disposed_edge_section_data)
      edge_section_arena_store.val.push(-1)
      edge_section_slot_handles.val.push(-1)
      fresh
    }
  }
  let id = graph_handle_allocate(
    slot,
    edge_section_next_handle,
    edge_section_handle_slots.val,
    edge_section_slot_handles.val,
  )
  edge_section_store.val[slot] = {
    _edge: edge,
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
  graph_arena_register_edge_section(edge_arena_store.val[edge_slot(edge)], id)
  let edge_data = edge_store.val[edge_slot(edge)]
  edge_data.sections.push(id)
  edge_store.val[edge_slot(edge)] = edge_data
  id
}

///|
pub fn edge_sections(edge : ElkEdge) -> Array[ElkEdgeSection] {
  checked_edge(edge)
  edge_store.val[edge_slot(edge)].sections.copy()
}

///|
pub fn edge_section_identifier(section : ElkEdgeSection) -> String {
  checked_edge_section(section)
  edge_section_store.val[edge_section_slot(section)].identifier
}

///|
pub fn edge_section_set_identifier(
  section : ElkEdgeSection,
  identifier : String,
) -> Unit {
  checked_edge_section(section)
  let section_data = edge_section_store.val[edge_section_slot(section)]
  section_data.identifier = identifier
  edge_section_store.val[edge_section_slot(section)] = section_data
}

///|
pub fn edge_section_set_start(
  section : ElkEdgeSection,
  x : Double,
  y : Double,
) -> Unit {
  checked_edge_section(section)
  let section_data = edge_section_store.val[edge_section_slot(section)]
  section_data.start_x = x
  section_data.start_y = y
  edge_section_store.val[edge_section_slot(section)] = section_data
}

///|
pub fn edge_section_set_end(
  section : ElkEdgeSection,
  x : Double,
  y : Double,
) -> Unit {
  checked_edge_section(section)
  let section_data = edge_section_store.val[edge_section_slot(section)]
  section_data.end_x = x
  section_data.end_y = y
  edge_section_store.val[edge_section_slot(section)] = section_data
}

///|
pub fn edge_section_start_x(section : ElkEdgeSection) -> Double {
  checked_edge_section(section)
  edge_section_store.val[edge_section_slot(section)].start_x
}

///|
pub fn edge_section_start_y(section : ElkEdgeSection) -> Double {
  checked_edge_section(section)
  edge_section_store.val[edge_section_slot(section)].start_y
}

///|
pub fn edge_section_end_x(section : ElkEdgeSection) -> Double {
  checked_edge_section(section)
  edge_section_store.val[edge_section_slot(section)].end_x
}

///|
pub fn edge_section_end_y(section : ElkEdgeSection) -> Double {
  checked_edge_section(section)
  edge_section_store.val[edge_section_slot(section)].end_y
}

///|
pub fn edge_section_bend_points(
  section : ElkEdgeSection,
) -> Array[ElkBendPoint] {
  checked_edge_section(section)
  edge_section_store.val[edge_section_slot(section)].bend_points.copy()
}

///|
pub fn edge_section_add_bend_point(
  section : ElkEdgeSection,
  bend_point : ElkBendPoint,
) -> Unit {
  checked_edge_section(section)
  let section_data = edge_section_store.val[edge_section_slot(section)]
  section_data.bend_points.push(bend_point)
  edge_section_store.val[edge_section_slot(section)] = section_data
}

///|
pub fn edge_section_clear_bend_points(section : ElkEdgeSection) -> Unit {
  checked_edge_section(section)
  let section_data = edge_section_store.val[edge_section_slot(section)]
  section_data.bend_points.clear()
  edge_section_store.val[edge_section_slot(section)] = section_data
}

///|
pub fn edge_section_set_incoming_shape(
  section : ElkEdgeSection,
  shape : ElkConnectableShape?,
) -> Unit {
  checked_edge_section(section)
  if shape is Some(value) {
    graph_arena_require_same(
      edge_section_arena_store.val[edge_section_slot(section)],
      graph_arena_for_shape(value),
    )
  }
  let section_data = edge_section_store.val[edge_section_slot(section)]
  section_data.incoming_shape = shape
  edge_section_store.val[edge_section_slot(section)] = section_data
}

///|
pub fn edge_section_set_outgoing_shape(
  section : ElkEdgeSection,
  shape : ElkConnectableShape?,
) -> Unit {
  checked_edge_section(section)
  if shape is Some(value) {
    graph_arena_require_same(
      edge_section_arena_store.val[edge_section_slot(section)],
      graph_arena_for_shape(value),
    )
  }
  let section_data = edge_section_store.val[edge_section_slot(section)]
  section_data.outgoing_shape = shape
  edge_section_store.val[edge_section_slot(section)] = section_data
}

///|
pub fn edge_section_incoming_shape(
  section : ElkEdgeSection,
) -> ElkConnectableShape? {
  checked_edge_section(section)
  edge_section_store.val[edge_section_slot(section)].incoming_shape
}

///|
pub fn edge_section_outgoing_shape(
  section : ElkEdgeSection,
) -> ElkConnectableShape? {
  checked_edge_section(section)
  edge_section_store.val[edge_section_slot(section)].outgoing_shape
}

///|
pub fn edge_section_add_incoming_section(
  section : ElkEdgeSection,
  incoming_section : ElkEdgeSection,
) -> Unit {
  checked_edge_section(section)
  checked_edge_section(incoming_section)
  graph_arena_require_same(
    edge_section_arena_store.val[edge_section_slot(section)],
    edge_section_arena_store.val[edge_section_slot(incoming_section)],
  )
  if edge_section_reaches(section, incoming_section) {
    abort("edge section relation would create a cycle")
  }
  let section_data = edge_section_store.val[edge_section_slot(section)]
  if !section_data.incoming_sections.contains(incoming_section) {
    section_data.incoming_sections.push(incoming_section)
  }
  edge_section_store.val[edge_section_slot(section)] = section_data
}

///|
pub fn edge_section_add_outgoing_section(
  section : ElkEdgeSection,
  outgoing_section : ElkEdgeSection,
) -> Unit {
  checked_edge_section(section)
  checked_edge_section(outgoing_section)
  graph_arena_require_same(
    edge_section_arena_store.val[edge_section_slot(section)],
    edge_section_arena_store.val[edge_section_slot(outgoing_section)],
  )
  if edge_section_reaches(outgoing_section, section) {
    abort("edge section relation would create a cycle")
  }
  let section_data = edge_section_store.val[edge_section_slot(section)]
  if !section_data.outgoing_sections.contains(outgoing_section) {
    section_data.outgoing_sections.push(outgoing_section)
  }
  edge_section_store.val[edge_section_slot(section)] = section_data
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
  let neighbors = edge_section_store.val[edge_section_slot(section)].outgoing_sections.copy()
  for slot = 0; slot < edge_section_store.val.length(); slot = slot + 1 {
    if edge_section_arena_store.val[slot] >= 0 &&
      edge_section_store.val[slot].incoming_sections.contains(section) {
      neighbors.push(edge_section_slot_handles.val[slot])
    }
  }
  neighbors
}

///|
pub fn edge_section_incoming_sections(
  section : ElkEdgeSection,
) -> Array[ElkEdgeSection] {
  checked_edge_section(section)
  edge_section_store.val[edge_section_slot(section)].incoming_sections.copy()
}

///|
pub fn edge_section_outgoing_sections(
  section : ElkEdgeSection,
) -> Array[ElkEdgeSection] {
  checked_edge_section(section)
  edge_section_store.val[edge_section_slot(section)].outgoing_sections.copy()
}
