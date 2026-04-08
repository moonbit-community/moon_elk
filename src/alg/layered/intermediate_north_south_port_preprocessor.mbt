///|
let north_south_port_preprocessor_use_new_approach : Bool = true

///|
priv suberror NorthSouthPortPreprocessorException {
  NorthSouthPortPreprocessorException(String)
} derive(Debug, ToJson)

///|
fn[T] north_south_port_preprocessor_raise(
  message : String,
) -> T raise NorthSouthPortPreprocessorException {
  raise NorthSouthPortPreprocessorException(message)
}

///|
fn north_south_port_preprocessor_parse_port_constraints(
  value : String,
) -> @core.PortConstraints {
  match value {
    "UNDEFINED" => @core.PortConstraints::Undefined
    "FREE" => @core.PortConstraints::Free
    "FIXED_SIDE" => @core.PortConstraints::FixedSide
    "FIXED_ORDER" => @core.PortConstraints::FixedOrder
    "FIXED_RATIO" => @core.PortConstraints::FixedRatio
    "FIXED_POS" => @core.PortConstraints::FixedPos
    _ => @core.PortConstraints::Undefined
  }
}

///|
fn north_south_port_preprocessor_parse_ordering_strategy(
  value : String,
) -> OrderingStrategy {
  match value {
    "NODES_AND_EDGES" => OrderingStrategy::NodesAndEdges
    "PREFER_EDGES" => OrderingStrategy::PreferEdges
    "PREFER_NODES" => OrderingStrategy::PreferNodes
    _ => OrderingStrategy::NoneType
  }
}

///|
fn north_south_port_preprocessor_ordering_strategy_is_none(
  strategy : OrderingStrategy,
) -> Bool {
  match strategy {
    OrderingStrategy::NoneType => true
    _ => false
  }
}

///|
fn north_south_port_preprocessor_port_side_is_north(
  side : @core.PortSide,
) -> Bool {
  match side {
    @core.PortSide::North => true
    _ => false
  }
}

///|
fn north_south_port_preprocessor_port_side_is_south(
  side : @core.PortSide,
) -> Bool {
  match side {
    @core.PortSide::South => true
    _ => false
  }
}

///|
fn north_south_port_preprocessor_port_side_equals(
  left : @core.PortSide,
  right : @core.PortSide,
) -> Bool {
  match (left, right) {
    (@core.PortSide::North, @core.PortSide::North) => true
    (@core.PortSide::East, @core.PortSide::East) => true
    (@core.PortSide::South, @core.PortSide::South) => true
    (@core.PortSide::West, @core.PortSide::West) => true
    (@core.PortSide::SideUndefined, @core.PortSide::SideUndefined) => true
    _ => false
  }
}

///|
fn north_south_port_preprocessor_port_side_rank(side : @core.PortSide) -> Int {
  match side {
    @core.PortSide::SideUndefined => 0
    @core.PortSide::North => 1
    @core.PortSide::East => 2
    @core.PortSide::South => 3
    @core.PortSide::West => 4
  }
}

///|
fn north_south_port_preprocessor_lnode_equals(
  left : LNode,
  right : LNode,
) -> Bool {
  left.get_handle() == right.get_handle()
}

///|
fn north_south_port_preprocessor_lport_equals(
  left : LPort,
  right : LPort,
) -> Bool {
  left.get_handle() == right.get_handle()
}

///|
fn north_south_port_preprocessor_require_source(
  edge : LEdge,
) -> LPort raise NorthSouthPortPreprocessorException {
  match edge.get_source() {
    Some(value) => value
    None => north_south_port_preprocessor_raise("edge has no source")
  }
}

///|
fn north_south_port_preprocessor_require_target(
  edge : LEdge,
) -> LPort raise NorthSouthPortPreprocessorException {
  match edge.get_target() {
    Some(value) => value
    None => north_south_port_preprocessor_raise("edge has no target")
  }
}

