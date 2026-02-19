///|
fn node_promotion_layer_of(node : LNode) -> Layer {
  match node.get_layer() {
    Some(layer) => layer
    None => abort("node has no assigned layer")
  }
}

///|
fn node_promotion_require_bi_layer_key(
  bi_layer_map : BiLinkedHashMultiMap[Int],
  node : LNode,
) -> Int {
  match bi_layer_map.get_key(node.get_id()) {
    Some(layer_key) => layer_key
    None => abort("node is not present in bi-layer map")
  }
}

///|
fn node_promotion_require_edge_source_node(edge : LEdge) -> LNode {
  let source = match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source port")
  }
  match source.get_node() {
    Some(value) => value
    None => abort("source port has no owner node")
  }
}

///|
fn node_promotion_require_edge_target_node(edge : LEdge) -> LNode {
  let target = match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target port")
  }
  match target.get_node() {
    Some(value) => value
    None => abort("target port has no owner node")
  }
}

///|
fn node_promotion_require_first_outgoing(node : LNode) -> LEdge {
  let outgoing = node.get_outgoing_edges()
  if outgoing.is_empty() {
    abort("node has no outgoing edges")
  }
  outgoing[0]
}

///|
fn node_promotion_require_first_incoming(node : LNode) -> LEdge {
  let incoming = node.get_incoming_edges()
  if incoming.is_empty() {
    abort("node has no incoming edges")
  }
  incoming[0]
}

///|
fn node_promotion_add_unique_node(nodes : Array[LNode], node : LNode) -> Unit {
  let handle = node.get_handle()
  for existing in nodes {
    if existing.get_handle() == handle {
      return
    }
  }
  nodes.push(node)
}

///|
fn node_promotion_model_order(node : LNode) -> Int {
  if node.has_property_int(internal_properties_model_order) {
    node.get_property_int(internal_properties_model_order)
  } else {
    0
  }
}

///|
fn node_promotion_compare_model_order_desc(left : LNode, right : LNode) -> Int {
  if left.has_property_int(internal_properties_model_order) &&
    right.has_property_int(internal_properties_model_order) {
    node_promotion_model_order(right) - node_promotion_model_order(left)
  } else {
    0
  }
}

///|
fn node_promotion_compare_model_order_asc(left : LNode, right : LNode) -> Int {
  if left.has_property_int(internal_properties_model_order) &&
    right.has_property_int(internal_properties_model_order) {
    node_promotion_model_order(left) - node_promotion_model_order(right)
  } else {
    0
  }
}

///|
fn node_promotion_node_type_is_label_node(node_type : NodeType) -> Bool {
  match node_type {
    NodeType::LabelNode => true
    _ => false
  }
}

///|
fn node_promotion_node_type_is_normal(node_type : NodeType) -> Bool {
  match node_type {
    NodeType::Normal => true
    _ => false
  }
}

///|
fn node_promotion_insertion_sort_nodes(
  nodes : Array[LNode],
  compare : (LNode, LNode) -> Int,
) -> Unit {
  let mut i = 1
  while i < nodes.length() {
    let current = nodes[i]
    let mut j = i
    while j > 0 && compare(nodes[j - 1], current) > 0 {
      nodes[j] = nodes[j - 1]
      j -= 1
    }
    nodes[j] = current
    i += 1
  }
}

///|
fn node_promotion_insertion_sort_ints(values : Array[Int]) -> Unit {
  let mut i = 1
  while i < values.length() {
    let current = values[i]
    let mut j = i
    while j > 0 && values[j - 1] > current {
      values[j] = values[j - 1]
      j -= 1
    }
    values[j] = current
    i += 1
  }
}

///|
fn node_promotion_max_width(values : Array[Int]) -> Int {
  let mut result = 0
  for value in values {
    if value > result {
      result = value
    }
  }
  result
}

///|
fn node_promotion_max_width_pixel(values : Array[Double]) -> Double {
  let mut result = 0.0
  for value in values {
    if value > result {
      result = value
    }
  }
  result
}

