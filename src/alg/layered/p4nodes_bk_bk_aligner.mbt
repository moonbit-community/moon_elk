///|
pub struct BKAligner {
  layered_graph : LGraph
  ni : NeighborhoodInformation
}

///|
pub fn new_bk_aligner(
  layered_graph : LGraph,
  ni : NeighborhoodInformation,
) -> BKAligner {
  { layered_graph, ni }
}

///|
fn bk_aligner_reverse_layers(layers : Array[Layer]) -> Array[Layer] {
  let reversed : Array[Layer] = []
  for i = layers.length() - 1; i >= 0; i = i - 1 {
    reversed.push(layers[i])
  }
  reversed
}

///|
fn bk_aligner_reverse_nodes(nodes : Array[LNode]) -> Array[LNode] {
  let reversed : Array[LNode] = []
  for i = nodes.length() - 1; i >= 0; i = i - 1 {
    reversed.push(nodes[i])
  }
  reversed
}

///|
fn bk_aligner_same_node(left : LNode, right : LNode) -> Bool {
  left.get_handle() == right.get_handle()
}

///|
fn bk_aligner_get_edge(source : LNode, target : LNode) -> LEdge? {
  for edge in source.get_connected_edges() {
    let source_node = match edge.get_source() {
      Some(port) =>
        match port.get_node() {
          Some(node) => node
          None => continue
        }
      None => continue
    }
    let target_node = match edge.get_target() {
      Some(port) =>
        match port.get_node() {
          Some(node) => node
          None => continue
        }
      None => continue
    }

    if target_node.get_handle() == target.get_handle() ||
      source_node.get_handle() == target.get_handle() {
      return Some(edge)
    }
  }

  None
}

///|
pub fn BKAligner::vertical_alignment(
  self : BKAligner,
  bal : BKAlignedLayout,
  marked_edges : Map[Int, Bool],
) -> Unit {
  for layer in self.layered_graph.get_layers() {
    for node in layer.get_nodes() {
      let node_id = node.get_id()
      bal.root[node_id] = Some(node)
      bal.align[node_id] = Some(node)
      bal.inner_shift[node_id] = 0.0
    }
  }

  let mut layers = self.layered_graph.get_layers().copy()
  if bk_hdirection_is_left(bal.require_hdir()) {
    layers = bk_aligner_reverse_layers(layers)
  }

  for layer in layers {
    let mut r = -1
    let mut nodes = layer.get_nodes().copy()

    if bk_vdirection_is_up(bal.require_vdir()) {
      r = 2147483647
      nodes = bk_aligner_reverse_nodes(nodes)
    }

    for node in nodes {
      let neighbors = if bk_hdirection_is_left(bal.require_hdir()) {
        self.ni.right_neighbors[node.get_id()]
      } else {
        self.ni.left_neighbors[node.get_id()]
      }

      if neighbors.is_empty() {
        continue
      }

      let d = neighbors.length()
      let low = (d - 1) / 2
      let high = d / 2

      if bk_vdirection_is_up(bal.require_vdir()) {
        for m = high; m >= low; m = m - 1 {
          if !bk_aligner_same_node(bal.require_align(node), node) {
            continue
          }

          let neighbor = neighbors[m].0
          let edge = neighbors[m].1
          if marked_edges.contains(edge.get_handle()) {
            continue
          }

          let neighbor_index = self.ni.node_index[neighbor.get_id()]
          if r > neighbor_index {
            bal.align[neighbor.get_id()] = Some(node)
            bal.root[node.get_id()] = Some(bal.require_root(neighbor))
            bal.align[node.get_id()] = Some(bal.require_root(node))

            let root_node = bal.require_root(node)
            let node_is_long_edge = match node.get_type() {
              NodeType::LongEdge => true
              _ => false
            }
            bal.od[root_node.get_id()] = bal.od[root_node.get_id()] &&
              node_is_long_edge

            r = neighbor_index
          }
        }
      } else {
        for m = low; m <= high; m = m + 1 {
          if !bk_aligner_same_node(bal.require_align(node), node) {
            continue
          }

          let neighbor = neighbors[m].0
          let edge = neighbors[m].1
          if marked_edges.contains(edge.get_handle()) {
            continue
          }

          let neighbor_index = self.ni.node_index[neighbor.get_id()]
          if r < neighbor_index {
            bal.align[neighbor.get_id()] = Some(node)
            bal.root[node.get_id()] = Some(bal.require_root(neighbor))
            bal.align[node.get_id()] = Some(bal.require_root(node))

            let root_node = bal.require_root(node)
            let node_is_long_edge = match node.get_type() {
              NodeType::LongEdge => true
              _ => false
            }
            bal.od[root_node.get_id()] = bal.od[root_node.get_id()] &&
              node_is_long_edge

            r = neighbor_index
          }
        }
      }
    }
  }
}

///|
pub fn BKAligner::inside_block_shift(
  self : BKAligner,
  bal : BKAlignedLayout,
) -> Unit {
  ignore(self)

  for layer in bal.layered_graph.get_layers() {
    for root in layer.get_nodes() {
      if !bk_aligner_same_node(root, bal.require_root(root)) {
        continue
      }

      let mut space_above = root.get_margin().top
      let mut space_below = root.get_size().y + root.get_margin().bottom
      bal.inner_shift[root.get_id()] = 0.0

      let root_handle = root.get_handle()
      let mut current = root
      while true {
        let next = bal.require_align(current)
        if next.get_handle() == root_handle {
          break
        }

        let edge = match bk_aligner_get_edge(current, next) {
          Some(value) => value
          None => abort("BKAligner: missing edge between aligned nodes")
        }

        let source = match edge.get_source() {
          Some(value) => value
          None => abort("BKAligner: edge source missing")
        }
        let target = match edge.get_target() {
          Some(value) => value
          None => abort("BKAligner: edge target missing")
        }

        let port_pos_diff = if bk_hdirection_is_left(bal.require_hdir()) {
          target.get_position().y +
          target.get_anchor().y -
          source.get_position().y -
          source.get_anchor().y
        } else {
          source.get_position().y +
          source.get_anchor().y -
          target.get_position().y -
          target.get_anchor().y
        }

        let next_inner_shift = bal.inner_shift[current.get_id()] + port_pos_diff
        bal.inner_shift[next.get_id()] = next_inner_shift

        let above = next.get_margin().top - next_inner_shift
        let below = next_inner_shift +
          next.get_size().y +
          next.get_margin().bottom

        if above > space_above {
          space_above = above
        }
        if below > space_below {
          space_below = below
        }

        current = next
      }

      current = root
      while true {
        bal.inner_shift[current.get_id()] = bal.inner_shift[current.get_id()] +
          space_above
        current = bal.require_align(current)
        if current.get_handle() == root_handle {
          break
        }
      }

      bal.block_size[root.get_id()] = space_above + space_below
    }
  }
}
