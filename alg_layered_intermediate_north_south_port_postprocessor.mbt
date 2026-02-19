///|
fn north_south_port_postprocessor_parse_edge_routing(
  value : String,
) -> EdgeRouting {
  for routing in edge_routing_values() {
    if edge_routing_to_string(routing) == value {
      return routing
    }
  }
  EdgeRouting::RoutingUndefined
}

///|
fn north_south_port_postprocessor_edge_routing_is_splines(
  routing : EdgeRouting,
) -> Bool {
  match routing {
    EdgeRouting::Splines => true
    _ => false
  }
}

///|
fn north_south_port_postprocessor_node_type_is_north_south_port(
  node_type : NodeType,
) -> Bool {
  match node_type {
    NodeType::NorthSouthPort => true
    _ => false
  }
}

///|
fn north_south_port_postprocessor_require_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(value) => value
    None => abort("port has no owner node")
  }
}

///|
fn north_south_port_postprocessor_require_origin_port(port : LPort) -> LPort {
  match port.get_property_l_port(internal_properties_origin_l_port) {
    Some(value) => value
    None => abort("port has no origin port")
  }
}

///|
fn north_south_port_postprocessor_require_origin_edge(node : LNode) -> LEdge {
  match node.get_property_l_edge(internal_properties_origin_l_edge) {
    Some(value) => value
    None => abort("dummy node has no origin edge")
  }
}

///|
fn north_south_port_postprocessor_lport_equals(
  left : LPort,
  right : LPort,
) -> Bool {
  lport_internal_handle(left) == lport_internal_handle(right)
}

///|
fn north_south_port_postprocessor_add_junction_point(
  edge : LEdge,
  x : Double,
  y : Double,
) -> Unit {
  if !edge.has_property_kvector_chain(layered_options_junction_points) {
    edge.set_property_kvector_chain(
      layered_options_junction_points,
      new_kvector_chain(),
    )
  }
  let junction_points = edge.get_property_kvector_chain(
    layered_options_junction_points,
  )
  junction_points.add_last_xy(x, y)
}

///|
fn north_south_port_postprocessor_process_input_port(
  input_port : LPort,
  add_junction_points : Bool,
) -> Unit {
  let origin_port = north_south_port_postprocessor_require_origin_port(
    input_port,
  )
  let x = origin_port.get_absolute_anchor().x
  let y = north_south_port_postprocessor_require_node(input_port).get_position().y

  for in_edge in input_port.get_incoming_edges().copy() {
    in_edge.set_target(Some(origin_port))
    in_edge.get_bend_points().add_last_xy(x, y)

    if add_junction_points {
      north_south_port_postprocessor_add_junction_point(in_edge, x, y)
    }
  }
}

///|
fn north_south_port_postprocessor_process_output_port(
  output_port : LPort,
  add_junction_points : Bool,
) -> Unit {
  let origin_port = north_south_port_postprocessor_require_origin_port(
    output_port,
  )
  let x = origin_port.get_absolute_anchor().x
  let y = north_south_port_postprocessor_require_node(output_port).get_position().y

  for out_edge in output_port.get_outgoing_edges().copy() {
    out_edge.set_source(Some(origin_port))
    out_edge.get_bend_points().add_first_xy(x, y)

    if add_junction_points {
      north_south_port_postprocessor_add_junction_point(out_edge, x, y)
    }
  }
}

