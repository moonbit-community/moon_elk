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
let network_simplex_priority_straightness : IProperty[Int] = new_property(
  "priority.straightness", 0,
)

///|
let network_simplex_edge_weight_base : Double = 4.0

///|
let network_simplex_small_edge_weight : Double = 0.1

///|
let network_simplex_node_size_weight_static : Double = 10000.0

///|
let network_simplex_node_size_weight_flexible : Double = 1.0

///|
let network_simplex_offset_integral_epsilon : Double = 0.00001

///|
priv struct NetworkSimplexNodeRep {
  origin : LNode
  is_flexible : Bool
  head : NNode
  tail : NNode
}

///|
priv struct NetworkSimplexEdgeRep {
  origin : LEdge
  left : NEdge
  right : NEdge
}

///|
priv struct NetworkSimplexAuxiliaryState {
  n_graph : NGraph
  spacings : Spacings
  node_reps : Array[NetworkSimplexNodeRep?]
  edge_reps : Array[NetworkSimplexEdgeRep?]
  port_map : Map[Int, NNode]
  flexible_where_space_permits_edges : Array[NEdge]
}

///|
fn network_simplex_int_max(left : Int, right : Int) -> Int {
  if left >= right {
    left
  } else {
    right
  }
}

///|
fn network_simplex_double_abs(value : Double) -> Double {
  if value < 0.0 {
    -value
  } else {
    value
  }
}

///|
fn network_simplex_double_max(left : Double, right : Double) -> Double {
  if left >= right {
    left
  } else {
    right
  }
}

///|
fn network_simplex_port_offset_delta_is_integral(value : Double) -> Bool {
  network_simplex_double_abs(value - value.round()) <=
  network_simplex_offset_integral_epsilon
}

///|
fn network_simplex_node_flexibility_is_none(value : String) -> Bool {
  value == "NONE"
}

///|
fn network_simplex_node_flexibility_is_flexible_size(value : String) -> Bool {
  value == "NODE_SIZE"
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
fn network_simplex_port_side_is_east_west(port_side : PortSide) -> Bool {
  match port_side {
    PortSide::East => true
    PortSide::West => true
    _ => false
  }
}

///|
fn network_simplex_require_port_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(value) => value
    None => abort("port has no owner node")
  }
}

///|
fn network_simplex_require_edge_source_port(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source port")
  }
}

///|
fn network_simplex_require_edge_target_port(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target port")
  }
}

///|
fn network_simplex_require_node_rep(
  state : NetworkSimplexAuxiliaryState,
  node : LNode,
) -> NetworkSimplexNodeRep {
  match state.node_reps[node.get_id()] {
    Some(rep) => rep
    None => abort("missing network simplex node representation")
  }
}

///|
fn network_simplex_require_port_rep(
  state : NetworkSimplexAuxiliaryState,
  port : LPort,
) -> NNode {
  match state.port_map.get(port.get_handle()) {
    Some(rep) => rep
    None => abort("missing network simplex port representation")
  }
}

///|
fn network_simplex_reverse_ports(ports : Array[LPort]) -> Array[LPort] {
  let reversed : Array[LPort] = []
  let mut idx = ports.length()
  while idx > 0 {
    idx -= 1
    reversed.push(ports[idx])
  }
  reversed
}

///|
fn network_simplex_new_auxiliary_state(
  layered_graph : LGraph,
  node_count : Int,
  edge_count : Int,
) -> NetworkSimplexAuxiliaryState {
  {
    n_graph: new_ngraph(),
    spacings: new_layered_spacings(layered_graph),
    node_reps: Array::make(node_count, None),
    edge_reps: Array::make(edge_count, None),
    port_map: {},
    flexible_where_space_permits_edges: [],
  }
}

///|
fn network_simplex_node_type_edge_weight(
  source_type : NodeType,
  target_type : NodeType,
) -> Double {
  if network_simplex_node_type_is_normal(source_type) &&
    network_simplex_node_type_is_normal(target_type) {
    network_simplex_edge_weight_base
  } else if network_simplex_node_type_is_normal(source_type) ||
    network_simplex_node_type_is_normal(target_type) {
    2.0 * network_simplex_edge_weight_base
  } else {
    8.0 * network_simplex_edge_weight_base
  }
}

