///|
struct SporeNodeEntry {
  vertex : KVector
  node : Node
  elk_node : ElkNode
}

///|
pub struct SporeElkGraphImporter {
  mut graph : SporeGraph?
  mut node_map : Array[SporeNodeEntry]
  mut elk_graph : ElkNode?
  mut spacing_node_node : Double
}

///|
pub fn new_spore_elk_graph_importer() -> SporeElkGraphImporter {
  { graph: None, node_map: [], elk_graph: None, spacing_node_node: 0.0 }
}

///|
fn spore_padding_from_graph(graph : ElkNode) -> ElkPadding {
  let result = new_elk_padding()
  result.parse(node_get_string_property(graph, spore_padding))
  result
}

///|
fn spore_node_entry_find(
  entries : Array[SporeNodeEntry],
  vertex : KVector,
) -> SporeNodeEntry? {
  for entry in entries {
    if entry.vertex.equals(vertex) {
      return Some(entry)
    }
  }
  None
}

///|
fn spore_node_entry_contains(
  entries : Array[SporeNodeEntry],
  vertex : KVector,
) -> Bool {
  match spore_node_entry_find(entries, vertex) {
    Some(_) => true
    None => false
  }
}

///|
fn spore_elk_graph_importer_get_graph(
  importer : SporeElkGraphImporter,
) -> SporeGraph {
  match importer.graph {
    Some(graph) => graph
    None => abort("Spore graph importer is not initialized")
  }
}

///|
fn spore_elk_graph_importer_center_distance(
  importer : SporeElkGraphImporter,
  edge : TEdge,
) -> Double {
  ignore(importer)
  edge.u.distance(edge.v)
}

///|
fn spore_elk_graph_importer_minimum_root_distance(
  importer : SporeElkGraphImporter,
  edge : TEdge,
) -> Double {
  let graph = spore_elk_graph_importer_get_graph(importer)
  let preferred_root = match graph.preferred_root {
    Some(node) => node
    None => return 0.0
  }
  let distance_u = edge.u.distance(preferred_root.vertex)
  let distance_v = edge.v.distance(preferred_root.vertex)
  if distance_u < distance_v {
    distance_u
  } else {
    distance_v
  }
}

///|
fn spore_elk_graph_importer_circle_underlap(
  importer : SporeElkGraphImporter,
  edge : TEdge,
) -> Double {
  let first_entry = match spore_node_entry_find(importer.node_map, edge.u) {
    Some(entry) => entry
    None => return 0.0
  }
  let second_entry = match spore_node_entry_find(importer.node_map, edge.v) {
    Some(entry) => entry
    None => return 0.0
  }
  edge.u.distance(edge.v) -
  edge.u.distance(first_entry.node.rect.get_position()) -
  edge.v.distance(second_entry.node.rect.get_position())
}

///|
fn spore_elk_graph_importer_rectangle_underlap(
  importer : SporeElkGraphImporter,
  edge : TEdge,
) -> Double {
  let first_entry = match spore_node_entry_find(importer.node_map, edge.u) {
    Some(entry) => entry
    None => return 0.0
  }
  let second_entry = match spore_node_entry_find(importer.node_map, edge.v) {
    Some(entry) => entry
    None => return 0.0
  }
  first_entry.node.underlap(second_entry.node)
}

///|
fn spore_elk_graph_importer_inverted_overlap(
  importer : SporeElkGraphImporter,
  edge : TEdge,
) -> Double {
  let first_entry = match spore_node_entry_find(importer.node_map, edge.u) {
    Some(entry) => entry
    None => return 0.0
  }
  let second_entry = match spore_node_entry_find(importer.node_map, edge.v) {
    Some(entry) => entry
    None => return 0.0
  }
  let r1 = first_entry.node.rect
  let r2 = second_entry.node.rect
  let dist = shortest_distance(r1, r2)
  if dist >= 0.0 {
    return dist
  }
  let s = r2.get_center().sub(r1.get_center()).length()
  -(overlap(r1, r2) - 1.0) * s
}

///|
fn spore_target_node_from_edge(edge : ElkEdge) -> ElkNode? {
  if edge_targets(edge).is_empty() {
    return None
  }
  match edge_targets(edge)[0] {
    NodeShape(node) => Some(node)
    PortShape(port) => port_parent(port)
  }
}

