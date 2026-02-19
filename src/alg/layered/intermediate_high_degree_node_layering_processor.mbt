///|
type HighDegreeEdgeSelector = (LNode) -> Array[LEdge]

///|
pub struct HighDegreeNodeInformation {
  mut inc_trees_max_height : Int
  inc_tree_roots : Array[LNode]
  mut out_trees_max_height : Int
  out_tree_roots : Array[LNode]
}

///|
fn new_high_degree_node_information() -> HighDegreeNodeInformation {
  {
    inc_trees_max_height: -1,
    inc_tree_roots: [],
    out_trees_max_height: -1,
    out_tree_roots: [],
  }
}

///|
priv struct HighDegreeNodeCandidate {
  info : HighDegreeNodeInformation
}

///|
fn high_degree_incoming_edges(node : LNode) -> Array[LEdge] {
  node.get_incoming_edges()
}

///|
fn high_degree_outgoing_edges(node : LNode) -> Array[LEdge] {
  node.get_outgoing_edges()
}

///|
fn high_degree_require_source_node(edge : LEdge) -> LNode {
  match edge.get_source() {
    Some(source_port) =>
      match source_port.get_node() {
        Some(source_node) => source_node
        None => abort("source port has no owner node")
      }
    None => abort("edge has no source")
  }
}

///|
fn high_degree_require_target_node(edge : LEdge) -> LNode {
  match edge.get_target() {
    Some(target_port) =>
      match target_port.get_node() {
        Some(target_node) => target_node
        None => abort("target port has no owner node")
      }
    None => abort("edge has no target")
  }
}

///|
fn high_degree_other_node(edge : LEdge, node : LNode) -> LNode {
  let source_node = high_degree_require_source_node(edge)
  if source_node.get_handle() == node.get_handle() {
    high_degree_require_target_node(edge)
  } else {
    source_node
  }
}

///|
fn high_degree_degree(node : LNode) -> Int {
  node.get_connected_edges().length()
}

///|
fn high_degree_is_high_degree_node(
  node : LNode,
  degree_threshold : Int,
) -> Bool {
  high_degree_degree(node) >= degree_threshold
}

///|
fn high_degree_has_single_connection(
  node : LNode,
  edge_selector : HighDegreeEdgeSelector,
) -> Bool {
  let mut connection : LNode? = None

  for edge in edge_selector(node) {
    let candidate = high_degree_other_node(edge, node)
    match connection {
      None => connection = Some(candidate)
      Some(existing) =>
        if existing.get_handle() != candidate.get_handle() {
          return false
        }
    }
  }

  true
}

///|
fn high_degree_is_tree_root(
  root : LNode,
  ancestor_edges : HighDegreeEdgeSelector,
  descendant_edges : HighDegreeEdgeSelector,
  degree_threshold : Int,
  tree_height_threshold : Int,
) -> Int {
  if high_degree_is_high_degree_node(root, degree_threshold) {
    return -1
  }

  if !high_degree_has_single_connection(root, ancestor_edges) {
    return -1
  }

  if descendant_edges(root).is_empty() {
    return 1
  }

  let mut current_height = 0
  for edge in descendant_edges(root) {
    let other = high_degree_other_node(edge, root)
    let height = high_degree_is_tree_root(
      other, ancestor_edges, descendant_edges, degree_threshold, tree_height_threshold,
    )

    if height == -1 {
      return -1
    }

    current_height = Int::max(current_height, height)
    if current_height > tree_height_threshold - 1 {
      return -1
    }
  }

  current_height + 1
}

