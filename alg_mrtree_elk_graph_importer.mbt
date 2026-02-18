///|
pub struct MrtreeElkGraphImporter {
  marker : Int
}

///|
pub fn new_mrtree_elk_graph_importer() -> MrtreeElkGraphImporter {
  { marker: 0 }
}

///|
fn mrtree_target_node_from_edge(edge : ElkEdge) -> ElkNode? {
  if edge_targets(edge).is_empty() {
    return None
  }
  match edge_targets(edge)[0] {
    NodeShape(node) => Some(node)
    PortShape(port) => port_parent(port)
  }
}

///|
fn mrtree_all_outgoing_edges(node : ElkNode) -> Array[ElkEdge] {
  let outgoing = []
  let seen : Map[ElkEdge, Bool] = {}

  for edge in node_outgoing_edges(node) {
    if !seen.contains(edge) {
      seen[edge] = true
      outgoing.push(edge)
    }
  }

  for port in node_ports(node) {
    for edge in port_outgoing_edges(port) {
      if !seen.contains(edge) {
        seen[edge] = true
        outgoing.push(edge)
      }
    }
  }

  outgoing
}

///|
fn mrtree_edge_is_hierarchical(
  parent_node : ElkNode,
  target_node : ElkNode,
) -> Bool {
  if node_parent(target_node) is Some(target_parent) {
    target_parent != parent_node
  } else {
    true
  }
}

///|
fn mrtree_first_or_create_edge_section(edge : ElkEdge) -> ElkEdgeSection {
  let sections = edge_sections(edge)
  let section = if sections.is_empty() {
    create_edge_section(edge)
  } else {
    sections[0]
  }
  if edge_section_incoming_shape(section) is None {
    let sources = edge_sources(edge)
    if sources.length() == 1 {
      edge_section_set_incoming_shape(section, Some(sources[0]))
    }
  }
  if edge_section_outgoing_shape(section) is None {
    let targets = edge_targets(edge)
    if targets.length() == 1 {
      edge_section_set_outgoing_shape(section, Some(targets[0]))
    }
  }
  section
}

///|
fn mrtree_apply_vector_chain_to_edge(
  vector_chain : KVectorChain,
  edge : ElkEdge,
) -> Unit {
  if vector_chain.size() < 2 {
    return
  }

  let first_section = mrtree_first_or_create_edge_section(edge)
  let first_point = vector_chain.get(0)
  edge_section_set_start(first_section, first_point.x, first_point.y)

  if vector_chain.size() == 2 {
    let last_point = vector_chain.get(1)
    edge_section_set_end(first_section, last_point.x, last_point.y)
    let targets = edge_targets(edge)
    if targets.length() == 1 {
      edge_section_set_outgoing_shape(first_section, Some(targets[0]))
    }
    return
  }

  edge_section_set_outgoing_shape(first_section, None)
  let mut previous_section = first_section
  for i in 1..<(vector_chain.size() - 1) {
    let middle_point = vector_chain.get(i)
    edge_section_set_end(previous_section, middle_point.x, middle_point.y)
    let next_section = create_edge_section(edge)
    edge_section_set_start(next_section, middle_point.x, middle_point.y)
    edge_section_set_incoming_shape(next_section, None)
    edge_section_set_outgoing_shape(next_section, None)
    edge_section_add_outgoing_section(previous_section, next_section)
    edge_section_add_incoming_section(next_section, previous_section)
    previous_section = next_section
  }

  let last_point = vector_chain.get(vector_chain.size() - 1)
  edge_section_set_end(previous_section, last_point.x, last_point.y)
  let targets = edge_targets(edge)
  if targets.length() == 1 {
    edge_section_set_outgoing_shape(previous_section, Some(targets[0]))
  }
}

///|
fn mrtree_transform_nodes(
  parent_node : ElkNode,
  graph : MrtreeGraph,
  elem_map : Map[ElkNode, MrtreeNode],
) -> Unit {
  let mut index = 0
  for elk_node in node_children(parent_node) {
    let label = if node_labels(elk_node).is_empty() {
      ""
    } else {
      label_text(node_labels(elk_node)[0])
    }
    let node = new_mrtree_node(index, graph, label~)
    mrtree_node_copy_properties_from_elk(node, elk_node)
    let position = mrtree_node_position(node)
    let size = mrtree_node_size(node)
    position.y = node_y(elk_node) + node_height(elk_node) / 2.0
    size.x = if node_width(elk_node) > 1.0 { node_width(elk_node) } else { 1.0 }
    position.x = node_x(elk_node) + node_width(elk_node) / 2.0
    size.y = if node_height(elk_node) > 1.0 {
      node_height(elk_node)
    } else {
      1.0
    }
    elem_map[elk_node] = node
    index += 1
  }
}

