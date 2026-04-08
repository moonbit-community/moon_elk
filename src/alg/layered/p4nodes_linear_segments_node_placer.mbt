///|
priv suberror LinearSegmentsNodePlacerException {
  LinearSegmentsNodePlacerException(String)
} derive(Debug, ToJson)

///|
fn[T] linear_segments_raise(
  message : String,
) -> T raise LinearSegmentsNodePlacerException {
  raise LinearSegmentsNodePlacerException(message)
}

///|
let linear_segments_input_prio : @graph.IProperty[Int] = @graph.new_property(
  "linearSegments.inputPrio", 0,
)

///|
let linear_segments_output_prio : @graph.IProperty[Int] = @graph.new_property(
  "linearSegments.outputPrio", 0,
)

///|
let linear_segments_option_deflection_dampening : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.alg.layered.nodePlacement.linearSegments.deflectionDampening",
  0.3,
)

///|
let linear_segments_threshold_factor : Double = 20.0

///|
let linear_segments_pendulum_iters : Int = 4

///|
let linear_segments_final_iters : Int = 3

///|
let linear_segments_overlap_detect : Double = 0.0001

///|
priv enum LinearSegmentsMode {
  ForwPendulum
  BackwPendulum
  Rubber
}

///|
struct LinearSegment {
  nodes : Array[LNode]
  mut id : Int
  mut index_in_last_layer : Int
  mut last_layer : Int
  mut deflection : Double
  mut weight : Int
  mut ref_segment_id : Int
  mut _node_type : NodeType
}

///|
fn new_linear_segment(id : Int) -> LinearSegment {
  {
    nodes: [],
    id,
    index_in_last_layer: -1,
    last_layer: -1,
    deflection: 0.0,
    weight: 0,
    ref_segment_id: -1,
    _node_type: NodeType::Normal,
  }
}

///|
priv struct LinearSegmentsState {
  mut linear_segments : Array[LinearSegment]
  mut spacings : Spacings?
}

///|
fn new_linear_segments_state() -> LinearSegmentsState {
  { linear_segments: [], spacings: None }
}

///|
fn linear_segments_require_spacings(
  state : LinearSegmentsState,
) -> Spacings raise LinearSegmentsNodePlacerException {
  match state.spacings {
    Some(value) => value
    None => linear_segments_raise("LinearSegmentsNodePlacer: spacings not set")
  }
}

///|
fn linear_segments_vertical_spacing(
  spacings : Spacings,
  first : LNode,
  second : LNode,
) -> Double raise LinearSegmentsNodePlacerException {
  spacings.get_vertical_spacing(first, second) catch {
    LayeredSpacingsException(message) => linear_segments_raise(message)
  }
}

///|
fn linear_segments_graph_has_external_ports(graph : LGraph) -> Bool {
  for
    property in graph.get_property_graph_properties_array(
      internal_properties_graph_properties,
    ) {
    match property {
      GraphProperties::ExternalPorts => return true
      _ => ()
    }
  }
  false
}

///|
fn linear_segments_mode_is_forw(mode : LinearSegmentsMode) -> Bool {
  match mode {
    LinearSegmentsMode::ForwPendulum => true
    _ => false
  }
}

///|
fn linear_segments_mode_is_backw(mode : LinearSegmentsMode) -> Bool {
  match mode {
    LinearSegmentsMode::BackwPendulum => true
    _ => false
  }
}

///|
fn linear_segments_node_type_is_dummy(node_type : NodeType) -> Bool {
  match node_type {
    NodeType::LongEdge => true
    NodeType::NorthSouthPort => true
    _ => false
  }
}

///|
fn linear_segments_node_index_in_segment(
  segment : LinearSegment,
  node : LNode,
) -> Int {
  for i in 0..<segment.nodes.length() {
    if lnode_internal_handle(segment.nodes[i]) == lnode_internal_handle(node) {
      return i
    }
  }
  -1
}

