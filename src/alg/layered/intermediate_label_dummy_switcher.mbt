///|
pub let label_dummy_switcher_include_label : @graph.IProperty[Bool] = @graph.new_property(
  "edgelabelcenterednessanalysis.includelabel", false,
)

///|
priv suberror LabelDummySwitcherException {
  LabelDummySwitcherException(String)
} derive(Show, ToJson)

///|
fn[T] label_dummy_switcher_raise(
  message : String,
) -> T raise LabelDummySwitcherException {
  raise LabelDummySwitcherException(message)
}

///|
priv struct LabelDummySwitcherInfo {
  label_dummy : LNode
  mut placement_strategy : CenterEdgeLabelPlacementStrategy
  left_long_edge_dummies : Array[LNode]
  right_long_edge_dummies : Array[LNode]
  mut leftmost_layer_id : Int
  mut rightmost_layer_id : Int
}

///|
fn label_dummy_switcher_strategy_values() -> Array[
  CenterEdgeLabelPlacementStrategy,
] {
  [
    CenterEdgeLabelPlacementStrategy::MedianLayer,
    CenterEdgeLabelPlacementStrategy::TailLayer,
    CenterEdgeLabelPlacementStrategy::HeadLayer,
    CenterEdgeLabelPlacementStrategy::SpaceEfficientLayer,
    CenterEdgeLabelPlacementStrategy::WidestLayer,
    CenterEdgeLabelPlacementStrategy::CenterLayer,
  ]
}

///|
fn label_dummy_switcher_parse_strategy(
  value : String,
) -> CenterEdgeLabelPlacementStrategy {
  match value {
    "TAIL_LAYER" => CenterEdgeLabelPlacementStrategy::TailLayer
    "HEAD_LAYER" => CenterEdgeLabelPlacementStrategy::HeadLayer
    "SPACE_EFFICIENT_LAYER" =>
      CenterEdgeLabelPlacementStrategy::SpaceEfficientLayer
    "WIDEST_LAYER" => CenterEdgeLabelPlacementStrategy::WidestLayer
    "CENTER_LAYER" => CenterEdgeLabelPlacementStrategy::CenterLayer
    _ => CenterEdgeLabelPlacementStrategy::MedianLayer
  }
}

///|
fn label_dummy_switcher_strategy_equals(
  left : CenterEdgeLabelPlacementStrategy,
  right : CenterEdgeLabelPlacementStrategy,
) -> Bool {
  match (left, right) {
    (
      CenterEdgeLabelPlacementStrategy::MedianLayer,
      CenterEdgeLabelPlacementStrategy::MedianLayer,
    ) => true
    (
      CenterEdgeLabelPlacementStrategy::TailLayer,
      CenterEdgeLabelPlacementStrategy::TailLayer,
    ) => true
    (
      CenterEdgeLabelPlacementStrategy::HeadLayer,
      CenterEdgeLabelPlacementStrategy::HeadLayer,
    ) => true
    (
      CenterEdgeLabelPlacementStrategy::SpaceEfficientLayer,
      CenterEdgeLabelPlacementStrategy::SpaceEfficientLayer,
    ) => true
    (
      CenterEdgeLabelPlacementStrategy::WidestLayer,
      CenterEdgeLabelPlacementStrategy::WidestLayer,
    ) => true
    (
      CenterEdgeLabelPlacementStrategy::CenterLayer,
      CenterEdgeLabelPlacementStrategy::CenterLayer,
    ) => true
    _ => false
  }
}

///|
fn label_dummy_switcher_node_type_is_label(node_type : NodeType) -> Bool {
  match node_type {
    NodeType::LabelNode => true
    _ => false
  }
}

///|
fn label_dummy_switcher_node_type_is_long_edge(node_type : NodeType) -> Bool {
  match node_type {
    NodeType::LongEdge => true
    _ => false
  }
}

///|
fn label_dummy_switcher_port_type_is_input(port_type : PortType) -> Bool {
  match port_type {
    PortType::Input => true
    _ => false
  }
}

///|
fn label_dummy_switcher_max_double(left : Double, right : Double) -> Double {
  if left >= right {
    left
  } else {
    right
  }
}

