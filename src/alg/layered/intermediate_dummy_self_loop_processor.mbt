///|
fn dummy_self_loop_processor_reverse_edge(edge : LEdge) -> Unit {
  let old_source = edge.get_source()
  let old_target = edge.get_target()
  edge.set_source(None)
  edge.set_target(None)
  edge.set_source(old_target)
  edge.set_target(old_source)
  edge.set_property_bool(
    internal_properties_reversed,
    !edge.get_property_bool(internal_properties_reversed),
  )
}

///|
fn dummy_self_loop_processor_is_side_east(side : @core.PortSide) -> Bool {
  match side {
    East => true
    _ => false
  }
}

///|
fn dummy_self_loop_processor_is_side_west(side : @core.PortSide) -> Bool {
  match side {
    West => true
    _ => false
  }
}

///|
fn dummy_self_loop_processor_is_side_north_or_south(
  side : @core.PortSide,
) -> Bool {
  match side {
    North => true
    South => true
    _ => false
  }
}

///|
fn dummy_self_loop_processor_is_side_north(side : @core.PortSide) -> Bool {
  match side {
    North => true
    _ => false
  }
}

///|
fn dummy_self_loop_processor_is_side_south(side : @core.PortSide) -> Bool {
  match side {
    South => true
    _ => false
  }
}

///|
fn dummy_self_loop_processor_require_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(port) => port
    None => abort("edge has no source port")
  }
}

///|
fn dummy_self_loop_processor_require_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(port) => port
    None => abort("edge has no target port")
  }
}

///|
fn dummy_self_loop_processor_require_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(node) => node
    None => abort("port has no owner node")
  }
}

///|
fn dummy_self_loop_processor_create_dummy(
  layered_graph : LGraph,
  edge : LEdge,
  source_port : LPort,
  target_port : LPort,
) -> LNode {
  let dummy_node = new_l_node(graph=Some(layered_graph))
  dummy_node.set_type(NodeType::LongEdge)
  dummy_node.set_property_l_edge(internal_properties_origin_l_edge, Some(edge))
  dummy_node.set_property_string(@core.port_constraints, "FIXED_POS")
  dummy_node.set_property_l_port(
    internal_properties_long_edge_source,
    Some(source_port),
  )
  dummy_node.set_property_l_port(
    internal_properties_long_edge_target,
    Some(target_port),
  )

  let dummy_input = new_l_port()
  dummy_input.set_side(West)
  dummy_input.set_node(Some(dummy_node))

  let dummy_output = new_l_port()
  dummy_output.set_side(East)
  dummy_output.set_node(Some(dummy_node))

  edge.set_target(Some(dummy_input))

  let dummy_edge = new_l_edge()
  dummy_edge.copy_properties(edge)
  dummy_edge.set_property_kvector_chain(
    layered_options_junction_points,
    @core.new_kvector_chain(),
  )
  dummy_edge.set_source(Some(dummy_output))
  dummy_edge.set_target(Some(target_port))

  dummy_node
}

///|
fn dummy_self_loop_processor_process(
  layered_graph : LGraph,
  monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let progress = match monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(progress.begin("Self-loop processing", 1.0))

  let created_dummies = []

  for layer in layered_graph.get_layers() {
    created_dummies.clear()

    for node in layer.get_nodes() {
      for port in node.get_ports() {
        let edges = port.get_outgoing_edges().copy()

        for edge in edges {
          let source_port = dummy_self_loop_processor_require_source(edge)
          let target_port = dummy_self_loop_processor_require_target(edge)

          if dummy_self_loop_processor_require_node(source_port).get_handle() !=
            dummy_self_loop_processor_require_node(target_port).get_handle() {
            continue
          }

          let source_port_side = source_port.get_side()
          let target_port_side = target_port.get_side()

          if dummy_self_loop_processor_is_side_north_or_south(source_port_side) &&
            dummy_self_loop_processor_is_side_west(target_port_side) {
            dummy_self_loop_processor_reverse_edge(edge)
          } else if dummy_self_loop_processor_is_side_south(source_port_side) &&
            dummy_self_loop_processor_is_side_north(target_port_side) {
            dummy_self_loop_processor_reverse_edge(edge)
          } else if dummy_self_loop_processor_is_side_east(source_port_side) &&
            !dummy_self_loop_processor_is_side_east(target_port_side) {
            dummy_self_loop_processor_reverse_edge(edge)
          }

          if dummy_self_loop_processor_is_side_east(source_port_side) &&
            dummy_self_loop_processor_is_side_west(target_port_side) {
            created_dummies.push(
              dummy_self_loop_processor_create_dummy(
                layered_graph, edge, target_port, source_port,
              ),
            )
          } else if dummy_self_loop_processor_is_side_west(source_port_side) &&
            dummy_self_loop_processor_is_side_east(target_port_side) {
            created_dummies.push(
              dummy_self_loop_processor_create_dummy(
                layered_graph, edge, source_port, target_port,
              ),
            )
          }
        }
      }
    }

    for dummy in created_dummies {
      dummy.set_layer(Some(layer))
    }
  }

  progress.done()
}

///|
pub fn new_dummy_self_loop_processor_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(dummy_self_loop_processor_process)
}