///|
fn node_promotion_degree_array(size : Int) -> Array[Array[Int]] {
  let result = []
  for _ in 0..<size {
    result.push([0, 0, 0])
  }
  result
}

///|
fn node_promotion_strategy_from_string(value : String) -> NodePromotionStrategy {
  match value {
    "NIKOLOV" => NodePromotionStrategy::Nikolov
    "NIKOLOV_PIXEL" => NodePromotionStrategy::NikolovPixel
    "NIKOLOV_IMPROVED" => NodePromotionStrategy::NikolovImproved
    "NIKOLOV_IMPROVED_PIXEL" => NodePromotionStrategy::NikolovImprovedPixel
    "DUMMYNODE_PERCENTAGE" => NodePromotionStrategy::DummyNodePercentage
    "NODECOUNT_PERCENTAGE" => NodePromotionStrategy::NodeCountPercentage
    "NO_BOUNDARY" => NodePromotionStrategy::NoBoundary
    "MODEL_ORDER_LEFT_TO_RIGHT" => NodePromotionStrategy::ModelOrderLeftToRight
    "MODEL_ORDER_RIGHT_TO_LEFT" => NodePromotionStrategy::ModelOrderRightToLeft
    _ => NodePromotionStrategy::NoneType
  }
}

///|
fn node_promotion_strategy_is_none(strategy : NodePromotionStrategy) -> Bool {
  match strategy {
    NodePromotionStrategy::NoneType => true
    _ => false
  }
}

///|
fn node_promotion_strategy_is_nikolov(strategy : NodePromotionStrategy) -> Bool {
  match strategy {
    NodePromotionStrategy::Nikolov => true
    _ => false
  }
}

///|
fn node_promotion_strategy_is_nikolov_pixel(
  strategy : NodePromotionStrategy,
) -> Bool {
  match strategy {
    NodePromotionStrategy::NikolovPixel => true
    _ => false
  }
}

///|
fn node_promotion_strategy_is_model_order_left_to_right(
  strategy : NodePromotionStrategy,
) -> Bool {
  match strategy {
    NodePromotionStrategy::ModelOrderLeftToRight => true
    _ => false
  }
}

///|
fn node_promotion_strategy_is_model_order_right_to_left(
  strategy : NodePromotionStrategy,
) -> Bool {
  match strategy {
    NodePromotionStrategy::ModelOrderRightToLeft => true
    _ => false
  }
}

///|
fn node_promotion_is_model_order_strategy(
  strategy : NodePromotionStrategy,
) -> Bool {
  node_promotion_strategy_is_model_order_left_to_right(strategy) ||
  node_promotion_strategy_is_model_order_right_to_left(strategy)
}

///|
fn node_promotion_require_node_by_id(
  state : NodePromotionState,
  node_id : Int,
) -> LNode {
  match state.nodes_by_id.get(node_id) {
    Some(node) => node
    None => abort("node id not present in node map")
  }
}

///|
priv struct NodePromotionResult {
  dummy_diff : Int
  max_width_not_exceeded : Bool
}

///|
priv struct NodePromotionState {
  master_graph : LGraph
  mut nodes_with_incoming_edges : Array[LNode]
  mut nodes : Array[LNode]
  mut current_width : Array[Int]
  mut current_width_pixel : Array[Double]
  mut layers : Array[Int]
  mut degree_diff : Array[Array[Int]]
  mut max_width : Int
  mut max_width_pixel : Double
  mut dummy_node_count : Int
  mut max_height : Int
  mut node_size_affix : Double
  mut dummy_size : Double
  mut promotion_strategy : NodePromotionStrategy
  mut bi_layer_map : BiLinkedHashMultiMap[Int]
  mut nodes_by_id : Map[Int, LNode]
}

///|
fn node_promotion_new_state(
  layered_graph : LGraph,
  promotion_strategy : NodePromotionStrategy,
) -> NodePromotionState {
  {
    master_graph: layered_graph,
    nodes_with_incoming_edges: [],
    nodes: [],
    current_width: [],
    current_width_pixel: [],
    layers: [],
    degree_diff: [],
    max_width: 0,
    max_width_pixel: 0.0,
    dummy_node_count: 0,
    max_height: 0,
    node_size_affix: 0.0,
    dummy_size: 0.0,
    promotion_strategy,
    bi_layer_map: new_bi_linked_hash_multi_map(),
    nodes_by_id: {},
  }
}