///|
fn spore_source_node_from_edge(edge : ElkEdge) -> ElkNode? {
  if edge_sources(edge).is_empty() {
    return None
  }
  match edge_sources(edge)[0] {
    NodeShape(node) => Some(node)
    PortShape(port) => port_parent(port)
  }
}

///|
fn spore_apply_translation_to_sections(
  graph : ElkNode,
  dx : Double,
  dy : Double,
) -> Unit {
  for edge in node_contained_edges(graph) {
    for section in edge_sections(edge) {
      edge_section_set_start(
        section,
        edge_section_start_x(section) + dx,
        edge_section_start_y(section) + dy,
      )
      edge_section_set_end(
        section,
        edge_section_end_x(section) + dx,
        edge_section_end_y(section) + dy,
      )
    }
  }
}

///|
pub fn SporeElkGraphImporter::import_graph(
  self : SporeElkGraphImporter,
  input_graph : ElkNode,
) -> SporeGraph {
  self.elk_graph = Some(input_graph)
  self.node_map.clear()

  let preferred_root_id = node_get_string_property(
    input_graph, spore_processing_order_preferred_root,
  )
  let cost_function_id = spore_spanning_tree_cost_function_from_string(
    node_get_string_property(
      input_graph, spore_processing_order_spanning_tree_cost_function,
    ),
  )
  let tree_construction_strategy = spore_tree_construction_strategy_from_string(
    node_get_string_property(
      input_graph, spore_processing_order_tree_construction,
    ),
  )
  let compaction_strategy = spore_compaction_strategy_from_string(
    node_get_string_property(input_graph, spore_compaction_compaction_strategy),
  )
  let root_selection = spore_root_selection_from_string(
    node_get_string_property(input_graph, spore_processing_order_root_selection),
  )
  self.spacing_node_node = node_get_double_property(
    input_graph, spore_spacing_node_node,
  )

  let graph_placeholder = new_spore_graph(
    _ => 0.0,
    tree_construction_strategy,
    compaction_strategy,
  )
  self.graph = Some(graph_placeholder)

  let cost_function : ICostFunction = match cost_function_id {
    CENTER_DISTANCE =>
      edge => spore_elk_graph_importer_center_distance(self, edge)
    CIRCLE_UNDERLAP =>
      edge => spore_elk_graph_importer_circle_underlap(self, edge)
    RECTANGLE_UNDERLAP =>
      edge => spore_elk_graph_importer_rectangle_underlap(self, edge)
    INVERTED_OVERLAP =>
      edge => spore_elk_graph_importer_inverted_overlap(self, edge)
    MINIMUM_ROOT_DISTANCE =>
      edge => spore_elk_graph_importer_minimum_root_distance(self, edge)
  }
  let graph = new_spore_graph(
    cost_function, tree_construction_strategy, compaction_strategy,
  )
  graph.debug_svg = node_get_bool_property(input_graph, spore_debug_mode)
  graph.orthogonal_compaction = node_get_bool_property(
    input_graph, spore_compaction_orthogonal,
  )
  self.graph = Some(graph)

  if node_children(input_graph).is_empty() {
    return graph
  }

  let mut shift_index = 0
  for elk_node in node_children(input_graph) {
    let half_width = node_width(elk_node) / 2.0
    let half_height = node_height(elk_node) / 2.0
    let vertex = new_kvector_xy(
      node_x(elk_node) + half_width,
      node_y(elk_node) + half_height,
    )
    while spore_node_entry_contains(self.node_map, vertex) {
      shift_index += 1
      let shift = shift_index.to_double() * 0.001
      ignore(vertex.add(new_kvector_xy(shift, -shift)))
    }

    let node = new_node(
      vertex,
      new_elk_rectangle_xywh(
        vertex.x - half_width - self.spacing_node_node / 2.0,
        vertex.y - half_height - self.spacing_node_node / 2.0,
        node_width(elk_node) + self.spacing_node_node,
        node_height(elk_node) + self.spacing_node_node,
      ),
    )
    graph.vertices.push(node)
    self.node_map.push({ vertex, node, elk_node })
  }

  match root_selection {
    FIXED =>
      if preferred_root_id.is_empty() {
        graph.preferred_root = Some(graph.vertices[0])
      } else {
        for node in graph.vertices {
          let entry = match
            spore_node_entry_find(self.node_map, node.original_vertex) {
            Some(value) => value
            None => continue
          }
          let id = node_identifier(entry.elk_node)
          if !id.is_empty() && id == preferred_root_id {
            graph.preferred_root = Some(node)
          }
        }
      }
    CENTER_NODE => {
      let center = new_kvector_xy(
        node_width(input_graph),
        node_height(input_graph),
      )
      ignore(center.scale(0.5))
      ignore(
        center.add(new_kvector_xy(node_x(input_graph), node_y(input_graph))),
      )
      let mut closest = @double.infinity
      for node in graph.vertices {
        let distance = node.original_vertex.distance(center)
        if distance < closest {
          closest = distance
          graph.preferred_root = Some(node)
        }
      }
    }
  }

  graph
}

