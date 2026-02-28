///|
pub type ElkEdge = Int

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
let edge_store : Ref[Array[EdgeData]] = Ref::new([])

///|
fn checked_edge(edge : ElkEdge) -> Unit {
  if edge < 0 || edge >= edge_store.val.length() {
    ignore("invalid edge id")
  }
}

///|
pub fn create_edge(containing_node : ElkNode?) -> ElkEdge {
  if containing_node is Some(node_id) {
    checked_node(node_id)
  }
  let id = edge_store.val.length()
  edge_store.val.push({
    containing_node,
    sources: [],
    targets: [],
    identifier: "",
    sections: [],
    junction_points: [],
    layout_option_string_values: {},
  })
  if containing_node is Some(node_id) {
    append_contained_edge(node_id, id)
  }
  id
}

///|
pub fn edge_add_source(edge : ElkEdge, source : ElkConnectableShape) -> Unit {
  checked_edge(edge)
  match source {
    NodeShape(node) => checked_node(node)
    PortShape(port) => checked_port(port)
  }
  let data = edge_store.val[edge]
  data.sources.push(source)
  edge_store.val[edge] = data
}

///|
pub fn edge_add_target(edge : ElkEdge, target : ElkConnectableShape) -> Unit {
  checked_edge(edge)
  match target {
    NodeShape(node) => checked_node(node)
    PortShape(port) => checked_port(port)
  }
  let data = edge_store.val[edge]
  data.targets.push(target)
  edge_store.val[edge] = data
}

///|
pub fn edge_set_layout_option_string_by_id(
  edge : ElkEdge,
  option_id : String,
  value : String,
) -> Unit {
  checked_edge(edge)
  let data = edge_store.val[edge]
  data.layout_option_string_values[option_id] = value
  edge_store.val[edge] = data
}

///|
pub fn edge_layout_option_string_value(
  edge : ElkEdge,
  option_id : String,
) -> String? {
  checked_edge(edge)
  edge_store.val[edge].layout_option_string_values.get(option_id)
}

///|
pub fn edge_layout_option_string_entries(
  edge : ElkEdge,
) -> Array[(String, String)] {
  checked_edge(edge)
  edge_store.val[edge].layout_option_string_values.to_array()
}

///|
pub fn edge_copy_properties(target : ElkEdge, source : ElkEdge) -> Unit {
  checked_edge(target)
  checked_edge(source)
  let target_data = edge_store.val[target]
  let source_data = edge_store.val[source]
  edge_store.val[target] = {
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
  edge_store.val[edge].sources
}

///|
pub fn edge_targets(edge : ElkEdge) -> Array[ElkConnectableShape] {
  checked_edge(edge)
  edge_store.val[edge].targets
}

///|
pub fn all_edges() -> Array[ElkEdge] {
  let edges = []
  for edge = 0; edge < edge_store.val.length(); edge = edge + 1 {
    edges.push(edge)
  }
  edges
}

///|
pub fn edge_is_connected(edge : ElkEdge) -> Bool {
  checked_edge(edge)
  !edge_store.val[edge].sources.is_empty() &&
  !edge_store.val[edge].targets.is_empty()
}

///|
pub fn edge_containing_node(edge : ElkEdge) -> ElkNode? {
  checked_edge(edge)
  edge_store.val[edge].containing_node
}

///|
pub fn edge_set_containing_node(
  edge : ElkEdge,
  containing_node : ElkNode?,
) -> Unit {
  checked_edge(edge)
  if containing_node is Some(node_id) {
    checked_node(node_id)
  }
  let data = edge_store.val[edge]
  if data.containing_node is Some(old_parent) {
    remove_contained_edge(old_parent, edge)
  }
  if containing_node is Some(new_parent) {
    append_contained_edge(new_parent, edge)
  }
  edge_store.val[edge] = {
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
  let data = edge_store.val[edge]
  edge_store.val[edge] = {
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
  edge_store.val[edge].identifier
}

///|
pub fn edge_junction_points(edge : ElkEdge) -> Array[ElkBendPoint] {
  checked_edge(edge)
  edge_store.val[edge].junction_points
}

///|
pub fn edge_set_junction_points(
  edge : ElkEdge,
  junction_points : Array[ElkBendPoint],
) -> Unit {
  checked_edge(edge)
  let data = edge_store.val[edge]
  edge_store.val[edge] = {
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
  let data = edge_store.val[edge]
  data.junction_points.push(point)
  edge_store.val[edge] = data
}

///|
pub fn edge_clear_junction_points(edge : ElkEdge) -> Unit {
  checked_edge(edge)
  let data = edge_store.val[edge]
  data.junction_points.clear()
  edge_store.val[edge] = data
}