///|
fn node_promotion_precalculate_and_set_information(
  state : NodePromotionState,
) -> Unit {
  state.node_size_affix = state.master_graph.get_property_double(
    @core.spacing_node_node,
  )
  state.dummy_size = state.master_graph.get_property_double(
    layered_options_spacing_edge_node_between_layers,
  )

  state.max_height = state.master_graph.get_layers().length()
  let mut layer_id = state.max_height - 1
  let mut node_id = 0
  state.max_width = 0
  state.max_width_pixel = 0.0
  state.current_width = Array::make(state.max_height, 0)
  state.current_width_pixel = Array::make(state.max_height, 0.0)

  for layer in state.master_graph.get_layers() {
    layer.set_id(layer_id)
    for node in layer.get_nodes() {
      node.set_id(node_id)
      node_id += 1
    }
    layer_id -= 1
  }

  state.layers = Array::make(node_id, 0)
  state.degree_diff = node_promotion_degree_array(node_id)
  state.nodes = []
  state.nodes_with_incoming_edges = []
  state.nodes_by_id = {}
  let mut dummy_baggage = 0
  state.dummy_node_count = 0

  for layer in state.master_graph.get_layers() {
    layer_id = layer.get_id()
    let mut incoming = 0
    let mut outcoming = 0
    let layer_size = layer.get_nodes().length()
    let mut layer_size_pixel = 0.0

    for node in layer.get_nodes() {
      node_id = node.get_id()
      state.nodes_by_id[node_id] = node
      state.layers[node_id] = node_promotion_layer_of(node).get_id()
      layer_size_pixel += node.get_size().y + state.node_size_affix
      let in_degree = node.get_incoming_edges().length()
      let out_degree = node.get_outgoing_edges().length()
      state.degree_diff[node_id][0] = out_degree - in_degree
      state.degree_diff[node_id][1] = in_degree
      state.degree_diff[node_id][2] = out_degree
      incoming += in_degree
      outcoming += out_degree
      if in_degree > 0 {
        state.nodes_with_incoming_edges.push(node)
      }
      state.nodes.push(node)
    }

    dummy_baggage -= incoming
    let nodes_and_dummies = layer_size + dummy_baggage
    layer_size_pixel += dummy_baggage.to_double() * state.dummy_size

    state.current_width[layer_id] = nodes_and_dummies
    state.current_width_pixel[layer_id] = layer_size_pixel
    if nodes_and_dummies > state.max_width {
      state.max_width = nodes_and_dummies
    }
    if layer_size_pixel > state.max_width_pixel {
      state.max_width_pixel = layer_size_pixel
    }
    state.dummy_node_count += dummy_baggage
    dummy_baggage += outcoming
  }
}

///|
fn node_promotion_precalculate_and_set_information_model_order(
  state : NodePromotionState,
) -> Unit {
  state.bi_layer_map = new_bi_linked_hash_multi_map()
  state.nodes_by_id = {}
  let mut node_id = 0
  let mut layer_id = 0
  for layer in state.master_graph.get_layers() {
    layer.set_id(layer_id)
    for node in layer.get_nodes() {
      node.set_id(node_id)
      state.nodes_by_id[node_id] = node
      node_id += 1
    }
    layer_id += 1
  }

  let left_to_right = node_promotion_strategy_is_model_order_left_to_right(
    state.promotion_strategy,
  )

  for layer in state.master_graph.get_layers() {
    if left_to_right {
      node_promotion_insertion_sort_nodes(
        layer.get_nodes(),
        node_promotion_compare_model_order_desc,
      )
    } else {
      node_promotion_insertion_sort_nodes(
        layer.get_nodes(),
        node_promotion_compare_model_order_asc,
      )
    }
    let layer_node_ids = []
    for layer_node in layer.get_nodes() {
      layer_node_ids.push(layer_node.get_id())
    }
    state.bi_layer_map.put_all(layer.get_id(), layer_node_ids)
  }
}