///|
fn linear_segments_same_layer(left : LNode, right : LNode) -> Bool {
  match (left.get_layer(), right.get_layer()) {
    (Some(left_layer), Some(right_layer)) =>
      layer_internal_handle(left_layer) == layer_internal_handle(right_layer)
    _ => false
  }
}

///|
fn linear_segments_require_node_layer(
  node : LNode,
) -> Layer raise LinearSegmentsNodePlacerException {
  match node.get_layer() {
    Some(value) => value
    None => linear_segments_raise("LinearSegmentsNodePlacer: node has no layer")
  }
}

///|
fn linear_segments_require_port_node(
  port : LPort,
) -> LNode raise LinearSegmentsNodePlacerException {
  match port.get_node() {
    Some(value) => value
    None => linear_segments_raise("LinearSegmentsNodePlacer: port has no node")
  }
}

///|
fn linear_segments_successor_ports(port : LPort) -> Array[LPort] {
  let ports = []
  for edge in port.get_outgoing_edges() {
    match edge.get_target() {
      Some(target) => ports.push(target)
      None => ()
    }
  }
  ports
}

///|
fn linear_segments_find_node_index(layer : Layer, node : LNode) -> Int {
  let nodes = layer.get_nodes()
  for i in 0..<nodes.length() {
    if lnode_internal_handle(nodes[i]) == lnode_internal_handle(node) {
      return i
    }
  }
  -1
}

///|
fn linear_segments_split_segment(
  segment_list : Array[LinearSegment],
  segment_id : Int,
  split_node : LNode,
  new_id : Int,
) -> LinearSegment raise LinearSegmentsNodePlacerException {
  let segment = segment_list[segment_id]
  let split_index = linear_segments_node_index_in_segment(segment, split_node)
  if split_index < 0 {
    linear_segments_raise("LinearSegmentsNodePlacer: split node not in segment")
  }

  let new_segment = new_linear_segment(new_id)
  let index = split_index
  while index < segment.nodes.length() {
    let moved = segment.nodes.remove(index)
    moved.set_id(new_id)
    new_segment.nodes.push(moved)
  }

  segment_list[segment_id] = segment
  new_segment
}

///|
fn linear_segments_fill_segment(
  node : LNode,
  segment_id : Int,
  segment_list : Array[LinearSegment],
) -> Bool raise LinearSegmentsNodePlacerException {
  let node_type = node.get_type()

  if node.get_id() >= 0 {
    return false
  }

  node.set_id(segment_id)
  let segment = segment_list[segment_id]
  segment.nodes.push(node)
  segment._node_type = node_type
  segment_list[segment_id] = segment

  if linear_segments_node_type_is_dummy(node_type) {
    for source_port in node.get_ports() {
      for target_port in linear_segments_successor_ports(source_port) {
        let target_node = linear_segments_require_port_node(target_port)
        let target_node_type = target_node.get_type()

        if !linear_segments_same_layer(node, target_node) &&
          linear_segments_node_type_is_dummy(target_node_type) {
          if linear_segments_fill_segment(target_node, segment_id, segment_list) {
            return true
          }
        }
      }
    }
  }

  true
}

///|
fn linear_segments_remove_dependency(
  dependencies : Array[Int],
  target_segment_id : Int,
) -> Unit {
  for i in 0..<dependencies.length() {
    if dependencies[i] == target_segment_id {
      ignore(dependencies.remove(i))
      return
    }
  }
}