///|
fn north_south_port_preprocessor_require_node(
  port : LPort,
) -> LNode raise NorthSouthPortPreprocessorException {
  match port.get_node() {
    Some(value) => value
    None => north_south_port_preprocessor_raise("port has no owner node")
  }
}

///|
fn north_south_port_preprocessor_require_origin_port(
  port : LPort,
) -> LPort raise NorthSouthPortPreprocessorException {
  match port.get_property_l_port(internal_properties_origin_l_port) {
    Some(value) => value
    None => north_south_port_preprocessor_raise("dummy port has no origin port")
  }
}

///|
fn north_south_port_preprocessor_add_successor(
  node : LNode,
  successor : LNode,
) -> Unit {
  let successors = node.get_property_l_node_array(
    internal_properties_in_layer_successor_constraints,
  )
  successors.push(successor)
  node.set_property_l_node_array(
    internal_properties_in_layer_successor_constraints, successors,
  )
}

///|
fn north_south_port_preprocessor_insert_node_at(
  layer : Layer,
  node : LNode,
  index : Int,
) -> Unit {
  node.set_layer(Some(layer))

  let nodes = layer.get_nodes()
  let mut existing_index = -1
  for i in 0..<nodes.length() {
    if nodes[i].get_handle() == node.get_handle() {
      existing_index = i
      break
    }
  }
  if existing_index < 0 {
    return
  }

  let inserted = nodes.remove(existing_index)
  let clamped_index = if index < 0 {
    0
  } else if index > nodes.length() {
    nodes.length()
  } else {
    index
  }
  nodes.insert(clamped_index, inserted)
}

///|
fn north_south_port_preprocessor_compare_ports_for_sorting(
  port1 : LPort,
  port2 : LPort,
) -> Int {
  let side1 = port1.get_side()
  let side2 = port2.get_side()
  let side_diff = north_south_port_preprocessor_port_side_rank(side1) -
    north_south_port_preprocessor_port_side_rank(side2)
  if side_diff != 0 {
    return side_diff
  }

  if port1.get_id() == port2.get_id() {
    return 0
  }

  if north_south_port_preprocessor_port_side_is_north(side1) {
    port1.get_id() - port2.get_id()
  } else {
    port2.get_id() - port1.get_id()
  }
}

///|
fn north_south_port_preprocessor_sort_port_list(node : LNode) -> Unit {
  let ports = node.get_ports()
  let ports_count = ports.length()

  let mut in_ports = 0
  let mut in_out_ports = ports_count
  let mut out_ports = 2 * ports_count

  for port in ports {
    match port.get_side() {
      @core.PortSide::East => port.set_id(-1)
      @core.PortSide::West => port.set_id(-1)
      @core.PortSide::North | @core.PortSide::South => {
        let incoming = port.get_incoming_edges().length()
        let outgoing = port.get_outgoing_edges().length()
        if incoming > 0 && outgoing > 0 {
          port.set_id(in_out_ports)
          in_out_ports = in_out_ports + 1
        } else if incoming > 0 {
          port.set_id(in_ports)
          in_ports = in_ports + 1
        } else if outgoing > 0 {
          port.set_id(out_ports)
          out_ports = out_ports + 1
        } else {
          port.set_id(in_ports)
          in_ports = in_ports + 1
        }
      }
      @core.PortSide::SideUndefined => ()
    }
  }

  let mut i = 1
  while i < ports.length() {
    let current = ports[i]
    let mut j = i
    while j > 0 &&
          north_south_port_preprocessor_compare_ports_for_sorting(
            ports[j - 1],
            current,
          ) >
          0 {
      ports[j] = ports[j - 1]
      j = j - 1
    }
    ports[j] = current
    i = i + 1
  }
}

///|
fn north_south_port_preprocessor_reverse_ports(
  ports : Array[LPort],
) -> Array[LPort] {
  let result : Array[LPort] = []
  let mut index = ports.length() - 1
  while index >= 0 {
    result.push(ports[index])
    index = index - 1
  }
  result
}