///|
fn node_promotion_promote_node(
  state : NodePromotionState,
  node : LNode,
) -> NodePromotionResult {
  let mut max_width_not_exceeded = true
  let mut dummy_diff = 0
  let mut node_layer_pos = state.layers[node.get_id()]
  let node_size = node.get_size().y + state.node_size_affix
  let dummies_built = state.degree_diff[node.get_id()][2]

  state.current_width[node_layer_pos] = state.current_width[node_layer_pos] -
    1 +
    dummies_built
  state.current_width_pixel[node_layer_pos] = state.current_width_pixel[node_layer_pos] -
    node_size +
    dummies_built.to_double() * state.dummy_size

  node_layer_pos += 1
  if node_layer_pos >= state.max_height {
    state.max_height += 1
    state.current_width.push(1)
    state.current_width_pixel.push(node_size)
  } else {
    let dummies_reduced = state.degree_diff[node.get_id()][1]
    state.current_width[node_layer_pos] = state.current_width[node_layer_pos] +
      1 -
      dummies_reduced
    state.current_width_pixel[node_layer_pos] = state.current_width_pixel[node_layer_pos] +
      node_size -
      dummies_reduced.to_double() * state.dummy_size
  }

  if node_promotion_strategy_is_nikolov(state.promotion_strategy) &&
    (
      state.current_width[node_layer_pos] > state.max_width ||
      state.current_width[node_layer_pos - 1] > state.max_width
    ) {
    max_width_not_exceeded = false
  }
  if node_promotion_strategy_is_nikolov_pixel(state.promotion_strategy) &&
    (
      state.current_width_pixel[node_layer_pos] > state.max_width_pixel ||
      state.current_width_pixel[node_layer_pos - 1] > state.max_width_pixel
    ) {
    max_width_not_exceeded = false
  }

  for edge in node.get_incoming_edges() {
    let predecessor = node_promotion_require_edge_source_node(edge)
    if state.layers[predecessor.get_id()] == node_layer_pos {
      let promoted = node_promotion_promote_node(state, predecessor)
      dummy_diff += promoted.dummy_diff
      max_width_not_exceeded = max_width_not_exceeded &&
        promoted.max_width_not_exceeded
    }
  }

  state.layers[node.get_id()] = node_layer_pos
  dummy_diff += state.degree_diff[node.get_id()][0]
  { dummy_diff, max_width_not_exceeded }
}

///|
fn node_promotion_promotion_magic(
  state : NodePromotionState,
  should_continue : (Int, Int) -> Bool,
) -> Unit {
  let mut iteration_counter = 0
  let mut reduced_dummies = 0

  let mut layering_backup = state.layers.copy()
  let mut dummy_backup = state.dummy_node_count
  let mut height_backup = state.max_height
  let mut current_width_backup = state.current_width.copy()
  let mut current_width_pixel_backup = state.current_width_pixel.copy()

  let mut promotion_flag = true
  while promotion_flag {
    let mut promotions = 0

    for node in state.nodes_with_incoming_edges {
      let promoted = node_promotion_promote_node(state, node)
      let mut apply = true
      if node_promotion_strategy_is_nikolov(state.promotion_strategy) ||
        node_promotion_strategy_is_nikolov_pixel(state.promotion_strategy) {
        apply = promoted.max_width_not_exceeded
      }

      if promoted.dummy_diff < 0 && apply {
        promotions += 1
        layering_backup = state.layers.copy()
        state.dummy_node_count += promoted.dummy_diff
        reduced_dummies += dummy_backup - state.dummy_node_count
        dummy_backup = state.dummy_node_count + promoted.dummy_diff
        height_backup = state.max_height
        current_width_backup = state.current_width.copy()
        current_width_pixel_backup = state.current_width_pixel.copy()
      } else {
        state.layers = layering_backup.copy()
        state.dummy_node_count = dummy_backup
        state.current_width = current_width_backup.copy()
        state.current_width_pixel = current_width_pixel_backup.copy()
        state.max_height = height_backup
      }
    }

    iteration_counter += 1
    promotion_flag = promotions != 0 &&
      should_continue(reduced_dummies, iteration_counter)
  }
}

