///|
pub struct RecursiveGraphLayoutEngine {
  marker : Int
}

///|
pub fn new_recursive_graph_layout_engine() -> RecursiveGraphLayoutEngine {
  { marker: 0 }
}

///|
fn max_positive(value : Double, fallback : Double) -> Double {
  if value > 0.0 {
    value
  } else {
    fallback
  }
}

///|
fn parse_node_padding(node : ElkNode) -> ElkPadding {
  let parsed = new_elk_padding()
  parsed.parse(node_get_string_property(node, padding))
  parsed
}

///|
fn parse_node_minimum_size(node : ElkNode) -> KVector {
  let parsed = new_kvector()
  parsed.parse(node_get_string_property(node, node_size_minimum))
  parsed
}

///|
fn has_minimum_size_constraint(node : ElkNode) -> Bool {
  for value in node_get_string_set_property(node, node_size_constraints) {
    if value == "MINIMUM_SIZE" || value == "MINIMUM_SIZE_WITH_PORTS" {
      return true
    }
  }
  false
}

///|
fn node_layout_option_value_by_candidates(
  node : ElkNode,
  candidates : Array[String],
) -> String? {
  for candidate in candidates {
    match node_layout_option_string_value(node, candidate) {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn node_individual_spacing_value_by_candidates(
  node : ElkNode,
  candidates : Array[String],
) -> String? {
  for candidate in candidates {
    match node_individual_spacing_option_string_value(node, candidate) {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn placement_tokens(value : String) -> Array[String] {
  let normalized = value
    .replace_all(old="[", new="")
    .replace_all(old="]", new="")
  let tokens = []
  for token_view in normalized.split(",") {
    let token = token_view.trim().to_string()
    if !token.is_empty() {
      tokens.push(token)
    }
  }
  tokens
}

///|
fn has_placement_token(tokens : Array[String], expected : String) -> Bool {
  for token in tokens {
    if token == expected {
      return true
    }
  }
  false
}

///|
fn node_label_padding_top(node : ElkNode) -> Double {
  let keys = [
    "nodeLabels.padding", "elk.nodeLabels.padding", "org.eclipse.elk.nodeLabels.padding",
  ]
  let padding_text = match
    node_individual_spacing_value_by_candidates(node, keys) {
    Some(value) => value
    None =>
      match node_layout_option_value_by_candidates(node, keys) {
        Some(value) => value
        None => return 0.0
      }
  }
  let parsed = new_elk_padding()
  parsed.parse(padding_text)
  parsed.top
}

///|
fn recursive_layout_node_labels(node : ElkNode) -> Unit {
  let keys = [
    "nodeLabels.placement", "elk.nodeLabels.placement", "org.eclipse.elk.nodeLabels.placement",
  ]
  let tokens = match node_layout_option_value_by_candidates(node, keys) {
    Some(value) => placement_tokens(value)
    None =>
      if node_has_string_set_property(node, node_labels_placement) {
        node_get_string_set_property(node, node_labels_placement)
      } else {
        return
      }
  }
  if !(has_placement_token(tokens, "INSIDE") &&
    has_placement_token(tokens, "V_TOP")) {
    return
  }
  let top = node_label_padding_top(node)
  for label in node_labels(node) {
    label_set_location(label, label_x(label), top)
  }
}

///|
fn ensure_edge_section_for_edge(edge : ElkEdge) -> Unit {
  if !edge_sections(edge).is_empty() {
    return
  }
  if edge_sources(edge).length() != 1 || edge_targets(edge).length() != 1 {
    return
  }
  let source_shape = edge_sources(edge)[0]
  let target_shape = edge_targets(edge)[0]
  match source_shape {
    NodeShape(source_node) =>
      match target_shape {
        NodeShape(target_node) => {
          let section = create_edge_section(edge)
          let start_x = node_x(source_node) +
            max_positive(node_width(source_node), 10.0)
          let start_y = node_y(source_node) +
            max_positive(node_height(source_node), 10.0) / 2.0
          let end_x = node_x(target_node)
          let end_y = node_y(target_node) +
            max_positive(node_height(target_node), 10.0) / 2.0
          edge_section_set_start(section, start_x, start_y)
          edge_section_set_end(section, end_x, end_y)
          edge_section_set_incoming_shape(section, Some(source_shape))
          edge_section_set_outgoing_shape(section, Some(target_shape))
        }
        _ => ()
      }
    _ => ()
  }
}

///|
priv struct RecursiveLayeredContext {
  layered_graph : LGraph
  elk_to_lnode : Map[ElkNode, LNode]
  lnode_to_elk : Map[Int, ElkNode]
  edge_to_ledge : Map[ElkEdge, LEdge]
}

///|
fn recursive_layered_edge_endpoint_node(
  edge_shapes : Array[ElkConnectableShape],
) -> ElkNode? {
  if edge_shapes.is_empty() {
    return None
  }
  match edge_shapes[0] {
    NodeShape(node) => Some(node)
    PortShape(port) => port_parent(port)
  }
}

///|
fn recursive_layered_edge_endpoint_port(
  edge_shapes : Array[ElkConnectableShape],
  elk_to_lport : Map[ElkPort, LPort],
) -> LPort? {
  if edge_shapes.is_empty() {
    return None
  }
  match edge_shapes[0] {
    PortShape(port) => elk_to_lport.get(port)
    _ => None
  }
}

///|
fn recursive_layered_port_side_from_string(value : String) -> PortSide {
  match value {
    "NORTH" => PortSide::North
    "EAST" => PortSide::East
    "SOUTH" => PortSide::South
    "WEST" => PortSide::West
    _ => PortSide::SideUndefined
  }
}

///|
fn recursive_layered_port_side_option(port : ElkPort) -> String {
  let candidates = ["org.eclipse.elk.port.side", "elk.port.side", "port.side"]
  for candidate in candidates {
    match port_layout_option_string_value(port, candidate) {
      Some(value) => return value
      None => ()
    }
  }
  "UNDEFINED"
}

///|
fn recursive_layered_model_order_cycle_breaking(
  cycle_breaking_strategy : String,
) -> Bool {
  cycle_breaking_strategy == "MODEL_ORDER" ||
  cycle_breaking_strategy == "BFS_NODE_ORDER" ||
  cycle_breaking_strategy == "DFS_NODE_ORDER" ||
  cycle_breaking_strategy == "GREEDY_MODEL_ORDER" ||
  cycle_breaking_strategy == "SCC_CONNECTIVITY" ||
  cycle_breaking_strategy == "SCC_NODE_TYPE"
}

///|
fn recursive_layered_model_order_layering(
  layering_strategy : String,
  node_promotion_strategy : String,
) -> Bool {
  layering_strategy == "BF_MODEL_ORDER" ||
  layering_strategy == "DF_MODEL_ORDER" ||
  node_promotion_strategy == "MODEL_ORDER_LEFT_TO_RIGHT" ||
  node_promotion_strategy == "MODEL_ORDER_RIGHT_TO_LEFT"
}

///|
fn recursive_layered_needs_model_order(
  cycle_breaking_strategy : String,
  layering_strategy : String,
  node_promotion_strategy : String,
  consider_model_order_strategy : String,
) -> Bool {
  recursive_layered_model_order_cycle_breaking(cycle_breaking_strategy) ||
  recursive_layered_model_order_layering(
    layering_strategy, node_promotion_strategy,
  ) ||
  consider_model_order_strategy != "NONE"
}

///|
fn recursive_layered_new_edge_port(owner : LNode, side : PortSide) -> LPort {
  let port = new_l_port()
  port.set_node(Some(owner))
  port.set_side(side)
  ignore(port.get_size().set_xy(0.0, 0.0))
  port
}

///|
fn recursive_layered_parse_edge_routing(value : String) -> EdgeRouting {
  for routing in edge_routing_values() {
    if edge_routing_to_string(routing) == value {
      return routing
    }
  }
  RoutingUndefined
}

///|
fn recursive_layered_cycle_breaking_factory(
  strategy : String,
) -> ILayoutProcessorFactory[LayeredPhases, LGraph] {
  match strategy {
    "DEPTH_FIRST" =>
      new_layout_processor_factory(21001, 0, () => {
        new_depth_first_cycle_breaker_layout_phase()
      })
    "INTERACTIVE" =>
      new_layout_processor_factory(21002, 0, () => {
        new_interactive_cycle_breaker_layout_phase()
      })
    "MODEL_ORDER" =>
      new_layout_processor_factory(21003, 0, () => {
        new_model_order_cycle_breaker_layout_phase()
      })
    "GREEDY_MODEL_ORDER" =>
      new_layout_processor_factory(21004, 0, () => {
        new_greedy_model_order_cycle_breaker_layout_phase()
      })
    "SCC_CONNECTIVITY" =>
      new_layout_processor_factory(21005, 0, () => {
        new_sc_connectivity_cycle_breaker_layout_phase()
      })
    "SCC_NODE_TYPE" =>
      new_layout_processor_factory(21006, 0, () => {
        new_scc_node_type_cycle_breaker_layout_phase()
      })
    "DFS_NODE_ORDER" =>
      new_layout_processor_factory(21007, 0, () => {
        new_dfs_node_order_cycle_breaker_layout_phase()
      })
    "BFS_NODE_ORDER" =>
      new_layout_processor_factory(21008, 0, () => {
        new_bfs_node_order_cycle_breaker_layout_phase()
      })
    _ =>
      new_layout_processor_factory(21000, 0, () => {
        new_greedy_cycle_breaker_layout_phase()
      })
  }
}

///|
fn recursive_layered_layering_factory(
  strategy : String,
) -> ILayoutProcessorFactory[LayeredPhases, LGraph] {
  match strategy {
    "LONGEST_PATH" =>
      new_layout_processor_factory(22001, 1, () => {
        new_longest_path_layerer_layout_phase()
      })
    "LONGEST_PATH_SOURCE" =>
      new_layout_processor_factory(22002, 1, () => {
        new_longest_path_source_layerer_layout_phase()
      })
    "COFFMAN_GRAHAM" =>
      new_layout_processor_factory(22003, 1, () => {
        new_coffman_graham_layerer_layout_phase()
      })
    "INTERACTIVE" =>
      new_layout_processor_factory(22004, 1, () => {
        new_interactive_layerer_layout_phase()
      })
    "STRETCH_WIDTH" =>
      new_layout_processor_factory(22005, 1, () => {
        new_stretch_width_layerer_layout_phase()
      })
    "MIN_WIDTH" =>
      new_layout_processor_factory(22006, 1, () => {
        new_min_width_layerer_layout_phase()
      })
    "BF_MODEL_ORDER" =>
      new_layout_processor_factory(22007, 1, () => {
        new_breadth_first_model_order_layerer_layout_phase()
      })
    "DF_MODEL_ORDER" =>
      new_layout_processor_factory(22008, 1, () => {
        new_depth_first_model_order_layerer_layout_phase()
      })
    _ =>
      new_layout_processor_factory(22000, 1, () => {
        new_network_simplex_layerer_layout_phase()
      })
  }
}

///|
fn recursive_layered_crossing_factory(
  strategy : String,
) -> ILayoutProcessorFactory[LayeredPhases, LGraph] {
  match strategy {
    "NONE" =>
      new_layout_processor_factory(23002, 2, () => {
        new_no_crossing_minimizer_layout_phase()
      })
    "INTERACTIVE" =>
      new_layout_processor_factory(23003, 2, () => {
        new_interactive_crossing_minimizer_layout_phase()
      })
    "MEDIAN_LAYER_SWEEP" =>
      new_layout_processor_factory(23001, 2, () => {
        new_layer_sweep_crossing_minimizer_layout_phase(CrossMinType::Median)
      })
    _ =>
      new_layout_processor_factory(23000, 2, () => {
        new_layer_sweep_crossing_minimizer_layout_phase(
          CrossMinType::Barycenter,
        )
      })
  }
}

///|
fn recursive_layered_node_placement_factory(
  strategy : String,
) -> ILayoutProcessorFactory[LayeredPhases, LGraph] {
  match strategy {
    "SIMPLE" =>
      new_layout_processor_factory(24100, 3, () => {
        new_simple_node_placer_layout_phase()
      })
    "BRANDES_KOEPF" =>
      new_layout_processor_factory(24103, 3, () => {
        new_bk_node_placer_layout_phase()
      })
    _ =>
      new_layout_processor_factory(24103, 3, () => {
        new_bk_node_placer_layout_phase()
      })
  }
}

///|
fn recursive_layered_primary_option(
  node : ElkNode,
  key : String,
  fallback : String,
) -> String {
  match node_layout_option_string_value(node, key) {
    Some(value) => value
    None => fallback
  }
}

///|
fn recursive_layered_create_context(node : ElkNode) -> RecursiveLayeredContext? {
  let layered_graph = new_l_graph()
  let elk_to_lnode : Map[ElkNode, LNode] = {}
  let elk_to_lport : Map[ElkPort, LPort] = {}
  let lnode_to_elk : Map[Int, ElkNode] = {}
  let edge_to_ledge : Map[ElkEdge, LEdge] = {}

  let spacing_node = node_get_double_property(node, spacing_node_node)
  let spacing_between_layers = node_get_double_property(
    node, layered_options_spacing_node_node_between_layers,
  )
  let spacing_edge_edge_between_layers = node_get_double_property(
    node, layered_options_spacing_edge_edge_between_layers,
  )
  let consider_model_order = node_get_string_property(
    node, layered_options_consider_model_order_strategy,
  )
  let node_promotion_strategy = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.layered.nodePromotion.strategy",
    node_get_string_property(
      node, layered_options_layering_node_promotion_strategy,
    ),
  )
  let crossing_strategy = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.layered.crossingMinimization.strategy",
    node_get_string_property(
      node, layered_options_crossing_minimization_strategy,
    ),
  )
  let edge_routing_value = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.edgeRouting",
    node_get_string_property(node, edge_routing),
  )
  let cycle_breaking_strategy = recursive_layered_primary_option(
    node, "org.eclipse.elk.layered.cycleBreaking.strategy", "GREEDY",
  )
  let layering_strategy = recursive_layered_primary_option(
    node, "org.eclipse.elk.layered.layering.strategy", "NETWORK_SIMPLEX",
  )
  let needs_model_order = recursive_layered_needs_model_order(
    cycle_breaking_strategy, layering_strategy, node_promotion_strategy, consider_model_order,
  )

  layered_graph.set_property_double(
    spacing_node_node,
    if spacing_node > 0.0 {
      spacing_node
    } else {
      spacing_node_node.get_default()
    },
  )
  layered_graph.set_property_double(
    layered_options_spacing_node_node_between_layers,
    if spacing_between_layers > 0.0 {
      spacing_between_layers
    } else {
      layered_options_spacing_node_node_between_layers.get_default()
    },
  )
  layered_graph.set_property_double(
    layered_options_spacing_edge_edge_between_layers,
    if spacing_edge_edge_between_layers > 0.0 {
      spacing_edge_edge_between_layers
    } else {
      layered_options_spacing_edge_edge_between_layers.get_default()
    },
  )
  layered_graph.set_property_string(
    layered_options_consider_model_order_strategy, consider_model_order,
  )
  layered_graph.set_property_string(
    layered_options_layering_node_promotion_strategy, node_promotion_strategy,
  )
  layered_graph.set_property_string(
    layered_options_crossing_minimization_strategy, crossing_strategy,
  )
  layered_graph.set_property_string(
    edge_routing,
    if edge_routing_value == "UNDEFINED" || edge_routing_value.is_empty() {
      "ORTHOGONAL"
    } else {
      edge_routing_value
    },
  )
  layered_graph.set_property_graph_properties_array(
    internal_properties_graph_properties,
    [],
  )
  layered_graph.set_property_int(
    internal_properties_cb_num_model_order_groups, 0,
  )

  let mut node_model_order = 0
  for child in node_children(node) {
    if node_get_bool_property(child, no_layout) {
      continue
    }
    let lnode = new_l_node(graph=Some(layered_graph))
    lnode.get_size().x = max_positive(node_width(child), 10.0)
    lnode.get_size().y = max_positive(node_height(child), 10.0)
    let original_port_constraints = node_get_string_property(
      child, port_constraints,
    )
    lnode.set_property_string(
      internal_properties_original_port_constraints, original_port_constraints,
    )
    lnode.set_property_string(
      port_constraints,
      if original_port_constraints == "UNDEFINED" {
        "FREE"
      } else {
        original_port_constraints
      },
    )
    if needs_model_order {
      lnode.set_property_int(internal_properties_model_order, node_model_order)
      node_model_order += 1
    }

    for elk_label in node_labels(child) {
      let text = label_text(elk_label)
      if text.is_empty() {
        continue
      }
      let llabel = new_l_label_text(text)
      llabel.get_size().x = label_width(elk_label)
      llabel.get_size().y = label_height(elk_label)
      llabel.get_position().x = label_x(elk_label)
      llabel.get_position().y = label_y(elk_label)
      lnode.get_labels().push(llabel)
    }

    let mut port_model_order = 0
    for elk_port in node_ports(child) {
      let lport = new_l_port()
      lport.set_node(Some(lnode))
      lport.set_side(
        recursive_layered_port_side_from_string(
          recursive_layered_port_side_option(elk_port),
        ),
      )
      lport.get_size().x = port_width(elk_port)
      lport.get_size().y = port_height(elk_port)
      lport.get_position().x = port_x(elk_port)
      lport.get_position().y = port_y(elk_port)
      if needs_model_order {
        lport.set_property_int(
          internal_properties_model_order, port_model_order,
        )
        port_model_order += 1
      }
      elk_to_lport[elk_port] = lport
    }

    layered_graph.get_layerless_nodes().push(lnode)
    elk_to_lnode[child] = lnode
    lnode_to_elk[lnode.get_handle()] = child
  }
  layered_graph.set_property_int(
    internal_properties_max_model_order_nodes, node_model_order,
  )

  let mut edge_model_order = 0
  for edge in node_contained_edges(node) {
    let source_node = match
      recursive_layered_edge_endpoint_node(edge_sources(edge)) {
      Some(value) => value
      None => return None
    }
    let target_node = match
      recursive_layered_edge_endpoint_node(edge_targets(edge)) {
      Some(value) => value
      None => return None
    }
    let source_lnode = match elk_to_lnode.get(source_node) {
      Some(value) => value
      None => return None
    }
    let target_lnode = match elk_to_lnode.get(target_node) {
      Some(value) => value
      None => return None
    }

    let source_port = match
      recursive_layered_edge_endpoint_port(edge_sources(edge), elk_to_lport) {
      Some(port) => port
      None => recursive_layered_new_edge_port(source_lnode, PortSide::East)
    }
    let target_port = match
      recursive_layered_edge_endpoint_port(edge_targets(edge), elk_to_lport) {
      Some(port) => port
      None => recursive_layered_new_edge_port(target_lnode, PortSide::West)
    }

    let l_edge = new_l_edge()
    l_edge.set_source(Some(source_port))
    l_edge.set_target(Some(target_port))
    if needs_model_order {
      l_edge.set_property_int(internal_properties_model_order, edge_model_order)
      edge_model_order += 1
    }
    l_edge.set_property_double(edge_thickness, edge_thickness.get_default())

    for elk_label in edge_labels(edge) {
      let text = label_text(elk_label)
      if text.is_empty() {
        continue
      }
      let llabel = new_l_label_text(text)
      llabel.get_size().x = label_width(elk_label)
      llabel.get_size().y = label_height(elk_label)
      llabel.get_position().x = label_x(elk_label)
      llabel.get_position().y = label_y(elk_label)
      l_edge.get_labels().push(llabel)
    }

    edge_to_ledge[edge] = l_edge
  }

  Some({ layered_graph, elk_to_lnode, lnode_to_elk, edge_to_ledge })
}

///|
fn recursive_layered_apply_layout(
  context : RecursiveLayeredContext,
  parent_node : ElkNode,
) -> Unit {
  let mut rightmost = 0.0
  let mut max_bottom = 0.0
  let graph_offset = context.layered_graph.get_offset()

  for entry in context.elk_to_lnode.to_array() {
    let (elk_node, layered_node) = entry
    let position = layered_node.get_position()
    let size = layered_node.get_size()
    let actual_x = position.x + graph_offset.x
    let actual_y = position.y + graph_offset.y
    node_set_location(elk_node, actual_x, actual_y)
    node_set_dimensions(elk_node, size.x, size.y)

    if actual_x + size.x > rightmost {
      rightmost = actual_x + size.x
    }
    if actual_y + size.y > max_bottom {
      max_bottom = actual_y + size.y
    }
  }

  for entry in context.edge_to_ledge.to_array() {
    let (elk_edge, layered_edge) = entry
    ensure_edge_section_for_edge(elk_edge)
    if edge_sections(elk_edge).is_empty() {
      continue
    }
    let section = edge_sections(elk_edge)[0]
    let source_port = match layered_edge.get_source() {
      Some(value) => value
      None => continue
    }
    let target_port = match layered_edge.get_target() {
      Some(value) => value
      None => continue
    }
    let source_anchor = source_port.get_absolute_anchor()
    let target_anchor = target_port.get_absolute_anchor()
    edge_section_set_start(
      section,
      source_anchor.x + graph_offset.x,
      source_anchor.y + graph_offset.y,
    )
    edge_section_set_end(
      section,
      target_anchor.x + graph_offset.x,
      target_anchor.y + graph_offset.y,
    )

    let source_node = match source_port.get_node() {
      Some(value) => value
      None => continue
    }
    let target_node = match target_port.get_node() {
      Some(value) => value
      None => continue
    }
    match context.lnode_to_elk.get(source_node.get_handle()) {
      Some(elk_source) =>
        edge_section_set_incoming_shape(
          section,
          Some(make_node_shape(elk_source)),
        )
      None => ()
    }
    match context.lnode_to_elk.get(target_node.get_handle()) {
      Some(elk_target) =>
        edge_section_set_outgoing_shape(
          section,
          Some(make_node_shape(elk_target)),
        )
      None => ()
    }
  }

  let padding_value = parse_node_padding(parent_node)
  let mut width = rightmost + padding_value.left + padding_value.right
  let mut height = max_bottom + padding_value.top + padding_value.bottom
  if width < 10.0 {
    width = 10.0
  }
  if height < 10.0 {
    height = 10.0
  }
  node_set_dimensions(parent_node, width, height)
}

///|
fn recursive_layered_try_layout(
  node : ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Bool {
  let context = match recursive_layered_create_context(node) {
    Some(value) => value
    None => return false
  }

  let layering_strategy = recursive_layered_primary_option(
    node, "org.eclipse.elk.layered.layering.strategy", "NETWORK_SIMPLEX",
  )
  let cycle_breaking_strategy = recursive_layered_primary_option(
    node, "org.eclipse.elk.layered.cycleBreaking.strategy", "GREEDY",
  )
  let crossing_strategy = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.layered.crossingMinimization.strategy",
    context.layered_graph.get_property_string(
      layered_options_crossing_minimization_strategy,
    ),
  )
  let node_placement_strategy = recursive_layered_primary_option(
    node, "org.eclipse.elk.layered.nodePlacement.strategy", "BRANDES_KOEPF",
  )
  let edge_routing_value = context.layered_graph.get_property_string(
    edge_routing,
  )

  let assembler = algorithm_assembler_create(layered_phase_descriptor)
  ignore(assembler.reset())
  ignore(
    assembler.set_phase(
      LayeredPhases::P1CycleBreaking,
      recursive_layered_cycle_breaking_factory(cycle_breaking_strategy),
    ),
  )
  ignore(
    assembler.set_phase(
      LayeredPhases::P2Layering,
      recursive_layered_layering_factory(layering_strategy),
    ),
  )
  ignore(
    assembler.set_phase(
      LayeredPhases::P3NodeOrdering,
      recursive_layered_crossing_factory(crossing_strategy),
    ),
  )
  ignore(
    assembler.set_phase(
      LayeredPhases::P4NodePlacement,
      recursive_layered_node_placement_factory(node_placement_strategy),
    ),
  )
  ignore(
    assembler.set_phase(
      LayeredPhases::P5EdgeRouting,
      edge_router_factory_factory_for(
        recursive_layered_parse_edge_routing(edge_routing_value),
      ),
    ),
  )
  ignore(
    assembler.add_processor_configuration(
      layout_processor_configuration_create(layered_phase_descriptor)
      .add_before(
        LayeredPhases::P3NodeOrdering,
        new_layout_processor_factory(23030, 30, () => {
          new_port_side_processor_layout_processor()
        }),
      )
      .add_before(
        LayeredPhases::P5EdgeRouting,
        new_layout_processor_factory(23040, 40, () => {
          new_layer_size_and_graph_height_calculator_layout_processor()
        }),
      ),
    ),
  )

  if context.layered_graph.get_property_string(
      layered_options_consider_model_order_strategy,
    ) !=
    "NONE" {
    ignore(
      assembler.add_processor_configuration(
        layout_processor_configuration_create(layered_phase_descriptor).add_before(
          LayeredPhases::P3NodeOrdering,
          new_layout_processor_factory(23039, 39, () => {
            new_sort_by_input_model_processor_layout_processor()
          }),
        ),
      ),
    )
  }

  let algorithm = assembler.build(context.layered_graph)
  let algorithm_monitor = match progress_monitor.sub_task(1.0) {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(
    algorithm_monitor.begin("Layered layout", algorithm.length().to_double()),
  )
  for processor in algorithm {
    if algorithm_monitor.is_canceled() {
      algorithm_monitor.done()
      return false
    }
    processor.process(context.layered_graph, algorithm_monitor.sub_task(1.0))
  }
  algorithm_monitor.done()
  recursive_layered_apply_layout(context, node)
  true
}

///|
fn layout_node_recursively(
  node : ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  if node_get_bool_property(node, no_layout) {
    return
  }
  let children = node_children(node)
  for child in children {
    layout_node_recursively(child, progress_monitor)
  }
  if children.is_empty() {
    recursive_layout_node_labels(node)
    return
  }
  let resolved = node_get_string_property(node, resolved_algorithm)
  if resolved.is_empty() {
    abort("Resolved algorithm is not set")
  }
  if layout_meta_data_service_get_algorithm_data_by_suffix(resolved) is None {
    abort("Resolved algorithm is unknown")
  }
  if resolved == mrtree_algorithm_id {
    let provider = new_mrtree_tree_layout_provider()
    provider.layout(node, progress_monitor)
    return
  }
  if resolved == "org.eclipse.elk.layered" {
    if recursive_layered_try_layout(node, progress_monitor) {
      return
    }
  }
  let mut rightmost = 0.0
  let mut max_height = 0.0
  let mut cursor_x = 12.0
  for child in children {
    let child_width = max_positive(node_width(child), 10.0)
    let child_height = max_positive(node_height(child), 10.0)
    node_set_dimensions(child, child_width, child_height)
    node_set_location(child, cursor_x, 12.0)
    let child_right = cursor_x + child_width
    if child_right > rightmost {
      rightmost = child_right
    }
    cursor_x = child_right + 20.0
    if child_height > max_height {
      max_height = child_height
    }
  }
  for edge in node_contained_edges(node) {
    ensure_edge_section_for_edge(edge)
  }
  let padding_value = parse_node_padding(node)
  if children.length() == 1 {
    let child = children[0]
    let child_width = max_positive(node_width(child), 10.0)
    let child_height = max_positive(node_height(child), 10.0)
    let requested_width = child_width + padding_value.left + padding_value.right
    let requested_height = child_height +
      padding_value.top +
      padding_value.bottom
    if requested_width > rightmost + 12.0 {
      rightmost = requested_width - 12.0
    }
    if requested_height > max_height + 24.0 {
      max_height = requested_height - 24.0
    }
  }
  let mut width = max_positive(rightmost + 12.0, 10.0)
  let mut height = max_positive(max_height + 24.0, 10.0)
  if has_minimum_size_constraint(node) {
    let min_size = parse_node_minimum_size(node)
    if width < min_size.x {
      width = min_size.x
    }
    if height < min_size.y {
      height = min_size.y
    }
  }
  node_set_dimensions(node, width, height)
  if children.length() == 1 {
    let child = children[0]
    let child_width = max_positive(
      node_width(node) - padding_value.left - padding_value.right,
      0.0,
    )
    let child_height = max_positive(
      node_height(node) - padding_value.top - padding_value.bottom,
      0.0,
    )
    node_set_location(child, padding_value.left, padding_value.top)
    node_set_dimensions(child, child_width, child_height)
  }
  recursive_layout_node_labels(node)
}

///|
pub fn RecursiveGraphLayoutEngine::layout(
  self : RecursiveGraphLayoutEngine,
  layout_graph : ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  ignore(self)
  ignore(progress_monitor.begin("Recursive Graph Layout", 1.0))
  if node_get_string_property(layout_graph, resolved_algorithm).is_empty() {
    let resolver = new_layout_algorithm_resolver()
    apply_visitors(layout_graph, [resolver.to_visitor()])
  }
  layout_node_recursively(layout_graph, progress_monitor)
  progress_monitor.done()
}
