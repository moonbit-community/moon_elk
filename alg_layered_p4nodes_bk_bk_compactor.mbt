///|
fn bk_compactor_same_node(left : LNode, right : LNode) -> Bool {
  left.get_handle() == right.get_handle()
}

///|
fn bk_compactor_reverse_layers(layers : Array[Layer]) -> Array[Layer] {
  let reversed : Array[Layer] = []
  for i = layers.length() - 1; i >= 0; i = i - 1 {
    reversed.push(layers[i])
  }
  reversed
}

///|
fn bk_compactor_reverse_nodes(nodes : Array[LNode]) -> Array[LNode] {
  let reversed : Array[LNode] = []
  for i = nodes.length() - 1; i >= 0; i = i - 1 {
    reversed.push(nodes[i])
  }
  reversed
}

///|
pub struct BKCompactor {
  layered_graph : LGraph
  thresh_strategy : BkThresholdStrategy
  ni : NeighborhoodInformation
  spacings : Spacings
  class_nodes : Map[Int, LNode]
  class_outgoing : Map[Int, Array[(Int, Double)]]
  class_indegree : Map[Int, Int]
  class_shift : Map[Int, Double]
}

///|
pub fn new_bk_compactor(
  layered_graph : LGraph,
  ni : NeighborhoodInformation,
) -> BKCompactor {
  let edge_straightening = layered_graph.get_property_string(
    layered_options_node_placement_bk_edge_straightening,
  )

  let thresh_strategy = if edge_straightening == "IMPROVE_STRAIGHTNESS" {
    new_bk_simple_threshold_strategy()
  } else {
    new_bk_null_threshold_strategy()
  }

  {
    layered_graph,
    thresh_strategy,
    ni,
    spacings: new_layered_spacings(layered_graph),
    class_nodes: {},
    class_outgoing: {},
    class_indegree: {},
    class_shift: {},
  }
}

///|
fn BKCompactor::ensure_class_node(self : BKCompactor, sink_node : LNode) -> Int {
  let handle = sink_node.get_handle()
  if !self.class_nodes.contains(handle) {
    self.class_nodes[handle] = sink_node
    self.class_outgoing[handle] = []
    self.class_indegree[handle] = 0
  }
  handle
}

///|
fn BKCompactor::add_class_edge(
  self : BKCompactor,
  source_sink : LNode,
  target_sink : LNode,
  separation : Double,
) -> Unit {
  let source_handle = self.ensure_class_node(source_sink)
  let target_handle = self.ensure_class_node(target_sink)

  let outgoing = match self.class_outgoing.get(source_handle) {
    Some(value) => value
    None => []
  }
  outgoing.push((target_handle, separation))
  self.class_outgoing[source_handle] = outgoing

  let target_indegree = match self.class_indegree.get(target_handle) {
    Some(value) => value
    None => 0
  }
  self.class_indegree[target_handle] = target_indegree + 1
}

///|
fn BKCompactor::place_classes(
  self : BKCompactor,
  bal : BKAlignedLayout,
) -> Unit {
  let queue : Array[Int] = []
  for entry in self.class_nodes.to_array() {
    let (handle, _) = entry
    let indegree = match self.class_indegree.get(handle) {
      Some(value) => value
      None => 0
    }
    if indegree == 0 {
      queue.push(handle)
    }
  }

  let mut head = 0
  while head < queue.length() {
    let handle = queue[head]
    head += 1

    if !self.class_shift.contains(handle) {
      self.class_shift[handle] = 0.0
    }

    let current_shift = match self.class_shift.get(handle) {
      Some(value) => value
      None => 0.0
    }

    let outgoing = match self.class_outgoing.get(handle) {
      Some(value) => value
      None => []
    }

    for edge in outgoing {
      let (target_handle, separation) = edge
      let candidate_shift = current_shift + separation

      if !self.class_shift.contains(target_handle) {
        self.class_shift[target_handle] = candidate_shift
      } else {
        let old_shift = match self.class_shift.get(target_handle) {
          Some(value) => value
          None => candidate_shift
        }

        if bk_vdirection_is_down(bal.require_vdir()) {
          if candidate_shift < old_shift {
            self.class_shift[target_handle] = candidate_shift
          }
        } else if candidate_shift > old_shift {
          self.class_shift[target_handle] = candidate_shift
        }
      }

      let new_indegree = (match self.class_indegree.get(target_handle) {
          Some(value) => value
          None => 0
        }) -
        1
      self.class_indegree[target_handle] = new_indegree
      if new_indegree == 0 {
        queue.push(target_handle)
      }
    }
  }

  for entry in self.class_nodes.to_array() {
    let (handle, node) = entry
    match self.class_shift.get(handle) {
      Some(class_shift) => bal.shift[node.get_id()] = class_shift
      None => ()
    }
  }
}