///|
fn node_promotion_promote_node_by_model_order(
  state : NodePromotionState,
  node : LNode,
  left_to_right : Bool,
) -> Array[LNode] {
  let old_layer_id = node_promotion_require_bi_layer_key(
    state.bi_layer_map,
    node,
  )
  if left_to_right {
    state.bi_layer_map.put(old_layer_id + 1, node.get_id())
  } else {
    state.bi_layer_map.put(old_layer_id - 1, node.get_id())
  }

  let nodes_to_promote = []
  if left_to_right {
    for edge in node.get_outgoing_edges() {
      let next_node = node_promotion_require_edge_target_node(edge)
      if node_promotion_require_bi_layer_key(state.bi_layer_map, next_node) ==
        node_promotion_require_bi_layer_key(state.bi_layer_map, node) {
        node_promotion_add_unique_node(nodes_to_promote, next_node)
      }
    }
  } else {
    for edge in node.get_incoming_edges() {
      let next_node = node_promotion_require_edge_source_node(edge)
      if node_promotion_require_bi_layer_key(state.bi_layer_map, next_node) ==
        node_promotion_require_bi_layer_key(state.bi_layer_map, node) {
        node_promotion_add_unique_node(nodes_to_promote, next_node)
      }
    }
  }
  nodes_to_promote
}

