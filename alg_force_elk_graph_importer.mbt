///|
pub struct ElkGraphImporter {
  _dummy : Unit
}

///|
pub fn new_elk_graph_importer() -> ElkGraphImporter {
  { _dummy: () }
}

///|
fn first_node_label_text(node : ElkNode) -> String {
  let labels = node_labels(node)
  if labels.is_empty() {
    ""
  } else {
    label_text(labels[0])
  }
}

///|
fn first_or_create_edge_section(edge : ElkEdge) -> ElkEdgeSection {
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
fn force_transform_nodes(
  parent_node : ElkNode,
  fgraph : FGraph,
  elem_map : Map[ElkNode, FNode],
) -> Unit {
  let mut index = 0
  for node in node_children(parent_node) {
    let new_node = new_fnode(label=first_node_label_text(node))
    fnode_set_origin(new_node, node)
    fnode_set_id(new_node, index)
    fnode_position(new_node).x = node_x(node) + node_width(node) / 2.0
    fnode_position(new_node).y = node_y(node) + node_height(node) / 2.0
    fnode_size(new_node).x = force_max(node_width(node), 1.0)
    fnode_size(new_node).y = force_max(node_height(node), 1.0)
    let priority_value = node_get_double_property(node, priority)
    fnode_set_int_property(new_node, force_priority, priority_value.to_int())
    index += 1
    elem_map[node] = new_node
    fgraph.add_node(new_node)
  }
}

///|
fn force_transform_edges(
  parent_node : ElkNode,
  fgraph : FGraph,
  elem_map : Map[ElkNode, FNode],
) -> Unit {
  for edge in node_contained_edges(parent_node) {
    let sources = edge_sources(edge)
    let targets = edge_targets(edge)
    if sources.length() != 1 || targets.length() != 1 {
      abort("Graph must not contain hyperedges.")
    }
    let source_node = connectable_shape_to_node(Some(sources[0]))
    let target_node = connectable_shape_to_node(Some(targets[0]))
    if source_node == target_node {
      continue
    }
    match (elem_map.get(source_node), elem_map.get(target_node)) {
      (Some(source), Some(target)) => {
        let new_edge = new_fedge()
        fedge_set_origin(new_edge, edge)
        fedge_set_source(new_edge, source)
        fedge_set_target(new_edge, target)
        fedge_set_int_property(
          new_edge,
          force_priority,
          force_priority.get_default(),
        )
        fedge_set_int_property(
          new_edge,
          force_repulsive_power,
          force_repulsive_power.get_default(),
        )
        fgraph.add_edge(new_edge)
        for edge_label in edge_labels(edge) {
          let new_label = new_flabel(new_edge, text=label_text(edge_label))
          flabel_set_origin(new_label, edge_label)
          flabel_size(new_label).x = force_max(label_width(edge_label), 1.0)
          flabel_size(new_label).y = force_max(label_height(edge_label), 1.0)
          flabel_set_bool_property(new_label, force_edge_labels_inline, false)
          flabel_refresh_position(new_label)
          fgraph.add_label(new_label)
        }
      }
      _ => ()
    }
  }
}

///|
pub fn ElkGraphImporter::import_graph(
  self : ElkGraphImporter,
  graph : ElkNode,
) -> FGraph {
  ignore(self)
  let fgraph = new_fgraph()
  fgraph.set_internal_node_property(force_internal_origin, graph)
  let elem_map : Map[ElkNode, FNode] = {}
  force_transform_nodes(graph, fgraph, elem_map)
  force_transform_edges(graph, fgraph, elem_map)
  fgraph
}

///|
pub fn ElkGraphImporter::apply_layout(
  self : ElkGraphImporter,
  force_graph : FGraph,
) -> Unit {
  ignore(self)
  let graph = match
    force_graph.get_internal_node_property(force_internal_origin) {
    Some(graph) => graph
    None => return
  }
  let mut min_x = 1.0e20
  let mut min_y = 1.0e20
  let mut max_x = -1.0e20
  let mut max_y = -1.0e20
  for node in force_graph.get_nodes() {
    let position = fnode_position(node)
    let size = fnode_size(node)
    min_x = force_min(min_x, position.x - size.x / 2.0)
    min_y = force_min(min_y, position.y - size.y / 2.0)
    max_x = force_max(max_x, position.x + size.x / 2.0)
    max_y = force_max(max_y, position.y + size.y / 2.0)
  }
  for bendpoint in force_graph.get_bendpoints() {
    let position = fbendpoint_position(bendpoint)
    let size = fbendpoint_size(bendpoint)
    min_x = force_min(min_x, position.x - size.x / 2.0)
    min_y = force_min(min_y, position.y - size.y / 2.0)
    max_x = force_max(max_x, position.x + size.x / 2.0)
    max_y = force_max(max_y, position.y + size.y / 2.0)
  }
  let padding = force_graph.get_padding_property(force_padding)
  let offset = new_kvector_xy(
    padding.get_left() - min_x,
    padding.get_top() - min_y,
  )
  for node in force_graph.get_nodes() {
    match fnode_origin(node) {
      Some(origin_node) => {
        let node_position = fnode_position(node).clone().add(offset)
        node_set_location(
          origin_node,
          node_position.x - node_width(origin_node) / 2.0,
          node_position.y - node_height(origin_node) / 2.0,
        )
      }
      None => ()
    }
  }
  for edge in force_graph.get_edges() {
    match fedge_origin(edge) {
      Some(origin_edge) => {
        let start_position = fedge_source_point(edge).clone().add(offset)
        let end_position = fedge_target_point(edge).clone().add(offset)
        let first_section = first_or_create_edge_section(origin_edge)
        if fedge_bendpoints(edge).is_empty() {
          edge_section_set_start(
            first_section,
            start_position.x,
            start_position.y,
          )
          edge_section_set_end(first_section, end_position.x, end_position.y)
        } else {
          edge_section_set_start(
            first_section,
            start_position.x,
            start_position.y,
          )
          edge_section_set_outgoing_shape(first_section, None)
          let mut previous_section = first_section
          for bendpoint in fedge_bendpoints(edge) {
            let bendpoint_position = fbendpoint_position(bendpoint)
              .clone()
              .add(offset)
            edge_section_set_end(
              previous_section,
              bendpoint_position.x,
              bendpoint_position.y,
            )
            let next_section = create_edge_section(origin_edge)
            edge_section_set_start(
              next_section,
              bendpoint_position.x,
              bendpoint_position.y,
            )
            edge_section_set_incoming_shape(next_section, None)
            edge_section_set_outgoing_shape(next_section, None)
            edge_section_add_outgoing_section(previous_section, next_section)
            edge_section_add_incoming_section(next_section, previous_section)
            previous_section = next_section
          }
          edge_section_set_end(previous_section, end_position.x, end_position.y)
          let targets = edge_targets(origin_edge)
          if targets.length() == 1 {
            edge_section_set_outgoing_shape(previous_section, Some(targets[0]))
          }
        }
      }
      None => ()
    }
  }
  for label in force_graph.get_labels() {
    match flabel_origin(label) {
      Some(origin_label) => {
        let label_position = flabel_position(label).clone().add(offset)
        label_set_location(origin_label, label_position.x, label_position.y)
      }
      None => ()
    }
  }
  let width = max_x - min_x + padding.get_horizontal()
  let height = max_y - min_y + padding.get_vertical()
  if !node_get_bool_property(graph, node_size_fixed_graph_size) {
    node_set_dimensions(graph, width, height)
  }
  node_set_double_property(
    graph,
    child_area_width,
    width - padding.get_horizontal(),
  )
  node_set_double_property(
    graph,
    child_area_height,
    height - padding.get_vertical(),
  )
}

///|
pub fn elk_graph_importer_as_igraph_importer(
  importer : ElkGraphImporter,
) -> IGraphImporter[ElkNode] {
  new_igraph_importer(graph => importer.import_graph(graph), force_graph => importer.apply_layout(
    force_graph,
  ))
}
