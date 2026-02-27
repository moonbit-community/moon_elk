///|
let network_simplex_edge_weight_base : Double = 4.0

///|
let network_simplex_small_edge_weight : Double = 0.1

///|
let network_simplex_long_edge_vs_path_factor : Double = 2.0

///|
let network_simplex_node_size_weight_static : Double = 10000.0

///|
let network_simplex_node_size_weight_flexible : Double = 1.0

///|
let network_simplex_offset_integral_epsilon : Double = 0.00001

///|
let network_simplex_visited : Int = -1

///|
let network_simplex_other : Int = 0

///|
let network_simplex_junction : Int = 2

///|
pub suberror NetworkSimplexPlacerException {
  NetworkSimplexPlacerException(String)
} derive(Show, ToJson)

///|
fn[T] network_simplex_placer_raise(
  message : String,
) -> T raise NetworkSimplexPlacerException {
  raise NetworkSimplexPlacerException(message)
}

///|
fn network_simplex_placer_raise_unit(
  message : String,
) -> Unit raise NetworkSimplexPlacerException {
  network_simplex_placer_raise(message)
}

///|
priv struct NetworkSimplexNodeRep {
  origin : LNode
  is_flexible : Bool
  head : @common.NNode
  tail : @common.NNode
}

///|
priv struct NetworkSimplexEdgeRep {
  _origin : LEdge
  left : @common.NEdge
  right : @common.NEdge
}