///|
fn node_promotion_model_order_node_promotion(
  state : NodePromotionState,
  left_to_right : Bool,
) -> Unit {
  let mut something_changed = true
  while something_changed {
    something_changed = false
    let key_count = state.bi_layer_map.key_set().length()
    if key_count < 2 {
      return
    }
    let mut current_layer_id = if left_to_right { key_count - 2 } else { 1 }
    while (if left_to_right {
            current_layer_id >= 0
          } else {
            current_layer_id < key_count
          }) {
      let current_layer = state.bi_layer_map.get_values(current_layer_id)
      let mut node_index = 0
      while node_index < current_layer.length() {
        let node = node_promotion_require_node_by_id(
          state,
          current_layer[node_index],
        )
        if !node.has_property_int(internal_properties_model_order) {
          node_index += 1
          continue
        }
        if state.bi_layer_map.is_maximal_key(current_layer_id) && left_to_right {
          node_index += 1
          continue
        }
        if state.bi_layer_map.is_minimal_key(current_layer_id) && !left_to_right {
          node_index += 1
          continue
        }

        let mut shall_be_promoted = true
        let node_model_order = node_promotion_model_order(node)
        for other_node_id in current_layer {
          let other_node = node_promotion_require_node_by_id(
            state, other_node_id,
          )
          if !other_node.has_property_int(internal_properties_model_order) {
            continue
          }
          let other_model_order = node_promotion_model_order(other_node)
          if left_to_right && node_model_order < other_model_order {
            shall_be_promoted = false
          }
          if !left_to_right && node_model_order > other_model_order {
            shall_be_promoted = false
          }
        }
        if !shall_be_promoted {
          node_index += 1
          continue
        }

        let next_layer_id = if left_to_right {
          current_layer_id + 1
        } else {
          current_layer_id - 1
        }
        let next_layer = state.bi_layer_map.get_values(next_layer_id)

        let mut model_order_allows_promotion = false
        let mut promote_through_dummy_layer = true
        let mut contains_labels = false
        for next_layer_node_id in next_layer {
          let next_layer_node = node_promotion_require_node_by_id(
            state, next_layer_node_id,
          )
          if next_layer_node.has_property_int(internal_properties_model_order) {
            if next_layer_node.get_id() != node.get_id() {
              let next_model_order = node_promotion_model_order(next_layer_node)
              if left_to_right {
                model_order_allows_promotion = model_order_allows_promotion ||
                  next_model_order < node_model_order
              } else {
                model_order_allows_promotion = model_order_allows_promotion ||
                  next_model_order > node_model_order
              }
              promote_through_dummy_layer = false
            }
          } else if !model_order_allows_promotion && promote_through_dummy_layer {
            if node_promotion_node_type_is_label_node(
                next_layer_node.get_type(),
              ) {
              contains_labels = true
              let node_connected_to_next_layer = if left_to_right {
                let edge = node_promotion_require_first_incoming(
                  next_layer_node,
                )
                node_promotion_require_edge_source_node(edge)
              } else {
                let edge = node_promotion_require_first_outgoing(
                  next_layer_node,
                )
                node_promotion_require_edge_target_node(edge)
              }
              if node_connected_to_next_layer.get_handle() == node.get_handle() {
                let connected_node = if left_to_right {
                  let edge = node_promotion_require_first_outgoing(
                    next_layer_node,
                  )
                  node_promotion_require_edge_target_node(edge)
                } else {
                  let edge = node_promotion_require_first_incoming(
                    next_layer_node,
                  )
                  node_promotion_require_edge_source_node(edge)
                }
                let diff = if left_to_right {
                  node_promotion_require_bi_layer_key(
                    state.bi_layer_map,
                    connected_node,
                  ) -
                  node_promotion_require_bi_layer_key(
                    state.bi_layer_map,
                    node_connected_to_next_layer,
                  )
                } else {
                  node_promotion_require_bi_layer_key(
                    state.bi_layer_map,
                    node_connected_to_next_layer,
                  ) -
                  node_promotion_require_bi_layer_key(
                    state.bi_layer_map,
                    connected_node,
                  )
                }
                if diff <= 2 {
                  promote_through_dummy_layer = false
                }
              }
            }
          }
        }

        if contains_labels && promote_through_dummy_layer {
          let connected_node = if left_to_right {
            let edge = node_promotion_require_first_outgoing(node)
            node_promotion_require_edge_target_node(edge)
          } else {
            let edge = node_promotion_require_first_incoming(node)
            node_promotion_require_edge_source_node(edge)
          }
          let diff = if left_to_right {
            node_promotion_require_bi_layer_key(
              state.bi_layer_map,
              connected_node,
            ) -
            node_promotion_require_bi_layer_key(state.bi_layer_map, node)
          } else {
            node_promotion_require_bi_layer_key(state.bi_layer_map, node) -
            node_promotion_require_bi_layer_key(
              state.bi_layer_map,
              connected_node,
            )
          }
          if diff <= 2 &&
            node_promotion_node_type_is_normal(connected_node.get_type()) {
            promote_through_dummy_layer = false
          }
        }

        if model_order_allows_promotion || promote_through_dummy_layer {
          let nodes_to_promote = node_promotion_promote_node_by_model_order(
            state, node, left_to_right,
          )
          while !nodes_to_promote.is_empty() {
            let node_to_promote = nodes_to_promote[0]
            ignore(nodes_to_promote.remove(0))
            let promoted = node_promotion_promote_node_by_model_order(
              state, node_to_promote, left_to_right,
            )
            for promoted_node in promoted {
              node_promotion_add_unique_node(nodes_to_promote, promoted_node)
            }
          }
          node_index -= 1
          something_changed = true
        }
        node_index += 1
      }
      if left_to_right {
        current_layer_id -= 1
      } else {
        current_layer_id += 1
      }
    }
  }
}

///|
fn node_promotion_set_new_layering(state : NodePromotionState) -> Unit {
  let layered_graph = state.master_graph
  let lay_list = []
  let layer_count = state.max_height + 1
  for i in 0..<layer_count {
    let layer = new_layer(layered_graph)
    layer.set_id(state.max_height - i)
    lay_list.push(layer)
  }

  for node in state.nodes {
    node.set_layer(
      Some(lay_list[state.max_height - state.layers[node.get_id()]]),
    )
  }

  let mut i = 0
  while i < lay_list.length() {
    if lay_list[i].get_nodes().is_empty() {
      ignore(lay_list.remove(i))
    } else {
      i += 1
    }
  }

  let graph_layers = layered_graph.get_layers()
  graph_layers.clear()
  for layer in lay_list {
    graph_layers.push(layer)
  }
}

