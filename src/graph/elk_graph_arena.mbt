///|
/// Owns every graph object created for one root graph.
///
/// Each handle identifies an arena-owned slot by index and generation. Graph
/// access therefore uses checked array indexing instead of a process-global
/// handle-to-slot map. Disposing the arena releases every payload and makes all
/// outstanding handles invalid.
pub struct GraphArena {
  priv mut alive : Bool
  priv mut next_object_id : Int
  priv mut root : ElkNode?
  priv nodes : Array[NodeSlot]
  priv ports : Array[PortSlot]
  priv edges : Array[EdgeSlot]
  priv edge_sections : Array[EdgeSectionSlot]
  priv labels : Array[LabelSlot]
}

///|
pub fn new_graph_arena() -> GraphArena {
  {
    alive: true,
    next_object_id: 0,
    root: None,
    nodes: [],
    ports: [],
    edges: [],
    edge_sections: [],
    labels: [],
  }
}

///|
pub fn GraphArena::is_alive(self : GraphArena) -> Bool {
  self.alive
}

///|
fn checked_graph_arena(arena : GraphArena) -> Unit {
  if !arena.alive {
    abort("invalid or disposed graph arena")
  }
}

///|
fn GraphArena::allocate_object_id(self : GraphArena) -> Int {
  checked_graph_arena(self)
  let id = self.next_object_id
  self.next_object_id = id + 1
  id
}

///|
fn label_has_edge_ancestor(label : ElkLabel, edge : ElkEdge) -> Bool {
  let mut current = label
  while true {
    match label_data(current).parent {
      Some(EdgeLabelParent(parent_edge)) => return parent_edge == edge
      Some(LabelLabelParent(parent_label)) => current = parent_label
      _ => return false
    }
  }
  false
}

///|
fn graph_arena_move_edge_slot(edge : ElkEdge, target : GraphArena) -> EdgeData {
  let source_slot = checked_edge_slot(edge)
  let data = match source_slot.data {
    Some(data) => data
    None => abort("invalid or disposed edge id")
  }
  source_slot.data = None
  source_slot.generation += 1
  let target_slot = target.edges.length()
  edge.arena = target
  edge.slot = target_slot
  edge.generation = 0
  target.edges.push({ generation: 0, handle: edge, data: Some(data) })
  data
}

///|
fn graph_arena_move_edge_section_slot(
  section : ElkEdgeSection,
  target : GraphArena,
) -> Unit {
  let source_slot = checked_edge_section_slot(section)
  let data = match source_slot.data {
    Some(data) => data
    None => abort("invalid or disposed edge section id")
  }
  source_slot.data = None
  source_slot.generation += 1
  let target_slot = target.edge_sections.length()
  section.arena = target
  section.slot = target_slot
  section.generation = 0
  target.edge_sections.push({ generation: 0, handle: section, data: Some(data) })
}

///|
fn graph_arena_move_label_slot(label : ElkLabel, target : GraphArena) -> Unit {
  let source_slot = checked_label_slot(label)
  let data = match source_slot.data {
    Some(data) => data
    None => abort("invalid or disposed label id")
  }
  source_slot.data = None
  source_slot.generation += 1
  let target_slot = target.labels.length()
  label.arena = target
  label.slot = target_slot
  label.generation = 0
  target.labels.push({ generation: 0, handle: label, data: Some(data) })
}

///|
fn graph_arena_has_owned_objects(arena : GraphArena) -> Bool {
  for slot in arena.nodes {
    if slot.data is Some(_) {
      return true
    }
  }
  for slot in arena.ports {
    if slot.data is Some(_) {
      return true
    }
  }
  for slot in arena.edges {
    if slot.data is Some(_) {
      return true
    }
  }
  for slot in arena.edge_sections {
    if slot.data is Some(_) {
      return true
    }
  }
  for slot in arena.labels {
    if slot.data is Some(_) {
      return true
    }
  }
  false
}

///|
fn graph_arena_move_edge(edge : ElkEdge, target_arena : GraphArena) -> Unit {
  let source_arena = edge_graph_arena(edge)
  if physical_equal(source_arena, target_arena) {
    return
  }
  checked_graph_arena(target_arena)
  let sections = edge_data(edge).sections.copy()
  let labels = []
  for slot in source_arena.labels {
    if slot.data is Some(_) && label_has_edge_ancestor(slot.handle, edge) {
      labels.push(slot.handle)
    }
  }
  ignore(graph_arena_move_edge_slot(edge, target_arena))
  for section in sections {
    if physical_equal(edge_section_graph_arena(section), source_arena) {
      graph_arena_move_edge_section_slot(section, target_arena)
    }
  }
  for label in labels {
    graph_arena_move_label_slot(label, target_arena)
  }
  if source_arena.root is None && !graph_arena_has_owned_objects(source_arena) {
    source_arena.nodes.clear()
    source_arena.ports.clear()
    source_arena.edges.clear()
    source_arena.edge_sections.clear()
    source_arena.labels.clear()
    source_arena.alive = false
  }
}

///|
fn graph_arena_adopt_standalone_edge(
  edge : ElkEdge,
  target_arena : GraphArena,
) -> Unit {
  let source_arena = edge_graph_arena(edge)
  if physical_equal(source_arena, target_arena) {
    return
  }
  if source_arena.root is None {
    graph_arena_move_edge(edge, target_arena)
  } else {
    abort("graph relations cannot cross arena ownership")
  }
}

///|
fn graph_arena_for_shape(shape : ElkConnectableShape) -> GraphArena {
  match shape {
    NodeShape(node) => node_graph_arena(node)
    PortShape(port) => port_graph_arena(port)
  }
}

///|
fn graph_arena_require_same(first : GraphArena, second : GraphArena) -> Unit {
  if !physical_equal(first, second) {
    abort("graph relations cannot cross arena ownership")
  }
}

///|
pub fn GraphArena::create_graph(self : GraphArena) -> ElkNode {
  checked_graph_arena(self)
  if self.root is Some(_) {
    abort("a graph arena can own only one root graph")
  }
  let root = create_node_in_arena(None, self)
  self.root = Some(root)
  root
}

///|
pub fn GraphArena::create_node(self : GraphArena) -> ElkNode {
  checked_graph_arena(self)
  create_node_in_arena(None, self)
}

///|
pub fn GraphArena::dispose(self : GraphArena) -> Unit {
  if !self.alive {
    return
  }
  // Reset object payloads before clearing the owning arrays. This breaks the
  // graph's internal cycles and makes stale handles fail deterministically.
  for slot in self.labels.copy() {
    if slot.data is Some(_) {
      dispose_label_slot(slot.handle)
    }
  }
  for slot in self.edge_sections.copy() {
    if slot.data is Some(_) {
      dispose_edge_section_slot(slot.handle)
    }
  }
  for slot in self.edges.copy() {
    if slot.data is Some(_) {
      dispose_edge_slot(slot.handle)
    }
  }
  for slot in self.ports.copy() {
    if slot.data is Some(_) {
      dispose_port_slot(slot.handle)
    }
  }
  for slot in self.nodes.copy() {
    if slot.data is Some(_) {
      dispose_node_slot(slot.handle)
    }
  }
  self.labels.clear()
  self.edge_sections.clear()
  self.edges.clear()
  self.ports.clear()
  self.nodes.clear()
  self.root = None
  self.alive = false
}

///|
pub fn dispose_graph(root : ElkNode) -> Unit {
  checked_node(root)
  let arena = node_graph_arena(root)
  if arena.root != Some(root) {
    abort("dispose_graph expects the root node owned by the arena")
  }
  arena.dispose()
}
