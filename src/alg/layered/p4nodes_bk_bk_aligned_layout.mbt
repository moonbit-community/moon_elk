///|
pub enum BKVDirection {
  Down
  Up
}

///|
pub enum BKHDirection {
  Right
  Left
}

///|
pub fn bk_vdirection_is_down(value : BKVDirection) -> Bool {
  match value {
    BKVDirection::Down => true
    _ => false
  }
}

///|
pub fn bk_vdirection_is_up(value : BKVDirection) -> Bool {
  match value {
    BKVDirection::Up => true
    _ => false
  }
}

///|
pub fn bk_hdirection_is_right(value : BKHDirection) -> Bool {
  match value {
    BKHDirection::Right => true
    _ => false
  }
}

///|
pub fn bk_hdirection_is_left(value : BKHDirection) -> Bool {
  match value {
    BKHDirection::Left => true
    _ => false
  }
}

///|
pub struct BKAlignedLayout {
  layered_graph : LGraph
  spacings : Spacings
  root : Array[LNode?]
  block_size : Array[Double]
  align : Array[LNode?]
  inner_shift : Array[Double]
  sink : Array[LNode?]
  shift : Array[Double]
  y : Array[Double?]
  vdir : BKVDirection?
  hdir : BKHDirection?
  su : Array[Bool]
  od : Array[Bool]
}

///|
pub fn new_bk_aligned_layout(
  layered_graph : LGraph,
  node_count : Int,
  vdir : BKVDirection?,
  hdir : BKHDirection?,
) -> BKAlignedLayout {
  let root : Array[LNode?] = Array::make(node_count, None)
  let block_size : Array[Double] = Array::make(node_count, 0.0)
  let align : Array[LNode?] = Array::make(node_count, None)
  let inner_shift : Array[Double] = Array::make(node_count, 0.0)
  let sink : Array[LNode?] = Array::make(node_count, None)
  let shift : Array[Double] = Array::make(node_count, 0.0)
  let y : Array[Double?] = Array::make(node_count, None)
  let su : Array[Bool] = Array::make(node_count, false)
  let od : Array[Bool] = Array::make(node_count, true)

  {
    layered_graph,
    spacings: new_layered_spacings(layered_graph),
    root,
    block_size,
    align,
    inner_shift,
    sink,
    shift,
    y,
    vdir,
    hdir,
    su,
    od,
  }
}

///|
pub fn BKAlignedLayout::cleanup(self : BKAlignedLayout) -> Unit {
  self.root.clear()
  self.block_size.clear()
  self.align.clear()
  self.inner_shift.clear()
  self.sink.clear()
  self.shift.clear()
  self.y.clear()
  self.su.clear()
  self.od.clear()
}

///|
fn bk_aligned_layout_require_index(
  length : Int,
  index : Int,
  kind : String,
) -> Unit {
  if index < 0 || index >= length {
    abort("BKAlignedLayout: invalid \{kind} index")
  }
}

///|
pub fn BKAlignedLayout::require_vdir(self : BKAlignedLayout) -> BKVDirection {
  match self.vdir {
    Some(value) => value
    None => abort("BKAlignedLayout: vdir is not set")
  }
}

///|
pub fn BKAlignedLayout::require_hdir(self : BKAlignedLayout) -> BKHDirection {
  match self.hdir {
    Some(value) => value
    None => abort("BKAlignedLayout: hdir is not set")
  }
}

///|
pub fn BKAlignedLayout::require_root(
  self : BKAlignedLayout,
  node : LNode,
) -> LNode {
  self.require_root_by_id(node.get_id())
}

///|
pub fn BKAlignedLayout::require_root_by_id(
  self : BKAlignedLayout,
  node_id : Int,
) -> LNode {
  bk_aligned_layout_require_index(self.root.length(), node_id, "root")
  match self.root[node_id] {
    Some(value) => value
    None => abort("BKAlignedLayout: root is not set")
  }
}