///|
fn linear_segments_create_dependency_graph_edges(
  monitor : @core.IElkProgressMonitor,
  layered_graph : LGraph,
  segment_list : Array[LinearSegment],
  outgoing_list : Array[Array[Int]],
  incoming_count_list : Array[Int],
) -> Unit raise LinearSegmentsNodePlacerException {
  let mut next_linear_segment_id = segment_list.length()
  let mut layer_index = 0

  for layer in layered_graph.get_layers() {
    let nodes = layer.get_nodes()
    if nodes.is_empty() {
      continue
    }

    let mut index_in_layer = 0
    let mut previous_node : LNode? = None
    let mut current_node : LNode? = Some(nodes[0])
    let mut next_node_index = 1

    while true {
      let current = match current_node {
        Some(value) => value
        None => break
      }

      let mut current_segment_id = current.get_id()
      let current_segment = segment_list[current_segment_id]

      if current_segment.index_in_last_layer >= 0 {
        let mut cycle_segment_id : Int? = None
        let mut cycle_index = index_in_layer + 1
        while cycle_index < nodes.length() {
          let cycle_node = nodes[cycle_index]
          let cycle_candidate_id = cycle_node.get_id()
          let cycle_candidate = segment_list[cycle_candidate_id]

          if cycle_candidate.last_layer == current_segment.last_layer &&
            cycle_candidate.index_in_last_layer <
            current_segment.index_in_last_layer {
            cycle_segment_id = Some(cycle_candidate_id)
            break
          }
          cycle_index = cycle_index + 1
        }

        if cycle_segment_id is Some(_) {
          match previous_node {
            Some(previous) => {
              let current_id_before_split = current.get_id()
              incoming_count_list[current_id_before_split] = incoming_count_list[current_id_before_split] -
                1
              linear_segments_remove_dependency(
                outgoing_list[previous.get_id()],
                current_id_before_split,
              )
            }
            None => ()
          }

          let new_segment = linear_segments_split_segment(
            segment_list, current_segment_id, current, next_linear_segment_id,
          )
          next_linear_segment_id = next_linear_segment_id + 1
          current_segment_id = new_segment.id
          segment_list.push(new_segment)
          outgoing_list.push([])

          match previous_node {
            Some(previous) => {
              outgoing_list[previous.get_id()].push(current_segment_id)
              incoming_count_list.push(1)
            }
            None => incoming_count_list.push(0)
          }
        }
      }

      let mut next_node : LNode? = None
      if next_node_index < nodes.length() {
        let next = nodes[next_node_index]
        next_node_index = next_node_index + 1
        let next_segment_id = next.get_id()

        outgoing_list[current.get_id()].push(next_segment_id)
        incoming_count_list[next_segment_id] = incoming_count_list[next_segment_id] +
          1
        next_node = Some(next)
      }

      let updated_segment = segment_list[current_segment_id]
      updated_segment.last_layer = layer_index
      updated_segment.index_in_last_layer = index_in_layer
      segment_list[current_segment_id] = updated_segment
      index_in_layer = index_in_layer + 1

      previous_node = Some(current)
      current_node = next_node
    }

    layer_index = layer_index + 1
  }

  if monitor.is_logging_enabled() {
    ()
  }
}

