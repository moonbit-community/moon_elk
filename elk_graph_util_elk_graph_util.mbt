///|
fn shape_to_node_or_panic(connectable_shape : ElkConnectableShape) -> ElkNode {
  match connectable_shape {
    NodeShape(node) => node
    PortShape(port) =>
      match port_parent(port) {
        Some(node) => node
        None => abort("port parent cannot be null")
      }
  }
}

///|
pub fn connectable_shape_to_node(
  connectable_shape : ElkConnectableShape?,
) -> ElkNode {
  match connectable_shape {
    Some(shape) => shape_to_node_or_panic(shape)
    None => abort("connectableShape cannot be null")
  }
}

///|
pub fn connectable_shape_to_port(
  connectable_shape : ElkConnectableShape?,
) -> ElkPort? {
  match connectable_shape {
    Some(NodeShape(_)) => None
    Some(PortShape(port)) => Some(port)
    None => abort("connectableShape cannot be null")
  }
}

///|
pub fn all_incoming_edges(node : ElkNode) -> Array[ElkEdge] {
  let incoming = node_incoming_edges(node)
  for port in node_ports(node) {
    for edge in port_incoming_edges(port) {
      incoming.push(edge)
    }
  }
  incoming
}

///|
pub fn all_outgoing_edges(node : ElkNode) -> Array[ElkEdge] {
  let outgoing = node_outgoing_edges(node)
  for port in node_ports(node) {
    for edge in port_outgoing_edges(port) {
      outgoing.push(edge)
    }
  }
  outgoing
}

///|
pub fn all_incident_edges_for_shape(
  shape : ElkConnectableShape,
) -> Array[ElkEdge] {
  let incident = []
  match shape {
    NodeShape(node) => {
      for edge in node_incoming_edges(node) {
        incident.push(edge)
      }
      for edge in node_outgoing_edges(node) {
        incident.push(edge)
      }
    }
    PortShape(port) => {
      for edge in port_incoming_edges(port) {
        incident.push(edge)
      }
      for edge in port_outgoing_edges(port) {
        incident.push(edge)
      }
    }
  }
  incident
}

///|
pub fn all_incident_edges(node : ElkNode) -> Array[ElkEdge] {
  let incident = all_outgoing_edges(node)
  for edge in all_incoming_edges(node) {
    incident.push(edge)
  }
  incident
}

///|
pub fn all_incident_shapes(edge : ElkEdge) -> Array[ElkConnectableShape] {
  let all = []
  for source in edge_sources(edge) {
    all.push(source)
  }
  for target in edge_targets(edge) {
    all.push(target)
  }
  all
}

///|
pub fn all_incident_sections(section : ElkEdgeSection) -> Array[ElkEdgeSection] {
  let all = edge_section_incoming_sections(section)
  for outgoing_section in edge_section_outgoing_sections(section) {
    all.push(outgoing_section)
  }
  all
}

///|
pub fn is_descendant(child : ElkNode, ancestor : ElkNode) -> Bool {
  let mut current = child
  while node_parent(current) is Some(parent) {
    if parent == ancestor {
      return true
    }
    current = parent
  }
  false
}

///|
fn node_ancestors(node : ElkNode) -> Array[ElkNode] {
  let ancestors = []
  let mut current : ElkNode? = Some(node)
  while current is Some(value) {
    ancestors.push(value)
    current = node_parent(value)
  }
  ancestors
}

///|
pub fn find_lowest_common_ancestor(
  node1 : ElkNode,
  node2 : ElkNode,
) -> ElkNode? {
  let ancestors1 = node_ancestors(node1)
  let ancestors2 = node_ancestors(node2)
  let mut i = ancestors1.length() - 1
  let mut j = ancestors2.length() - 1
  let mut common_ancestor : ElkNode? = None
  while i >= 0 && j >= 0 {
    let a1 = ancestors1[i]
    let a2 = ancestors2[j]
    if a1 == a2 {
      common_ancestor = Some(a1)
    } else {
      break
    }
    i = i - 1
    j = j - 1
  }
  common_ancestor
}

///|
pub fn find_best_edge_containment(edge : ElkEdge?) -> ElkNode? {
  let edge = match edge {
    Some(edge) => edge
    None => abort("edge cannot be null")
  }
  let sources = edge_sources(edge)
  let targets = edge_targets(edge)
  let total = sources.length() + targets.length()
  if total == 0 {
    abort("The edge must have at least one source or target.")
  }
  if total == 1 {
    if sources.is_empty() {
      return node_parent(connectable_shape_to_node(Some(targets[0])))
    }
    return node_parent(connectable_shape_to_node(Some(sources[0])))
  }
  if sources.length() == 1 && targets.length() == 1 {
    let source_node = connectable_shape_to_node(Some(sources[0]))
    let target_node = connectable_shape_to_node(Some(targets[0]))
    if node_parent(source_node) == node_parent(target_node) {
      return node_parent(source_node)
    }
    if node_parent(target_node) == Some(source_node) {
      return Some(source_node)
    }
    if node_parent(source_node) == Some(target_node) {
      return Some(target_node)
    }
  }
  let incident_shapes = all_incident_shapes(edge)
  let mut common_ancestor : ElkNode? = Some(
    shape_to_node_or_panic(incident_shapes[0]),
  )
  for i = 1; i < incident_shapes.length(); i = i + 1 {
    let incident_node = shape_to_node_or_panic(incident_shapes[i])
    match common_ancestor {
      Some(ancestor) =>
        if incident_node != ancestor && !is_descendant(incident_node, ancestor) {
          if node_parent(incident_node) == node_parent(ancestor) {
            common_ancestor = node_parent(incident_node)
          } else {
            common_ancestor = find_lowest_common_ancestor(
              ancestor, incident_node,
            )
            if common_ancestor is None {
              return None
            }
          }
        }
      None => return None
    }
  }
  common_ancestor
}

///|
pub fn update_containment(edge : ElkEdge?) -> Unit {
  let edge = match edge {
    Some(edge) => edge
    None => abort("edge cannot be null")
  }
  edge_set_containing_node(edge, find_best_edge_containment(Some(edge)))
}

///|
pub fn create_simple_edge(source : ElkNode, target : ElkNode) -> ElkEdge {
  let edge = create_edge(None)
  edge_add_source(edge, make_node_shape(source))
  edge_add_target(edge, make_node_shape(target))
  update_containment(Some(edge))
  edge
}

///|
pub fn create_hyperedge(
  sources : Array[ElkConnectableShape],
  targets : Array[ElkConnectableShape],
) -> ElkEdge {
  let edge = create_edge(None)
  for source in sources {
    edge_add_source(edge, source)
  }
  for target in targets {
    edge_add_target(edge, target)
  }
  update_containment(Some(edge))
  edge
}

///|
pub fn create_label_with_text(
  text : String,
  parent : ElkLabelParent?,
) -> ElkLabel {
  let label = create_label(parent)
  label_set_text(label, text)
  label
}

///|
pub fn properties_skipping_nodes(
  graph : ElkNode,
  include_root? : Bool = true,
) -> Array[ElkNode] {
  let nodes = node_all_descendants_including_self(graph)
  if include_root {
    nodes
  } else {
    let filtered = []
    for node in nodes {
      if node != graph {
        filtered.push(node)
      }
    }
    filtered
  }
}
