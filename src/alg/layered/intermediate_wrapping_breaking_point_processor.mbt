///|
priv suberror BreakingPointProcessorException {
  BreakingPointProcessorException(String)
} derive(Show, ToJson)

///|
fn[T] breaking_point_processor_raise(
  message : String,
) -> T raise BreakingPointProcessorException {
  raise BreakingPointProcessorException(message)
}

///|
fn breaking_point_processor_node_type_equals(
  left : NodeType,
  right : NodeType,
) -> Bool {
  match (left, right) {
    (NodeType::Normal, NodeType::Normal) => true
    (NodeType::LongEdge, NodeType::LongEdge) => true
    (NodeType::ExternalPort, NodeType::ExternalPort) => true
    (NodeType::NorthSouthPort, NodeType::NorthSouthPort) => true
    (NodeType::LabelNode, NodeType::LabelNode) => true
    (NodeType::BreakingPoint, NodeType::BreakingPoint) => true
    (NodeType::Placeholder, NodeType::Placeholder) => true
    (NodeType::NonshiftingPlaceholder, NodeType::NonshiftingPlaceholder) => true
    _ => false
  }
}

///|
fn breaking_point_processor_reverse_edge(edge : LEdge, graph : LGraph) -> Unit {
  edge.reverse(graph, true)
}

///|
fn breaking_point_processor_set_layer_with_index(
  node : LNode,
  target_layer : Layer,
  insert_index : Int,
) -> Unit {
  node.set_layer(Some(target_layer))
  let nodes = target_layer.get_nodes()

  let mut current_idx = -1
  for i in 0..<nodes.length() {
    if nodes[i].get_handle() == node.get_handle() {
      current_idx = i
      break
    }
  }
  if current_idx < 0 {
    return
  }

  let mut target_idx = insert_index
  if target_idx < 0 {
    target_idx = 0
  }
  if target_idx > nodes.length() - 1 {
    return
  }
  if target_idx == current_idx {
    return
  }

  let moved = nodes[current_idx]
  ignore(nodes.remove(current_idx))
  ignore(nodes.insert(target_idx, moved))
}

///|
fn breaking_point_processor_require_bp_info(
  node : LNode,
) -> BPInfo raise BreakingPointProcessorException {
  match node.get_property_bp_info(internal_properties_breaking_point_info) {
    Some(value) => value
    None => breaking_point_processor_raise("breaking-point node has no BPInfo")
  }
}

///|
fn breaking_point_processor_require_node_layer(
  node : LNode,
) -> Layer raise BreakingPointProcessorException {
  match node.get_layer() {
    Some(value) => value
    None => breaking_point_processor_raise("node has no layer")
  }
}

///|
fn breaking_point_processor_require_bp_in_layer_dummy(
  dummy : LNode?,
) -> LNode raise BreakingPointProcessorException {
  match dummy {
    Some(value) => value
    None => breaking_point_processor_raise("BPInfo in-layer dummy is missing")
  }
}

///|
fn breaking_point_processor_require_bp_in_layer_edge(
  edge : LEdge?,
) -> LEdge raise BreakingPointProcessorException {
  match edge {
    Some(value) => value
    None => breaking_point_processor_raise("BPInfo in-layer edge is missing")
  }
}

///|
fn breaking_point_processor_reverse_array(nodes : Array[LNode]) -> Array[LNode] {
  let result = []
  let mut index = nodes.length()
  while index > 0 {
    index = index - 1
    result.push(nodes[index])
  }
  result
}

///|
fn breaking_point_processor_update_indexes_after(
  node : LNode,
) -> Unit raise BreakingPointProcessorException {
  let layer = breaking_point_processor_require_node_layer(node)
  let layer_nodes = layer.get_nodes()
  let mut i = node.get_id() + 1
  while i < layer_nodes.length() {
    let curr = layer_nodes[i]
    curr.set_id(curr.get_id() - 1)
    i = i + 1
  }
}

///|
fn breaking_point_processor_other_node_or_raise(
  edge : LEdge,
  node : LNode,
) -> LNode raise BreakingPointProcessorException {
  try edge.get_other_node(node) catch {
    LEdgeException::IllegalArgumentException(message) =>
      breaking_point_processor_raise(message)
    LEdgeException::IllegalStateException(message) =>
      breaking_point_processor_raise(message)
  } noraise {
    other => other
  }
}