///|
fn label_dummy_switcher_is_vertical_layout(graph : LGraph) -> Bool {
  let graph_direction = graph.get_property_string(@core.direction)
  graph_direction == "UP" || graph_direction == "DOWN"
}

///|
fn label_dummy_switcher_require_source(
  edge : LEdge,
) -> LPort raise LabelDummySwitcherException {
  match edge.get_source() {
    Some(value) => value
    None => label_dummy_switcher_raise("edge has no source")
  }
}

///|
fn label_dummy_switcher_require_target(
  edge : LEdge,
) -> LPort raise LabelDummySwitcherException {
  match edge.get_target() {
    Some(value) => value
    None => label_dummy_switcher_raise("edge has no target")
  }
}

///|
fn label_dummy_switcher_require_node(
  port : LPort,
) -> LNode raise LabelDummySwitcherException {
  match port.get_node() {
    Some(value) => value
    None => label_dummy_switcher_raise("port has no owner node")
  }
}

///|
fn label_dummy_switcher_require_layer(
  node : LNode,
) -> Layer raise LabelDummySwitcherException {
  match node.get_layer() {
    Some(value) => value
    None => label_dummy_switcher_raise("node has no layer")
  }
}

///|
fn label_dummy_switcher_require_first_incoming_edge(
  node : LNode,
) -> LEdge raise LabelDummySwitcherException {
  let incoming = node.get_incoming_edges()
  if incoming.is_empty() {
    label_dummy_switcher_raise("node has no incoming edge")
  }
  incoming[0]
}

///|
fn label_dummy_switcher_require_first_outgoing_edge(
  node : LNode,
) -> LEdge raise LabelDummySwitcherException {
  let outgoing = node.get_outgoing_edges()
  if outgoing.is_empty() {
    label_dummy_switcher_raise("node has no outgoing edge")
  }
  outgoing[0]
}

///|
fn label_dummy_switcher_require_port_by_type(
  node : LNode,
  port_type : PortType,
) -> LPort raise LabelDummySwitcherException {
  let ports = node.get_ports_by_type(port_type)
  if ports.is_empty() {
    if label_dummy_switcher_port_type_is_input(port_type) {
      label_dummy_switcher_raise("node has no input port")
    } else {
      label_dummy_switcher_raise("node has no output port")
    }
  }
  ports[0]
}

///|
fn label_dummy_switcher_copy_edges(edges : Array[LEdge]) -> Array[LEdge] {
  let copied = []
  for edge in edges {
    copied.push(edge)
  }
  copied
}

///|
fn label_dummy_switcher_index_of_node(
  nodes : Array[LNode],
  node : LNode,
) -> Int {
  for i in 0..<nodes.length() {
    if lnode_internal_handle(nodes[i]) == lnode_internal_handle(node) {
      return i
    }
  }
  -1
}

///|
fn label_dummy_switcher_set_layer_with_index(
  node : LNode,
  layer : Layer,
  index : Int,
) -> Unit {
  node.set_layer(Some(layer))

  let nodes = layer.get_nodes()
  let node_index = label_dummy_switcher_index_of_node(nodes, node)
  if node_index < 0 {
    return
  }

  let moved = nodes.remove(node_index)
  let insert_index = if index < 0 {
    0
  } else if index > nodes.length() {
    nodes.length()
  } else {
    index
  }
  ignore(nodes.insert(insert_index, moved))
}

///|
fn label_dummy_switcher_assign_ids_to_layers(layered_graph : LGraph) -> Unit {
  let layers = layered_graph.get_layers()
  for i in 0..<layers.length() {
    layers[i].set_id(i)
  }
}

///|
fn label_dummy_switcher_gather_left_long_edge_dummies(
  info : LabelDummySwitcherInfo,
) -> Unit raise LabelDummySwitcherException {
  let mut source = info.label_dummy
  while true {
    source = label_dummy_switcher_require_node(
      label_dummy_switcher_require_source(
        label_dummy_switcher_require_first_incoming_edge(source),
      ),
    )
    if label_dummy_switcher_node_type_is_long_edge(source.get_type()) {
      ignore(info.left_long_edge_dummies.insert(0, source))
    } else {
      break
    }
  }
}

