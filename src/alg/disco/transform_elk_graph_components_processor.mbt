///|
fn disco_edge_source_node(edge : @graph.ElkEdge) -> @graph.ElkNode {
  let sources = @graph.edge_sources(edge)
  if sources.is_empty() {
    @core.layout_runtime_report_unsupported_configuration(
      "edge source is missing",
    )
    return @graph.create_node(None)
  }
  try @graph.connectable_shape_to_node(Some(sources[0])) catch {
    _ => {
      @core.layout_runtime_report_unsupported_configuration(
        "edge source shape is not attached to a node",
      )
      @graph.create_node(None)
    }
  } noraise {
    value => value
  }
}

///|
fn disco_edge_target_node(edge : @graph.ElkEdge) -> @graph.ElkNode {
  let targets = @graph.edge_targets(edge)
  if targets.is_empty() {
    @core.layout_runtime_report_unsupported_configuration(
      "edge target is missing",
    )
    return @graph.create_node(None)
  }
  try @graph.connectable_shape_to_node(Some(targets[0])) catch {
    _ => {
      @core.layout_runtime_report_unsupported_configuration(
        "edge target shape is not attached to a node",
      )
      @graph.create_node(None)
    }
  } noraise {
    value => value
  }
}

///|
fn disco_edge_source_port(edge : @graph.ElkEdge) -> @graph.ElkPort? {
  let sources = @graph.edge_sources(edge)
  if sources.is_empty() {
    None
  } else {
    try @graph.connectable_shape_to_port(Some(sources[0])) catch {
      _ => None
    } noraise {
      value => value
    }
  }
}

///|
fn disco_edge_target_port(edge : @graph.ElkEdge) -> @graph.ElkPort? {
  let targets = @graph.edge_targets(edge)
  if targets.is_empty() {
    None
  } else {
    try @graph.connectable_shape_to_port(Some(targets[0])) catch {
      _ => None
    } noraise {
      value => value
    }
  }
}

///|
fn disco_all_incoming_edges(node : @graph.ElkNode) -> Array[@graph.ElkEdge] {
  let incoming = @graph.node_incoming_edges(node).copy()
  for port in @graph.node_ports(node) {
    for edge in @graph.port_incoming_edges(port) {
      incoming.push(edge)
    }
  }
  incoming
}

///|
fn disco_all_outgoing_edges(node : @graph.ElkNode) -> Array[@graph.ElkEdge] {
  let outgoing = @graph.node_outgoing_edges(node).copy()
  for port in @graph.node_ports(node) {
    for edge in @graph.port_outgoing_edges(port) {
      outgoing.push(edge)
    }
  }
  outgoing
}

///|
fn disco_add_nodes_to_incidence_set(
  incident_nodes : Map[@graph.ElkNode, Unit],
  edges : Array[@graph.ElkEdge],
  choose_node : (@graph.ElkEdge) -> @graph.ElkNode,
) -> Unit {
  for edge in edges {
    incident_nodes[choose_node(edge)] = ()
  }
}

///|
fn disco_get_inner_neighbors_of_port(
  port : @graph.ElkPort,
) -> Map[@graph.ElkNode, Unit] {
  let port_parent_node = match @graph.port_parent(port) {
    Some(parent) => parent
    None => return {}
  }
  let neighbors : Map[@graph.ElkNode, Unit] = {}
  let all_edges = @graph.port_incoming_edges(port).copy()
  for edge in @graph.port_outgoing_edges(port) {
    all_edges.push(edge)
  }
  for edge in all_edges {
    let source_node = disco_edge_source_node(edge)
    let target_node = disco_edge_target_node(edge)
    let source_inside = @graph.node_parent(source_node) ==
      Some(port_parent_node)
    let target_inside = @graph.node_parent(target_node) ==
      Some(port_parent_node)
    if source_inside || target_inside {
      if source_node == port_parent_node {
        neighbors[target_node] = ()
      } else {
        neighbors[source_node] = ()
      }
    }
  }
  neighbors
}