///|
fn breaking_point_processor_is_in_layer_dummy(
  node : LNode,
) -> Bool raise BreakingPointProcessorException {
  if !breaking_point_processor_node_type_equals(
      node.get_type(),
      NodeType::LongEdge,
    ) {
    return false
  }

  for edge in node.get_connected_edges() {
    if !edge.is_self_loop() {
      let other = breaking_point_processor_other_node_or_raise(edge, node)
      let node_layer = node.get_layer()
      let other_layer = other.get_layer()
      match (node_layer, other_layer) {
        (Some(left), Some(right)) =>
          if left.get_index() == right.get_index() {
            return true
          }
        _ => ()
      }
    }
  }

  false
}

///|
fn breaking_point_processor_next_long_edge_dummy(
  start : LNode,
  forwards : Bool,
) -> LNode? raise BreakingPointProcessorException {
  let edges = if forwards {
    start.get_outgoing_edges()
  } else {
    start.get_incoming_edges()
  }

  for edge in edges {
    let other = breaking_point_processor_other_node_or_raise(edge, start)
    if breaking_point_processor_node_type_equals(
        other.get_type(),
        NodeType::LongEdge,
      ) {
      match (other.get_layer(), start.get_layer()) {
        (Some(other_layer), Some(start_layer)) =>
          if other_layer.get_index() != start_layer.get_index() {
            return Some(other)
          }
        _ => ()
      }
    }
  }
  None
}

///|
fn breaking_point_processor_is_adjacent_or_separated_by_breakingpoints(
  dummy_1 : LNode,
  dummy_2 : LNode,
  forwards : Bool,
) -> Bool raise BreakingPointProcessorException {
  let layer = breaking_point_processor_require_node_layer(dummy_1)
  let start = if forwards { dummy_2 } else { dummy_1 }
  let end = if forwards { dummy_1 } else { dummy_2 }

  let mut i = start.get_id() + 1
  while i < end.get_id() {
    let node = layer.get_nodes()[i]
    if !breaking_point_processor_node_type_equals(
        node.get_type(),
        NodeType::BreakingPoint,
      ) &&
      !breaking_point_processor_is_in_layer_dummy(node) {
      return false
    }
    i = i + 1
  }

  true
}

///|
fn breaking_point_processor_drop_dummies(
  bp_node : LNode,
  in_layer_dummy : LNode,
  forwards : Bool,
  force : Bool,
) -> Bool raise BreakingPointProcessorException {
  let mut pred_one = breaking_point_processor_next_long_edge_dummy(
    bp_node, forwards,
  )
  let mut pred_two = breaking_point_processor_next_long_edge_dummy(
    in_layer_dummy, forwards,
  )

  let mut didsome = false

  while pred_one is Some(_) && pred_two is Some(_) {
    let first = match pred_one {
      Some(value) => value
      None => breaking_point_processor_raise("unreachable")
    }
    let second = match pred_two {
      Some(value) => value
      None => breaking_point_processor_raise("unreachable")
    }

    if force ||
      breaking_point_processor_is_adjacent_or_separated_by_breakingpoints(
        first, second, forwards,
      ) {
      let next_one = breaking_point_processor_next_long_edge_dummy(
        first, forwards,
      )
      let next_two = breaking_point_processor_next_long_edge_dummy(
        second, forwards,
      )

      breaking_point_processor_update_indexes_after(in_layer_dummy)
      breaking_point_processor_update_indexes_after(bp_node)

      let new_layer = breaking_point_processor_require_node_layer(first)

      long_edge_joiner_join_at(first, false)
      long_edge_joiner_join_at(second, false)

      if forwards {
        breaking_point_processor_set_layer_with_index(
          in_layer_dummy,
          new_layer,
          second.get_id(),
        )
        in_layer_dummy.set_id(second.get_id())

        breaking_point_processor_set_layer_with_index(
          bp_node,
          new_layer,
          first.get_id() + 1,
        )
        bp_node.set_id(first.get_id())
      } else {
        breaking_point_processor_set_layer_with_index(
          bp_node,
          new_layer,
          first.get_id(),
        )
        bp_node.set_id(first.get_id())

        breaking_point_processor_set_layer_with_index(
          in_layer_dummy,
          new_layer,
          second.get_id() + 1,
        )
        in_layer_dummy.set_id(second.get_id())
      }

      first.set_layer(None)
      second.set_layer(None)

      pred_one = next_one
      pred_two = next_two
      didsome = true
    } else {
      break
    }
  }

  didsome
}