///|
fn BKCompactor::place_block(
  self : BKCompactor,
  root : LNode,
  bal : BKAlignedLayout,
) -> Unit {
  if bal.y[root.get_id()] is Some(_) {
    return
  }

  let mut is_initial_assignment = true
  bal.y[root.get_id()] = Some(0.0)

  let mut current_node = root
  let mut threshold = if bk_vdirection_is_down(bal.require_vdir()) {
    @double.neg_infinity
  } else {
    @double.infinity
  }

  let root_handle = root.get_handle()
  while true {
    let current_layer = match current_node.get_layer() {
      Some(value) => value
      None => abort("BKCompactor: node has no layer")
    }
    let current_index_in_layer = self.ni.node_index[current_node.get_id()]
    let current_layer_size = current_layer.get_nodes().length()

    if (bk_vdirection_is_down(bal.require_vdir()) && current_index_in_layer > 0) ||
      (
        bk_vdirection_is_up(bal.require_vdir()) &&
        current_index_in_layer < current_layer_size - 1
      ) {
      let neighbor = if bk_vdirection_is_up(bal.require_vdir()) {
        current_layer.get_nodes()[current_index_in_layer + 1]
      } else {
        current_layer.get_nodes()[current_index_in_layer - 1]
      }
      let neighbor_root = bal.require_root(neighbor)

      self.place_block(neighbor_root, bal)

      threshold = self.thresh_strategy.calculate_threshold(
        threshold, root, current_node,
      )

      if bk_compactor_same_node(bal.require_sink(root), root) {
        bal.sink[root.get_id()] = Some(bal.require_sink(neighbor_root))
      }

      if bk_compactor_same_node(
          bal.require_sink(root),
          bal.require_sink(neighbor_root),
        ) {
        let spacing = self.spacings.get_vertical_spacing(current_node, neighbor)

        if bk_vdirection_is_up(bal.require_vdir()) {
          let current_block_position = bal.require_y(root)
          let new_position = bal.require_y(neighbor_root) +
            bal.inner_shift[neighbor.get_id()] -
            neighbor.get_margin().top -
            spacing -
            current_node.get_margin().bottom -
            current_node.get_size().y -
            bal.inner_shift[current_node.get_id()]

          if is_initial_assignment {
            is_initial_assignment = false
            bal.y[root.get_id()] = Some(
              if new_position < threshold {
                new_position
              } else {
                threshold
              },
            )
          } else {
            let candidate = if new_position < threshold {
              new_position
            } else {
              threshold
            }
            bal.y[root.get_id()] = Some(
              if current_block_position < candidate {
                current_block_position
              } else {
                candidate
              },
            )
          }
        } else {
          let current_block_position = bal.require_y(root)
          let new_position = bal.require_y(neighbor_root) +
            bal.inner_shift[neighbor.get_id()] +
            neighbor.get_size().y +
            neighbor.get_margin().bottom +
            spacing +
            current_node.get_margin().top -
            bal.inner_shift[current_node.get_id()]

          if is_initial_assignment {
            is_initial_assignment = false
            bal.y[root.get_id()] = Some(
              if new_position > threshold {
                new_position
              } else {
                threshold
              },
            )
          } else {
            let candidate = if new_position > threshold {
              new_position
            } else {
              threshold
            }
            bal.y[root.get_id()] = Some(
              if current_block_position > candidate {
                current_block_position
              } else {
                candidate
              },
            )
          }
        }
      } else {
        let spacing = self.layered_graph.get_property_double(spacing_node_node)

        let source_sink = bal.require_sink(root)
        let target_sink = bal.require_sink(neighbor_root)

        if bk_vdirection_is_up(bal.require_vdir()) {
          let required_space = bal.require_y(root) +
            bal.inner_shift[current_node.get_id()] +
            current_node.get_size().y +
            current_node.get_margin().bottom +
            spacing -
            (
              bal.require_y(neighbor_root) +
              bal.inner_shift[neighbor.get_id()] -
              neighbor.get_margin().top
            )

          self.add_class_edge(source_sink, target_sink, required_space)
        } else {
          let required_space = bal.require_y(root) +
            bal.inner_shift[current_node.get_id()] -
            current_node.get_margin().top -
            bal.require_y(neighbor_root) -
            bal.inner_shift[neighbor.get_id()] -
            neighbor.get_size().y -
            neighbor.get_margin().bottom -
            spacing

          self.add_class_edge(source_sink, target_sink, required_space)
        }
      }
    } else {
      threshold = self.thresh_strategy.calculate_threshold(
        threshold, root, current_node,
      )
    }

    current_node = bal.require_align(current_node)
    if current_node.get_handle() == root_handle {
      break
    }
  }

  self.thresh_strategy.finish_block(root)
}

