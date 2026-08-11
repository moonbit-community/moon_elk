///|
pub struct ElkEdge {
  priv mut arena : GraphArena
  priv mut slot : Int
  priv mut generation : Int
  priv id : Int
}

///|
pub impl Eq for ElkEdge with fn equal(self, other) {
  physical_equal(self, other)
}

///|
pub impl Hash for ElkEdge with fn hash(self) {
  self.id
}

///|
pub impl Hash for ElkEdge with fn hash_combine(self, hasher) {
  hasher.combine_int(self.id)
}

///|
pub impl @debug.Debug for ElkEdge with fn to_repr(self) {
  Repr(self.id)
}

///|
pub impl Show for ElkEdge with fn output(self, logger) {
  logger.write_string(self.id.to_string())
}

///|
priv struct EdgeData {
  containing_node : ElkNode?
  sources : Array[ElkConnectableShape]
  targets : Array[ElkConnectableShape]
  identifier : String
  sections : Array[ElkEdgeSection]
  junction_points : Array[ElkBendPoint]
  layout_option_string_values : Map[String, String]
}

///|
priv struct EdgeSlot {
  mut generation : Int
  handle : ElkEdge
  mut data : EdgeData?
}

///|
fn checked_edge_slot(edge : ElkEdge) -> EdgeSlot {
  let arena = edge.arena
  checked_graph_arena(arena)
  if edge.slot < 0 || edge.slot >= arena.edges.length() {
    abort("invalid or disposed edge id")
  }
  let slot = arena.edges[edge.slot]
  if slot.generation != edge.generation || slot.data is None {
    abort("invalid or disposed edge id")
  }
  slot
}

///|
fn checked_edge(edge : ElkEdge) -> Unit {
  ignore(checked_edge_slot(edge))
}

///|
fn edge_data(edge : ElkEdge) -> EdgeData {
  match checked_edge_slot(edge).data {
    Some(data) => data
    None => abort("invalid or disposed edge id")
  }
}

///|
fn set_edge_data(edge : ElkEdge, data : EdgeData) -> Unit {
  checked_edge_slot(edge).data = Some(data)
}

///|
fn edge_graph_arena(edge : ElkEdge) -> GraphArena {
  checked_edge(edge)
  edge.arena
}

///|
pub fn ElkEdge::graph_arena(self : ElkEdge) -> GraphArena {
  edge_graph_arena(self)
}

///|
fn dispose_edge_slot(edge : ElkEdge) -> Unit {
  let slot = checked_edge_slot(edge)
  slot.data = None
  slot.generation += 1
}

///|
fn create_edge_in_arena(
  containing_node : ElkNode?,
  arena : GraphArena,
) -> ElkEdge {
  checked_graph_arena(arena)
  let slot = arena.edges.length()
  let edge : ElkEdge = {
    arena,
    slot,
    generation: 0,
    id: arena.allocate_object_id(),
  }
  arena.edges.push({
    generation: 0,
    handle: edge,
    data: Some({
      containing_node,
      sources: [],
      targets: [],
      identifier: "",
      sections: [],
      junction_points: [],
      layout_option_string_values: Map([]),
    }),
  })
  if containing_node is Some(node_id) {
    append_contained_edge(node_id, edge)
  }
  edge
}

///|
pub fn GraphArena::create_edge(self : GraphArena) -> ElkEdge {
  checked_graph_arena(self)
  create_edge_in_arena(None, self)
}

///|
pub fn create_edge(containing_node : ElkNode?) -> ElkEdge {
  match containing_node {
    Some(node_id) => {
      checked_node(node_id)
      create_edge_in_arena(Some(node_id), node_graph_arena(node_id))
    }
    None => new_graph_arena().create_edge()
  }
}

///|
pub fn edge_add_source(edge : ElkEdge, source : ElkConnectableShape) -> Unit {
  match source {
    NodeShape(node) => checked_node(node)
    PortShape(port) => checked_port(port)
  }
  graph_arena_adopt_standalone_edge(edge, graph_arena_for_shape(source))
  let data = edge_data(edge)
  data.sources.push(source)
  set_edge_data(edge, data)
}

///|
pub fn edge_add_target(edge : ElkEdge, target : ElkConnectableShape) -> Unit {
  match target {
    NodeShape(node) => checked_node(node)
    PortShape(port) => checked_port(port)
  }
  graph_arena_adopt_standalone_edge(edge, graph_arena_for_shape(target))
  let data = edge_data(edge)
  data.targets.push(target)
  set_edge_data(edge, data)
}

