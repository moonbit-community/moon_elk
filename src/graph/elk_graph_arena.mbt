///|
pub struct GraphArena {
  id : Int
}

///|
priv struct GraphArenaData {
  alive : Bool
  mut root : ElkNode?
  nodes : Array[ElkNode]
  ports : Array[ElkPort]
  edges : Array[ElkEdge]
  edge_sections : Array[ElkEdgeSection]
  labels : Array[ElkLabel]
}

///|
let graph_arena_store : Ref[Array[GraphArenaData]] = Ref([])

///|
let node_arena_store : Ref[Array[Int]] = Ref([])

///|
let port_arena_store : Ref[Array[Int]] = Ref([])

///|
let edge_arena_store : Ref[Array[Int]] = Ref([])

///|
let edge_section_arena_store : Ref[Array[Int]] = Ref([])

///|
let label_arena_store : Ref[Array[Int]] = Ref([])

///|
fn new_graph_arena_data() -> GraphArenaData {
  {
    alive: true,
    root: None,
    nodes: [],
    ports: [],
    edges: [],
    edge_sections: [],
    labels: [],
  }
}

///|
let disposed_graph_arena_data : GraphArenaData = {
  alive: false,
  root: None,
  nodes: [],
  ports: [],
  edges: [],
  edge_sections: [],
  labels: [],
}

///|
fn graph_arena_id_is_alive(arena_id : Int) -> Bool {
  arena_id >= 0 &&
  arena_id < graph_arena_store.val.length() &&
  graph_arena_store.val[arena_id].alive
}

///|
fn checked_graph_arena(arena : GraphArena) -> Unit {
  if !graph_arena_id_is_alive(arena.id) {
    abort("invalid or disposed graph arena")
  }
}

///|
pub fn new_graph_arena() -> GraphArena {
  let id = graph_arena_store.val.length()
  graph_arena_store.val.push(new_graph_arena_data())
  { id, }
}

///|
fn graph_arena_register_node(arena_id : Int, node : ElkNode) -> Unit {
  let data = graph_arena_store.val[arena_id]
  data.nodes.push(node)
  graph_arena_store.val[arena_id] = data
  node_arena_store.val.push(arena_id)
}

///|
fn graph_arena_register_port(arena_id : Int, port : ElkPort) -> Unit {
  let data = graph_arena_store.val[arena_id]
  data.ports.push(port)
  graph_arena_store.val[arena_id] = data
  port_arena_store.val.push(arena_id)
}

///|
fn graph_arena_register_edge(arena_id : Int, edge : ElkEdge) -> Unit {
  let data = graph_arena_store.val[arena_id]
  data.edges.push(edge)
  graph_arena_store.val[arena_id] = data
  edge_arena_store.val.push(arena_id)
}

///|
fn graph_arena_register_edge_section(
  arena_id : Int,
  section : ElkEdgeSection,
) -> Unit {
  let data = graph_arena_store.val[arena_id]
  data.edge_sections.push(section)
  graph_arena_store.val[arena_id] = data
  edge_section_arena_store.val.push(arena_id)
}

///|
fn graph_arena_register_label(arena_id : Int, label : ElkLabel) -> Unit {
  let data = graph_arena_store.val[arena_id]
  data.labels.push(label)
  graph_arena_store.val[arena_id] = data
  label_arena_store.val.push(arena_id)
}

