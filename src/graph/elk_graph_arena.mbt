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
let graph_arena_next_handle : Ref[Int] = Ref(0)

///|
let graph_arena_free_slots : Ref[Array[Int]] = Ref([])

///|
let graph_arena_handle_slots : Ref[Map[Int, Int]] = Ref(Map([]))

///|
let graph_arena_slot_handles : Ref[Array[Int]] = Ref([])

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
  match graph_arena_handle_slots.val.get(arena_id) {
    Some(slot) => graph_arena_store.val[slot].alive
    None => false
  }
}

///|
fn graph_arena_slot(arena_id : Int) -> Int {
  if !graph_arena_id_is_alive(arena_id) {
    abort("invalid or disposed graph arena")
  }
  match graph_arena_handle_slots.val.get(arena_id) {
    Some(slot) => slot
    None => abort("invalid or disposed graph arena")
  }
}

///|
fn checked_graph_arena(arena : GraphArena) -> Unit {
  if !graph_arena_id_is_alive(arena.id) {
    abort("invalid or disposed graph arena")
  }
}

///|
pub fn new_graph_arena() -> GraphArena {
  let slot = match graph_arena_free_slots.val.pop() {
    Some(reused) => reused
    None => {
      let fresh = graph_arena_store.val.length()
      graph_arena_store.val.push(disposed_graph_arena_data)
      graph_arena_slot_handles.val.push(-1)
      fresh
    }
  }
  let id = graph_handle_allocate(
    slot,
    graph_arena_next_handle,
    graph_arena_handle_slots.val,
    graph_arena_slot_handles.val,
  )
  graph_arena_store.val[slot] = new_graph_arena_data()
  { id, }
}

///|
fn graph_arena_register_node(arena_id : Int, node : ElkNode) -> Unit {
  let data = graph_arena_store.val[graph_arena_slot(arena_id)]
  data.nodes.push(node)
  graph_arena_store.val[graph_arena_slot(arena_id)] = data
  node_arena_store.val[node_allocated_slot(node)] = arena_id
}

///|
fn graph_arena_register_port(arena_id : Int, port : ElkPort) -> Unit {
  let data = graph_arena_store.val[graph_arena_slot(arena_id)]
  data.ports.push(port)
  graph_arena_store.val[graph_arena_slot(arena_id)] = data
  port_arena_store.val[port_allocated_slot(port)] = arena_id
}

///|
fn graph_arena_register_edge(arena_id : Int, edge : ElkEdge) -> Unit {
  let data = graph_arena_store.val[graph_arena_slot(arena_id)]
  data.edges.push(edge)
  graph_arena_store.val[graph_arena_slot(arena_id)] = data
  edge_arena_store.val[edge_allocated_slot(edge)] = arena_id
}

///|
fn graph_arena_register_edge_section(
  arena_id : Int,
  section : ElkEdgeSection,
) -> Unit {
  let data = graph_arena_store.val[graph_arena_slot(arena_id)]
  data.edge_sections.push(section)
  graph_arena_store.val[graph_arena_slot(arena_id)] = data
  edge_section_arena_store.val[edge_section_allocated_slot(section)] = arena_id
}

///|
fn graph_arena_register_label(arena_id : Int, label : ElkLabel) -> Unit {
  let data = graph_arena_store.val[graph_arena_slot(arena_id)]
  data.labels.push(label)
  graph_arena_store.val[graph_arena_slot(arena_id)] = data
  label_arena_store.val[label_allocated_slot(label)] = arena_id
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
  let slot = graph_arena_slot(arena_id)
  let data = graph_arena_store.val[slot]
  if data.root is None &&
    data.nodes.is_empty() &&
    data.ports.is_empty() &&
    data.edges.is_empty() &&
    data.edge_sections.is_empty() &&
    data.labels.is_empty() {
    graph_arena_store.val[slot] = disposed_graph_arena_data
    graph_handle_release(
      arena_id,
      slot,
      graph_arena_handle_slots.val,
      graph_arena_slot_handles.val,
      graph_arena_free_slots.val,
    )
  }
}

///|
fn label_has_edge_ancestor(label : ElkLabel, edge : ElkEdge) -> Bool {
  let mut current = label
  while true {
    match label_store.val[label_slot(current)].parent {
      Some(EdgeLabelParent(parent_edge)) => return parent_edge == edge
      Some(LabelLabelParent(parent_label)) => current = parent_label
      _ => return false
    }
  }
  false
}