///|
fn label_dummy_switcher_gather_right_long_edge_dummies(
  info : LabelDummySwitcherInfo,
) -> Unit raise LabelDummySwitcherException {
  let mut target = info.label_dummy
  while true {
    target = label_dummy_switcher_require_node(
      label_dummy_switcher_require_target(
        label_dummy_switcher_require_first_outgoing_edge(target),
      ),
    )
    if label_dummy_switcher_node_type_is_long_edge(target.get_type()) {
      info.right_long_edge_dummies.push(target)
    } else {
      break
    }
  }
}

///|
fn label_dummy_switcher_new_info(
  label_dummy : LNode,
  default_placement_strategy : CenterEdgeLabelPlacementStrategy,
) -> LabelDummySwitcherInfo raise LabelDummySwitcherException {
  let info : LabelDummySwitcherInfo = {
    label_dummy,
    placement_strategy: default_placement_strategy,
    left_long_edge_dummies: [],
    right_long_edge_dummies: [],
    leftmost_layer_id: 0,
    rightmost_layer_id: 0,
  }

  label_dummy_switcher_gather_left_long_edge_dummies(info)
  label_dummy_switcher_gather_right_long_edge_dummies(info)

  if info.left_long_edge_dummies.is_empty() {
    info.leftmost_layer_id = label_dummy_switcher_require_layer(label_dummy).get_id()
  } else {
    info.leftmost_layer_id = label_dummy_switcher_require_layer(
      info.left_long_edge_dummies[0],
    ).get_id()
  }

  if info.right_long_edge_dummies.is_empty() {
    info.rightmost_layer_id = label_dummy_switcher_require_layer(label_dummy).get_id()
  } else {
    info.rightmost_layer_id = label_dummy_switcher_require_layer(
      info.right_long_edge_dummies[info.right_long_edge_dummies.length() - 1],
    ).get_id()
  }

  for
    label in label_dummy.get_property_l_label_array(
      internal_properties_represented_labels,
    ) {
    if label.has_property_string(
        layered_options_edge_labels_center_label_placement_strategy,
      ) {
      info.placement_strategy = label_dummy_switcher_parse_strategy(
        label.get_property_string(
          layered_options_edge_labels_center_label_placement_strategy,
        ),
      )
      break
    }
  }

  info
}

///|
fn label_dummy_switcher_gather_label_dummy_infos(
  layered_graph : LGraph,
  default_placement_strategy : CenterEdgeLabelPlacementStrategy,
) -> Array[LabelDummySwitcherInfo] raise LabelDummySwitcherException {
  let infos = []
  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      if label_dummy_switcher_node_type_is_label(node.get_type()) {
        infos.push(
          label_dummy_switcher_new_info(node, default_placement_strategy),
        )
      }
    }
  }
  infos
}

///|
fn label_dummy_switcher_calculate_layer_widths(
  layered_graph : LGraph,
  layer_widths : Array[Double],
) -> Unit {
  if label_dummy_switcher_is_vertical_layout(layered_graph) {
    return
  }

  for layer in layered_graph.get_layers() {
    let mut max_width = 0.0
    for node in layer.get_nodes() {
      match node.get_type() {
        NodeType::Normal =>
          max_width = label_dummy_switcher_max_double(
            max_width,
            node.get_size().x,
          )
        _ => ()
      }
    }
    layer_widths[layer.get_id()] = max_width
  }
}

///|
fn label_dummy_switcher_collect_infos_for_strategy(
  infos : Array[LabelDummySwitcherInfo],
  strategy : CenterEdgeLabelPlacementStrategy,
) -> Array[LabelDummySwitcherInfo] {
  let selected = []
  for info in infos {
    if label_dummy_switcher_strategy_equals(info.placement_strategy, strategy) {
      selected.push(info)
    }
  }
  selected
}

///|
fn label_dummy_switcher_total_dummy_count(info : LabelDummySwitcherInfo) -> Int {
  info.rightmost_layer_id - info.leftmost_layer_id + 1
}

///|
fn label_dummy_switcher_ith_dummy_node(
  info : LabelDummySwitcherInfo,
  index : Int,
) -> LNode {
  if index < info.left_long_edge_dummies.length() {
    return info.left_long_edge_dummies[index]
  }
  if index == info.left_long_edge_dummies.length() {
    return info.label_dummy
  }
  info.right_long_edge_dummies[index - info.left_long_edge_dummies.length() - 1]
}