///|
pub fn BKCompactor::horizontal_compaction(
  self : BKCompactor,
  bal : BKAlignedLayout,
) -> Unit {
  for layer in self.layered_graph.get_layers() {
    for node in layer.get_nodes() {
      let node_id = node.get_id()
      bal.sink[node_id] = Some(node)
      bal.shift[node_id] = if bk_vdirection_is_up(bal.require_vdir()) {
        @double.neg_infinity
      } else {
        @double.infinity
      }
    }
  }

  self.class_nodes.clear()
  self.class_outgoing.clear()
  self.class_indegree.clear()
  self.class_shift.clear()

  let mut layers = self.layered_graph.get_layers().copy()
  if bk_hdirection_is_left(bal.require_hdir()) {
    layers = bk_compactor_reverse_layers(layers)
  }

  self.thresh_strategy.init(bal, self.ni)
  for i = 0; i < bal.y.length(); i = i + 1 {
    bal.y[i] = None
  }

  for layer in layers {
    let mut nodes = layer.get_nodes().copy()
    if bk_vdirection_is_up(bal.require_vdir()) {
      nodes = bk_compactor_reverse_nodes(nodes)
    }

    for node in nodes {
      if bk_compactor_same_node(bal.require_root(node), node) {
        self.place_block(node, bal)
      }
    }
  }

  self.place_classes(bal)

  for layer in layers {
    for node in layer.get_nodes() {
      let root_node = bal.require_root(node)
      bal.y[node.get_id()] = Some(bal.require_y(root_node))

      if bk_compactor_same_node(node, root_node) {
        let sink_shift = bal.shift[bal.require_sink(node).get_id()]
        if (bk_vdirection_is_up(bal.require_vdir()) && !sink_shift.is_neg_inf()) ||
          (
            bk_vdirection_is_down(bal.require_vdir()) &&
            !sink_shift.is_pos_inf()
          ) {
          bal.y[node.get_id()] = Some(bal.require_y(node) + sink_shift)
        }
      }
    }
  }

  self.thresh_strategy.post_process()
}
