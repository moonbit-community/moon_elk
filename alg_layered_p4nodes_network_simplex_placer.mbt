///|
let network_simplex_node_flexibility : IProperty[String] = new_property(
  "org.eclipse.elk.layered.nodePlacement.networkSimplex.nodeFlexibility", "NONE",
)

///|
fn network_simplex_node_flexibility_is_flexible(value : String) -> Bool {
  match value {
    "PORT_POSITION" => true
    "NODE_SIZE_WHERE_SPACE_PERMITS" => true
    "NODE_SIZE" => true
    _ => false
  }
}

///|
fn network_simplex_port_constraints_allows_flexible(value : String) -> Bool {
  value != "FIXED_POS" && value != "FIXED_RATIO"
}

///|
fn network_simplex_node_is_flexible(node : LNode) -> Bool {
  if !network_simplex_port_constraints_allows_flexible(
      node.get_property_string(port_constraints),
    ) {
    return false
  }

  network_simplex_node_flexibility_is_flexible(
    node.get_property_string(network_simplex_node_flexibility),
  )
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