///|
fn north_south_port_preprocessor_model_order_north_south_input_reversing(
  port_list : Array[LPort],
) -> Array[LPort] {
  let incoming : Array[LPort] = []
  let outgoing : Array[LPort] = []
  for port in port_list {
    if !port.get_incoming_edges().is_empty() {
      incoming.push(port)
    } else {
      outgoing.push(port)
    }
  }

  let reversed_incoming = north_south_port_preprocessor_reverse_ports(incoming)
  for port in outgoing {
    reversed_incoming.push(port)
  }
  reversed_incoming
}

///|
fn north_south_port_preprocessor_find_port_index(
  ports : Array[LPort],
  target : LPort,
) -> Int {
  for i in 0..<ports.length() {
    if north_south_port_preprocessor_lport_equals(ports[i], target) {
      return i
    }
  }
  -1
}

///|
fn north_south_port_preprocessor_create_dummy_node(
  layered_graph : LGraph,
  in_port : LPort?,
  out_port : LPort?,
  dummy_nodes : Array[LNode],
) -> LNode raise NorthSouthPortPreprocessorException {
  let dummy = new_l_node(graph=Some(layered_graph))
  dummy.set_type(NodeType::NorthSouthPort)
  dummy.set_property_string(@core.port_constraints, "FIXED_POS")

  let mut crossing_hint = 0

  match in_port {
    Some(value) => {
      let dummy_input_port = new_l_port()
      dummy_input_port.set_property_l_port(
        internal_properties_origin_l_port,
        Some(value),
      )
      dummy.set_property_l_node(
        internal_properties_origin_l_node,
        Some(north_south_port_preprocessor_require_node(value)),
      )
      dummy_input_port.set_side(@core.PortSide::West)
      dummy_input_port.set_node(Some(dummy))

      for edge in value.get_incoming_edges().copy() {
        edge.set_target(Some(dummy_input_port))
      }

      value.set_property_l_node(internal_properties_port_dummy, Some(dummy))
      crossing_hint = crossing_hint + 1
    }
    None => ()
  }

  match out_port {
    Some(value) => {
      let dummy_output_port = new_l_port()
      dummy.set_property_l_node(
        internal_properties_origin_l_node,
        Some(north_south_port_preprocessor_require_node(value)),
      )
      dummy_output_port.set_property_l_port(
        internal_properties_origin_l_port,
        Some(value),
      )
      dummy_output_port.set_side(@core.PortSide::East)
      dummy_output_port.set_node(Some(dummy))

      for edge in value.get_outgoing_edges().copy() {
        edge.set_source(Some(dummy_output_port))
      }

      value.set_property_l_node(internal_properties_port_dummy, Some(dummy))
      crossing_hint = crossing_hint + 1
    }
    None => ()
  }

  dummy.set_property_int(internal_properties_crossing_hint, crossing_hint)
  dummy_nodes.push(dummy)
  dummy
}

///|
fn north_south_port_preprocessor_create_same_side_self_loop_dummy_node(
  layered_graph : LGraph,
  self_loop : LEdge,
  dummy_nodes : Array[LNode],
) -> Unit raise NorthSouthPortPreprocessorException {
  let dummy = new_l_node(graph=Some(layered_graph))
  dummy.set_type(NodeType::NorthSouthPort)
  dummy.set_property_string(@core.port_constraints, "FIXED_POS")
  dummy.set_property_l_edge(internal_properties_origin_l_edge, Some(self_loop))

  let dummy_input_port = new_l_port()
  dummy_input_port.set_property_l_port(
    internal_properties_origin_l_port,
    Some(north_south_port_preprocessor_require_target(self_loop)),
  )
  dummy_input_port.set_side(@core.PortSide::West)
  dummy_input_port.set_node(Some(dummy))

  let dummy_output_port = new_l_port()
  dummy_output_port.set_property_l_port(
    internal_properties_origin_l_port,
    Some(north_south_port_preprocessor_require_source(self_loop)),
  )
  dummy_output_port.set_side(@core.PortSide::East)
  dummy_output_port.set_node(Some(dummy))

  north_south_port_preprocessor_require_source(self_loop).set_property_l_node(
    internal_properties_port_dummy,
    Some(dummy),
  )
  north_south_port_preprocessor_require_target(self_loop).set_property_l_node(
    internal_properties_port_dummy,
    Some(dummy),
  )

  self_loop.set_source(None)
  self_loop.set_target(None)

  dummy_nodes.push(dummy)
  dummy.set_property_int(internal_properties_crossing_hint, 2)
}

