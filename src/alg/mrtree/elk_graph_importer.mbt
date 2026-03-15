///|
pub struct MrtreeElkGraphImporter {
  marker : Int
}

///|
pub fn new_mrtree_elk_graph_importer() -> MrtreeElkGraphImporter {
  { marker: 0 }
}

///|
fn mrtree_target_node_from_edge(edge : @graph.ElkEdge) -> @graph.ElkNode? {
  if @graph.edge_targets(edge).is_empty() {
    return None
  }
  match @graph.edge_targets(edge)[0] {
    NodeShape(node) => Some(node)
    PortShape(port) => @graph.port_parent(port)
  }
}

///|
fn mrtree_all_outgoing_edges(node : @graph.ElkNode) -> Array[@graph.ElkEdge] {
  let outgoing = []
  let seen : Map[@graph.ElkEdge, Bool] = {}

  for edge in @graph.node_outgoing_edges(node) {
    if !seen.contains(edge) {
      seen[edge] = true
      outgoing.push(edge)
    }
  }

  for port in @graph.node_ports(node) {
    for edge in @graph.port_outgoing_edges(port) {
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
  parent_node : @graph.ElkNode,
  target_node : @graph.ElkNode,
) -> Bool {
  if @graph.node_parent(target_node) is Some(target_parent) {
    target_parent != parent_node
  } else {
    true
  }
}

///|
fn mrtree_first_or_create_edge_section(
  edge : @graph.ElkEdge,
) -> @graph.ElkEdgeSection {
  let sections = @graph.edge_sections(edge)
  if sections.is_empty() {
    @graph.create_edge_section(edge)
  } else {
    sections[0]
  }
}

///|
fn mrtree_apply_vector_chain_to_edge(
  vector_chain : @core.KVectorChain,
  edge : @graph.ElkEdge,
) -> Unit {
  if vector_chain.size() < 2 {
    return
  }

  let first_section = mrtree_first_or_create_edge_section(edge)
  let first_point = vector_chain.get(0)
  @graph.edge_section_set_start(first_section, first_point.x, first_point.y)
  @graph.edge_section_clear_bend_points(first_section)
  for i in 0..<vector_chain.size() {
    let point = vector_chain.get(i)
    @graph.edge_section_add_bend_point(
      first_section,
      @graph.new_elk_bend_point(x=point.x, y=point.y),
    )
  }
  let last_point = vector_chain.get(vector_chain.size() - 1)
  @graph.edge_section_set_end(first_section, last_point.x, last_point.y)
}

///|
fn mrtree_transform_nodes(
  parent_node : @graph.ElkNode,
  graph : MrtreeGraph,
  elem_map : Map[@graph.ElkNode, MrtreeNode],
) -> Unit {
  let mut index = 0
  for elk_node in @graph.node_children(parent_node) {
    let label = if @graph.node_labels(elk_node).is_empty() {
      ""
    } else {
      @graph.label_text(@graph.node_labels(elk_node)[0])
    }
    let node = new_mrtree_node(index, graph, label~)
    mrtree_node_copy_properties_from_elk(node, elk_node)
    let position = mrtree_node_position(node)
    let size = mrtree_node_size(node)
    position.y = @graph.node_y(elk_node) + @graph.node_height(elk_node) / 2.0
    size.x = if @graph.node_width(elk_node) > 1.0 {
      @graph.node_width(elk_node)
    } else {
      1.0
    }
    position.x = @graph.node_x(elk_node) + @graph.node_width(elk_node) / 2.0
    size.y = if @graph.node_height(elk_node) > 1.0 {
      @graph.node_height(elk_node)
    } else {
      1.0
    }
    elem_map[elk_node] = node
    index += 1
  }
}

///|
fn mrtree_transform_edges(
  parent_node : @graph.ElkNode,
  elem_map : Map[@graph.ElkNode, MrtreeNode],
) -> Unit {
  for source_elk in @graph.node_children(parent_node) {
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
  elk_graph : @graph.ElkNode,
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
fn mrtree_apply_edges(graph : MrtreeGraph, offset : @core.KVector) -> Unit {
  for edge in mrtree_graph_edges(graph) {
    if mrtree_edge_origin(edge) is Some(elk_edge) {
      let source_node = mrtree_edge_source(edge)
      let target_node = mrtree_edge_target(edge)
      let bend_points = mrtree_edge_bend_points(edge)
      let source_point = mrtree_node_position(source_node).clone()
      let target_point = mrtree_node_position(target_node).clone()
      bend_points.add_first_vector(source_point)
      bend_points.add_last_vector(target_point)
      if bend_points.size() >= 2 {
        mrtree_to_node_border(
          source_point,
          bend_points.get(1),
          mrtree_node_size(source_node),
        )
        mrtree_to_node_border(
          target_point,
          bend_points.get(bend_points.size() - 2),
          mrtree_node_size(target_node),
        )
      }
      let translated = @core.new_kvector_chain()
      for i in 0..<bend_points.size() {
        translated.add_vector(bend_points.get(i).clone().add(offset))
      }
      mrtree_apply_vector_chain_to_edge(translated, elk_edge)
    }
  }
}

///|
fn mrtree_to_node_border(
  center : @core.KVector,
  next : @core.KVector,
  size : @core.KVector,
) -> Unit {
  let wh = size.x / 2.0
  let hh = size.y / 2.0
  let absx = (next.x - center.x).abs()
  let absy = (next.y - center.y).abs()
  let mut xscale = 1.0
  let mut yscale = 1.0
  if absx > wh {
    xscale = wh / absx
  }
  if absy > hh {
    yscale = hh / absy
  }
  let scale = @cmp.minimum(xscale, yscale)
  center.x = center.x + scale * (next.x - center.x)
  center.y = center.y + scale * (next.y - center.y)
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
    min_x = if position.x - size.x / 2.0 < min_x {
      position.x - size.x / 2.0
    } else {
      min_x
    }
    min_y = if position.y - size.y / 2.0 < min_y {
      position.y - size.y / 2.0
    } else {
      min_y
    }
    max_x = if position.x + size.x / 2.0 > max_x {
      position.x + size.x / 2.0
    } else {
      max_x
    }
    max_y = if position.y + size.y / 2.0 > max_y {
      position.y + size.y / 2.0
    } else {
      max_y
    }
  }

  let padding_value = mrtree_graph_padding(graph)
  let offset = @core.new_kvector_xy(
    padding_value.get_left() - min_x,
    padding_value.get_top() - min_y,
  )

  for node in mrtree_graph_nodes(graph) {
    match mrtree_node_origin(node) {
      Some(elk_node) => {
        let node_position = mrtree_node_position(node).clone().add(offset)
        @graph.node_set_location(
          elk_node,
          node_position.x - @graph.node_width(elk_node) / 2.0,
          node_position.y - @graph.node_height(elk_node) / 2.0,
        )
      }
      None => ()
    }
  }

  mrtree_apply_edges(graph, offset)

  let width = max_x - min_x + padding_value.get_horizontal()
  let height = max_y - min_y + padding_value.get_vertical()
  @graph.node_set_dimensions(elk_graph, width, height)
}

///|
pub fn new_mrtree_elk_graph_as_igraph_importer() -> MrtreeIGraphImporter[
  @graph.ElkNode,
] {
  let importer = new_mrtree_elk_graph_importer()
  new_mrtree_igraph_importer(
    fn(graph : @graph.ElkNode) { importer.import_graph(graph) },
    fn(graph : MrtreeGraph) { importer.apply_layout(graph) },
  )
}