///|
pub fn BKAlignedLayout::require_align(
  self : BKAlignedLayout,
  node : LNode,
) -> LNode {
  self.require_align_by_id(node.get_id())
}

///|
pub fn BKAlignedLayout::require_align_by_id(
  self : BKAlignedLayout,
  node_id : Int,
) -> LNode {
  bk_aligned_layout_require_index(self.align.length(), node_id, "align")
  match self.align[node_id] {
    Some(value) => value
    None => abort("BKAlignedLayout: align is not set")
  }
}

///|
pub fn BKAlignedLayout::require_sink(
  self : BKAlignedLayout,
  node : LNode,
) -> LNode {
  self.require_sink_by_id(node.get_id())
}

///|
pub fn BKAlignedLayout::require_sink_by_id(
  self : BKAlignedLayout,
  node_id : Int,
) -> LNode {
  bk_aligned_layout_require_index(self.sink.length(), node_id, "sink")
  match self.sink[node_id] {
    Some(value) => value
    None => abort("BKAlignedLayout: sink is not set")
  }
}

///|
pub fn BKAlignedLayout::require_y(
  self : BKAlignedLayout,
  node : LNode,
) -> Double {
  self.require_y_by_id(node.get_id())
}

///|
pub fn BKAlignedLayout::require_y_by_id(
  self : BKAlignedLayout,
  node_id : Int,
) -> Double {
  bk_aligned_layout_require_index(self.y.length(), node_id, "y")
  match self.y[node_id] {
    Some(value) => value
    None => abort("BKAlignedLayout: y is not set")
  }
}

///|
pub fn BKAlignedLayout::set_y_by_id(
  self : BKAlignedLayout,
  node_id : Int,
  value : Double,
) -> Unit {
  bk_aligned_layout_require_index(self.y.length(), node_id, "y")
  self.y[node_id] = Some(value)
}

///|
pub fn BKAlignedLayout::layout_size(self : BKAlignedLayout) -> Double {
  let mut min_value = @double.infinity
  let mut max_value = @double.neg_infinity

  for layer in self.layered_graph.get_layers() {
    for node in layer.get_nodes() {
      let node_id = node.get_id()
      let y_min = self.require_y_by_id(node_id)
      let root_node = self.require_root_by_id(node_id)
      let y_max = y_min + self.block_size[root_node.get_id()]

      if y_min < min_value {
        min_value = y_min
      }
      if y_max > max_value {
        max_value = y_max
      }
    }
  }

  if min_value.is_pos_inf() {
    0.0
  } else {
    max_value - min_value
  }
}

///|
pub fn BKAlignedLayout::calculate_delta(
  self : BKAlignedLayout,
  src : LPort,
  tgt : LPort,
) -> Double {
  let src_node = match src.get_node() {
    Some(value) => value
    None => abort("BKAlignedLayout: source port has no node")
  }
  let tgt_node = match tgt.get_node() {
    Some(value) => value
    None => abort("BKAlignedLayout: target port has no node")
  }

  let src_id = src_node.get_id()
  let tgt_id = tgt_node.get_id()

  let src_pos = self.require_y_by_id(src_id) +
    self.inner_shift[src_id] +
    src.get_position().y +
    src.get_anchor().y
  let tgt_pos = self.require_y_by_id(tgt_id) +
    self.inner_shift[tgt_id] +
    tgt.get_position().y +
    tgt.get_anchor().y

  tgt_pos - src_pos
}

///|
pub fn BKAlignedLayout::shift_block(
  self : BKAlignedLayout,
  root_node : LNode,
  delta : Double,
) -> Unit {
  let root_handle = root_node.get_handle()
  let mut current = root_node

  while true {
    let current_id = current.get_id()
    let new_pos = self.require_y_by_id(current_id) + delta
    self.y[current_id] = Some(new_pos)

    current = self.require_align(current)
    if current.get_handle() == root_handle {
      break
    }
  }
}