///|
fn network_simplex_get_edge_weight(edge : LEdge) -> Double {
  let source_port = network_simplex_require_edge_source_port(edge)
  let target_port = network_simplex_require_edge_target_port(edge)
  let source_node = network_simplex_require_port_node(source_port)
  let target_node = network_simplex_require_port_node(target_port)
  let priority = network_simplex_int_max(
    1,
    edge.get_property_int(network_simplex_priority_straightness),
  )
  priority.to_double() *
  network_simplex_node_type_edge_weight(
    source_node.get_type(),
    target_node.get_type(),
  )
}

///|
fn network_simplex_is_handled_edge(edge : LEdge) -> Bool {
  !edge.is_self_loop() && !edge.is_in_layer_edge()
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
fn network_simplex_prepare(layered_graph : LGraph) -> (Int, Int) {
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

  (node_idx, edge_idx)
}

///|
fn network_simplex_transform_fixed_pos_node(
  node : LNode,
  state : NetworkSimplexAuxiliaryState,
) -> NetworkSimplexNodeRep {
  let single_node = nnode_of()
    .origin(node.get_handle().to_string())
    .node_type("non-flexible")
    .create(state.n_graph)

  for port in node.get_ports() {
    if network_simplex_port_side_is_east_west(port.get_side()) {
      state.port_map[port.get_handle()] = single_node
    }
  }

  { origin: node, is_flexible: false, head: single_node, tail: single_node }
}

///|
fn network_simplex_transform_ports(
  ports : Array[LPort],
  corners : NetworkSimplexNodeRep,
  state : NetworkSimplexAuxiliaryState,
) -> Unit {
  if ports.is_empty() {
    return
  }

  let port_spacing = layered_spacings_get_individual_or_default(
    corners.origin,
    spacing_port_port,
  )
  let graph = corners.origin.get_graph()
  let port_surrounding = if graph.has_property_elk_margin(
      layered_options_spacing_ports_surrounding,
    ) {
    graph.get_property_elk_margin(layered_options_spacing_ports_surrounding)
  } else {
    new_elk_margin()
  }

  let mut last_nnode = corners.head
  let mut last_port : LPort? = None
  for port in ports {
    let spacing = match last_port {
      Some(previous) => port_spacing + previous.get_size().y
      None => port_surrounding.top
    }
    let nnode = nnode_of()
      .origin(port.get_handle().to_string())
      .node_type("port")
      .create(state.n_graph)
    state.port_map[port.get_handle()] = nnode
    ignore(
      nedge_of()
      .weight(0.0)
      .delta(spacing.ceil().to_int())
      .source(last_nnode)
      .target(nnode)
      .create(),
    )
    last_nnode = nnode
    last_port = Some(port)
  }

  let final_spacing = match last_port {
    Some(previous) => port_surrounding.bottom + previous.get_size().y
    None => abort("non-empty port list expected")
  }
  ignore(
    nedge_of()
    .weight(0.0)
    .delta(final_spacing.ceil().to_int())
    .source(last_nnode)
    .target(corners.tail)
    .create(),
  )
}

///|
fn network_simplex_transform_fixed_order_node(
  node : LNode,
  state : NetworkSimplexAuxiliaryState,
) -> NetworkSimplexNodeRep {
  let top = nnode_of()
    .origin(node.get_handle().to_string())
    .node_type("flexible-head")
    .create(state.n_graph)
  let bottom = nnode_of()
    .origin(node.get_handle().to_string())
    .node_type("flexible-tail")
    .create(state.n_graph)
  let corners = { origin: node, is_flexible: true, head: top, tail: bottom }

  let min_height = node.get_size().y
  let node_flexibility = network_simplex_node_flexibility_value(node)
  let size_weight = if network_simplex_node_flexibility_is_flexible_size(
      node_flexibility,
    ) {
    network_simplex_node_size_weight_flexible
  } else {
    network_simplex_node_size_weight_static
  }
  let node_size_edge = nedge_of()
    .weight(size_weight)
    .delta(min_height.ceil().to_int())
    .source(top)
    .target(bottom)
    .create()
  if node_flexibility == "NODE_SIZE_WHERE_SPACE_PERMITS" {
    state.flexible_where_space_permits_edges.push(node_size_edge)
  }

  network_simplex_transform_ports(
    network_simplex_reverse_ports(node.get_port_side_view(PortSide::West)),
    corners,
    state,
  )
  network_simplex_transform_ports(
    node.get_port_side_view(PortSide::East),
    corners,
    state,
  )
  corners
}

///|
fn network_simplex_transform_layer(
  layer : Layer,
  state : NetworkSimplexAuxiliaryState,
) -> Unit {
  let mut last_rep : NetworkSimplexNodeRep? = None
  for node in layer.get_nodes() {
    let node_rep = if network_simplex_node_is_flexible(node) {
      network_simplex_transform_fixed_order_node(node, state)
    } else {
      network_simplex_transform_fixed_pos_node(node, state)
    }
    state.node_reps[node.get_id()] = Some(node_rep)

    match last_rep {
      Some(previous) => {
        let mut spacing = previous.origin.get_margin().bottom +
          state.spacings.get_vertical_spacing(previous.origin, node) +
          node.get_margin().top
        if !previous.is_flexible {
          spacing += previous.origin.get_size().y
        }
        ignore(
          nedge_of()
          .delta(spacing.ceil().to_int())
          .weight(0.0)
          .source(previous.tail)
          .target(node_rep.head)
          .create(),
        )
      }
      None => ()
    }

    last_rep = Some(node_rep)
  }
}

///|
fn network_simplex_transform_edge(
  edge : LEdge,
  state : NetworkSimplexAuxiliaryState,
) -> Unit {
  let dummy = nnode_of().node_type("edge").create(state.n_graph)

  let source_port = network_simplex_require_edge_source_port(edge)
  let target_port = network_simplex_require_edge_target_port(edge)
  let source_node = network_simplex_require_port_node(source_port)
  let target_node = network_simplex_require_port_node(target_port)
  let source_rep = network_simplex_require_node_rep(state, source_node)
  let target_rep = network_simplex_require_node_rep(state, target_node)

  let mut source_offset = source_port.get_anchor().y
  let mut target_offset = target_port.get_anchor().y
  if !source_rep.is_flexible {
    source_offset += source_port.get_position().y
  }
  if !target_rep.is_flexible {
    target_offset += target_port.get_position().y
  }

  let offset_delta = source_offset - target_offset
  if !network_simplex_port_offset_delta_is_integral(offset_delta) {
    abort("port positions must be integral")
  }
  let target_delta = network_simplex_double_max(0.0, offset_delta)
    .round()
    .to_int()
  let source_delta = network_simplex_double_max(0.0, -offset_delta)
    .round()
    .to_int()

  let weight = network_simplex_get_edge_weight(edge)
  let left = nedge_of()
    .origin(edge.get_handle().to_string())
    .weight(weight)
    .delta(source_delta)
    .source(dummy)
    .target(network_simplex_require_port_rep(state, source_port))
    .create()
  let right = nedge_of()
    .origin(edge.get_handle().to_string())
    .weight(weight)
    .delta(target_delta)
    .source(dummy)
    .target(network_simplex_require_port_rep(state, target_port))
    .create()
  state.edge_reps[edge.get_id()] = Some({ origin: edge, left, right })
}

///|
fn network_simplex_transform_edges(
  layered_graph : LGraph,
  state : NetworkSimplexAuxiliaryState,
) -> Unit {
  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      for edge in node.get_outgoing_edges() {
        if network_simplex_is_handled_edge(edge) {
          network_simplex_transform_edge(edge, state)
        }
      }
    }
  }
}