///|
fn remove_arena_member(members : Array[Int], removed : Int) -> Unit {
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
fn graph_arena_retire_if_empty(arena_id : Int) -> Unit {
  if !graph_arena_id_is_alive(arena_id) {
    return
  }
  let data = graph_arena_store.val[arena_id]
  if data.root is None &&
    data.nodes.is_empty() &&
    data.ports.is_empty() &&
    data.edges.is_empty() &&
    data.edge_sections.is_empty() &&
    data.labels.is_empty() {
    graph_arena_store.val[arena_id] = disposed_graph_arena_data
  }
}

///|
fn label_has_edge_ancestor(label : ElkLabel, edge : ElkEdge) -> Bool {
  let mut current = label
  while true {
    match label_store.val[current].parent {
      Some(EdgeLabelParent(parent_edge)) => return parent_edge == edge
      Some(LabelLabelParent(parent_label)) => current = parent_label
      _ => return false
    }
  }
  false
}

///|
fn graph_arena_move_edge(edge : ElkEdge, target_arena_id : Int) -> Unit {
  let source_arena_id = edge_arena_store.val[edge]
  if source_arena_id == target_arena_id {
    return
  }
  let source_data = graph_arena_store.val[source_arena_id]
  let target_data = graph_arena_store.val[target_arena_id]
  remove_arena_member(source_data.edges, edge)
  target_data.edges.push(edge)
  edge_arena_store.val[edge] = target_arena_id
  for section in edge_store.val[edge].sections {
    if edge_section_arena_store.val[section] == source_arena_id {
      remove_arena_member(source_data.edge_sections, section)
      target_data.edge_sections.push(section)
      edge_section_arena_store.val[section] = target_arena_id
    }
  }
  for label = 0; label < label_store.val.length(); label = label + 1 {
    if label_arena_store.val[label] == source_arena_id &&
      label_has_edge_ancestor(label, edge) {
      remove_arena_member(source_data.labels, label)
      target_data.labels.push(label)
      label_arena_store.val[label] = target_arena_id
    }
  }
  graph_arena_store.val[source_arena_id] = source_data
  graph_arena_store.val[target_arena_id] = target_data
  graph_arena_retire_if_empty(source_arena_id)
}

///|
fn graph_arena_adopt_standalone_edge(
  edge : ElkEdge,
  target_arena_id : Int,
) -> Unit {
  let source_arena_id = edge_arena_store.val[edge]
  if source_arena_id != target_arena_id &&
    graph_arena_store.val[source_arena_id].root is None {
    graph_arena_move_edge(edge, target_arena_id)
  }
}

///|
fn graph_arena_for_shape(shape : ElkConnectableShape) -> Int {
  match shape {
    NodeShape(node) => node_arena_store.val[node]
    PortShape(port) => port_arena_store.val[port]
  }
}

///|
pub fn GraphArena::create_graph(self : GraphArena) -> ElkNode {
  checked_graph_arena(self)
  let arena_data = graph_arena_store.val[self.id]
  if arena_data.root is Some(_) {
    abort("a graph arena can own only one root graph")
  }
  let root = create_node_in_arena(None, self.id)
  arena_data.root = Some(root)
  graph_arena_store.val[self.id] = arena_data
  root
}

///|
pub fn GraphArena::dispose(self : GraphArena) -> Unit {
  if self.id < 0 || self.id >= graph_arena_store.val.length() {
    abort("invalid graph arena")
  }
  if !graph_arena_store.val[self.id].alive {
    return
  }
  let data = graph_arena_store.val[self.id]
  // Integer handles remain stable for compatibility. Replacing each owned slot
  // with a shared tombstone releases the graph data without renumbering handles
  // that belong to other live arenas.
  for label in data.labels {
    dispose_label_slot(label)
  }
  for section in data.edge_sections {
    dispose_edge_section_slot(section)
  }
  for edge in data.edges {
    dispose_edge_slot(edge)
  }
  for port in data.ports {
    dispose_port_slot(port)
  }
  for node in data.nodes {
    dispose_node_slot(node)
  }
  graph_arena_store.val[self.id] = disposed_graph_arena_data
}

///|
pub fn dispose_graph(root : ElkNode) -> Unit {
  checked_node(root)
  let arena_id = node_arena_store.val[root]
  if graph_arena_store.val[arena_id].root != Some(root) {
    abort("dispose_graph expects the root node owned by the arena")
  }
  GraphArena::{ id: arena_id }.dispose()
}
