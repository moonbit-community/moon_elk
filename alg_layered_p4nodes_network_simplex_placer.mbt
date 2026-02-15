///|
let network_simplex_node_flexibility : IProperty[String] = new_property(
  "org.eclipse.elk.layered.nodePlacement.networkSimplex.nodeFlexibility", "NONE",
)

///|
let network_simplex_node_flexibility_default : IProperty[String] = new_property(
  "org.eclipse.elk.layered.nodePlacement.networkSimplex.nodeFlexibility.default",
  "NONE",
)

///|
fn network_simplex_node_flexibility_is_none(value : String) -> Bool {
  value == "NONE"
}

///|
fn network_simplex_node_flexibility_is_flexible_size_where_space_permits(
  value : String,
) -> Bool {
  match value {
    "NODE_SIZE_WHERE_SPACE_PERMITS" => true
    "NODE_SIZE" => true
    _ => false
  }
}

///|
fn network_simplex_port_constraints_is_pos_fixed(value : String) -> Bool {
  value == "FIXED_POS" || value == "FIXED_RATIO"
}

///|
fn network_simplex_node_flexibility_value(node : LNode) -> String {
  if node.has_property_string(network_simplex_node_flexibility) {
    return node.get_property_string(network_simplex_node_flexibility)
  }

  node.get_graph().get_property_string(network_simplex_node_flexibility_default)
}

///|
fn network_simplex_node_requires_more_height_for_flexible_ports(
  node : LNode,
) -> Bool {
  let port_spacing = layered_spacings_get_individual_or_default(
    node, spacing_port_port,
  )
  let graph = node.get_graph()
  let additional_port_spacing = if graph.has_property_elk_margin(
      layered_options_spacing_ports_surrounding,
    ) {
    graph.get_property_elk_margin(layered_options_spacing_ports_surrounding)
  } else {
    new_elk_margin_values(
      port_spacing, port_spacing, port_spacing, port_spacing,
    )
  }

  let west_ports = node.get_port_side_view(PortSide::West)
  let required_west_height = additional_port_spacing.top +
    additional_port_spacing.bottom +
    (west_ports.length() - 1).to_double() * port_spacing
  if required_west_height > node.get_size().y {
    return true
  }

  let east_ports = node.get_port_side_view(PortSide::East)
  let required_east_height = additional_port_spacing.top +
    additional_port_spacing.bottom +
    (east_ports.length() - 1).to_double() * port_spacing
  required_east_height > node.get_size().y
}

///|
fn network_simplex_node_type_is_normal(node_type : NodeType) -> Bool {
  match node_type {
    NodeType::Normal => true
    _ => false
  }
}

///|
fn network_simplex_node_is_flexible(node : LNode) -> Bool {
  if !network_simplex_node_type_is_normal(node.get_type()) {
    return false
  }

  if node.get_ports().length() <= 1 {
    return false
  }

  if network_simplex_port_constraints_is_pos_fixed(
      node.get_property_string(port_constraints),
    ) {
    return false
  }

  let node_flexibility = network_simplex_node_flexibility_value(node)
  if network_simplex_node_flexibility_is_none(node_flexibility) {
    return false
  }

  if !network_simplex_node_flexibility_is_flexible_size_where_space_permits(
      node_flexibility,
    ) &&
    network_simplex_node_requires_more_height_for_flexible_ports(node) {
    return false
  }

  true
}

///|
fn network_simplex_prepare(layered_graph : LGraph) -> Unit {
  let mut node_idx = 0
  let mut edge_idx = 0

  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      node.set_id(node_idx)
      node_idx += 1

      for edge in node.get_outgoing_edges() {
        edge.set_id(edge_idx)
        edge_idx += 1
      }

      let anchor_must_be_integer = network_simplex_node_is_flexible(node)
      for port in node.get_ports() {
        if anchor_must_be_integer {
          let anchor_y = port.get_anchor().y
          if anchor_y != anchor_y.floor() {
            let offset = anchor_y - anchor_y.round()
            port.get_anchor().y -= offset
          }
        }

        let absolute_port_y = port.get_position().y + port.get_anchor().y
        if absolute_port_y != absolute_port_y.floor() {
          let offset = absolute_port_y - absolute_port_y.round()
          port.get_position().y -= offset
        }
      }
    }
  }
}

///|
fn network_simplex_node_placer_process(
  layered_graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Network simplex node placement", 1.0))
  network_simplex_prepare(layered_graph)
  // Keep current behavior stable until the dedicated network-simplex core
  // is fully transliterated from elk-reference.
  new_bk_node_placer_layout_phase().process(layered_graph, None)
  monitor.done()
}

///|
pub fn new_network_simplex_placer_layout_phase() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_phase(network_simplex_node_placer_process, graph => {
    for
      property in graph.get_property_graph_properties_array(
        internal_properties_graph_properties,
      ) {
      match property {
        GraphProperties::ExternalPorts =>
          return Some(
            layout_processor_configuration_create(layered_phase_descriptor).add_before(
              LayeredPhases::P5EdgeRouting,
              layered_intermediate_processor_factory(
                IntermediateProcessorStrategy::HierarchicalPortPositionProcessor,
              ),
            ),
          )
        _ => ()
      }
    }
    None
  })
}