///|
fn label_dummy_switcher_compute_layer_width_sums(
  info : LabelDummySwitcherInfo,
  layer_widths : Array[Double],
) -> Array[Double] raise LabelDummySwitcherException {
  let graph = info.label_dummy.get_graph()
  let edge_node_spacing = graph.get_property_double(
      layered_options_spacing_edge_node_between_layers,
    ) *
    2.0
  let node_node_spacing = graph.get_property_double(
    layered_options_spacing_node_node_between_layers,
  )
  let min_space_between_layers = label_dummy_switcher_max_double(
    edge_node_spacing, node_node_spacing,
  )

  let layer_width_sums = []
  let mut current_width_sum = -min_space_between_layers

  for left_dummy in info.left_long_edge_dummies {
    current_width_sum = current_width_sum +
      layer_widths[label_dummy_switcher_require_layer(left_dummy).get_id()] +
      min_space_between_layers
    layer_width_sums.push(current_width_sum)
  }

  current_width_sum = current_width_sum +
    layer_widths[label_dummy_switcher_require_layer(info.label_dummy).get_id()] +
    min_space_between_layers
  layer_width_sums.push(current_width_sum)

  for right_dummy in info.right_long_edge_dummies {
    current_width_sum = current_width_sum +
      layer_widths[label_dummy_switcher_require_layer(right_dummy).get_id()] +
      min_space_between_layers
    layer_width_sums.push(current_width_sum)
  }

  layer_width_sums
}

///|
fn label_dummy_switcher_find_widest_layer_target_id(
  info : LabelDummySwitcherInfo,
  layer_widths : Array[Double],
) -> Int {
  let mut widest_layer_index = info.leftmost_layer_id
  let start_index = widest_layer_index + 1
  let end_index = info.rightmost_layer_id + 1
  for index in start_index..<end_index {
    if layer_widths[index] > layer_widths[widest_layer_index] {
      widest_layer_index = index
    }
  }
  widest_layer_index
}

///|
fn label_dummy_switcher_find_center_layer_target_id(
  info : LabelDummySwitcherInfo,
  layer_widths : Array[Double],
) -> Int raise LabelDummySwitcherException {
  let layer_width_sums = label_dummy_switcher_compute_layer_width_sums(
    info, layer_widths,
  )
  let threshold = layer_width_sums[layer_width_sums.length() - 1] / 2.0
  for i in 0..<layer_width_sums.length() {
    if layer_width_sums[i] >= threshold {
      return info.leftmost_layer_id + i
    }
  }

  info.leftmost_layer_id + info.left_long_edge_dummies.length()
}

///|
fn label_dummy_switcher_find_median_layer_target_id(
  info : LabelDummySwitcherInfo,
) -> Int {
  let layers = label_dummy_switcher_total_dummy_count(info)
  let lower_median = (layers - 1) / 2
  info.leftmost_layer_id + lower_median
}

///|
fn label_dummy_switcher_is_part_of_reversed_edge(
  info : LabelDummySwitcherInfo,
) -> Bool raise LabelDummySwitcherException {
  let incoming = label_dummy_switcher_require_first_incoming_edge(
    info.label_dummy,
  )
  let outgoing = label_dummy_switcher_require_first_outgoing_edge(
    info.label_dummy,
  )
  incoming.get_property_bool(internal_properties_reversed) ||
  outgoing.get_property_bool(internal_properties_reversed)
}

///|
fn label_dummy_switcher_find_end_layer_target_id(
  info : LabelDummySwitcherInfo,
  head_layer : Bool,
) -> Int raise LabelDummySwitcherException {
  let reversed = label_dummy_switcher_is_part_of_reversed_edge(info)
  if (head_layer && !reversed) || (!head_layer && reversed) {
    info.rightmost_layer_id
  } else {
    info.leftmost_layer_id
  }
}

///|
fn label_dummy_switcher_set_end_layer_node_alignment(
  info : LabelDummySwitcherInfo,
) -> Unit raise LabelDummySwitcherException {
  let is_head_label = label_dummy_switcher_strategy_equals(
    info.placement_strategy,
    CenterEdgeLabelPlacementStrategy::HeadLayer,
  )
  let reversed = label_dummy_switcher_is_part_of_reversed_edge(info)

  if (is_head_label && !reversed) || (!is_head_label && reversed) {
    info.label_dummy.set_property_string(
      @core.alignment,
      @core.alignment_to_string(Right),
    )
  } else {
    info.label_dummy.set_property_string(
      @core.alignment,
      @core.alignment_to_string(Left),
    )
  }
}

