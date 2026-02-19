///|
let bk_threshold = @double.max_value

///|
pub enum BkThresholdStrategyKind {
  NullThreshold
  SimpleThreshold
}

///|
pub struct BkPostprocessable {
  free : LNode
  is_root : Bool
  mut has_edges : Bool
  mut edge : LEdge?
}

///|
fn new_bk_postprocessable(free : LNode, is_root : Bool) -> BkPostprocessable {
  { free, is_root, has_edges: false, edge: None }
}

///|
pub struct BkThresholdStrategy {
  kind : BkThresholdStrategyKind
  mut bal : BKAlignedLayout?
  mut ni : NeighborhoodInformation?
  block_finished : Map[Int, Bool]
  post_processables_queue : Array[BkPostprocessable]
  post_processables_stack : Array[BkPostprocessable]
}

///|
pub fn new_bk_null_threshold_strategy() -> BkThresholdStrategy {
  {
    kind: BkThresholdStrategyKind::NullThreshold,
    bal: None,
    ni: None,
    block_finished: {},
    post_processables_queue: [],
    post_processables_stack: [],
  }
}

///|
pub fn new_bk_simple_threshold_strategy() -> BkThresholdStrategy {
  {
    kind: BkThresholdStrategyKind::SimpleThreshold,
    bal: None,
    ni: None,
    block_finished: {},
    post_processables_queue: [],
    post_processables_stack: [],
  }
}

///|
fn BkThresholdStrategy::require_bal(
  self : BkThresholdStrategy,
) -> BKAlignedLayout {
  match self.bal {
    Some(value) => value
    None => abort("BkThresholdStrategy: bal is not initialized")
  }
}

///|
fn BkThresholdStrategy::require_ni(
  self : BkThresholdStrategy,
) -> NeighborhoodInformation {
  match self.ni {
    Some(value) => value
    None => abort("BkThresholdStrategy: ni is not initialized")
  }
}

///|
fn bk_threshold_strategy_same_node(left : LNode, right : LNode) -> Bool {
  left.get_handle() == right.get_handle()
}

///|
fn bk_threshold_strategy_require_node_from_port(port : LPort) -> LNode {
  match port.get_node() {
    Some(value) => value
    None => abort("BkThresholdStrategy: port has no owner node")
  }
}

///|
fn bk_threshold_strategy_require_edge(pp : BkPostprocessable) -> LEdge {
  match pp.edge {
    Some(value) => value
    None => abort("BkThresholdStrategy: postprocessable has no edge")
  }
}

///|
pub fn BkThresholdStrategy::init(
  self : BkThresholdStrategy,
  bal : BKAlignedLayout,
  ni : NeighborhoodInformation,
) -> Unit {
  self.bal = Some(bal)
  self.ni = Some(ni)
  self.block_finished.clear()
  self.post_processables_queue.clear()
  self.post_processables_stack.clear()
}

///|
pub fn BkThresholdStrategy::finish_block(
  self : BkThresholdStrategy,
  node : LNode,
) -> Unit {
  self.block_finished[node.get_handle()] = true
}

///|
pub fn BkThresholdStrategy::get_other(
  self : BkThresholdStrategy,
  edge : LEdge,
  node : LNode,
) -> LNode {
  ignore(self)
  let source = match edge.get_source() {
    Some(value) => value
    None => abort("BkThresholdStrategy: edge has no source")
  }
  let target = match edge.get_target() {
    Some(value) => value
    None => abort("BkThresholdStrategy: edge has no target")
  }
  let source_node = bk_threshold_strategy_require_node_from_port(source)
  let target_node = bk_threshold_strategy_require_node_from_port(target)

  if source_node.get_handle() == node.get_handle() {
    target_node
  } else if target_node.get_handle() == node.get_handle() {
    source_node
  } else {
    abort("BkThresholdStrategy: node is neither source nor target of edge")
  }
}

///|
fn BkThresholdStrategy::pick_edge(
  self : BkThresholdStrategy,
  pp : BkPostprocessable,
) -> BkPostprocessable {
  let bal = self.require_bal()

  let edges = if pp.is_root {
    if bk_hdirection_is_right(bal.require_hdir()) {
      pp.free.get_incoming_edges()
    } else {
      pp.free.get_outgoing_edges()
    }
  } else if bk_hdirection_is_left(bal.require_hdir()) {
    pp.free.get_incoming_edges()
  } else {
    pp.free.get_outgoing_edges()
  }

  let mut has_edges = false
  for edge in edges {
    let free_root = bal.require_root(pp.free)
    let only_dummies = bal.od[free_root.get_id()]

    if !only_dummies && edge.is_in_layer_edge() {
      continue
    }

    if bal.su[free_root.get_id()] {
      continue
    }

    has_edges = true

    let other = self.get_other(edge, pp.free)
    let other_root = bal.require_root(other)
    if self.block_finished.contains(other_root.get_handle()) {
      pp.has_edges = true
      pp.edge = Some(edge)
      return pp
    }
  }

  pp.has_edges = has_edges
  pp.edge = None
  pp
}

