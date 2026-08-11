///|
pub struct ElkEdge {
  priv mut data : EdgeData
  priv mut arena : GraphArena?
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
fn checked_edge(edge : ElkEdge) -> Unit {
  match edge.arena {
    Some(arena) => checked_graph_arena(arena)
    None => abort("invalid or disposed edge id")
  }
}

///|
fn edge_graph_arena(edge : ElkEdge) -> GraphArena {
  checked_edge(edge)
  match edge.arena {
    Some(arena) => arena
    None => abort("invalid or disposed edge id")
  }
}

///|
pub fn ElkEdge::graph_arena(self : ElkEdge) -> GraphArena {
  edge_graph_arena(self)
}

///|
let disposed_edge_data : EdgeData = {
  containing_node: None,
  sources: [],
  targets: [],
  identifier: "",
  sections: [],
  junction_points: [],
  layout_option_string_values: Map([]),
}

///|
fn dispose_edge_slot(edge : ElkEdge) -> Unit {
  checked_edge(edge)
  edge.data = disposed_edge_data
  edge.arena = None
}

///|
fn create_edge_in_arena(
  containing_node : ElkNode?,
  arena : GraphArena,
) -> ElkEdge {
  let edge : ElkEdge = {
    data: {
      containing_node,
      sources: [],
      targets: [],
      identifier: "",
      sections: [],
      junction_points: [],
      layout_option_string_values: Map([]),
    },
    arena: Some(arena),
    id: arena.allocate_object_id(),
  }
  graph_arena_register_edge(arena, edge)
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
  checked_edge(edge)
  match source {
    NodeShape(node) => checked_node(node)
    PortShape(port) => checked_port(port)
  }
  graph_arena_adopt_standalone_edge(edge, graph_arena_for_shape(source))
  let data = edge.data
  data.sources.push(source)
  edge.data = data
}

///|
pub fn edge_add_target(edge : ElkEdge, target : ElkConnectableShape) -> Unit {
  checked_edge(edge)
  match target {
    NodeShape(node) => checked_node(node)
    PortShape(port) => checked_port(port)
  }
  graph_arena_adopt_standalone_edge(edge, graph_arena_for_shape(target))
  let data = edge.data
  data.targets.push(target)
  edge.data = data
}

///|
pub fn edge_set_layout_option_string_by_id(
  edge : ElkEdge,
  option_id : String,
  value : String,
) -> Unit {
  checked_edge(edge)
  let data = edge.data
  data.layout_option_string_values[option_id] = value
  edge.data = data
}

///|
pub fn edge_layout_option_string_value(
  edge : ElkEdge,
  option_id : String,
) -> String? {
  checked_edge(edge)
  edge.data.layout_option_string_values.get(option_id)
}

///|
pub fn edge_layout_option_string_entries(
  edge : ElkEdge,
) -> Array[(String, String)] {
  checked_edge(edge)
  edge.data.layout_option_string_values.to_array()
}

///|
pub fn edge_copy_properties(target : ElkEdge, source : ElkEdge) -> Unit {
  checked_edge(target)
  checked_edge(source)
  let target_data = target.data
  let source_data = source.data
  target.data = {
    containing_node: target_data.containing_node,
    sources: target_data.sources,
    targets: target_data.targets,
    identifier: target_data.identifier,
    sections: target_data.sections,
    junction_points: source_data.junction_points.copy(),
    layout_option_string_values: clone_string_string_map(
      source_data.layout_option_string_values,
    ),
  }
}

///|
pub fn edge_sources(edge : ElkEdge) -> Array[ElkConnectableShape] {
  checked_edge(edge)
  edge.data.sources.copy()
}

///|
pub fn edge_targets(edge : ElkEdge) -> Array[ElkConnectableShape] {
  checked_edge(edge)
  edge.data.targets.copy()
}

///|
pub fn GraphArena::all_edges(self : GraphArena) -> Array[ElkEdge] {
  checked_graph_arena(self)
  self.edges.copy()
}

///|
pub fn edge_is_connected(edge : ElkEdge) -> Bool {
  checked_edge(edge)
  !edge.data.sources.is_empty() && !edge.data.targets.is_empty()
}

///|
pub fn edge_containing_node(edge : ElkEdge) -> ElkNode? {
  checked_edge(edge)
  edge.data.containing_node
}

///|
pub fn edge_set_containing_node(
  edge : ElkEdge,
  containing_node : ElkNode?,
) -> Unit {
  checked_edge(edge)
  if containing_node is Some(node_id) {
    checked_node(node_id)
    graph_arena_adopt_standalone_edge(edge, node_graph_arena(node_id))
  }
  let data = edge.data
  if data.containing_node is Some(old_parent) {
    remove_contained_edge(old_parent, edge)
  }
  if containing_node is Some(new_parent) {
    append_contained_edge(new_parent, edge)
  }
  edge.data = {
    containing_node,
    sources: data.sources,
    targets: data.targets,
    identifier: data.identifier,
    sections: data.sections,
    junction_points: data.junction_points,
    layout_option_string_values: data.layout_option_string_values,
  }
}

///|
pub fn edge_set_identifier(edge : ElkEdge, identifier : String) -> Unit {
  checked_edge(edge)
  let data = edge.data
  edge.data = {
    containing_node: data.containing_node,
    sources: data.sources,
    targets: data.targets,
    identifier,
    sections: data.sections,
    junction_points: data.junction_points,
    layout_option_string_values: data.layout_option_string_values,
  }
}

///|
pub fn edge_identifier(edge : ElkEdge) -> String {
  checked_edge(edge)
  edge.data.identifier
}

///|
pub fn edge_junction_points(edge : ElkEdge) -> Array[ElkBendPoint] {
  checked_edge(edge)
  edge.data.junction_points
}

///|
pub fn edge_set_junction_points(
  edge : ElkEdge,
  junction_points : Array[ElkBendPoint],
) -> Unit {
  checked_edge(edge)
  let data = edge.data
  edge.data = {
    containing_node: data.containing_node,
    sources: data.sources,
    targets: data.targets,
    identifier: data.identifier,
    sections: data.sections,
    junction_points,
    layout_option_string_values: data.layout_option_string_values,
  }
}

///|
pub fn edge_add_junction_point(edge : ElkEdge, point : ElkBendPoint) -> Unit {
  checked_edge(edge)
  let data = edge.data
  data.junction_points.push(point)
  edge.data = data
}

///|
pub fn edge_clear_junction_points(edge : ElkEdge) -> Unit {
  checked_edge(edge)
  let data = edge.data
  data.junction_points.clear()
  edge.data = data
}