///|
priv struct NetworkSimplexAuxiliaryState {
  n_graph : @common.NGraph
  spacings : Spacings
  node_reps : Array[NetworkSimplexNodeRep?]
  edge_reps : Array[NetworkSimplexEdgeRep?]
  port_map : Map[Int, @common.NNode]
  flexible_where_space_permits_edges : Array[@common.NEdge]
  node_state : Array[Int]
  two_paths : Array[Array[LEdge]]
  crossing : Array[Bool]
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
fn network_simplex_int_abs(value : Int) -> Int {
  if value < 0 {
    -value
  } else {
    value
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
fn network_simplex_create_edge(builder : @common.NEdgeBuilder) -> @common.NEdge {
  try builder.create() catch {
    err => {
      @core.layout_runtime_report_unsupported_configuration(err.to_string())
      network_simplex_create_edge(builder)
    }
  } noraise {
    edge => edge
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
fn network_simplex_node_flexibility_is_flexible_ports(value : String) -> Bool {
  match value {
    "PORT_POSITION" => true
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
  if node.has_property_string(
      layered_options_node_placement_network_simplex_node_flexibility,
    ) {
    return node.get_property_string(
      layered_options_node_placement_network_simplex_node_flexibility,
    )
  }

  node
  .get_graph()
  .get_property_string(
    layered_options_node_placement_network_simplex_node_flexibility_default,
  )
}

///|
fn network_simplex_get_individual_or_default_elk_margin(
  node : LNode,
  property : @graph.IProperty[@core.ElkMargin],
) -> @core.ElkMargin {
  if node.has_property_elk_margin(property) {
    node.get_property_elk_margin(property)
  } else {
    node.get_graph().get_property_elk_margin(property)
  }
}

///|
fn network_simplex_node_requires_more_height_for_flexible_ports(
  node : LNode,
) -> Bool {
  let port_spacing = layered_spacings_get_individual_or_default(
    node, @core.spacing_port_port,
  )
  let additional_port_spacing = if node.has_property_elk_margin(
      layered_options_spacing_ports_surrounding,
    ) {
    node.get_property_elk_margin(layered_options_spacing_ports_surrounding)
  } else {
    let graph = node.get_graph()
    if graph.has_property_elk_margin(layered_options_spacing_ports_surrounding) {
      graph.get_property_elk_margin(layered_options_spacing_ports_surrounding)
    } else {
      @core.new_elk_margin_values(
        port_spacing, port_spacing, port_spacing, port_spacing,
      )
    }
  }

  let west_ports = node.get_port_side_view(@core.PortSide::West)
  let required_west_height = additional_port_spacing.top +
    additional_port_spacing.bottom +
    (west_ports.length() - 1).to_double() * port_spacing
  if required_west_height > node.get_size().y {
    return true
  }

  let east_ports = node.get_port_side_view(@core.PortSide::East)
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
fn network_simplex_node_type_is_long_edge(node_type : NodeType) -> Bool {
  match node_type {
    NodeType::LongEdge => true
    _ => false
  }
}

///|
fn network_simplex_port_side_is_east_west(port_side : @core.PortSide) -> Bool {
  match port_side {
    @core.PortSide::East => true
    @core.PortSide::West => true
    _ => false
  }
}

///|
fn network_simplex_require_port_node(port : LPort) -> LNode {
  port.get_node().unwrap()
}

///|
fn network_simplex_require_edge_source_port(edge : LEdge) -> LPort {
  edge.get_source().unwrap()
}

///|
fn network_simplex_require_edge_target_port(edge : LEdge) -> LPort {
  edge.get_target().unwrap()
}

///|
fn network_simplex_require_edge_source_node(edge : LEdge) -> LNode {
  network_simplex_require_port_node(
    network_simplex_require_edge_source_port(edge),
  )
}

///|
fn network_simplex_require_edge_target_node(edge : LEdge) -> LNode {
  network_simplex_require_port_node(
    network_simplex_require_edge_target_port(edge),
  )
}

///|
fn network_simplex_require_node_rep(
  state : NetworkSimplexAuxiliaryState,
  node : LNode,
) -> NetworkSimplexNodeRep {
  state.node_reps[node.get_id()].unwrap()
}

///|
fn network_simplex_require_port_rep(
  state : NetworkSimplexAuxiliaryState,
  port : LPort,
) -> @common.NNode {
  state.port_map.get(port.get_handle()).unwrap()
}

///|
fn network_simplex_require_edge_rep(
  state : NetworkSimplexAuxiliaryState,
  edge : LEdge,
) -> NetworkSimplexEdgeRep {
  state.edge_reps[edge.get_id()].unwrap()
}

///|
fn network_simplex_require_node_layer(node : LNode) -> Layer {
  node.get_layer().unwrap()
}

///|
fn network_simplex_layers_equal(left : Layer, right : Layer) -> Bool {
  left.get_index() == right.get_index()
}

///|
fn network_simplex_node_is_in_layer(node : LNode, layer : Layer) -> Bool {
  match node.get_layer() {
    Some(node_layer) => network_simplex_layers_equal(node_layer, layer)
    None => false
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
    n_graph: @common.new_ngraph(),
    spacings: new_layered_spacings(layered_graph),
    node_reps: Array::make(node_count, None),
    edge_reps: Array::make(edge_count, None),
    port_map: {},
    flexible_where_space_permits_edges: [],
    node_state: Array::make(node_count, network_simplex_other),
    two_paths: [],
    crossing: Array::make(edge_count, false),
  }
}

///|
fn network_simplex_vertical_spacing(
  state : NetworkSimplexAuxiliaryState,
  first : LNode,
  second : LNode,
) -> Double {
  state.spacings.get_vertical_spacing(first, second) catch {
    LayeredSpacingsException(message) => {
      @core.layout_runtime_report_unsupported_configuration(message)
      0.0
    }
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
    edge.get_property_int(layered_options_priority_straightness),
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
      node.get_property_string(@core.port_constraints),
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
  let single_node = @common.nnode_of()
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
    @core.spacing_port_port,
  )
  let port_surrounding = network_simplex_get_individual_or_default_elk_margin(
    corners.origin,
    layered_options_spacing_ports_surrounding,
  )

  let mut last_nnode = corners.head
  let mut last_port : LPort? = None
  for port in ports {
    let spacing = match last_port {
      Some(previous) => port_spacing + previous.get_size().y
      None => port_surrounding.top
    }
    let nnode = @common.nnode_of()
      .origin(port.get_handle().to_string())
      .node_type("port")
      .create(state.n_graph)
    state.port_map[port.get_handle()] = nnode
    ignore(
      network_simplex_create_edge(
        @common.nedge_of()
        .weight(0.0)
        .delta(spacing.ceil().to_int())
        .source(last_nnode)
        .target(nnode),
      ),
    )
    last_nnode = nnode
    last_port = Some(port)
  }

  let final_spacing = port_surrounding.bottom + last_port.unwrap().get_size().y
  ignore(
    network_simplex_create_edge(
      @common.nedge_of()
      .weight(0.0)
      .delta(final_spacing.ceil().to_int())
      .source(last_nnode)
      .target(corners.tail),
    ),
  )
}

///|
fn network_simplex_transform_fixed_order_node(
  node : LNode,
  state : NetworkSimplexAuxiliaryState,
) -> NetworkSimplexNodeRep {
  let top = @common.nnode_of()
    .origin(node.get_handle().to_string())
    .node_type("flexible-head")
    .create(state.n_graph)
  let bottom = @common.nnode_of()
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
  let node_size_edge = network_simplex_create_edge(
    @common.nedge_of()
    .weight(size_weight)
    .delta(min_height.ceil().to_int())
    .source(top)
    .target(bottom),
  )
  if node_flexibility == "NODE_SIZE_WHERE_SPACE_PERMITS" {
    state.flexible_where_space_permits_edges.push(node_size_edge)
  }

  network_simplex_transform_ports(
    network_simplex_reverse_ports(node.get_port_side_view(@core.PortSide::West)),
    corners,
    state,
  )
  network_simplex_transform_ports(
    node.get_port_side_view(@core.PortSide::East),
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
          network_simplex_vertical_spacing(state, previous.origin, node) +
          node.get_margin().top
        if !previous.is_flexible {
          spacing += previous.origin.get_size().y
        }
        ignore(
          network_simplex_create_edge(
            @common.nedge_of()
            .delta(spacing.ceil().to_int())
            .weight(0.0)
            .source(previous.tail)
            .target(node_rep.head),
          ),
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
  let dummy = @common.nnode_of().node_type("edge").create(state.n_graph)

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
    try
      network_simplex_placer_raise_unit("Port positions must be integral")
    catch {
      NetworkSimplexPlacerException(message) =>
        @core.layout_runtime_report_unsupported_configuration(
          "org.eclipse.elk.alg.layered.p4nodes.NetworkSimplexPlacer: " + message,
        )
    } noraise {
      _ => ()
    }
    return
  }
  let target_delta = network_simplex_double_max(0.0, offset_delta)
    .round()
    .to_int()
  let source_delta = network_simplex_double_max(0.0, -offset_delta)
    .round()
    .to_int()

  let weight = network_simplex_get_edge_weight(edge)
  let left = network_simplex_create_edge(
    @common.nedge_of()
    .origin(edge.get_handle().to_string())
    .weight(weight)
    .delta(source_delta)
    .source(dummy)
    .target(network_simplex_require_port_rep(state, source_port)),
  )
  let right = network_simplex_create_edge(
    @common.nedge_of()
    .origin(edge.get_handle().to_string())
    .weight(weight)
    .delta(target_delta)
    .source(dummy)
    .target(network_simplex_require_port_rep(state, target_port)),
  )
  state.edge_reps[edge.get_id()] = Some({ _origin: edge, left, right })
}

///|
fn network_simplex_edge_rep_not_straight_by(rep : NetworkSimplexEdgeRep) -> Int {
  rep.left.get_target().get_layer() -
  rep.left.get_delta() -
  (rep.right.get_target().get_layer() - rep.right.get_delta())
}

///|
fn network_simplex_edge_rep_is_straight(rep : NetworkSimplexEdgeRep) -> Bool {
  network_simplex_edge_rep_not_straight_by(rep) == 0
}

///|
fn network_simplex_nedge_length(edge : @common.NEdge) -> Int {
  network_simplex_int_abs(
    edge.get_source().get_layer() - edge.get_target().get_layer(),
  ) -
  edge.get_delta()
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
      for port in node.get_port_side_view(@core.PortSide::South) {
        match port.get_property_l_node(internal_properties_port_dummy) {
          Some(other) =>
            ignore(
              network_simplex_create_edge(
                @common.nedge_of()
                .delta(0)
                .weight(network_simplex_small_edge_weight)
                .source(network_simplex_require_node_rep(state, node).tail)
                .target(network_simplex_require_node_rep(state, other).head),
              ),
            )
          None => ()
        }
      }
      for port in node.get_port_side_view(@core.PortSide::North) {
        match port.get_property_l_node(internal_properties_port_dummy) {
          Some(other) =>
            ignore(
              network_simplex_create_edge(
                @common.nedge_of()
                .delta(0)
                .weight(network_simplex_small_edge_weight)
                .source(network_simplex_require_node_rep(state, other).tail)
                .target(network_simplex_require_node_rep(state, node).head),
              ),
            )
          None => ()
        }
      }
    }
  }
}

///|
fn network_simplex_get_other_port_or_abort(edge : LEdge, port : LPort) -> LPort {
  try edge.get_other_port(port) catch {
    LEdgeException::IllegalArgumentException(message) => {
      @core.layout_runtime_report_unsupported_configuration(message)
      port
    }
    LEdgeException::IllegalStateException(message) => {
      @core.layout_runtime_report_unsupported_configuration(message)
      port
    }
  } noraise {
    other => other
  }
}

///|
fn network_simplex_get_other_node_or_abort(edge : LEdge, node : LNode) -> LNode {
  try edge.get_other_node(node) catch {
    LEdgeException::IllegalArgumentException(message) => {
      @core.layout_runtime_report_unsupported_configuration(message)
      node
    }
    LEdgeException::IllegalStateException(message) => {
      @core.layout_runtime_report_unsupported_configuration(message)
      node
    }
  } noraise {
    other => other
  }
}

///|
fn network_simplex_insert_in_layer_edge_auxiliary_edges(
  layered_graph : LGraph,
  state : NetworkSimplexAuxiliaryState,
) -> Unit {
  let processed_edges : Map[Int, Bool] = {}
  for layer in layered_graph.get_layers() {
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
          network_simplex_get_other_port_or_abort(in_layer_edge, the_port),
        )

        let port_rep = network_simplex_require_port_rep(state, the_port)
        let dummy_rep = network_simplex_require_node_rep(state, dummy_node).head
        let port_node = network_simplex_require_port_node(the_port)
        let port_index = port_node.get_index()
        let dummy_index = dummy_node.get_index()
        let source = if port_index < dummy_index { port_rep } else { dummy_rep }
        let target = if port_index < dummy_index { dummy_rep } else { port_rep }
        ignore(
          network_simplex_create_edge(
            @common.nedge_of()
            .delta(0)
            .weight(network_simplex_edge_weight_base)
            .source(source)
            .target(target),
          ),
        )
      }
    }
  }
}

///|
fn network_simplex_insert_flexible_where_space_auxiliary_edges(
  state : NetworkSimplexAuxiliaryState,
) -> Unit {
  if state.n_graph.nodes.is_empty() {
    return
  }

  let mut min_layer = state.n_graph.nodes[0].get_layer()
  let mut max_layer = min_layer
  for nnode in state.n_graph.nodes {
    let layer = nnode.get_layer()
    if layer < min_layer {
      min_layer = layer
    }
    if layer > max_layer {
      max_layer = layer
    }
  }
  let used_layers = max_layer - min_layer

  let global_source = @common.nnode_of().create(state.n_graph)
  let global_sink = @common.nnode_of().create(state.n_graph)
  ignore(
    network_simplex_create_edge(
      @common.nedge_of()
      .weight(network_simplex_node_size_weight_static * 2.0)
      .delta(used_layers)
      .source(global_source)
      .target(global_sink),
    ),
  )

  for rep_opt in state.node_reps {
    match rep_opt {
      Some(rep) => {
        if !network_simplex_node_type_is_normal(rep.origin.get_type()) {
          continue
        }
        if rep.origin.get_ports().length() <= 1 {
          continue
        }
        ignore(
          network_simplex_create_edge(
            @common.nedge_of()
            .weight(0.0)
            .delta(rep.tail.get_layer() - min_layer)
            .source(global_source)
            .target(rep.tail),
          ),
        )
        ignore(
          network_simplex_create_edge(
            @common.nedge_of()
            .weight(0.0)
            .delta(used_layers - rep.head.get_layer())
            .source(rep.head)
            .target(global_sink),
          ),
        )
      }
      None => ()
    }
  }
}

///|
fn network_simplex_execute_auxiliary_graph(
  layered_graph : LGraph,
  state : NetworkSimplexAuxiliaryState,
  monitor : @core.IElkProgressMonitor,
) -> Unit {
  ignore(state.n_graph.make_connected())

  let iter_limit = network_simplex_int_max(
    1,
    layered_graph.get_property_int(layered_options_thoroughness) *
    state.n_graph.nodes.length(),
  )

  let simplex = @common.network_simplex_for_graph(state.n_graph)
  ignore(simplex.with_iteration_limit(iter_limit))
  ignore(simplex.with_balancing(false))
  match monitor.sub_task(1.0) {
    Some(sub_monitor) => simplex.execute(monitor=sub_monitor)
    None => simplex.execute()
  }

  if state.flexible_where_space_permits_edges.is_empty() {
    return
  }

  network_simplex_insert_flexible_where_space_auxiliary_edges(state)
  for edge in state.flexible_where_space_permits_edges {
    edge.set_weight(network_simplex_node_size_weight_flexible)
  }

  let rerun = @common.network_simplex_for_graph(state.n_graph)
  ignore(rerun.with_iteration_limit(iter_limit))
  ignore(rerun.with_balancing(false))
  match monitor.sub_task(1.0) {
    Some(sub_monitor) => rerun.execute(monitor=sub_monitor)
    None => rerun.execute()
  }
}

///|
fn network_simplex_favor_straight_edges(layered_graph : LGraph) -> Bool {
  layered_graph.get_property_bool(
    layered_options_node_placement_favor_straight_edges,
  )
}

///|
fn network_simplex_get_node_state(node : LNode) -> Int {
  let mut incoming = 0
  let mut outgoing = 0
  for port in node.get_ports() {
    for edge in port.get_incoming_edges() {
      if !edge.is_self_loop() {
        incoming += 1
      }
    }
    for edge in port.get_outgoing_edges() {
      if !edge.is_self_loop() {
        outgoing += 1
      }
    }
    if incoming > 1 || outgoing > 1 {
      return network_simplex_junction
    }
  }
  if incoming + outgoing == 1 {
    network_simplex_junction
  } else {
    network_simplex_other
  }
}

///|
fn network_simplex_mark_crossing_edges(
  left : Layer,
  right : Layer,
  state : NetworkSimplexAuxiliaryState,
) -> Unit {
  let open_edges : Array[LEdge] = []
  for node in left.get_nodes() {
    for port in node.get_port_side_view(@core.PortSide::East) {
      for edge in port.get_outgoing_edges() {
        if edge.is_in_layer_edge() || edge.is_self_loop() {
          continue
        }
        let target_node = network_simplex_require_edge_target_node(edge)
        if !network_simplex_node_is_in_layer(target_node, right) {
          continue
        }
        open_edges.push(edge)
      }
    }
  }

  let right_nodes = right.get_nodes()
  let mut right_index = right_nodes.length()
  while right_index > 0 {
    right_index -= 1
    let node = right_nodes[right_index]
    for port in node.get_port_side_view(@core.PortSide::West) {
      for edge in port.get_incoming_edges() {
        if edge.is_in_layer_edge() || edge.is_self_loop() {
          continue
        }
        let source_node = network_simplex_require_edge_source_node(edge)
        if !network_simplex_node_is_in_layer(source_node, left) {
          continue
        }

        if open_edges.is_empty() {
          continue
        }

        let mut cursor = open_edges.length() - 1
        let mut last = open_edges[cursor]
        while last.get_handle() != edge.get_handle() && cursor > 0 {
          state.crossing[last.get_id()] = true
          state.crossing[edge.get_id()] = true
          cursor -= 1
          last = open_edges[cursor]
        }
        if cursor > 0 {
          ignore(open_edges.remove(cursor))
        }
      }
    }
  }
}

///|
fn network_simplex_mark_edge_crossings(
  layered_graph : LGraph,
  state : NetworkSimplexAuxiliaryState,
) -> Unit {
  state.crossing.clear()
  for _ in 0..<state.edge_reps.length() {
    state.crossing.push(false)
  }
  let layers = layered_graph.get_layers()
  if layers.length() <= 1 {
    return
  }
  let mut i = 0
  while i + 1 < layers.length() {
    network_simplex_mark_crossing_edges(layers[i], layers[i + 1], state)
    i += 1
  }
}

///|
fn network_simplex_follow_path(
  edge : LEdge,
  current : LNode,
  path : Array[LEdge],
  state : NetworkSimplexAuxiliaryState,
) -> Array[LEdge] {
  let other = network_simplex_get_other_node_or_abort(edge, current)
  path.push(edge)

  let other_state = state.node_state[other.get_id()]
  if other_state == network_simplex_visited ||
    other_state == network_simplex_junction ||
    state.crossing[edge.get_id()] {
    return path
  }

  state.node_state[other.get_id()] = network_simplex_visited
  for incident in other.get_connected_edges() {
    if !network_simplex_is_handled_edge(incident) ||
      incident.get_handle() == edge.get_handle() {
      continue
    }
    return network_simplex_follow_path(incident, other, path, state)
  }
  path
}

///|
fn network_simplex_identify_paths(
  layered_graph : LGraph,
  state : NetworkSimplexAuxiliaryState,
) -> Array[Array[LEdge]] {
  let paths : Array[Array[LEdge]] = []
  for layer in layered_graph.get_layers() {
    for junction in layer.get_nodes() {
      if state.node_state[junction.get_id()] != network_simplex_junction {
        continue
      }
      for edge in junction.get_connected_edges() {
        if !network_simplex_is_handled_edge(edge) {
          continue
        }
        let path = network_simplex_follow_path(edge, junction, [], state)
        if path.length() > 1 {
          paths.push(path)
        }
      }
    }
  }
  paths
}

///|
fn network_simplex_path_contains_long_edge_dummy(path : Array[LEdge]) -> Bool {
  if path.is_empty() {
    return false
  }
  if network_simplex_node_type_is_long_edge(
      network_simplex_require_edge_source_node(path[0]).get_type(),
    ) {
    return true
  }
  for edge in path {
    if network_simplex_node_type_is_long_edge(
        network_simplex_require_edge_target_node(edge).get_type(),
      ) {
      return true
    }
  }
  false
}

///|
fn network_simplex_path_contains_flexible_node(
  path : Array[LEdge],
  predicate : (String) -> Bool,
) -> Bool {
  if path.is_empty() {
    return false
  }
  if predicate(
      network_simplex_node_flexibility_value(
        network_simplex_require_edge_source_node(path[0]),
      ),
    ) {
    return true
  }
  for edge in path {
    if predicate(
        network_simplex_node_flexibility_value(
          network_simplex_require_edge_target_node(edge),
        ),
      ) {
      return true
    }
  }
  false
}

///|
fn network_simplex_order_two_path(path : Array[LEdge]) -> Array[LEdge] {
  if path.length() != 2 {
    try
      network_simplex_placer_raise_unit("Order only allowed for two paths.")
    catch {
      NetworkSimplexPlacerException(message) =>
        @core.layout_runtime_report_unsupported_configuration(
          "org.eclipse.elk.alg.layered.p4nodes.NetworkSimplexPlacer: " + message,
        )
    } noraise {
      _ => ()
    }
    return path
  }

  let first = path[0]
  let second = path[1]
  let first_target = network_simplex_require_edge_target_node(first)
  let second_source = network_simplex_require_edge_source_node(second)
  if first_target.get_handle() == second_source.get_handle() {
    return path
  }
  [second, first]
}

///|
fn network_simplex_two_path_center_node_is_flexible(
  path : Array[LEdge],
) -> Bool {
  network_simplex_node_is_flexible(
    network_simplex_require_edge_target_node(path[0]),
  )
}

///|
fn network_simplex_prefer_straight_edges(
  layered_graph : LGraph,
  state : NetworkSimplexAuxiliaryState,
) -> Unit {
  state.node_state.clear()
  for _ in 0..<state.node_reps.length() {
    state.node_state.push(network_simplex_other)
  }
  state.two_paths.clear()

  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      state.node_state[node.get_id()] = network_simplex_get_node_state(node)
    }
  }

  network_simplex_mark_edge_crossings(layered_graph, state)
  let identified_paths = network_simplex_identify_paths(layered_graph, state)

  for path in identified_paths {
    if path.length() <= 1 {
      continue
    }

    if path.length() == 2 {
      let ordered = network_simplex_order_two_path(path)
      if !network_simplex_two_path_center_node_is_flexible(ordered) {
        state.two_paths.push(ordered)
      }
      continue
    }

    if network_simplex_path_contains_long_edge_dummy(path) ||
      network_simplex_path_contains_flexible_node(
        path, network_simplex_node_flexibility_is_flexible_size_where_space_permits,
      ) {
      continue
    }

    let mut i = 0
    while i < path.length() {
      let edge = path[i]
      let rep = network_simplex_require_edge_rep(state, edge)
      let mut weight = if i == 0 || i == path.length() - 1 {
        network_simplex_node_type_edge_weight(
          NodeType::Normal,
          NodeType::LongEdge,
        )
      } else {
        network_simplex_node_type_edge_weight(
          NodeType::LongEdge,
          NodeType::LongEdge,
        )
      }
      weight *= network_simplex_long_edge_vs_path_factor
      rep.left.set_weight(
        network_simplex_double_max(rep.left.get_weight(), weight),
      )
      rep.right.set_weight(
        network_simplex_double_max(rep.right.get_weight(), weight),
      )
      i += 1
    }
  }
}

///|
fn network_simplex_improve_two_path(
  path : Array[LEdge],
  state : NetworkSimplexAuxiliaryState,
  probe : Bool,
) -> Bool {
  let left_edge = network_simplex_require_edge_rep(state, path[0])
  let right_edge = network_simplex_require_edge_rep(state, path[1])
  if network_simplex_edge_rep_is_straight(left_edge) &&
    network_simplex_edge_rep_is_straight(right_edge) {
    return false
  }

  let center_node = network_simplex_require_edge_target_node(path[0])
  let nnode = network_simplex_require_node_rep(state, center_node)
  let center_layer = network_simplex_require_node_layer(center_node)
  let layer_nodes = center_layer.get_nodes()
  let mut center_index = -1
  let mut i = 0
  while i < layer_nodes.length() {
    if layer_nodes[i].get_handle() == center_node.get_handle() {
      center_index = i
      break
    }
    i += 1
  }
  if center_index < 0 {
    return false
  }

  let mut above_dist = 1.0e18
  if center_index > 0 {
    let above = layer_nodes[center_index - 1]
    let above_rep = network_simplex_require_node_rep(state, above)
    let spacing = network_simplex_vertical_spacing(state, above, center_node).ceil()
    above_dist = nnode.head.get_layer().to_double() -
      center_node.get_margin().top -
      (
        above_rep.head.get_layer().to_double() +
        above.get_size().y +
        above.get_margin().bottom
      ) -
      spacing
  }

  let mut below_dist = 1.0e18
  if center_index < layer_nodes.length() - 1 {
    let below = layer_nodes[center_index + 1]
    let below_rep = network_simplex_require_node_rep(state, below)
    let spacing = network_simplex_vertical_spacing(state, below, center_node).ceil()
    below_dist = below_rep.head.get_layer().to_double() -
      below.get_margin().top -
      (
        nnode.head.get_layer().to_double() +
        center_node.get_size().y +
        center_node.get_margin().bottom
      ) -
      spacing
  }

  if probe &&
    network_simplex_double_abs(above_dist - below_dist) <=
    network_simplex_offset_integral_epsilon {
    return true
  }

  let a = network_simplex_nedge_length(left_edge.left)
  let b = -network_simplex_nedge_length(left_edge.right)
  let c = -network_simplex_nedge_length(right_edge.left)
  let d = network_simplex_nedge_length(right_edge.right)

  let left_not_straight = network_simplex_edge_rep_not_straight_by(left_edge)
  let right_not_straight = network_simplex_edge_rep_not_straight_by(right_edge)

  let case_d = left_not_straight > 0 && right_not_straight < 0
  let case_c = left_not_straight < 0 && right_not_straight > 0
  let case_b = left_edge.left.get_target().get_layer() +
    left_edge.right.get_delta() <
    right_edge.right.get_target().get_layer() + right_edge.left.get_delta()
  let case_a = left_edge.left.get_target().get_layer() +
    left_edge.right.get_delta() >
    right_edge.right.get_target().get_layer() + right_edge.left.get_delta()

  let mut shift = 0
  if !case_d && !case_c {
    if case_a {
      if above_dist + c.to_double() > 0.0 {
        shift = c
      } else if below_dist - a.to_double() > 0.0 {
        shift = a
      }
    } else if case_b {
      if above_dist + b.to_double() > 0.0 {
        shift = b
      } else if below_dist - d.to_double() > 0.0 {
        shift = d
      }
    }
  }

  nnode.head.set_layer(nnode.head.get_layer() + shift)
  if nnode.is_flexible {
    nnode.tail.set_layer(nnode.tail.get_layer() + shift)
  }
  false
}

///|
fn network_simplex_post_process_two_paths(
  state : NetworkSimplexAuxiliaryState,
) -> Unit {
  let queue : Array[Array[LEdge]] = []
  for path in state.two_paths {
    queue.push(path)
  }

  let stack : Array[Array[LEdge]] = []
  while !queue.is_empty() {
    let path = queue.remove(0)
    let try_again = network_simplex_improve_two_path(path, state, true)
    if try_again {
      stack.push(path)
    }
  }

  while !stack.is_empty() {
    let path = stack.remove(stack.length() - 1)
    ignore(network_simplex_improve_two_path(path, state, false))
  }
}

///|
fn network_simplex_string_array_contains(
  values : Array[String],
  expected : String,
) -> Bool {
  for value in values {
    if value == expected {
      return true
    }
  }
  false
}

///|
fn network_simplex_adjust_label_position(
  node : LNode,
  label : LLabel,
  size_delta : Double,
) -> Unit {
  let placements = node.get_property_string_array(@core.node_labels_placement)
  let bottom = @core.node_label_placement_to_string(NodeLabelVBottom)
  let center = @core.node_label_placement_to_string(NodeLabelVCenter)
  if network_simplex_string_array_contains(placements, bottom) {
    label.get_position().y += size_delta
  } else if network_simplex_string_array_contains(placements, center) {
    label.get_position().y += size_delta / 2.0
  }
}

///|
fn network_simplex_apply_positions(
  layered_graph : LGraph,
  state : NetworkSimplexAuxiliaryState,
) -> Unit {
  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      let rep = network_simplex_require_node_rep(state, node)
      let min_y = rep.head.get_layer().to_double()
      let max_y = rep.tail.get_layer().to_double()

      node.get_position().y = min_y
      let size_delta = max_y - min_y - node.get_size().y

      let flexible_node = network_simplex_node_is_flexible(node)
      let node_flexibility = network_simplex_node_flexibility_value(node)

      if flexible_node &&
        network_simplex_node_flexibility_is_flexible_size_where_space_permits(
          node_flexibility,
        ) {
        node.get_size().y += size_delta
      }

      if flexible_node &&
        network_simplex_node_flexibility_is_flexible_ports(node_flexibility) {
        for port in node.get_ports() {
          if network_simplex_port_side_is_east_west(port.get_side()) {
            let nnode = network_simplex_require_port_rep(state, port)
            port.get_position().y = nnode.get_layer().to_double() - min_y
          }
        }

        for label in node.get_labels() {
          network_simplex_adjust_label_position(node, label, size_delta)
        }

        if network_simplex_node_flexibility_is_flexible_size_where_space_permits(
            node_flexibility,
          ) {
          for south_port in node.get_port_side_view(@core.PortSide::South) {
            south_port.get_position().y += size_delta
          }
        }
      }
    }
  }
}