///|
fn north_south_port_preprocessor_create_north_south_self_loop_dummy_nodes(
  layered_graph : LGraph,
  self_loop : LEdge,
  north_dummy_nodes : Array[LNode],
  south_dummy_nodes : Array[LNode]?,
  port_side : @core.PortSide,
) -> Unit raise NorthSouthPortPreprocessorException {
  let source_port = north_south_port_preprocessor_require_source(self_loop)
  let target_port = north_south_port_preprocessor_require_target(self_loop)

  let north_dummy = new_l_node(graph=Some(layered_graph))
  north_dummy.set_type(NodeType::NorthSouthPort)
  north_dummy.set_property_string(@core.port_constraints, "FIXED_POS")
  north_dummy.set_property_l_node(
    internal_properties_origin_l_node,
    Some(north_south_port_preprocessor_require_node(source_port)),
  )

  let north_dummy_output_port = new_l_port()
  north_dummy_output_port.set_property_l_port(
    internal_properties_origin_l_port,
    Some(source_port),
  )
  north_dummy_output_port.set_side(port_side)
  north_dummy_output_port.set_node(Some(north_dummy))

  source_port.set_property_l_node(
    internal_properties_port_dummy,
    Some(north_dummy),
  )

  let south_dummy = new_l_node(graph=Some(layered_graph))
  south_dummy.set_type(NodeType::NorthSouthPort)
  south_dummy.set_property_string(@core.port_constraints, "FIXED_POS")
  south_dummy.set_property_l_node(
    internal_properties_origin_l_node,
    Some(north_south_port_preprocessor_require_node(target_port)),
  )

  let south_dummy_input_port = new_l_port()
  south_dummy_input_port.set_property_l_port(
    internal_properties_origin_l_port,
    Some(target_port),
  )
  south_dummy_input_port.set_side(port_side)
  south_dummy_input_port.set_node(Some(south_dummy))

  target_port.set_property_l_node(
    internal_properties_port_dummy,
    Some(south_dummy),
  )

  self_loop.set_source(Some(north_dummy_output_port))
  self_loop.set_target(Some(south_dummy_input_port))

  north_dummy_nodes.insert(0, north_dummy)
  match south_dummy_nodes {
    Some(value) => value.push(south_dummy)
    None =>
      north_south_port_preprocessor_raise("missing opposing side dummy list")
  }

  north_dummy.set_property_int(internal_properties_crossing_hint, 1)
  south_dummy.set_property_int(internal_properties_crossing_hint, 1)
}