///|
fn node_promotion_set_new_layering_model_order(
  state : NodePromotionState,
) -> Unit {
  let layered_graph = state.master_graph
  let graph_layers = layered_graph.get_layers()
  graph_layers.clear()

  let key_set = state.bi_layer_map.key_set().copy()
  node_promotion_insertion_sort_ints(key_set)

  let layer_list = []
  for layer_index in key_set {
    let layer_node_ids = state.bi_layer_map.get_values(layer_index)
    if layer_node_ids.is_empty() {
      continue
    }
    let new_layer_value = new_layer(layered_graph)
    new_layer_value.set_id(layer_index)
    for node_id in layer_node_ids {
      let node = node_promotion_require_node_by_id(state, node_id)
      node.set_layer(Some(new_layer_value))
    }
    layer_list.push(new_layer_value)
  }

  for layer in layer_list {
    graph_layers.push(layer)
  }
}

///|
fn _node_promotion_configuration(
  graph : LGraph,
) -> @core.LayoutProcessorConfiguration[LayeredPhases, LGraph]? {
  ignore(graph)
  None
}

///|
fn node_promotion_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Node promotion heuristic", 1.0))

  let strategy = node_promotion_strategy_from_string(
    layered_graph.get_property_string(
      layered_options_layering_node_promotion_strategy,
    ),
  )
  if node_promotion_strategy_is_none(strategy) {
    monitor.done()
    return
  }

  let state = node_promotion_new_state(layered_graph, strategy)
  if node_promotion_is_model_order_strategy(strategy) {
    node_promotion_precalculate_and_set_information_model_order(state)
  } else {
    node_promotion_precalculate_and_set_information(state)
  }

  let promote_until = layered_graph.get_property_int(
    layered_options_layering_node_promotion_max_iterations,
  )
  let always_continue = (_reduced_dummies : Int, _iterations : Int) => true

  match strategy {
    NodePromotionStrategy::Nikolov =>
      node_promotion_promotion_magic(state, always_continue)
    NodePromotionStrategy::NikolovPixel =>
      node_promotion_promotion_magic(state, always_continue)
    NodePromotionStrategy::NikolovImproved => {
      state.promotion_strategy = NodePromotionStrategy::NoBoundary
      node_promotion_promotion_magic(state, always_continue)
      let new_max_width = node_promotion_max_width(state.current_width)
      if new_max_width > state.max_width {
        state.promotion_strategy = NodePromotionStrategy::Nikolov
        node_promotion_promotion_magic(state, always_continue)
      }
    }
    NodePromotionStrategy::NikolovImprovedPixel => {
      state.promotion_strategy = NodePromotionStrategy::NoBoundary
      node_promotion_promotion_magic(state, always_continue)
      let new_max_width_pixel = node_promotion_max_width_pixel(
        state.current_width_pixel,
      )
      if new_max_width_pixel > state.max_width_pixel {
        state.promotion_strategy = NodePromotionStrategy::NikolovPixel
        node_promotion_promotion_magic(state, always_continue)
      }
    }
    NodePromotionStrategy::NodeCountPercentage => {
      let promote_until_n = (state.layers.length() * promote_until + 99) / 100
      node_promotion_promotion_magic(state, (
        _reduced_dummies : Int,
        iterations : Int,
      ) => iterations < promote_until_n)
    }
    NodePromotionStrategy::DummyNodePercentage => {
      let promote_until_d = (state.dummy_node_count * promote_until + 99) / 100
      node_promotion_promotion_magic(state, (
        reduced_dummies : Int,
        _iterations : Int,
      ) => reduced_dummies < promote_until_d)
    }
    NodePromotionStrategy::ModelOrderLeftToRight =>
      node_promotion_model_order_node_promotion(state, true)
    NodePromotionStrategy::ModelOrderRightToLeft =>
      node_promotion_model_order_node_promotion(state, false)
    _ => node_promotion_promotion_magic(state, always_continue)
  }

  if node_promotion_is_model_order_strategy(strategy) {
    node_promotion_set_new_layering_model_order(state)
  } else {
    node_promotion_set_new_layering(state)
  }

  monitor.done()
}

///|
pub fn new_node_promotion_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(node_promotion_process)
}