///|
fn label_dummy_switcher_swap_nodes(
  label_dummy : LNode,
  long_edge_dummy : LNode,
) -> Unit raise LabelDummySwitcherException {
  let layer_1 = label_dummy_switcher_require_layer(label_dummy)
  let layer_2 = label_dummy_switcher_require_layer(long_edge_dummy)

  let dummy_1_layer_position = label_dummy_switcher_index_of_node(
    layer_1.get_nodes(),
    label_dummy,
  )
  let dummy_2_layer_position = label_dummy_switcher_index_of_node(
    layer_2.get_nodes(),
    long_edge_dummy,
  )

  let input_port_1 = label_dummy_switcher_require_port_by_type(
    label_dummy,
    PortType::Input,
  )
  let output_port_1 = label_dummy_switcher_require_port_by_type(
    label_dummy,
    PortType::Output,
  )
  let input_port_2 = label_dummy_switcher_require_port_by_type(
    long_edge_dummy,
    PortType::Input,
  )
  let output_port_2 = label_dummy_switcher_require_port_by_type(
    long_edge_dummy,
    PortType::Output,
  )

  let incoming_edges_1 = label_dummy_switcher_copy_edges(
    input_port_1.get_incoming_edges(),
  )
  let outgoing_edges_1 = label_dummy_switcher_copy_edges(
    output_port_1.get_outgoing_edges(),
  )
  let incoming_edges_2 = label_dummy_switcher_copy_edges(
    input_port_2.get_incoming_edges(),
  )
  let outgoing_edges_2 = label_dummy_switcher_copy_edges(
    output_port_2.get_outgoing_edges(),
  )

  label_dummy_switcher_set_layer_with_index(
    label_dummy, layer_2, dummy_2_layer_position,
  )
  for edge in incoming_edges_2 {
    edge.set_target(Some(input_port_1))
  }
  for edge in outgoing_edges_2 {
    edge.set_source(Some(output_port_1))
  }

  label_dummy_switcher_set_layer_with_index(
    long_edge_dummy, layer_1, dummy_1_layer_position,
  )
  for edge in incoming_edges_1 {
    edge.set_target(Some(input_port_2))
  }
  for edge in outgoing_edges_1 {
    edge.set_source(Some(output_port_2))
  }
}

///|
fn label_dummy_switcher_assign_layer(
  info : LabelDummySwitcherInfo,
  target_layer_index : Int,
  layer_widths : Array[Double],
) -> Unit raise LabelDummySwitcherException {
  if target_layer_index >= info.label_dummy.get_graph().get_layers().length() {
    label_dummy_switcher_raise("target layer index is out of bounds")
  }

  if target_layer_index !=
    info.leftmost_layer_id + info.left_long_edge_dummies.length() {
    label_dummy_switcher_swap_nodes(
      info.label_dummy,
      label_dummy_switcher_ith_dummy_node(
        info,
        target_layer_index - info.leftmost_layer_id,
      ),
    )
  }

  let new_layer_id = label_dummy_switcher_require_layer(info.label_dummy).get_id()
  layer_widths[new_layer_id] = label_dummy_switcher_max_double(
    layer_widths[new_layer_id],
    info.label_dummy.get_size().x,
  )

  for
    label in info.label_dummy.get_property_l_label_array(
      internal_properties_represented_labels,
    ) {
    label.set_property_bool(label_dummy_switcher_include_label, true)
  }
}

///|
fn label_dummy_switcher_do_update_long_edge_label_dummy_info(
  label_dummy : LNode,
  next_element : (LNode) -> LNode raise LabelDummySwitcherException,
  value : Bool,
) -> Unit raise LabelDummySwitcherException {
  let mut long_edge_dummy = next_element(label_dummy)
  while label_dummy_switcher_node_type_is_long_edge(long_edge_dummy.get_type()) {
    long_edge_dummy.set_property_bool(
      internal_properties_long_edge_before_label_dummy, value,
    )
    long_edge_dummy = next_element(long_edge_dummy)
  }
}