///|
fn breaking_point_processor_improve_multi_cut_index_edges(
  graph : LGraph,
) -> Unit raise BreakingPointProcessorException {
  for layer in graph.get_layers() {
    for node in layer.get_nodes().copy() {
      if bp_info_is_start(node) {
        let info = breaking_point_processor_require_bp_info(node)

        if info.prev is None && info.next is Some(_) {
          let mut current = info
          let mut next = info.next

          while next is Some(_) {
            let next_info = match next {
              Some(value) => value
              None => breaking_point_processor_raise("unreachable")
            }

            ignore(
              breaking_point_processor_drop_dummies(
                next_info.start,
                breaking_point_processor_require_bp_in_layer_dummy(
                  next_info.start_in_layer_dummy,
                ),
                false,
                true,
              ),
            )

            breaking_point_processor_update_indexes_after(current.end)
            breaking_point_processor_update_indexes_after(next_info.start)
            breaking_point_processor_update_indexes_after(
              breaking_point_processor_require_bp_in_layer_dummy(
                next_info.start_in_layer_dummy,
              ),
            )
            breaking_point_processor_update_indexes_after(
              breaking_point_processor_require_bp_in_layer_dummy(
                next_info.end_in_layer_dummy,
              ),
            )

            breaking_point_processor_require_bp_in_layer_edge(
              next_info.end_in_layer_edge,
            ).set_target(
              breaking_point_processor_require_bp_in_layer_edge(
                current.end_in_layer_edge,
              ).get_target(),
            )
            breaking_point_processor_require_bp_in_layer_edge(
              current.end_in_layer_edge,
            ).set_target(None)

            current.end.set_layer(None)
            next_info.start.set_layer(None)
            breaking_point_processor_require_bp_in_layer_dummy(
              next_info.start_in_layer_dummy,
            ).set_layer(None)
            breaking_point_processor_require_bp_in_layer_dummy(
              next_info.end_in_layer_dummy,
            ).set_layer(None)

            let new_info = new_bp_info(
              current.start,
              next_info.end,
              current.node_start_edge,
              next_info.start_end_edge,
              next_info.original_edge,
            )
            new_info.set_start_in_layer_dummy(current.start_in_layer_dummy)
            new_info.set_start_in_layer_edge(current.start_in_layer_edge)
            new_info.set_end_in_layer_dummy(current.end_in_layer_dummy)
            new_info.set_end_in_layer_edge(next_info.end_in_layer_edge)
            new_info.set_prev(current.prev)
            new_info.set_next(next_info.next)

            current.start.set_property_bp_info(
              internal_properties_breaking_point_info,
              Some(new_info),
            )
            next_info.end.set_property_bp_info(
              internal_properties_breaking_point_info,
              Some(new_info),
            )

            next = next_info.next
            current = new_info
          }
        }
      }
    }
  }
}

///|
fn breaking_point_processor_improve_unnecessarily_long_edges(
  graph : LGraph,
  forwards : Bool,
) -> Unit raise BreakingPointProcessorException {
  let mut didsome = false
  while true {
    didsome = false

    let layers = if forwards {
      let reversed_layers = []
      let mut idx = graph.get_layers().length()
      while idx > 0 {
        idx = idx - 1
        reversed_layers.push(graph.get_layers()[idx])
      }
      reversed_layers
    } else {
      graph.get_layers()
    }

    for layer in layers {
      let nodes = if forwards {
        breaking_point_processor_reverse_array(layer.get_nodes().copy())
      } else {
        layer.get_nodes().copy()
      }

      for node in nodes {
        let check = if forwards {
          bp_info_is_end(node)
        } else {
          bp_info_is_start(node)
        }
        if check {
          let bp_info = breaking_point_processor_require_bp_info(node)
          let dummy = if forwards {
            breaking_point_processor_require_bp_in_layer_dummy(
              bp_info.end_in_layer_dummy,
            )
          } else {
            breaking_point_processor_require_bp_in_layer_dummy(
              bp_info.start_in_layer_dummy,
            )
          }
          didsome = breaking_point_processor_drop_dummies(
            node, dummy, forwards, false,
          )
        }
      }
    }

    if !didsome {
      break
    }
  }
}

