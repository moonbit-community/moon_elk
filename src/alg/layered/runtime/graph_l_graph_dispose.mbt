///|
pub fn dispose_layered_graph(root : LGraph) -> Unit {
  let graphs = [root]
  let nodes : Array[LNode] = []
  let ports : Array[LPort] = []
  let edges : Array[LEdge] = []
  let labels : Array[LLabel] = []
  let seen_graphs : Map[Int, Unit] = Map([])
  let seen_nodes : Map[Int, Unit] = Map([])
  let seen_ports : Map[Int, Unit] = Map([])
  let seen_edges : Map[Int, Unit] = Map([])
  let mut graph_index = 0
  let mut node_index = 0
  let mut port_index = 0
  let mut edge_index = 0

  while graph_index < graphs.length() ||
        node_index < nodes.length() ||
        port_index < ports.length() ||
        edge_index < edges.length() {
    while graph_index < graphs.length() {
      let graph = graphs[graph_index]
      graph_index += 1
      if seen_graphs.contains(graph.get_handle()) {
        continue
      }
      seen_graphs[graph.get_handle()] = ()
      for node in graph.layerless_nodes {
        nodes.push(node)
      }
      for layer in graph.layers {
        for node in layer.nodes {
          nodes.push(node)
        }
      }
      if graph.parent_node is Some(parent_node) {
        nodes.push(parent_node)
      }
      for entry in layered_property_bag_entries(graph.node_array_properties) {
        let (_, property_nodes) = entry
        for node in property_nodes {
          nodes.push(node)
        }
      }
      for
        entry in layered_property_bag_entries(
          graph.cross_hierarchy_map_entry_array_properties,
        ) {
        let (_, entries) = entry
        for cross_hierarchy_entry in entries {
          let (first_edge, (second_edge, related_graph, _)) = cross_hierarchy_entry
          edges.push(first_edge)
          edges.push(second_edge)
          graphs.push(related_graph)
        }
      }
    }

    while node_index < nodes.length() {
      let node = nodes[node_index]
      node_index += 1
      if seen_nodes.contains(node.get_handle()) {
        continue
      }
      seen_nodes[node.get_handle()] = ()
      if node.graph is Some(graph) {
        graphs.push(graph)
      }
      if node.nested_graph is Some(graph) {
        graphs.push(graph)
      }
      for port in node.ports {
        ports.push(port)
      }
      for label in node.labels {
        labels.push(label)
      }
      for entry in layered_property_bag_entries(node.node_properties) {
        let (_, property_node) = entry
        nodes.push(property_node)
      }
      for entry in layered_property_bag_entries(node.node_array_properties) {
        let (_, property_nodes) = entry
        for property_node in property_nodes {
          nodes.push(property_node)
        }
      }
      for entry in layered_property_bag_entries(node.port_properties) {
        let (_, property_port) = entry
        ports.push(property_port)
      }
      for entry in layered_property_bag_entries(node.edge_properties) {
        let (_, property_edge) = entry
        edges.push(property_edge)
      }
    }

    while port_index < ports.length() {
      let port = ports[port_index]
      port_index += 1
      if seen_ports.contains(port.get_handle()) {
        continue
      }
      seen_ports[port.get_handle()] = ()
      if port.owner is Some(owner) {
        nodes.push(owner)
      }
      for edge in port.incoming_edges {
        edges.push(edge)
      }
      for edge in port.outgoing_edges {
        edges.push(edge)
      }
      for label in port.labels {
        labels.push(label)
      }
      for entry in layered_property_bag_entries(port.node_properties) {
        let (_, property_node) = entry
        nodes.push(property_node)
      }
      for entry in layered_property_bag_entries(port.port_properties) {
        let (_, property_port) = entry
        ports.push(property_port)
      }
    }

    while edge_index < edges.length() {
      let edge = edges[edge_index]
      edge_index += 1
      if seen_edges.contains(edge.get_handle()) {
        continue
      }
      seen_edges[edge.get_handle()] = ()
      if edge.source is Some(source) {
        ports.push(source)
      }
      if edge.target is Some(target) {
        ports.push(target)
      }
      for label in edge.labels {
        labels.push(label)
      }
      for entry in layered_property_bag_entries(edge.l_edge_array_properties) {
        let (_, property_edges) = entry
        for property_edge in property_edges {
          edges.push(property_edge)
        }
      }
      for entry in layered_property_bag_entries(edge.port_properties) {
        let (_, property_port) = entry
        ports.push(property_port)
      }
      for entry in layered_property_bag_entries(edge.edge_properties) {
        let (_, property_edge) = entry
        edges.push(property_edge)
      }
      for entry in layered_property_bag_entries(edge.l_graph_properties) {
        let (_, property_graph) = entry
        graphs.push(property_graph)
      }
    }
  }

  // Native reference counting cannot reclaim the normal graph-node-port-edge
  // ownership cycles. Detach endpoints and owners before clearing containers.
  for edge in edges {
    if seen_edges.contains(edge.get_handle()) {
      edge.set_source(None)
      edge.set_target(None)
      edge.labels.clear()
      edge.int_properties = None
      edge.double_properties = None
      edge.kvector_properties = None
      edge.kvector_chain_properties = None
      edge.bool_properties = None
      edge.l_edge_array_properties = None
      edge.spline_segment_array_properties = None
      edge.port_properties = None
      edge.edge_properties = None
      edge.l_graph_properties = None
      ignore(seen_edges.remove(edge.get_handle()))
    }
  }
  for port in ports {
    if seen_ports.contains(port.get_handle()) {
      port.set_node(None)
      port.labels.clear()
      port.incoming_edges.clear()
      port.outgoing_edges.clear()
      port.int_properties = None
      port.bool_properties = None
      port.double_properties = None
      port.node_properties = None
      port.port_properties = None
      ignore(seen_ports.remove(port.get_handle()))
    }
  }
  for node in nodes {
    if seen_nodes.contains(node.get_handle()) {
      node.set_layer(None)
      node.set_graph(None)
      node.set_nested_graph(None)
      node.ports.clear()
      node.labels.clear()
      node.int_properties = None
      node.bool_properties = None
      node.double_properties = None
      node.kvector_properties = None
      node.elk_margin_properties = None
      node.string_properties = None
      node.string_array_properties = None
      node.port_side_properties = None
      node.label_side_properties = None
      node.node_properties = None
      node.node_array_properties = None
      node.label_array_properties = None
      for
        entry in layered_property_bag_entries(
          node.end_label_cell_array_properties,
        ) {
        let (_, cells) = entry
        for cell in cells {
          cell.dispose()
        }
      }
      node.end_label_cell_array_properties = None
      node.int_int_map_properties = None
      node.port_properties = None
      node.edge_properties = None
      node.bp_info_properties = None
      node.self_loop_holder_properties = None
      node.port_side_indices.clear()
      ignore(seen_nodes.remove(node.get_handle()))
    }
  }
  for label in labels {
    label.bool_properties = None
    label.string_properties = None
    label.string_array_properties = None
    label.label_side_properties = None
    label.l_edge_properties = None
  }
  for graph in graphs {
    if seen_graphs.contains(graph.get_handle()) {
      graph.set_parent_node(None)
      graph.port_side_array_properties = None
      graph.graph_properties_array_properties = None
      graph.cross_hierarchy_map_entry_array_properties = None
      graph.node_array_properties = None
      graph.layout_state.clear()
      graph.int_properties = None
      graph.bool_properties = None
      graph.double_properties = None
      graph.string_properties = None
      graph.string_array_properties = None
      graph.label_manager_properties = None
      graph.spacings_properties = None
      graph.elk_margin_properties = None
      graph.component_ordering_strategy_properties = None
      graph.direction_properties = None
      graph.spline_routing_mode_properties = None
      graph.layerless_nodes.clear()
      graph.layers.clear()
      ignore(seen_graphs.remove(graph.get_handle()))
    }
  }
}