///|
fn north_south_port_preprocessor_create_dummy_nodes(
  layered_graph : LGraph,
  ports : Array[LPort],
  dummy_nodes : Array[LNode],
  opposing_side_dummy_nodes : Array[LNode]?,
  barycenter_associates : Array[LNode],
) -> Unit raise NorthSouthPortPreprocessorException {
  let in_ports : Array[LPort] = []
  let out_ports : Array[LPort] = []
  let in_out_ports : Array[LPort] = []
  let same_side_self_loop_edges : Array[LEdge] = []
  let north_south_self_loop_edges : Array[LEdge] = []

  for port in ports {
    for edge in port.get_outgoing_edges().copy() {
      let source = match edge.get_source() {
        Some(value) => value
        None => continue
      }
      let target = match edge.get_target() {
        Some(value) => value
        None => continue
      }
      let source_node = match source.get_node() {
        Some(value) => value
        None => continue
      }
      let target_node = match target.get_node() {
        Some(value) => value
        None => continue
      }

      if !north_south_port_preprocessor_lnode_equals(source_node, target_node) {
        continue
      }

      if north_south_port_preprocessor_port_side_equals(
          port.get_side(),
          target.get_side(),
        ) {
        same_side_self_loop_edges.push(edge)
        continue
      }

      if north_south_port_preprocessor_port_side_is_north(port.get_side()) &&
        north_south_port_preprocessor_port_side_is_south(target.get_side()) {
        north_south_self_loop_edges.push(edge)
      }
    }
  }

  for edge in north_south_self_loop_edges {
    north_south_port_preprocessor_create_north_south_self_loop_dummy_nodes(
      layered_graph,
      edge,
      dummy_nodes,
      opposing_side_dummy_nodes,
      @core.PortSide::East,
    )
  }

  for edge in same_side_self_loop_edges {
    north_south_port_preprocessor_create_same_side_self_loop_dummy_node(
      layered_graph, edge, dummy_nodes,
    )
  }

  for port in ports {
    let has_incoming = !port.get_incoming_edges().is_empty()
    let has_outgoing = !port.get_outgoing_edges().is_empty()
    if has_incoming && has_outgoing {
      in_out_ports.push(port)
    } else if has_incoming {
      in_ports.push(port)
    } else if has_outgoing {
      out_ports.push(port)
    }
  }

  if north_south_port_preprocessor_use_new_approach {
    for in_port in in_ports {
      barycenter_associates.push(
        north_south_port_preprocessor_create_dummy_node(
          layered_graph,
          Some(in_port),
          None,
          dummy_nodes,
        ),
      )
    }
    for out_port in out_ports {
      barycenter_associates.push(
        north_south_port_preprocessor_create_dummy_node(
          layered_graph,
          None,
          Some(out_port),
          dummy_nodes,
        ),
      )
    }
  } else {
    let mut in_index = 0
    let mut out_index = out_ports.length() - 1
    while in_index < in_ports.length() && out_index >= 0 {
      let in_port = in_ports[in_index]
      let out_port = out_ports[out_index]
      if north_south_port_preprocessor_find_port_index(ports, out_port) <
        north_south_port_preprocessor_find_port_index(ports, in_port) {
        break
      }

      barycenter_associates.push(
        north_south_port_preprocessor_create_dummy_node(
          layered_graph,
          Some(in_port),
          Some(out_port),
          dummy_nodes,
        ),
      )
      in_index = in_index + 1
      out_index = out_index - 1
    }

    while in_index < in_ports.length() {
      barycenter_associates.push(
        north_south_port_preprocessor_create_dummy_node(
          layered_graph,
          Some(in_ports[in_index]),
          None,
          dummy_nodes,
        ),
      )
      in_index = in_index + 1
    }

    while out_index >= 0 {
      barycenter_associates.push(
        north_south_port_preprocessor_create_dummy_node(
          layered_graph,
          None,
          Some(out_ports[out_index]),
          dummy_nodes,
        ),
      )
      out_index = out_index - 1
    }
  }

  for in_out_port in in_out_ports {
    barycenter_associates.push(
      north_south_port_preprocessor_create_dummy_node(
        layered_graph,
        Some(in_out_port),
        Some(in_out_port),
        dummy_nodes,
      ),
    )
  }
}