///|
fn mrtree_transform_edges(
  parent_node : ElkNode,
  elem_map : Map[ElkNode, MrtreeNode],
) -> Unit {
  for source_elk in node_children(parent_node) {
    let source = match elem_map.get(source_elk) {
      Some(node) => node
      None => continue
    }
    for elk_edge in mrtree_all_outgoing_edges(source_elk) {
      let target_elk = match mrtree_target_node_from_edge(elk_edge) {
        Some(node) => node
        None => continue
      }
      if source_elk == target_elk {
        continue
      }
      if mrtree_edge_is_hierarchical(parent_node, target_elk) {
        continue
      }
      let target = match elem_map.get(target_elk) {
        Some(node) => node
        None => continue
      }
      let edge = new_mrtree_edge(source, target)
      mrtree_edge_set_origin(edge, Some(elk_edge))
    }
  }
}

///|
pub fn MrtreeElkGraphImporter::import_graph(
  self : MrtreeElkGraphImporter,
  elk_graph : ElkNode,
) -> MrtreeGraph {
  ignore(self)
  let graph = new_mrtree_graph()
  mrtree_graph_copy_properties_from_elk(graph, elk_graph)
  let elem_map = {}
  mrtree_transform_nodes(elk_graph, graph, elem_map)
  mrtree_transform_edges(elk_graph, elem_map)
  graph
}

///|
fn mrtree_apply_edges(graph : MrtreeGraph) -> Unit {
  for edge in mrtree_graph_edges(graph) {
    if mrtree_edge_origin(edge) is Some(elk_edge) {
      mrtree_apply_vector_chain_to_edge(mrtree_edge_bend_points(edge), elk_edge)
    }
  }
}

///|
pub fn MrtreeElkGraphImporter::apply_layout(
  self : MrtreeElkGraphImporter,
  graph : MrtreeGraph,
) -> Unit {
  ignore(self)
  let elk_graph = match mrtree_graph_origin(graph) {
    Some(origin) => origin
    None => return
  }
  let mut min_x = 1.0e20
  let mut min_y = 1.0e20
  let mut max_x = -1.0e20
  let mut max_y = -1.0e20
  for node in mrtree_graph_nodes(graph) {
    let position = mrtree_node_position(node)
    let size = mrtree_node_size(node)
    min_x = if position.x < min_x { position.x } else { min_x }
    min_y = if position.y < min_y { position.y } else { min_y }
    max_x = if position.x + size.x > max_x {
      position.x + size.x
    } else {
      max_x
    }
    max_y = if position.y + size.y > max_y {
      position.y + size.y
    } else {
      max_y
    }
    match mrtree_node_origin(node) {
      Some(elk_node) => node_set_location(elk_node, position.x, position.y)
      None => ()
    }
  }

  mrtree_apply_edges(graph)

  let padding_value = mrtree_graph_padding(graph)
  let width = max_x - min_x + padding_value.get_horizontal()
  let height = max_y - min_y + padding_value.get_vertical()
  if !node_get_bool_property(elk_graph, node_size_fixed_graph_size) {
    node_set_dimensions(elk_graph, width, height)
  }
  node_set_double_property(
    elk_graph,
    child_area_width,
    width - padding_value.get_horizontal(),
  )
  node_set_double_property(
    elk_graph,
    child_area_height,
    height - padding_value.get_vertical(),
  )
}

///|
pub fn new_mrtree_elk_graph_as_igraph_importer() -> MrtreeIGraphImporter[
  ElkNode,
] {
  let importer = new_mrtree_elk_graph_importer()
  new_mrtree_igraph_importer(
    fn(graph : ElkNode) { importer.import_graph(graph) },
    fn(graph : MrtreeGraph) { importer.apply_layout(graph) },
  )
}