///|
fn network_simplex_build_initial_auxiliary_graph(
  layered_graph : LGraph,
  state : NetworkSimplexAuxiliaryState,
) -> Unit {
  for layer in layered_graph.get_layers() {
    network_simplex_transform_layer(layer, state)
  }
  network_simplex_transform_edges(layered_graph, state)
}

///|
fn network_simplex_insert_north_south_auxiliary_edges(
  layered_graph : LGraph,
  state : NetworkSimplexAuxiliaryState,
) -> Unit {
  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      for port in node.get_port_side_view(PortSide::South) {
        match port.get_property_l_node(internal_properties_port_dummy) {
          Some(other) =>
            ignore(
              nedge_of()
              .delta(0)
              .weight(network_simplex_small_edge_weight)
              .source(network_simplex_require_node_rep(state, node).tail)
              .target(network_simplex_require_node_rep(state, other).head)
              .create(),
            )
          None => ()
        }
      }
      for port in node.get_port_side_view(PortSide::North) {
        match port.get_property_l_node(internal_properties_port_dummy) {
          Some(other) =>
            ignore(
              nedge_of()
              .delta(0)
              .weight(network_simplex_small_edge_weight)
              .source(network_simplex_require_node_rep(state, other).tail)
              .target(network_simplex_require_node_rep(state, node).head)
              .create(),
            )
          None => ()
        }
      }
    }
  }
}