///|
fn graph_arena_move_edge(edge : ElkEdge, target_arena_id : Int) -> Unit {
  let source_arena_id = edge_arena_store.val[edge_slot(edge)]
  if source_arena_id == target_arena_id {
    return
  }
  let source_slot = graph_arena_slot(source_arena_id)
  let target_slot = graph_arena_slot(target_arena_id)
  let source_data = graph_arena_store.val[source_slot]
  let target_data = graph_arena_store.val[target_slot]
  remove_arena_member(source_data.edges, edge)
  target_data.edges.push(edge)
  edge_arena_store.val[edge_slot(edge)] = target_arena_id
  for section in edge_store.val[edge_slot(edge)].sections {
    if edge_section_arena_store.val[edge_section_slot(section)] ==
      source_arena_id {
      remove_arena_member(source_data.edge_sections, section)
      target_data.edge_sections.push(section)
      edge_section_arena_store.val[edge_section_slot(section)] = target_arena_id
    }
  }
  for label = 0; label < label_store.val.length(); label = label + 1 {
    if label_arena_store.val[label] == source_arena_id {
      let label_handle = label_slot_handles.val[label]
      if label_has_edge_ancestor(label_handle, edge) {
        remove_arena_member(source_data.labels, label_handle)
        target_data.labels.push(label_handle)
        label_arena_store.val[label] = target_arena_id
      }
    }
  }
  graph_arena_store.val[source_slot] = source_data
  graph_arena_store.val[target_slot] = target_data
  graph_arena_retire_if_empty(source_arena_id)
}

///|
fn graph_arena_adopt_standalone_edge(
  edge : ElkEdge,
  target_arena_id : Int,
) -> Unit {
  let source_arena_id = edge_arena_store.val[edge_slot(edge)]
  if source_arena_id == target_arena_id {
    return
  }
  if graph_arena_store.val[graph_arena_slot(source_arena_id)].root is None {
    graph_arena_move_edge(edge, target_arena_id)
  } else {
    abort("graph relations cannot cross arena ownership")
  }
}

///|
fn graph_arena_for_shape(shape : ElkConnectableShape) -> Int {
  match shape {
    NodeShape(node) => node_arena_store.val[node_slot(node)]
    PortShape(port) => port_arena_store.val[port_slot(port)]
  }
}

///|
fn graph_arena_require_same(
  first_arena_id : Int,
  second_arena_id : Int,
) -> Unit {
  if first_arena_id != second_arena_id {
    abort("graph relations cannot cross arena ownership")
  }
}

///|
pub fn GraphArena::create_graph(self : GraphArena) -> ElkNode {
  checked_graph_arena(self)
  let slot = graph_arena_slot(self.id)
  let arena_data = graph_arena_store.val[slot]
  if arena_data.root is Some(_) {
    abort("a graph arena can own only one root graph")
  }
  let root = create_node_in_arena(None, self.id)
  arena_data.root = Some(root)
  graph_arena_store.val[slot] = arena_data
  root
}

///|
pub fn GraphArena::create_node(self : GraphArena) -> ElkNode {
  checked_graph_arena(self)
  create_node_in_arena(None, self.id)
}

///|
pub fn GraphArena::dispose(self : GraphArena) -> Unit {
  if self.id < 0 {
    abort("invalid graph arena")
  }
  let slot = match graph_arena_handle_slots.val.get(self.id) {
    Some(active_slot) => active_slot
    None => return
  }
  if !graph_arena_store.val[slot].alive {
    return
  }
  let data = graph_arena_store.val[slot]
  // Clear owned data before returning its storage slots to the free lists.
  // Each released handle is also removed from its live handle-to-slot map.
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
  graph_arena_store.val[slot] = disposed_graph_arena_data
  graph_handle_release(
    self.id,
    slot,
    graph_arena_handle_slots.val,
    graph_arena_slot_handles.val,
    graph_arena_free_slots.val,
  )
}

///|
pub fn dispose_graph(root : ElkNode) -> Unit {
  checked_node(root)
  let arena_id = node_arena_store.val[node_slot(root)]
  if graph_arena_store.val[graph_arena_slot(arena_id)].root != Some(root) {
    abort("dispose_graph expects the root node owned by the arena")
  }
  GraphArena::{ id: arena_id }.dispose()
}