///|
fn network_simplex_cleanup(state : NetworkSimplexAuxiliaryState) -> Unit {
  state.n_graph.nodes.clear()
  state.node_reps.clear()
  state.edge_reps.clear()
  state.port_map.clear()
  state.flexible_where_space_permits_edges.clear()
  state.node_state.clear()
  state.two_paths.clear()
  state.crossing.clear()
}

///|
fn network_simplex_node_placer_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
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
  let prefer_straight_edges = network_simplex_favor_straight_edges(
    layered_graph,
  )
  if prefer_straight_edges {
    match monitor.sub_task(1.0) {
      Some(sub_monitor) => {
        ignore(sub_monitor.begin("Straight Edges Pre-Processing", 1.0))
        network_simplex_prefer_straight_edges(layered_graph, auxiliary_state)
        sub_monitor.done()
      }
      None =>
        network_simplex_prefer_straight_edges(layered_graph, auxiliary_state)
    }
  }

  network_simplex_execute_auxiliary_graph(
    layered_graph, auxiliary_state, monitor,
  )

  if prefer_straight_edges {
    match monitor.sub_task(1.0) {
      Some(sub_monitor) => {
        ignore(sub_monitor.begin("Straight Edges Post-Processing", 1.0))
        network_simplex_post_process_two_paths(auxiliary_state)
        sub_monitor.done()
      }
      None => network_simplex_post_process_two_paths(auxiliary_state)
    }
  }

  network_simplex_apply_positions(layered_graph, auxiliary_state)
  network_simplex_cleanup(auxiliary_state)
  monitor.done()
}

///|
pub fn new_network_simplex_placer_layout_phase() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_phase(network_simplex_node_placer_process, graph => {
    for
      property in graph.get_property_graph_properties_array(
        internal_properties_graph_properties,
      ) {
      match property {
        GraphProperties::ExternalPorts =>
          return Some(
            @core.layout_processor_configuration_create(
              layered_phase_descriptor,
            ).add_before(
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