///|
fn disco_dfs(
  start : @graph.ElkNode,
  component : Array[@graph.ElkNode],
  visited : Map[@graph.ElkNode, Unit],
  incidence_map : Map[@graph.ElkNode, Map[@graph.ElkNode, Unit]],
) -> Unit {
  visited[start] = ()
  component.push(start)
  match incidence_map.get(start) {
    Some(adjacent_nodes) =>
      adjacent_nodes.each((node, _) => {
        if !visited.contains(node) {
          disco_dfs(node, component, visited, incidence_map)
        }
      })
    None => ()
  }
}

///|
fn disco_compute_incidences(
  nodes : Array[@graph.ElkNode],
  incidence_map : Map[@graph.ElkNode, Map[@graph.ElkNode, Unit]],
) -> Unit {
  let adjacent_and_inside_parent : Map[
    @graph.ElkPort,
    Map[@graph.ElkNode, Unit],
  ] = {}
  for node in nodes {
    let adjacent_nodes : Map[@graph.ElkNode, Unit] = {}
    incidence_map[node] = adjacent_nodes

    let incoming_same_level : Array[@graph.ElkEdge] = []
    let incoming_other_level : Array[@graph.ElkEdge] = []
    for edge in disco_all_incoming_edges(node) {
      if @graph.node_parent(disco_edge_source_node(edge)) ==
        @graph.node_parent(disco_edge_target_node(edge)) {
        incoming_same_level.push(edge)
      } else {
        incoming_other_level.push(edge)
      }
    }
    disco_add_nodes_to_incidence_set(adjacent_nodes, incoming_same_level, edge => {
      disco_edge_source_node(edge)
    })

    for edge in incoming_other_level {
      if @graph.node_parent(disco_edge_target_node(edge)) ==
        Some(disco_edge_source_node(edge)) {
        match disco_edge_source_port(edge) {
          Some(port) => {
            let nodes_at_port = match adjacent_and_inside_parent.get(port) {
              Some(existing) => existing
              None => {
                let computed = disco_get_inner_neighbors_of_port(port)
                adjacent_and_inside_parent[port] = computed
                computed
              }
            }
            nodes_at_port.each((neighbor, _) => adjacent_nodes[neighbor] = ())
          }
          None => ()
        }
      }
    }

    let outgoing_same_level : Array[@graph.ElkEdge] = []
    let outgoing_other_level : Array[@graph.ElkEdge] = []
    for edge in disco_all_outgoing_edges(node) {
      if @graph.node_parent(disco_edge_source_node(edge)) ==
        @graph.node_parent(disco_edge_target_node(edge)) {
        outgoing_same_level.push(edge)
      } else {
        outgoing_other_level.push(edge)
      }
    }
    disco_add_nodes_to_incidence_set(adjacent_nodes, outgoing_same_level, edge => {
      disco_edge_target_node(edge)
    })

    for edge in outgoing_other_level {
      if @graph.node_parent(disco_edge_source_node(edge)) ==
        Some(disco_edge_target_node(edge)) {
        match disco_edge_target_port(edge) {
          Some(port) => {
            let nodes_at_port = match adjacent_and_inside_parent.get(port) {
              Some(existing) => existing
              None => {
                let computed = disco_get_inner_neighbors_of_port(port)
                adjacent_and_inside_parent[port] = computed
                computed
              }
            }
            nodes_at_port.each((neighbor, _) => adjacent_nodes[neighbor] = ())
          }
          None => ()
        }
      }
    }
  }
}

///|
pub fn elk_graph_components_processor_split(
  graph : @graph.ElkNode,
) -> Array[Array[@graph.ElkNode]] {
  let visited : Map[@graph.ElkNode, Unit] = {}
  let incidence_map : Map[@graph.ElkNode, Map[@graph.ElkNode, Unit]] = {}
  let components : Array[Array[@graph.ElkNode]] = []
  let children = @graph.node_children(graph)
  disco_compute_incidences(children, incidence_map)
  for node in children {
    if !visited.contains(node) {
      let component : Array[@graph.ElkNode] = []
      components.push(component)
      disco_dfs(node, component, visited, incidence_map)
    }
  }
  components
}