///|
fn high_degree_calculate_information(
  node : LNode,
  degree_threshold : Int,
  tree_height_threshold : Int,
) -> HighDegreeNodeInformation {
  let info = new_high_degree_node_information()

  for incoming_edge in node.get_incoming_edges() {
    if incoming_edge.is_self_loop() {
      continue
    }

    let source_node = high_degree_require_source_node(incoming_edge)
    if high_degree_has_single_connection(
        source_node, high_degree_outgoing_edges,
      ) {
      let tree_height = high_degree_is_tree_root(
        source_node, high_degree_outgoing_edges, high_degree_incoming_edges, degree_threshold,
        tree_height_threshold,
      )
      if tree_height == -1 {
        continue
      }

      info.inc_trees_max_height = Int::max(
        info.inc_trees_max_height,
        tree_height,
      )
      info.inc_tree_roots.push(source_node)
    }
  }

  for outgoing_edge in node.get_outgoing_edges() {
    if outgoing_edge.is_self_loop() {
      continue
    }

    let target_node = high_degree_require_target_node(outgoing_edge)
    if high_degree_has_single_connection(
        target_node, high_degree_incoming_edges,
      ) {
      let tree_height = high_degree_is_tree_root(
        target_node, high_degree_incoming_edges, high_degree_outgoing_edges, degree_threshold,
        tree_height_threshold,
      )
      if tree_height == -1 {
        continue
      }

      info.out_trees_max_height = Int::max(
        info.out_trees_max_height,
        tree_height,
      )
      info.out_tree_roots.push(target_node)
    }
  }

  info
}

///|
fn high_degree_move_tree(
  root : LNode,
  edge_selector : HighDegreeEdgeSelector,
  layers : Array[Layer],
  depth : Int,
) -> Unit {
  if depth >= layers.length() {
    return
  }

  root.set_layer(Some(layers[depth]))
  for edge in edge_selector(root) {
    high_degree_move_tree(
      high_degree_other_node(edge, root),
      edge_selector,
      layers,
      depth + 1,
    )
  }
}

///|
fn high_degree_move_tree_root(
  root : LNode,
  edge_selector : HighDegreeEdgeSelector,
  layers : Array[Layer],
) -> Unit {
  high_degree_move_tree(root, edge_selector, layers, 0)
}

///|
fn high_degree_node_layering_processor_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  ignore(progress_monitor)

  let degree_threshold = layered_graph.get_property_int(
    layered_options_high_degree_nodes_threshold,
  )
  let mut tree_height_threshold = layered_graph.get_property_int(
    layered_options_high_degree_nodes_tree_height,
  )
  if tree_height_threshold == 0 {
    tree_height_threshold = @int.max_value
  }

  let layers = layered_graph.get_layers()
  let mut layer_index = 0
  while layer_index < layers.length() {
    let layer = layers[layer_index]

    let high_degree_nodes : Array[HighDegreeNodeCandidate] = []
    let mut inc_max = -1
    let mut out_max = -1
    for node in layer.get_nodes().copy() {
      if high_degree_is_high_degree_node(node, degree_threshold) {
        let info = high_degree_calculate_information(
          node, degree_threshold, tree_height_threshold,
        )
        inc_max = Int::max(inc_max, info.inc_trees_max_height)
        out_max = Int::max(out_max, info.out_trees_max_height)
        let candidate : HighDegreeNodeCandidate = { info, }
        high_degree_nodes.push(candidate)
      }
    }

    let pre_layers : Array[Layer] = []
    let incoming_insertions = Int::max(inc_max, 0)
    for _ in 0..<incoming_insertions {
      let inserted = new_layer(layered_graph)
      ignore(layers.insert(layer_index, inserted))
      ignore(pre_layers.insert(0, inserted))
      layer_index = layer_index + 1
    }
    for candidate in high_degree_nodes {
      for root in candidate.info.inc_tree_roots {
        high_degree_move_tree_root(root, high_degree_incoming_edges, pre_layers)
      }
    }

    let after_layers : Array[Layer] = []
    let outgoing_insertions = Int::max(out_max, 0)
    for offset in 0..<outgoing_insertions {
      let inserted = new_layer(layered_graph)
      ignore(layers.insert(layer_index + 1 + offset, inserted))
      after_layers.push(inserted)
    }
    for candidate in high_degree_nodes {
      for root in candidate.info.out_tree_roots {
        high_degree_move_tree_root(
          root, high_degree_outgoing_edges, after_layers,
        )
      }
    }

    layer_index = layer_index + 1 + outgoing_insertions
  }

  let mut cleanup_index = 0
  while cleanup_index < layers.length() {
    if layers[cleanup_index].get_nodes().is_empty() {
      ignore(layers.remove(cleanup_index))
    } else {
      cleanup_index = cleanup_index + 1
    }
  }
}

///|
pub fn new_high_degree_node_layering_processor_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(high_degree_node_layering_processor_process)
}
