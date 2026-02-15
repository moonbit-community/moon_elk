///|
fn sort_by_input_model_processor_ordering_strategy_from_string(
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
fn sort_by_input_model_processor_long_edge_ordering_strategy_from_string(
  value : String,
) -> LongEdgeOrderingStrategy {
  match value {
    "DUMMY_NODE_UNDER" => LongEdgeOrderingStrategy::DummyNodeUnder
    "EQUAL" => LongEdgeOrderingStrategy::Equal
    _ => LongEdgeOrderingStrategy::DummyNodeOver
  }
}

///|
fn sort_by_input_model_processor_port_constraints_from_string(
  value : String,
) -> PortConstraints {
  match value {
    "UNDEFINED" => PortConstraints::Undefined
    "FREE" => PortConstraints::Free
    "FIXED_SIDE" => PortConstraints::FixedSide
    "FIXED_ORDER" => PortConstraints::FixedOrder
    "FIXED_RATIO" => PortConstraints::FixedRatio
    "FIXED_POS" => PortConstraints::FixedPos
    _ => PortConstraints::Undefined
  }
}

///|
fn sort_by_input_model_processor_node_type_is_normal(
  node_type : NodeType,
) -> Bool {
  match node_type {
    NodeType::Normal => true
    _ => false
  }
}

///|
fn sort_by_input_model_processor_constraints_skip_port_sort(
  constraints : PortConstraints,
) -> Bool {
  match constraints {
    PortConstraints::FixedOrder => true
    PortConstraints::FixedPos => true
    _ => false
  }
}

///|
fn sort_by_input_model_processor_minimum(left : Int, right : Int) -> Int {
  if left < right {
    left
  } else {
    right
  }
}

///|
pub fn sort_by_input_model_processor_long_edge_target_node_preprocessing(
  node : LNode,
) -> Map[Int, Int] {
  if node.has_property_int_int_map(internal_properties_target_node_model_order) {
    return node.get_property_int_int_map(
      internal_properties_target_node_model_order,
    )
  }

  let target_node_model_order : Map[Int, Int] = {}

  for port in node.get_ports() {
    if port.get_outgoing_edges().is_empty() {
      continue
    }

    let target_node = sort_by_input_model_processor_get_target_node(port)
    port.set_property_l_node(
      internal_properties_long_edge_target_node, target_node,
    )

    match target_node {
      Some(target) => {
        let target_handle = target.get_handle()
        let mut previous_order = @int.max_value
        match target_node_model_order.get(target_handle) {
          Some(value) => previous_order = value
          None => ()
        }

        let edge = port.get_outgoing_edges()[0]
        if !edge.get_property_bool(internal_properties_reversed) {
          target_node_model_order[target_handle] = sort_by_input_model_processor_minimum(
            edge.get_property_int(internal_properties_model_order),
            previous_order,
          )
        }
      }
      None => ()
    }
  }

  node.set_property_int_int_map(
    internal_properties_target_node_model_order, target_node_model_order,
  )
  node.get_property_int_int_map(internal_properties_target_node_model_order)
}

///|
fn sort_by_input_model_processor_get_target_node_from_edge(
  edge : LEdge,
) -> LNode? {
  let node = match edge.get_target() {
    Some(target_port) => target_port.get_node()
    None => None
  }

  match node {
    Some(value) => {
      if value.has_property_l_port(internal_properties_long_edge_target) {
        return match
          value.get_property_l_port(internal_properties_long_edge_target) {
          Some(target_port) => target_port.get_node()
          None => None
        }
      }

      if !sort_by_input_model_processor_node_type_is_normal(value.get_type()) {
        let outgoing = value.get_outgoing_edges()
        if outgoing.is_empty() {
          return None
        }
        return sort_by_input_model_processor_get_target_node_from_edge(
          outgoing[0],
        )
      }

      Some(value)
    }
    None => None
  }
}

///|
pub fn sort_by_input_model_processor_get_target_node(port : LPort) -> LNode? {
  if port.get_outgoing_edges().is_empty() {
    None
  } else {
    sort_by_input_model_processor_get_target_node_from_edge(
      port.get_outgoing_edges()[0],
    )
  }
}

///|
pub fn sort_by_input_model_processor_insertion_sort(
  layer : Array[LNode],
  comparator : ModelOrderNodeComparator,
) -> Unit {
  let mut i = 1
  while i < layer.length() {
    let current = layer[i]
    let mut j = i
    while j > 0 && comparator.compare(layer[j - 1], current) > 0 {
      layer[j] = layer[j - 1]
      j -= 1
    }
    layer[j] = current
    i += 1
  }
  comparator.clear_transitive_ordering()
}

///|
pub fn sort_by_input_model_processor_insertion_sort_port(
  ports : Array[LPort],
  comparator : ModelOrderPortComparator,
) -> Unit {
  let mut i = 1
  while i < ports.length() {
    let current = ports[i]
    let mut j = i
    while j > 0 && comparator.compare(ports[j - 1], current) > 0 {
      ports[j] = ports[j - 1]
      j -= 1
    }
    ports[j] = current
    i += 1
  }
  comparator.clear_transitive_ordering()
}

///|
fn sort_by_input_model_processor_process(
  graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(
    monitor.begin(
      "Sort By Input Model " +
      graph.get_property_string(layered_options_consider_model_order_strategy),
      1.0,
    ),
  )

  let ordering_strategy = sort_by_input_model_processor_ordering_strategy_from_string(
    graph.get_property_string(layered_options_consider_model_order_strategy),
  )
  let long_edge_strategy = sort_by_input_model_processor_long_edge_ordering_strategy_from_string(
    graph.get_property_string(
      layered_options_consider_model_order_long_edge_strategy,
    ),
  )
  let group_order_strategy = group_order_strategy_from_string(
    graph.get_property_string(
      layered_options_consider_model_order_group_model_order_cm_group_order_strategy,
    ),
  )
  let port_model_order = graph.get_property_bool(
    layered_options_consider_model_order_port_model_order,
  )

  let mut layer_index = 0
  for layer in graph.get_layers() {
    layer.set_id(layer_index)
    let previous_layer_index = if layer_index == 0 {
      0
    } else {
      layer_index - 1
    }
    let previous_layer = graph.get_layers()[previous_layer_index]

    let comparator_before_ports = new_model_order_node_comparator_from_layer(
      graph, previous_layer, ordering_strategy, long_edge_strategy, group_order_strategy,
      true,
    )
    sort_by_input_model_processor_insertion_sort(
      layer.get_nodes(),
      comparator_before_ports,
    )

    for node in layer.get_nodes() {
      let constraints_value = if node.has_property_string(port_constraints) {
        node.get_property_string(port_constraints)
      } else {
        port_constraints.get_default()
      }
      let constraints = sort_by_input_model_processor_port_constraints_from_string(
        constraints_value,
      )
      if sort_by_input_model_processor_constraints_skip_port_sort(constraints) {
        continue
      }

      let port_comparator = new_model_order_port_comparator_from_layer(
        graph,
        previous_layer,
        ordering_strategy,
        sort_by_input_model_processor_long_edge_target_node_preprocessing(node),
        port_model_order,
      )
      node
      .get_ports()
      .sort_by((left, right) => port_comparator.compare(left, right))
      port_comparator.clear_transitive_ordering()

      if monitor.is_logging_enabled() {
        monitor.log(
          "Node " +
          node.to_string() +
          " ports: " +
          node.get_ports().length().to_string(),
        )
      }
    }

    let comparator_after_ports = new_model_order_node_comparator_from_layer(
      graph, previous_layer, ordering_strategy, long_edge_strategy, group_order_strategy,
      false,
    )
    sort_by_input_model_processor_insertion_sort(
      layer.get_nodes(),
      comparator_after_ports,
    )

    if monitor.is_logging_enabled() {
      monitor.log("Layer " + layer_index.to_string() + ": " + layer.to_string())
    }
    layer_index = layer_index + 1
  }

  monitor.done()
}

///|
pub fn new_sort_by_input_model_processor_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(sort_by_input_model_processor_process)
}