///|
fn north_south_port_preprocessor_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Odd port side processing", 1.0))

  try {
    let north_dummy_nodes : Array[LNode] = []
    let south_dummy_nodes : Array[LNode] = []
    let ordering_strategy = north_south_port_preprocessor_parse_ordering_strategy(
      layered_graph.get_property_string(
        layered_options_consider_model_order_strategy,
      ),
    )

    for layer in layered_graph.get_layers() {
      let mut pointer = -1
      let node_array = layer.get_nodes().copy()
      for node in node_array {
        pointer = pointer + 1

        let is_regular = node.get_type() is NodeType::Normal
        let constraints = north_south_port_preprocessor_parse_port_constraints(
          node.get_property_string(@core.port_constraints),
        )
        if !(is_regular && constraints.is_side_fixed()) {
          continue
        }

        if !constraints.is_order_fixed() &&
          north_south_port_preprocessor_ordering_strategy_is_none(
            ordering_strategy,
          ) {
          north_south_port_preprocessor_sort_port_list(node)
        }

        node.set_property_l_node(
          internal_properties_in_layer_layout_unit,
          Some(node),
        )

        north_dummy_nodes.clear()
        south_dummy_nodes.clear()
        let barycenter_associates : Array[LNode] = []

        let mut north_ports = node.get_ports_by_side(@core.PortSide::North)
        if !north_south_port_preprocessor_ordering_strategy_is_none(
            ordering_strategy,
          ) {
          north_ports = north_south_port_preprocessor_model_order_north_south_input_reversing(
            north_ports,
          )
        }

        north_south_port_preprocessor_create_dummy_nodes(
          layered_graph,
          north_ports,
          north_dummy_nodes,
          Some(south_dummy_nodes),
          barycenter_associates,
        )

        let insert_point = pointer
        let mut successor = node
        for dummy in north_dummy_nodes {
          north_south_port_preprocessor_insert_node_at(
            layer, dummy, insert_point,
          )
          pointer = pointer + 1

          dummy.set_property_l_node(
            internal_properties_in_layer_layout_unit,
            Some(node),
          )

          let origin_port = north_south_port_preprocessor_require_origin_port(
            dummy.get_ports()[0],
          )
          if !origin_port.get_property_bool(
              layered_options_allow_non_flow_ports_to_switch_sides,
            ) {
            north_south_port_preprocessor_add_successor(dummy, successor)
          }

          if !north_south_port_preprocessor_use_new_approach {
            successor = dummy
          }
        }

        let south_ports : Array[LPort] = []
        for port in node.get_ports_by_side(@core.PortSide::South) {
          south_ports.insert(0, port)
        }
        let south_ports = if north_south_port_preprocessor_ordering_strategy_is_none(
            ordering_strategy,
          ) {
          south_ports
        } else {
          north_south_port_preprocessor_model_order_north_south_input_reversing(
            south_ports,
          )
        }

        north_south_port_preprocessor_create_dummy_nodes(
          layered_graph,
          south_ports,
          south_dummy_nodes,
          None,
          barycenter_associates,
        )

        let mut predecessor = node
        for dummy in south_dummy_nodes {
          pointer = pointer + 1
          north_south_port_preprocessor_insert_node_at(layer, dummy, pointer)

          dummy.set_property_l_node(
            internal_properties_in_layer_layout_unit,
            Some(node),
          )

          let origin_port = north_south_port_preprocessor_require_origin_port(
            dummy.get_ports()[0],
          )
          if !origin_port.get_property_bool(
              layered_options_allow_non_flow_ports_to_switch_sides,
            ) {
            north_south_port_preprocessor_add_successor(predecessor, dummy)
          }

          if !north_south_port_preprocessor_use_new_approach {
            predecessor = dummy
          }
        }

        if !barycenter_associates.is_empty() {
          node.set_property_l_node_array(
            internal_properties_barycenter_associates, barycenter_associates,
          )
        }
      }
    }
  } catch {
    NorthSouthPortPreprocessorException(message) =>
      @core.layout_runtime_report_unsupported_configuration(
        "java.lang.IllegalStateException: " + message,
      )
  } noraise {
    _ => ()
  }

  monitor.done()
}

///|
pub fn new_north_south_port_preprocessor_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(north_south_port_preprocessor_process)
}
