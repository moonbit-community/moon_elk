///|
/// Owns every graph object created for one root graph.
///
/// Handles keep a reference to their arena so ordinary graph operations do not
/// need a process-global store. Disposing the arena clears both directions of
/// that ownership relation and makes every owned handle invalid.
pub struct GraphArena {
  mut alive : Bool
  mut next_object_id : Int
  mut root : ElkNode?
  nodes : Array[ElkNode]
  ports : Array[ElkPort]
  edges : Array[ElkEdge]
  edge_sections : Array[ElkEdgeSection]
  labels : Array[ElkLabel]
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
fn graph_arena_register_node(arena : GraphArena, node : ElkNode) -> Unit {
  checked_graph_arena(arena)
  arena.nodes.push(node)
}

///|
fn graph_arena_register_port(arena : GraphArena, port : ElkPort) -> Unit {
  checked_graph_arena(arena)
  arena.ports.push(port)
}

///|
fn graph_arena_register_edge(arena : GraphArena, edge : ElkEdge) -> Unit {
  checked_graph_arena(arena)
  arena.edges.push(edge)
}

///|
fn graph_arena_register_edge_section(
  arena : GraphArena,
  section : ElkEdgeSection,
) -> Unit {
  checked_graph_arena(arena)
  arena.edge_sections.push(section)
}

///|
fn graph_arena_register_label(arena : GraphArena, label : ElkLabel) -> Unit {
  checked_graph_arena(arena)
  arena.labels.push(label)
}

///|
fn[T : Eq] remove_arena_member(members : Array[T], removed : T) -> Unit {
  let retained = []
  for current in members {
    if current != removed {
      retained.push(current)
    }
  }
  members.clear()
  for current in retained {
    members.push(current)
  }
}

///|
fn label_has_edge_ancestor(label : ElkLabel, edge : ElkEdge) -> Bool {
  let mut current = label
  while true {
    match current.data.parent {
      Some(EdgeLabelParent(parent_edge)) => return parent_edge == edge
      Some(LabelLabelParent(parent_label)) => current = parent_label
      _ => return false
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
  remove_arena_member(source_arena.edges, edge)
  target_arena.edges.push(edge)
  edge.arena = Some(target_arena)
  for section in edge.data.sections {
    if physical_equal(edge_section_graph_arena(section), source_arena) {
      remove_arena_member(source_arena.edge_sections, section)
      target_arena.edge_sections.push(section)
      section.arena = Some(target_arena)
    }
  }
  for label in source_arena.labels.copy() {
    if label_has_edge_ancestor(label, edge) {
      remove_arena_member(source_arena.labels, label)
      target_arena.labels.push(label)
      label.arena = Some(target_arena)
    }
  }
  if source_arena.root is None &&
    source_arena.nodes.is_empty() &&
    source_arena.ports.is_empty() &&
    source_arena.edges.is_empty() &&
    source_arena.edge_sections.is_empty() &&
    source_arena.labels.is_empty() {
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
  for label in self.labels.copy() {
    dispose_label_slot(label)
  }
  for section in self.edge_sections.copy() {
    dispose_edge_section_slot(section)
  }
  for edge in self.edges.copy() {
    dispose_edge_slot(edge)
  }
  for port in self.ports.copy() {
    dispose_port_slot(port)
  }
  for node in self.nodes.copy() {
    dispose_node_slot(node)
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