///|
fn label_dummy_switcher_update_long_edge_source_label_dummy_info(
  info : LabelDummySwitcherInfo,
) -> Unit raise LabelDummySwitcherException {
  label_dummy_switcher_do_update_long_edge_label_dummy_info(
    info.label_dummy,
    fn(node : LNode) -> LNode raise LabelDummySwitcherException {
      label_dummy_switcher_require_node(
        label_dummy_switcher_require_source(
          label_dummy_switcher_require_first_incoming_edge(node),
        ),
      )
    },
    true,
  )
}

///|
fn label_dummy_switcher_sort_infos_descending_by_width(
  infos : Array[LabelDummySwitcherInfo],
) -> Unit {
  for i in 1..<infos.length() {
    let current = infos[i]
    let mut j = i
    while j > 0 &&
          infos[j - 1].label_dummy.get_size().x <
          current.label_dummy.get_size().x {
      infos[j] = infos[j - 1]
      j = j - 1
    }
    infos[j] = current
  }
}

///|
fn label_dummy_switcher_assign_to_wider_layer(
  info : LabelDummySwitcherInfo,
  layer_widths : Array[Double],
) -> Bool raise LabelDummySwitcherException {
  let dummy_width = info.label_dummy.get_size().x
  let layers = info.label_dummy.get_graph().get_layers()
  let start_layer_index = info.leftmost_layer_id
  let end_layer_index = info.rightmost_layer_id + 1
  for layer_index in start_layer_index..<end_layer_index {
    if layers[layer_index].get_size().x >= dummy_width {
      label_dummy_switcher_assign_layer(info, layer_index, layer_widths)
      return true
    }
  }
  false
}

///|
fn label_dummy_switcher_perform_trivial_assignments(
  infos : Array[LabelDummySwitcherInfo],
  layer_widths : Array[Double],
) -> Array[LabelDummySwitcherInfo] raise LabelDummySwitcherException {
  let remaining = []
  for info in infos {
    if info.leftmost_layer_id == info.rightmost_layer_id {
      label_dummy_switcher_assign_layer(
        info,
        info.leftmost_layer_id,
        layer_widths,
      )
    } else if !label_dummy_switcher_assign_to_wider_layer(info, layer_widths) {
      remaining.push(info)
    }
  }
  remaining
}

///|
fn label_dummy_switcher_find_potentially_widest_layer(
  infos : Array[LabelDummySwitcherInfo],
  label_index : Int,
  layer_widths : Array[Double],
) -> Int {
  let label_count = infos.length()
  let info = infos[label_index]
  let label_dummy_width = info.label_dummy.get_size().x

  let mut widest_layer_index = info.leftmost_layer_id
  let mut widest_layer_width = 0.0

  let start_layer = info.leftmost_layer_id
  let end_layer = info.rightmost_layer_id + 1
  for layer in start_layer..<end_layer {
    if label_dummy_width <= layer_widths[layer] {
      return layer
    }

    let mut potential_width = layer_widths[layer]

    let mut largest_unassigned_label : LabelDummySwitcherInfo? = None
    let start_label = label_index + 1
    for label in start_label..<label_count {
      let current_info = infos[label]
      if current_info.leftmost_layer_id <= layer &&
        current_info.rightmost_layer_id >= layer {
        largest_unassigned_label = Some(current_info)
      }
    }

    match largest_unassigned_label {
      Some(value) =>
        potential_width = label_dummy_switcher_max_double(
          potential_width,
          value.label_dummy.get_size().x,
        )
      None => ()
    }

    if potential_width > widest_layer_width {
      widest_layer_index = layer
      widest_layer_width = potential_width
    }
  }

  widest_layer_index
}

///|
fn label_dummy_switcher_compute_space_efficient_assignment(
  infos : Array[LabelDummySwitcherInfo],
  layer_widths : Array[Double],
) -> Unit raise LabelDummySwitcherException {
  let non_trivial_labels = label_dummy_switcher_perform_trivial_assignments(
    infos, layer_widths,
  )
  if non_trivial_labels.is_empty() {
    return
  }

  label_dummy_switcher_sort_infos_descending_by_width(non_trivial_labels)

  let label_count = non_trivial_labels.length()
  for label_index in 0..<label_count {
    label_dummy_switcher_assign_layer(
      non_trivial_labels[label_index],
      label_dummy_switcher_find_potentially_widest_layer(
        non_trivial_labels, label_index, layer_widths,
      ),
      layer_widths,
    )
  }
}