///|
fn linear_segments_sort_linear_segments(
  layered_graph : LGraph,
  monitor : @core.IElkProgressMonitor,
  state : LinearSegmentsState,
) -> Array[LinearSegment] raise LinearSegmentsNodePlacerException {
  let segment_list : Array[LinearSegment] = []

  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      node.set_id(-1)
      let mut in_prio = @int.MIN_VALUE
      let mut out_prio = @int.MIN_VALUE
      for port in node.get_ports() {
        for edge in port.get_incoming_edges() {
          let prio = edge.get_property_int(
            layered_options_priority_straightness,
          )
          if prio > in_prio {
            in_prio = prio
          }
        }
        for edge in port.get_outgoing_edges() {
          let prio = edge.get_property_int(
            layered_options_priority_straightness,
          )
          if prio > out_prio {
            out_prio = prio
          }
        }
      }
      node.set_property_int(linear_segments_input_prio, in_prio)
      node.set_property_int(linear_segments_output_prio, out_prio)
    }
  }

  let mut next_linear_segment_id = 0
  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      if node.get_id() < 0 {
        let segment = new_linear_segment(next_linear_segment_id)
        next_linear_segment_id = next_linear_segment_id + 1
        segment_list.push(segment)
        ignore(linear_segments_fill_segment(node, segment.id, segment_list))
      }
    }
  }

  let outgoing_list : Array[Array[Int]] = []
  let incoming_count_list : Array[Int] = []
  for _ in 0..<segment_list.length() {
    outgoing_list.push([])
    incoming_count_list.push(0)
  }

  linear_segments_create_dependency_graph_edges(
    monitor, layered_graph, segment_list, outgoing_list, incoming_count_list,
  )

  let mut next_rank = 0
  let no_incoming : Array[Int] = []
  for segment_id in 0..<segment_list.length() {
    if incoming_count_list[segment_id] == 0 {
      no_incoming.push(segment_id)
    }
  }

  let new_ranks : Array[Int] = Array::make(segment_list.length(), 0)
  while !no_incoming.is_empty() {
    let segment_id = no_incoming.remove(0)
    new_ranks[segment_id] = next_rank
    next_rank = next_rank + 1

    while !outgoing_list[segment_id].is_empty() {
      let target_id = outgoing_list[segment_id].remove(0)
      incoming_count_list[target_id] = incoming_count_list[target_id] - 1
      if incoming_count_list[target_id] == 0 {
        no_incoming.push(target_id)
      }
    }
  }

  let reordered_opt : Array[LinearSegment?] = Array::make(
    segment_list.length(),
    None,
  )
  for old_id in 0..<segment_list.length() {
    let segment = segment_list[old_id]
    let rank = new_ranks[old_id]
    segment.id = rank
    reordered_opt[rank] = Some(segment)
    for node in segment.nodes {
      node.set_id(rank)
    }
  }

  let reordered : Array[LinearSegment] = []
  for item in reordered_opt {
    match item {
      Some(segment) => reordered.push(segment)
      None =>
        linear_segments_raise(
          "LinearSegmentsNodePlacer: incomplete topological ordering",
        )
    }
  }

  state.linear_segments = reordered
  reordered
}

///|
fn linear_segments_create_unbalanced_placement(
  layered_graph : LGraph,
  state : LinearSegmentsState,
) -> Unit raise LinearSegmentsNodePlacerException {
  let layer_count = layered_graph.get_layers().length()
  let node_count : Array[Int] = Array::make(layer_count, 0)
  let recent_node : Array[LNode?] = Array::make(layer_count, None)

  for segment in state.linear_segments {
    let mut uppermost_place = 0.0
    for node in segment.nodes {
      let layer = linear_segments_require_node_layer(node)
      let layer_index = layer.get_index()
      node_count[layer_index] = node_count[layer_index] + 1

      let mut spacing = layered_graph.get_property_double(
        @core.spacing_edge_edge,
      )
      if node_count[layer_index] > 0 {
        match recent_node[layer_index] {
          Some(previous) =>
            spacing = linear_segments_vertical_spacing(
              linear_segments_require_spacings(state),
              previous,
              node,
            )
          None => ()
        }
      }

      let candidate = layer.get_size().y + spacing
      if candidate > uppermost_place {
        uppermost_place = candidate
      }
    }

    for node in segment.nodes {
      let layer = linear_segments_require_node_layer(node)
      node.get_position().y = uppermost_place + node.get_margin().top
      layer.get_size().y = uppermost_place +
        node.get_margin().top +
        node.get_size().y +
        node.get_margin().bottom
      recent_node[layer.get_index()] = Some(node)
    }
  }
}