///|
fn breaking_point_processor_perform_wrapping(
  graph : LGraph,
) -> Unit raise BreakingPointProcessorException {
  let layers = graph.get_layers()
  ignore(layers.insert(0, new_layer(graph)))
  let traversed_layers = layers.copy()

  let mut reverse = false
  let mut idx = 1

  let mut layer_idx = 1
  while layer_idx < traversed_layers.length() {
    let layer = traversed_layers[layer_idx]
    let new_layer = layers[idx]
    let nodes_to_move = layer.get_nodes().copy()

    let offset = nodes_to_move.length()

    for node in nodes_to_move {
      node.set_layer(Some(new_layer))
    }

    if reverse {
      let reversed_nodes = breaking_point_processor_reverse_array(nodes_to_move)
      for node in reversed_nodes {
        for edge in node.get_incoming_edges().copy() {
          breaking_point_processor_reverse_edge(edge, graph)
          graph.set_property_bool(internal_properties_cyclic, true)

          let dummy_edges = try
            cutting_utils_insert_dummies(graph, edge, offset)
          catch {
            CuttingUtilsException(message) =>
              breaking_point_processor_raise(message)
          } noraise {
            value => value
          }

          let bp_info = breaking_point_processor_require_bp_info(node)
          let start_in_layer_edge = dummy_edges[dummy_edges.length() - 1]
          let start_in_layer_dummy = try
            breaking_point_inserter_require_port_node(
              breaking_point_inserter_require_edge_source(start_in_layer_edge),
            )
          catch {
            BreakingPointInserterException(message) =>
              breaking_point_processor_raise(message)
          } noraise {
            value => value
          }
          bp_info.set_start_in_layer_dummy(Some(start_in_layer_dummy))
          bp_info.set_start_in_layer_edge(Some(start_in_layer_edge))
          let end_in_layer_dummy = try
            breaking_point_inserter_require_port_node(
              breaking_point_inserter_require_edge_target(edge),
            )
          catch {
            BreakingPointInserterException(message) =>
              breaking_point_processor_raise(message)
          } noraise {
            value => value
          }
          bp_info.set_end_in_layer_dummy(Some(end_in_layer_dummy))
          bp_info.set_end_in_layer_edge(Some(edge))
        }
      }
      reverse = false
    } else if !nodes_to_move.is_empty() {
      let a_node = nodes_to_move[0]
      if breaking_point_processor_node_type_equals(
          a_node.get_type(),
          NodeType::BreakingPoint,
        ) {
        reverse = true
        idx = -1
      }
    }

    idx = idx + 1
    layer_idx = layer_idx + 1
  }

  let graph_layers = graph.get_layers()
  let mut i = 0
  while i < graph_layers.length() {
    if graph_layers[i].get_nodes().is_empty() {
      ignore(graph_layers.remove(i))
    } else {
      i = i + 1
    }
  }
}

///|
fn breaking_point_processor_process(
  graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Breaking Point Processor", 1.0))

  try {
    breaking_point_processor_perform_wrapping(graph)

    if graph.get_property_bool(
        layered_options_wrapping_multi_edge_improve_wrapped_edges,
      ) {
      for layer in graph.get_layers() {
        let mut index = 0
        for node in layer.get_nodes() {
          node.set_id(index)
          index = index + 1
        }
      }

      breaking_point_processor_improve_multi_cut_index_edges(graph)

      breaking_point_processor_improve_unnecessarily_long_edges(graph, true)
      breaking_point_processor_improve_unnecessarily_long_edges(graph, false)
    }
  } catch {
    BreakingPointProcessorException(message) =>
      @core.layout_runtime_report_unsupported_configuration(
        "java.lang.IllegalStateException: " + message,
      )
  } noraise {
    _ => ()
  }

  monitor.done()
}

///|
pub fn new_breaking_point_processor_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(breaking_point_processor_process)
}