///|
pub fn SporeElkGraphImporter::update_graph(
  self : SporeElkGraphImporter,
  graph : SporeGraph,
) -> Unit {
  let updated_node_map : Array[SporeNodeEntry] = []
  graph.t_edges = None
  graph.tree = None

  for node in graph.vertices {
    let original_entry = match
      spore_node_entry_find(self.node_map, node.original_vertex) {
      Some(entry) => entry
      None => continue
    }
    node.original_vertex = node.rect.get_center()
    updated_node_map.push({
      vertex: node.original_vertex,
      node,
      elk_node: original_entry.elk_node,
    })
  }
  self.node_map = updated_node_map
}

///|
pub fn SporeElkGraphImporter::apply_positions(
  self : SporeElkGraphImporter,
  graph : SporeGraph,
) -> Unit {
  let elk_graph = match self.elk_graph {
    Some(value) => value
    None => return
  }

  let mut min_x = @double.infinity
  let mut min_y = @double.infinity
  let mut max_x = -@double.infinity
  let mut max_y = -@double.infinity

  for node in graph.vertices {
    let entry = match
      spore_node_entry_find(self.node_map, node.original_vertex) {
      Some(value) => value
      None => continue
    }
    node_set_location(entry.elk_node, node.rect.x, node.rect.y)
    min_x = @math.minimum(min_x, node_x(entry.elk_node))
    min_y = @math.minimum(min_y, node_y(entry.elk_node))
    max_x = @math.maximum(
      max_x,
      node_x(entry.elk_node) + node_width(entry.elk_node),
    )
    max_y = @math.maximum(
      max_y,
      node_y(entry.elk_node) + node_height(entry.elk_node),
    )
  }

  let padding = spore_padding_from_graph(elk_graph)
  let width = max_x - min_x + padding.get_horizontal()
  let height = max_y - min_y + padding.get_vertical()
  node_set_dimensions(elk_graph, width, height)

  let dx = -min_x + padding.left
  let dy = -min_y + padding.top
  for child in node_children(elk_graph) {
    node_set_location(child, node_x(child) + dx, node_y(child) + dy)
  }
  spore_apply_translation_to_sections(elk_graph, dx, dy)

  for edge in node_contained_edges(elk_graph) {
    let section = if edge_sections(edge).is_empty() {
      create_edge_section(edge)
    } else {
      edge_sections(edge)[0]
    }
    let source = match spore_source_node_from_edge(edge) {
      Some(node) => node
      None => continue
    }
    let target = match spore_target_node_from_edge(edge) {
      Some(node) => node
      None => continue
    }
    let start_location = new_kvector_xy(
      node_x(source) + node_width(source) / 2.0,
      node_y(source) + node_height(source) / 2.0,
    )
    let end_location = new_kvector_xy(
      node_x(target) + node_width(target) / 2.0,
      node_y(target) + node_height(target) / 2.0,
    )
    let uv = end_location.clone().sub(start_location)
    ignore(clip_vector(uv, node_width(source), node_height(source)))
    ignore(start_location.add(uv))
    let vu = start_location.clone().sub(end_location)
    ignore(clip_vector(vu, node_width(target), node_height(target)))
    ignore(end_location.add(vu))
    edge_section_set_start(section, start_location.x, start_location.y)
    edge_section_set_end(section, end_location.x, end_location.y)
  }
}

///|
pub fn new_spore_elk_graph_as_igraph_importer() -> SporeIGraphImporter[ElkNode] {
  let importer = new_spore_elk_graph_importer()
  new_spore_igraph_importer(
    graph => importer.import_graph(graph),
    graph => importer.apply_positions(graph),
    graph => importer.update_graph(graph),
  )
}