///|
pub fn edge_set_layout_option_string_by_id(
  edge : ElkEdge,
  option_id : String,
  value : String,
) -> Unit {
  let data = edge_data(edge)
  data.layout_option_string_values[option_id] = value
  set_edge_data(edge, data)
}

///|
pub fn edge_layout_option_string_value(
  edge : ElkEdge,
  option_id : String,
) -> String? {
  edge_data(edge).layout_option_string_values.get(option_id)
}

///|
pub fn edge_layout_option_string_entries(
  edge : ElkEdge,
) -> Array[(String, String)] {
  edge_data(edge).layout_option_string_values.to_array()
}

///|
pub fn edge_copy_properties(target : ElkEdge, source : ElkEdge) -> Unit {
  let target_data = edge_data(target)
  let source_data = edge_data(source)
  set_edge_data(target, {
    containing_node: target_data.containing_node,
    sources: target_data.sources,
    targets: target_data.targets,
    identifier: target_data.identifier,
    sections: target_data.sections,
    junction_points: source_data.junction_points.copy(),
    layout_option_string_values: clone_string_string_map(
      source_data.layout_option_string_values,
    ),
  })
}

///|
pub fn edge_sources(edge : ElkEdge) -> Array[ElkConnectableShape] {
  edge_data(edge).sources.copy()
}

///|
pub fn edge_targets(edge : ElkEdge) -> Array[ElkConnectableShape] {
  edge_data(edge).targets.copy()
}

///|
pub fn GraphArena::all_edges(self : GraphArena) -> Array[ElkEdge] {
  checked_graph_arena(self)
  let edges = []
  for slot in self.edges {
    if slot.data is Some(_) {
      edges.push(slot.handle)
    }
  }
  edges
}

///|
pub fn edge_is_connected(edge : ElkEdge) -> Bool {
  !edge_data(edge).sources.is_empty() && !edge_data(edge).targets.is_empty()
}

///|
pub fn edge_containing_node(edge : ElkEdge) -> ElkNode? {
  edge_data(edge).containing_node
}

///|
pub fn edge_set_containing_node(
  edge : ElkEdge,
  containing_node : ElkNode?,
) -> Unit {
  if containing_node is Some(node_id) {
    checked_node(node_id)
    graph_arena_adopt_standalone_edge(edge, node_graph_arena(node_id))
  }
  let data = edge_data(edge)
  if data.containing_node is Some(old_parent) {
    remove_contained_edge(old_parent, edge)
  }
  if containing_node is Some(new_parent) {
    append_contained_edge(new_parent, edge)
  }
  set_edge_data(edge, {
    containing_node,
    sources: data.sources,
    targets: data.targets,
    identifier: data.identifier,
    sections: data.sections,
    junction_points: data.junction_points,
    layout_option_string_values: data.layout_option_string_values,
  })
}

///|
pub fn edge_set_identifier(edge : ElkEdge, identifier : String) -> Unit {
  let data = edge_data(edge)
  set_edge_data(edge, {
    containing_node: data.containing_node,
    sources: data.sources,
    targets: data.targets,
    identifier,
    sections: data.sections,
    junction_points: data.junction_points,
    layout_option_string_values: data.layout_option_string_values,
  })
}

///|
pub fn edge_identifier(edge : ElkEdge) -> String {
  edge_data(edge).identifier
}

///|
pub fn edge_junction_points(edge : ElkEdge) -> Array[ElkBendPoint] {
  edge_data(edge).junction_points
}

///|
pub fn edge_set_junction_points(
  edge : ElkEdge,
  junction_points : Array[ElkBendPoint],
) -> Unit {
  let data = edge_data(edge)
  set_edge_data(edge, {
    containing_node: data.containing_node,
    sources: data.sources,
    targets: data.targets,
    identifier: data.identifier,
    sections: data.sections,
    junction_points,
    layout_option_string_values: data.layout_option_string_values,
  })
}

///|
pub fn edge_add_junction_point(edge : ElkEdge, point : ElkBendPoint) -> Unit {
  let data = edge_data(edge)
  data.junction_points.push(point)
  set_edge_data(edge, data)
}

///|
pub fn edge_clear_junction_points(edge : ElkEdge) -> Unit {
  let data = edge_data(edge)
  data.junction_points.clear()
  set_edge_data(edge, data)
}