///|
fn linear_segments_calc_deflection(
  segment_id : Int,
  incoming : Bool,
  outgoing : Bool,
  deflection_dampening : Double,
  state : LinearSegmentsState,
) -> Unit raise LinearSegmentsNodePlacerException {
  let segment = state.linear_segments[segment_id]
  let mut segment_deflection = 0.0
  let mut node_weight_sum = 0

  for node in segment.nodes {
    let mut node_deflection = 0.0
    let mut edge_weight_sum = 0
    let input_prio = if incoming {
      node.get_property_int(linear_segments_input_prio)
    } else {
      @int.MIN_VALUE
    }
    let output_prio = if outgoing {
      node.get_property_int(linear_segments_output_prio)
    } else {
      @int.MIN_VALUE
    }
    let min_prio = if input_prio > output_prio {
      input_prio
    } else {
      output_prio
    }

    for port in node.get_ports() {
      let port_pos = node.get_position().y +
        port.get_position().y +
        port.get_anchor().y

      if outgoing {
        for edge in port.get_outgoing_edges() {
          let other_port = match edge.get_target() {
            Some(value) => value
            None => continue
          }
          let other_node = linear_segments_require_port_node(other_port)
          if segment_id != other_node.get_id() {
            let other_input_prio = other_node.get_property_int(
              linear_segments_input_prio,
            )
            let other_output_prio = other_node.get_property_int(
              linear_segments_output_prio,
            )
            let other_prio = if other_input_prio > other_output_prio {
              other_input_prio
            } else {
              other_output_prio
            }
            let prio = edge.get_property_int(
              layered_options_priority_straightness,
            )
            if prio >= min_prio && prio >= other_prio {
              node_deflection = node_deflection +
                other_node.get_position().y +
                other_port.get_position().y +
                other_port.get_anchor().y -
                port_pos
              edge_weight_sum = edge_weight_sum + 1
            }
          }
        }
      }

      if incoming {
        for edge in port.get_incoming_edges() {
          let other_port = match edge.get_source() {
            Some(value) => value
            None => continue
          }
          let other_node = linear_segments_require_port_node(other_port)
          if segment_id != other_node.get_id() {
            let other_input_prio = other_node.get_property_int(
              linear_segments_input_prio,
            )
            let other_output_prio = other_node.get_property_int(
              linear_segments_output_prio,
            )
            let other_prio = if other_input_prio > other_output_prio {
              other_input_prio
            } else {
              other_output_prio
            }
            let prio = edge.get_property_int(
              layered_options_priority_straightness,
            )
            if prio >= min_prio && prio >= other_prio {
              node_deflection = node_deflection +
                other_node.get_position().y +
                other_port.get_position().y +
                other_port.get_anchor().y -
                port_pos
              edge_weight_sum = edge_weight_sum + 1
            }
          }
        }
      }
    }

    if edge_weight_sum > 0 {
      segment_deflection = segment_deflection +
        node_deflection / edge_weight_sum.to_double()
      node_weight_sum = node_weight_sum + 1
    }
  }

  let updated = state.linear_segments[segment_id]
  if node_weight_sum > 0 {
    updated.deflection = deflection_dampening *
      segment_deflection /
      node_weight_sum.to_double()
    updated.weight = node_weight_sum
  } else {
    updated.deflection = 0.0
    updated.weight = 0
  }
  state.linear_segments[segment_id] = updated
}

///|
fn linear_segments_region_id(
  state : LinearSegmentsState,
  segment_id : Int,
) -> Int {
  let mut current_id = segment_id
  while state.linear_segments[current_id].ref_segment_id >= 0 {
    current_id = state.linear_segments[current_id].ref_segment_id
  }
  current_id
}

///|
fn linear_segments_merge_regions(
  layered_graph : LGraph,
  state : LinearSegmentsState,
) -> Bool raise LinearSegmentsNodePlacerException {
  let mut changed = false
  let node_spacing = layered_graph.get_property_double(@core.spacing_node_node)
  let threshold = linear_segments_overlap_detect * node_spacing
  let spacings = linear_segments_require_spacings(state)

  for layer in layered_graph.get_layers() {
    let nodes = layer.get_nodes()
    let mut node1 = nodes[0]
    let mut region1_id = linear_segments_region_id(state, node1.get_id())

    for i in 1..<nodes.length() {
      let node2 = nodes[i]
      let region2_id = linear_segments_region_id(state, node2.get_id())

      if region1_id != region2_id {
        let spacing = linear_segments_vertical_spacing(spacings, node1, node2)

        let node1_extent = node1.get_position().y +
          node1.get_size().y +
          node1.get_margin().bottom +
          state.linear_segments[region1_id].deflection +
          spacing
        let node2_extent = node2.get_position().y -
          node2.get_margin().top +
          state.linear_segments[region2_id].deflection

        if node1_extent > node2_extent + threshold {
          let weight_sum = state.linear_segments[region1_id].weight +
            state.linear_segments[region2_id].weight
          if weight_sum <= 0 {
            linear_segments_raise(
              "LinearSegmentsNodePlacer: invalid merge weight",
            )
          }

          let new_deflection = (
              state.linear_segments[region2_id].weight.to_double() *
              state.linear_segments[region2_id].deflection +
              state.linear_segments[region1_id].weight.to_double() *
              state.linear_segments[region1_id].deflection
            ) /
            weight_sum.to_double()

          let region2 = state.linear_segments[region2_id]
          region2.deflection = new_deflection
          region2.weight = weight_sum
          state.linear_segments[region2_id] = region2

          let region1 = state.linear_segments[region1_id]
          region1.ref_segment_id = region2_id
          state.linear_segments[region1_id] = region1
          changed = true
        }
      }

      node1 = node2
      region1_id = region2_id
    }
  }

  changed
}