///|
fn network_simplex_insert_in_layer_edge_auxiliary_edges(
  layered_graph : LGraph,
  state : NetworkSimplexAuxiliaryState,
) -> Unit {
  let processed_edges : Map[Int, Bool] = {}
  for layer in layered_graph.get_layers() {
    let layer_indices : Map[Int, Int] = {}
    let mut node_index = 0
    for node in layer.get_nodes() {
      layer_indices[node.get_handle()] = node_index
      node_index += 1
    }

    for node in layer.get_nodes() {
      if !network_simplex_node_type_is_normal(node.get_type()) {
        continue
      }
      for in_layer_edge in node.get_connected_edges() {
        if !in_layer_edge.is_in_layer_edge() {
          continue
        }
        if processed_edges.get(in_layer_edge.get_handle()) is Some(_) {
          continue
        }
        processed_edges[in_layer_edge.get_handle()] = true

        let source_port = network_simplex_require_edge_source_port(
          in_layer_edge,
        )
        let target_port = network_simplex_require_edge_target_port(
          in_layer_edge,
        )
        let source_node = network_simplex_require_port_node(source_port)
        let source_is_dummy = !network_simplex_node_type_is_normal(
          source_node.get_type(),
        )
        let the_port = if source_is_dummy { target_port } else { source_port }
        let dummy_node = network_simplex_require_port_node(
          in_layer_edge.get_other_port(the_port),
        )

        let port_rep = network_simplex_require_port_rep(state, the_port)
        let dummy_rep = network_simplex_require_node_rep(state, dummy_node).head
        let port_node = network_simplex_require_port_node(the_port)
        let port_index = match layer_indices.get(port_node.get_handle()) {
          Some(value) => value
          None => abort("missing port node index in layer")
        }
        let dummy_index = match layer_indices.get(dummy_node.get_handle()) {
          Some(value) => value
          None => abort("missing dummy node index in layer")
        }
        let source = if port_index < dummy_index { port_rep } else { dummy_rep }
        let target = if port_index < dummy_index { dummy_rep } else { port_rep }
        ignore(
          nedge_of()
          .delta(0)
          .weight(network_simplex_edge_weight_base)
          .source(source)
          .target(target)
          .create(),
        )
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
  let (node_count, edge_count) = network_simplex_prepare(layered_graph)
  let auxiliary_state = network_simplex_new_auxiliary_state(
    layered_graph, node_count, edge_count,
  )
  network_simplex_build_initial_auxiliary_graph(layered_graph, auxiliary_state)
  network_simplex_insert_north_south_auxiliary_edges(
    layered_graph, auxiliary_state,
  )
  network_simplex_insert_in_layer_edge_auxiliary_edges(
    layered_graph, auxiliary_state,
  )
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