///|
fn label_dummy_switcher_process_strategy(
  infos : Array[LabelDummySwitcherInfo],
  strategy : CenterEdgeLabelPlacementStrategy,
  layer_widths : Array[Double],
) -> Unit raise LabelDummySwitcherException {
  let strategy_infos = label_dummy_switcher_collect_infos_for_strategy(
    infos, strategy,
  )
  if strategy_infos.is_empty() {
    return
  }

  if label_dummy_switcher_strategy_equals(
      strategy,
      CenterEdgeLabelPlacementStrategy::SpaceEfficientLayer,
    ) {
    label_dummy_switcher_compute_space_efficient_assignment(
      strategy_infos, layer_widths,
    )
    return
  }

  for info in strategy_infos {
    match info.placement_strategy {
      CenterEdgeLabelPlacementStrategy::CenterLayer =>
        label_dummy_switcher_assign_layer(
          info,
          label_dummy_switcher_find_center_layer_target_id(info, layer_widths),
          layer_widths,
        )
      CenterEdgeLabelPlacementStrategy::MedianLayer =>
        label_dummy_switcher_assign_layer(
          info,
          label_dummy_switcher_find_median_layer_target_id(info),
          layer_widths,
        )
      CenterEdgeLabelPlacementStrategy::WidestLayer =>
        label_dummy_switcher_assign_layer(
          info,
          label_dummy_switcher_find_widest_layer_target_id(info, layer_widths),
          layer_widths,
        )
      CenterEdgeLabelPlacementStrategy::HeadLayer => {
        label_dummy_switcher_set_end_layer_node_alignment(info)
        label_dummy_switcher_assign_layer(
          info,
          label_dummy_switcher_find_end_layer_target_id(info, true),
          layer_widths,
        )
      }
      CenterEdgeLabelPlacementStrategy::TailLayer => {
        label_dummy_switcher_set_end_layer_node_alignment(info)
        label_dummy_switcher_assign_layer(
          info,
          label_dummy_switcher_find_end_layer_target_id(info, false),
          layer_widths,
        )
      }
      CenterEdgeLabelPlacementStrategy::SpaceEfficientLayer => ()
    }

    label_dummy_switcher_update_long_edge_source_label_dummy_info(info)
  }
}

///|
fn label_dummy_switcher_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Label dummy switching", 1.0))

  try {
    let default_placement_strategy = label_dummy_switcher_parse_strategy(
      layered_graph.get_property_string(
        layered_options_edge_labels_center_label_placement_strategy,
      ),
    )

    label_dummy_switcher_assign_ids_to_layers(layered_graph)
    let infos = label_dummy_switcher_gather_label_dummy_infos(
      layered_graph, default_placement_strategy,
    )

    let layer_widths = []
    for _ in 0..<layered_graph.get_layers().length() {
      layer_widths.push(0.0)
    }

    let mut has_size_based_strategy = false
    for strategy in label_dummy_switcher_strategy_values() {
      if strategy.uses_label_size_information() &&
        !label_dummy_switcher_collect_infos_for_strategy(infos, strategy).is_empty() {
        has_size_based_strategy = true
        break
      }
    }
    if has_size_based_strategy {
      label_dummy_switcher_calculate_layer_widths(layered_graph, layer_widths)
    }

    for strategy in label_dummy_switcher_strategy_values() {
      if !strategy.uses_label_size_information() {
        label_dummy_switcher_process_strategy(infos, strategy, layer_widths)
      }
    }

    for strategy in label_dummy_switcher_strategy_values() {
      if strategy.uses_label_size_information() {
        label_dummy_switcher_process_strategy(infos, strategy, layer_widths)
      }
    }
  } catch {
    LabelDummySwitcherException(message) =>
      @core.layout_runtime_report_unsupported_configuration(
        "java.lang.IllegalStateException: " + message,
      )
  } noraise {
    _ => ()
  }

  monitor.done()
}

///|
pub fn new_label_dummy_switcher_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(label_dummy_switcher_process)
}