///|
fn linear_segments_balance_placement(
  layered_graph : LGraph,
  state : LinearSegmentsState,
) -> Unit raise LinearSegmentsNodePlacerException {
  let deflection_dampening = layered_graph.get_property_double(
    linear_segments_option_deflection_dampening,
  )
  let thoroughness = layered_graph.get_property_int(
    layered_options_thoroughness,
  )
  let mut pendulum_iters = linear_segments_pendulum_iters
  let mut final_iters = linear_segments_final_iters
  let threshold = linear_segments_threshold_factor / thoroughness.to_double()

  let mut ready = false
  let mut mode = LinearSegmentsMode::ForwPendulum
  let mut last_total_deflection = @int.MAX_VALUE.to_double()

  while !(ready && final_iters <= 0) {
    let incoming = !linear_segments_mode_is_backw(mode)
    let outgoing = !linear_segments_mode_is_forw(mode)
    let mut total_deflection = 0.0

    for segment_id in 0..<state.linear_segments.length() {
      let segment = state.linear_segments[segment_id]
      segment.ref_segment_id = -1
      state.linear_segments[segment_id] = segment
      linear_segments_calc_deflection(
        segment_id, incoming, outgoing, deflection_dampening, state,
      )
      total_deflection = total_deflection +
        state.linear_segments[segment_id].deflection.abs()
    }

    let mut merged = linear_segments_merge_regions(layered_graph, state)
    while merged {
      merged = linear_segments_merge_regions(layered_graph, state)
    }

    for segment in state.linear_segments {
      let region_id = linear_segments_region_id(state, segment.id)
      let deflection = state.linear_segments[region_id].deflection
      if deflection != 0.0 {
        for node in segment.nodes {
          node.get_position().y = node.get_position().y + deflection
        }
      }
    }

    if linear_segments_mode_is_forw(mode) || linear_segments_mode_is_backw(mode) {
      pendulum_iters = pendulum_iters - 1
      if pendulum_iters <= 0 &&
        (
          total_deflection < last_total_deflection ||
          -pendulum_iters > thoroughness
        ) {
        mode = LinearSegmentsMode::Rubber
        last_total_deflection = @int.MAX_VALUE.to_double()
      } else if linear_segments_mode_is_forw(mode) {
        mode = LinearSegmentsMode::BackwPendulum
        last_total_deflection = total_deflection
      } else {
        mode = LinearSegmentsMode::ForwPendulum
        last_total_deflection = total_deflection
      }
    } else {
      ready = total_deflection >= last_total_deflection ||
        last_total_deflection - total_deflection < threshold
      last_total_deflection = total_deflection
      if ready {
        final_iters = final_iters - 1
      }
    }
  }
}