///|
fn BkThresholdStrategy::get_bound(
  self : BkThresholdStrategy,
  block_node : LNode,
  is_root : Bool,
) -> Double {
  let bal = self.require_bal()

  let invalid = if bk_vdirection_is_up(bal.require_vdir()) {
    @double.infinity
  } else {
    @double.neg_infinity
  }

  let pick = self.pick_edge(new_bk_postprocessable(block_node, is_root))
  if pick.edge is None {
    if pick.has_edges {
      self.post_processables_queue.push(pick)
    }
    return invalid
  }

  let edge = bk_threshold_strategy_require_edge(pick)
  let left = match edge.get_source() {
    Some(value) => value
    None => abort("BkThresholdStrategy: edge source missing")
  }
  let right = match edge.get_target() {
    Some(value) => value
    None => abort("BkThresholdStrategy: edge target missing")
  }

  let threshold = if is_root {
    let root_port = if bk_hdirection_is_right(bal.require_hdir()) {
      right
    } else {
      left
    }
    let other_port = if bk_hdirection_is_right(bal.require_hdir()) {
      left
    } else {
      right
    }

    let root_port_node = bk_threshold_strategy_require_node_from_port(root_port)
    let other_port_node = bk_threshold_strategy_require_node_from_port(
      other_port,
    )
    let other_root = bal.require_root(other_port_node)

    bal.require_y(other_root) +
    bal.inner_shift[other_port_node.get_id()] +
    other_port.get_position().y +
    other_port.get_anchor().y -
    bal.inner_shift[root_port_node.get_id()] -
    root_port.get_position().y -
    root_port.get_anchor().y
  } else {
    let root_port = if bk_hdirection_is_left(bal.require_hdir()) {
      right
    } else {
      left
    }
    let other_port = if bk_hdirection_is_left(bal.require_hdir()) {
      left
    } else {
      right
    }

    let root_port_node = bk_threshold_strategy_require_node_from_port(root_port)
    let other_port_node = bk_threshold_strategy_require_node_from_port(
      other_port,
    )
    let other_root = bal.require_root(other_port_node)

    bal.require_y(other_root) +
    bal.inner_shift[other_port_node.get_id()] +
    other_port.get_position().y +
    other_port.get_anchor().y -
    bal.inner_shift[root_port_node.get_id()] -
    root_port.get_position().y -
    root_port.get_anchor().y
  }

  let left_node = bk_threshold_strategy_require_node_from_port(left)
  let right_node = bk_threshold_strategy_require_node_from_port(right)
  bal.su[bal.require_root(left_node).get_id()] = true
  bal.su[bal.require_root(right_node).get_id()] = true

  threshold
}

///|
fn BkThresholdStrategy::calculate_threshold_simple(
  self : BkThresholdStrategy,
  old_thresh : Double,
  block_root : LNode,
  current_node : LNode,
) -> Double {
  let bal = self.require_bal()

  let is_root = bk_threshold_strategy_same_node(block_root, current_node)
  let is_last = bk_threshold_strategy_same_node(
    bal.require_align(current_node),
    block_root,
  )

  if !(is_root || is_last) {
    return old_thresh
  }

  let mut threshold = old_thresh

  if is_root {
    threshold = self.get_bound(block_root, true)
  }
  if threshold.is_inf() && is_last {
    threshold = self.get_bound(current_node, false)
  }

  threshold
}

///|
fn BkThresholdStrategy::process_postprocessable(
  self : BkThresholdStrategy,
  pp : BkPostprocessable,
) -> Bool {
  let bal = self.require_bal()
  let ni = self.require_ni()
  let edge = bk_threshold_strategy_require_edge(pp)

  let source = match edge.get_source() {
    Some(value) => value
    None => return false
  }
  let target = match edge.get_target() {
    Some(value) => value
    None => return false
  }

  let source_node = bk_threshold_strategy_require_node_from_port(source)

  let (fix, block) = if source_node.get_handle() == pp.free.get_handle() {
    (target, source)
  } else {
    (source, target)
  }

  let delta = bal.calculate_delta(fix, block)
  let block_node = bk_threshold_strategy_require_node_from_port(block)

  if delta > 0.0 && delta < bk_threshold {
    let available_space = bal.check_space_above(block_node, delta, ni)
    bal.shift_block(block_node, -available_space)
    return available_space > 0.0
  }

  if delta < 0.0 && -delta < bk_threshold {
    let available_space = bal.check_space_below(block_node, -delta, ni)
    bal.shift_block(block_node, available_space)
    return available_space > 0.0
  }

  false
}

///|
fn BkThresholdStrategy::post_process_simple(self : BkThresholdStrategy) -> Unit {
  let bal = self.require_bal()

  while !self.post_processables_queue.is_empty() {
    let pp = self.post_processables_queue.remove(0)
    let pick = self.pick_edge(pp)

    if pick.edge is None {
      continue
    }

    let edge = bk_threshold_strategy_require_edge(pick)
    let free_root = bal.require_root(pick.free)
    let only_dummies = bal.od[free_root.get_id()]

    if !only_dummies && edge.is_in_layer_edge() {
      continue
    }

    let moved = self.process_postprocessable(pick)
    if !moved {
      self.post_processables_stack.push(pick)
    }
  }

  while !self.post_processables_stack.is_empty() {
    let index = self.post_processables_stack.length() - 1
    let pp = self.post_processables_stack.remove(index)
    ignore(self.process_postprocessable(pp))
  }
}

///|
pub fn BkThresholdStrategy::calculate_threshold(
  self : BkThresholdStrategy,
  old_thresh : Double,
  block_root : LNode,
  current_node : LNode,
) -> Double {
  match self.kind {
    BkThresholdStrategyKind::NullThreshold =>
      if bk_vdirection_is_up(self.require_bal().require_vdir()) {
        @double.infinity
      } else {
        @double.neg_infinity
      }
    BkThresholdStrategyKind::SimpleThreshold =>
      self.calculate_threshold_simple(old_thresh, block_root, current_node)
  }
}

///|
pub fn BkThresholdStrategy::post_process(self : BkThresholdStrategy) -> Unit {
  match self.kind {
    BkThresholdStrategyKind::NullThreshold => ()
    BkThresholdStrategyKind::SimpleThreshold => self.post_process_simple()
  }
}