///|
fn north_south_port_postprocessor_process_self_loop(dummy : LNode) -> Unit {
  let self_loop = north_south_port_postprocessor_require_origin_edge(dummy)

  let input_ports = dummy.get_ports_by_side(PortSide::West)
  let output_ports = dummy.get_ports_by_side(PortSide::East)
  if input_ports.is_empty() || output_ports.is_empty() {
    abort("self-loop dummy must have west and east ports")
  }

  let input_port = input_ports[0]
  let output_port = output_ports[0]

  let origin_input_port = north_south_port_postprocessor_require_origin_port(
    input_port,
  )
  let origin_output_port = north_south_port_postprocessor_require_origin_port(
    output_port,
  )

  self_loop.set_source(Some(origin_output_port))
  self_loop.set_target(Some(origin_input_port))

  let first_bend = north_south_port_postprocessor_require_node(output_port)
    .get_position()
    .clone()
  first_bend.x = origin_output_port.get_absolute_anchor().x
  self_loop.get_bend_points().add_last_vector(first_bend)

  let second_bend = north_south_port_postprocessor_require_node(input_port)
    .get_position()
    .clone()
  second_bend.x = origin_input_port.get_absolute_anchor().x
  self_loop.get_bend_points().add_last_vector(second_bend)
}

///|
fn north_south_port_postprocessor_process_spline_input_port(
  input_port : LPort,
) -> Unit {
  let origin_port = north_south_port_postprocessor_require_origin_port(
    input_port,
  )
  origin_port.set_property_double(
    internal_properties_spline_ns_port_y_coord,
    north_south_port_postprocessor_require_node(input_port).get_position().y,
  )

  for in_edge in input_port.get_incoming_edges().copy() {
    in_edge.set_target(Some(origin_port))
  }
}

///|
fn north_south_port_postprocessor_process_spline_output_port(
  output_port : LPort,
) -> Unit {
  let origin_port = north_south_port_postprocessor_require_origin_port(
    output_port,
  )
  origin_port.set_property_double(
    internal_properties_spline_ns_port_y_coord,
    north_south_port_postprocessor_require_node(output_port).get_position().y,
  )

  for out_edge in output_port.get_outgoing_edges().copy() {
    out_edge.set_source(Some(origin_port))
  }
}

///|
fn north_south_port_postprocessor_same_origin_port(dummy : LNode) -> Bool {
  let ports = dummy.get_ports()
  if ports.length() < 2 {
    return false
  }

  let mut index = 1
  let mut previous = north_south_port_postprocessor_require_origin_port(
    ports[0],
  )
  while index < ports.length() {
    let current = north_south_port_postprocessor_require_origin_port(
      ports[index],
    )
    if !north_south_port_postprocessor_lport_equals(previous, current) {
      return false
    }
    previous = current
    index = index + 1
  }
  true
}

///|
fn north_south_port_postprocessor_process(
  layered_graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Odd port side processing", 1.0))

  let routing = north_south_port_postprocessor_parse_edge_routing(
    layered_graph.get_property_string(edge_routing),
  )

  for layer in layered_graph.get_layers() {
    let node_array = layer.get_nodes().copy()
    for node in node_array {
      if !north_south_port_postprocessor_node_type_is_north_south_port(
          node.get_type(),
        ) {
        continue
      }

      if north_south_port_postprocessor_edge_routing_is_splines(routing) {
        for port in node.get_ports() {
          if !port.get_incoming_edges().is_empty() {
            north_south_port_postprocessor_process_spline_input_port(port)
          }
          if !port.get_outgoing_edges().is_empty() {
            north_south_port_postprocessor_process_spline_output_port(port)
          }
        }
      } else if node.has_property_l_edge(internal_properties_origin_l_edge) {
        north_south_port_postprocessor_process_self_loop(node)
      } else {
        let same_origin_port = north_south_port_postprocessor_same_origin_port(
          node,
        )
        for port in node.get_ports() {
          if !port.get_incoming_edges().is_empty() {
            north_south_port_postprocessor_process_input_port(
              port, same_origin_port,
            )
          }
          if !port.get_outgoing_edges().is_empty() {
            north_south_port_postprocessor_process_output_port(
              port, same_origin_port,
            )
          }
        }
      }

      node.set_layer(None)
    }
  }

  monitor.done()
}

///|
pub fn new_north_south_port_postprocessor_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(north_south_port_postprocessor_process)
}