///|
fn linear_segments_post_process(
  state : LinearSegmentsState,
) -> Unit raise LinearSegmentsNodePlacerException {
  let spacings = linear_segments_require_spacings(state)

  for segment in state.linear_segments {
    let mut min_room_above = @int.MAX_VALUE.to_double()
    let mut min_room_below = @int.MAX_VALUE.to_double()

    for node in segment.nodes {
      let layer = linear_segments_require_node_layer(node)
      let index = linear_segments_find_node_index(layer, node)
      if index < 0 {
        linear_segments_raise(
          "LinearSegmentsNodePlacer: node missing from layer",
        )
      }

      let room_above = if index > 0 {
        let neighbor = layer.get_nodes()[index - 1]
        let spacing = linear_segments_vertical_spacing(spacings, node, neighbor)
        node.get_position().y -
        node.get_margin().top -
        (
          neighbor.get_position().y +
          neighbor.get_size().y +
          neighbor.get_margin().bottom +
          spacing
        )
      } else {
        node.get_position().y - node.get_margin().top
      }
      if room_above < min_room_above {
        min_room_above = room_above
      }

      let room_below = if index < layer.get_nodes().length() - 1 {
        let neighbor = layer.get_nodes()[index + 1]
        let spacing = linear_segments_vertical_spacing(spacings, node, neighbor)
        neighbor.get_position().y -
        neighbor.get_margin().top -
        (
          node.get_position().y +
          node.get_size().y +
          node.get_margin().bottom +
          spacing
        )
      } else {
        2.0 * node.get_position().y
      }
      if room_below < min_room_below {
        min_room_below = room_below
      }
    }

    let mut min_displacement = @int.MAX_VALUE.to_double()
    let mut found_place = false

    let first_node = segment.nodes[0]
    for target in first_node.get_ports() {
      let pos = first_node.get_position().y +
        target.get_position().y +
        target.get_anchor().y
      for edge in target.get_incoming_edges() {
        let source = match edge.get_source() {
          Some(value) => value
          None => continue
        }
        let source_node = linear_segments_require_port_node(source)
        let d = source_node.get_position().y +
          source.get_position().y +
          source.get_anchor().y -
          pos
        let displacement_limit = if d < 0.0 {
          min_room_above
        } else {
          min_room_below
        }
        if d.abs() < min_displacement.abs() && d.abs() < displacement_limit {
          min_displacement = d
          found_place = true
        }
      }
    }

    let last_node = segment.nodes[segment.nodes.length() - 1]
    for source in last_node.get_ports() {
      let pos = last_node.get_position().y +
        source.get_position().y +
        source.get_anchor().y
      for edge in source.get_outgoing_edges() {
        let target = match edge.get_target() {
          Some(value) => value
          None => continue
        }
        let target_node = linear_segments_require_port_node(target)
        let d = target_node.get_position().y +
          target.get_position().y +
          target.get_anchor().y -
          pos
        let displacement_limit = if d < 0.0 {
          min_room_above
        } else {
          min_room_below
        }
        if d.abs() < min_displacement.abs() && d.abs() < displacement_limit {
          min_displacement = d
          found_place = true
        }
      }
    }

    if found_place && min_displacement != 0.0 {
      for node in segment.nodes {
        node.get_position().y = node.get_position().y + min_displacement
      }
    }
  }
}

///|
fn linear_segments_node_placer_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Linear segments node placement", 1.0))

  let state = new_linear_segments_state()
  state.spacings = Some(new_layered_spacings(layered_graph))

  try {
    ignore(linear_segments_sort_linear_segments(layered_graph, monitor, state))
    linear_segments_create_unbalanced_placement(layered_graph, state)
    linear_segments_balance_placement(layered_graph, state)
    linear_segments_post_process(state)
  } catch {
    LinearSegmentsNodePlacerException(message) =>
      @core.layout_runtime_report_unsupported_configuration(
        "java.lang.IllegalStateException: " + message,
      )
  } noraise {
    _ => ()
  }

  state.linear_segments = []
  state.spacings = None
  monitor.done()
}

///|
pub fn new_linear_segments_node_placer_layout_phase() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_phase(linear_segments_node_placer_process, graph => {
    if linear_segments_graph_has_external_ports(graph) {
      return Some(
        @core.layout_processor_configuration_create(layered_phase_descriptor).add_before(
          LayeredPhases::P5EdgeRouting,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::HierarchicalPortPositionProcessor,
          ),
        ),
      )
    }
    None
  })
}
