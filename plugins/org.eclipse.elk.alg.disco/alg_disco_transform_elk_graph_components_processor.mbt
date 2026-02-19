///|
fn disco_edge_source_node(edge : ElkEdge) -> ElkNode {
  let sources = edge_sources(edge)
  if sources.is_empty() {
    abort("edge source is missing")
  }
  connectable_shape_to_node(Some(sources[0]))
}

///|
fn disco_edge_target_node(edge : ElkEdge) -> ElkNode {
  let targets = edge_targets(edge)
  if targets.is_empty() {
    abort("edge target is missing")
  }
  connectable_shape_to_node(Some(targets[0]))
}

///|
fn disco_edge_source_port(edge : ElkEdge) -> ElkPort? {
  let sources = edge_sources(edge)
  if sources.is_empty() {
    None
  } else {
    connectable_shape_to_port(Some(sources[0]))
  }
}

///|
fn disco_edge_target_port(edge : ElkEdge) -> ElkPort? {
  let targets = edge_targets(edge)
  if targets.is_empty() {
    None
  } else {
    connectable_shape_to_port(Some(targets[0]))
  }
}

///|
fn disco_all_incoming_edges(node : ElkNode) -> Array[ElkEdge] {
  let incoming = node_incoming_edges(node).copy()
  for port in node_ports(node) {
    for edge in port_incoming_edges(port) {
      incoming.push(edge)
    }
  }
  incoming
}

///|
fn disco_all_outgoing_edges(node : ElkNode) -> Array[ElkEdge] {
  let outgoing = node_outgoing_edges(node).copy()
  for port in node_ports(node) {
    for edge in port_outgoing_edges(port) {
      outgoing.push(edge)
    }
  }
  outgoing
}

///|
fn disco_add_nodes_to_incidence_set(
  incident_nodes : Map[ElkNode, Unit],
  edges : Array[ElkEdge],
  choose_node : (ElkEdge) -> ElkNode,
) -> Unit {
  for edge in edges {
    incident_nodes[choose_node(edge)] = ()
  }
}

///|
fn disco_get_inner_neighbors_of_port(port : ElkPort) -> Map[ElkNode, Unit] {
  let port_parent_node = match port_parent(port) {
    Some(parent) => parent
    None => return {}
  }
  let neighbors : Map[ElkNode, Unit] = {}
  let all_edges = port_incoming_edges(port).copy()
  for edge in port_outgoing_edges(port) {
    all_edges.push(edge)
  }
  for edge in all_edges {
    let source_node = disco_edge_source_node(edge)
    let target_node = disco_edge_target_node(edge)
    let source_inside = node_parent(source_node) == Some(port_parent_node)
    let target_inside = node_parent(target_node) == Some(port_parent_node)
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
  start : ElkNode,
  component : Array[ElkNode],
  visited : Map[ElkNode, Unit],
  incidence_map : Map[ElkNode, Map[ElkNode, Unit]],
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
  nodes : Array[ElkNode],
  incidence_map : Map[ElkNode, Map[ElkNode, Unit]],
) -> Unit {
  let adjacent_and_inside_parent : Map[ElkPort, Map[ElkNode, Unit]] = {}
  for node in nodes {
    let adjacent_nodes : Map[ElkNode, Unit] = {}
    incidence_map[node] = adjacent_nodes

    let incoming_same_level : Array[ElkEdge] = []
    let incoming_other_level : Array[ElkEdge] = []
    for edge in disco_all_incoming_edges(node) {
      if node_parent(disco_edge_source_node(edge)) ==
        node_parent(disco_edge_target_node(edge)) {
        incoming_same_level.push(edge)
      } else {
        incoming_other_level.push(edge)
      }
    }
    disco_add_nodes_to_incidence_set(adjacent_nodes, incoming_same_level, edge => {
      disco_edge_source_node(edge)
    })

    for edge in incoming_other_level {
      if node_parent(disco_edge_target_node(edge)) ==
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

    let outgoing_same_level : Array[ElkEdge] = []
    let outgoing_other_level : Array[ElkEdge] = []
    for edge in disco_all_outgoing_edges(node) {
      if node_parent(disco_edge_source_node(edge)) ==
        node_parent(disco_edge_target_node(edge)) {
        outgoing_same_level.push(edge)
      } else {
        outgoing_other_level.push(edge)
      }
    }
    disco_add_nodes_to_incidence_set(adjacent_nodes, outgoing_same_level, edge => {
      disco_edge_target_node(edge)
    })

    for edge in outgoing_other_level {
      if node_parent(disco_edge_source_node(edge)) ==
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
  graph : ElkNode,
) -> Array[Array[ElkNode]] {
  let visited : Map[ElkNode, Unit] = {}
  let incidence_map : Map[ElkNode, Map[ElkNode, Unit]] = {}
  let components : Array[Array[ElkNode]] = []
  let children = node_children(graph)
  disco_compute_incidences(children, incidence_map)
  for node in children {
    if !visited.contains(node) {
      let component : Array[ElkNode] = []
      components.push(component)
      disco_dfs(node, component, visited, incidence_map)
    }
  }
  components
}