///|
pub fn BKAlignedLayout::check_space_above(
  self : BKAlignedLayout,
  block_root : LNode,
  delta : Double,
  ni : NeighborhoodInformation,
) -> Double {
  let mut available_space = delta
  let root_handle = block_root.get_handle()
  let mut current = block_root

  while true {
    current = self.require_align(current)
    let min_y_current = self.get_min_y(current)

    match self.get_upper_neighbor(current, ni) {
      Some(neighbor) => {
        let max_y_neighbor = self.get_max_y(neighbor)
        let spacing = self.spacings.get_vertical_spacing(current, neighbor)
        let candidate = min_y_current - (max_y_neighbor + spacing)
        if candidate < available_space {
          available_space = candidate
        }
      }
      None => ()
    }

    if current.get_handle() == root_handle {
      break
    }
  }

  available_space
}

///|
pub fn BKAlignedLayout::check_space_below(
  self : BKAlignedLayout,
  block_root : LNode,
  delta : Double,
  ni : NeighborhoodInformation,
) -> Double {
  let mut available_space = delta
  let root_handle = block_root.get_handle()
  let mut current = block_root

  while true {
    current = self.require_align(current)
    let max_y_current = self.get_max_y(current)

    match self.get_lower_neighbor(current, ni) {
      Some(neighbor) => {
        let min_y_neighbor = self.get_min_y(neighbor)
        let spacing = self.spacings.get_vertical_spacing(current, neighbor)
        let candidate = min_y_neighbor - (max_y_current + spacing)
        if candidate < available_space {
          available_space = candidate
        }
      }
      None => ()
    }

    if current.get_handle() == root_handle {
      break
    }
  }

  available_space
}

///|
pub fn BKAlignedLayout::get_min_y(
  self : BKAlignedLayout,
  node : LNode,
) -> Double {
  let root_node = self.require_root(node)
  self.require_y(root_node) +
  self.inner_shift[node.get_id()] -
  node.get_margin().top
}

///|
pub fn BKAlignedLayout::get_max_y(
  self : BKAlignedLayout,
  node : LNode,
) -> Double {
  let root_node = self.require_root(node)
  self.require_y(root_node) +
  self.inner_shift[node.get_id()] +
  node.get_size().y +
  node.get_margin().bottom
}

///|
fn BKAlignedLayout::get_lower_neighbor(
  self : BKAlignedLayout,
  node : LNode,
  ni : NeighborhoodInformation,
) -> LNode? {
  ignore(self)
  let layer = match node.get_layer() {
    Some(value) => value
    None => return None
  }

  let node_id = node.get_id()
  let layer_pos = ni.node_index[node_id]
  let nodes = layer.get_nodes()

  if layer_pos < nodes.length() - 1 {
    Some(nodes[layer_pos + 1])
  } else {
    None
  }
}

///|
fn BKAlignedLayout::get_upper_neighbor(
  self : BKAlignedLayout,
  node : LNode,
  ni : NeighborhoodInformation,
) -> LNode? {
  ignore(self)
  let layer = match node.get_layer() {
    Some(value) => value
    None => return None
  }

  let node_id = node.get_id()
  let layer_pos = ni.node_index[node_id]
  let nodes = layer.get_nodes()

  if layer_pos > 0 {
    Some(nodes[layer_pos - 1])
  } else {
    None
  }
}

///|
pub fn BKAlignedLayout::to_string(self : BKAlignedLayout) -> String {
  let mut result = ""

  match self.hdir {
    Some(BKHDirection::Right) => result = result + "RIGHT"
    Some(BKHDirection::Left) => result = result + "LEFT"
    None => ()
  }

  match self.vdir {
    Some(BKVDirection::Down) => result = result + "DOWN"
    Some(BKVDirection::Up) => result = result + "UP"
    None => result = result + "BALANCED"
  }

  result
}
