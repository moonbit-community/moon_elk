///|
pub struct IRectangleStripOverlapRemovalStrategy {
  remove_overlaps : (RectangleStripOverlapRemover) -> Double
}

///|
pub fn new_irectangle_strip_overlap_removal_strategy(
  remove_overlaps : (RectangleStripOverlapRemover) -> Double,
) -> IRectangleStripOverlapRemovalStrategy {
  { remove_overlaps, }
}

///|
pub fn IRectangleStripOverlapRemovalStrategy::remove_overlaps(
  self : IRectangleStripOverlapRemovalStrategy,
  overlap_remover : RectangleStripOverlapRemover,
) -> Double {
  (self.remove_overlaps)(overlap_remover)
}

///|
pub struct RectangleNode {
  handle : Int
} derive(Eq)

///|
priv struct RectangleNodeData {
  mut original_rectangle : ElkRectangle
  rectangle : ElkRectangle
  overlapping_nodes : Array[RectangleNode]
}

///|
let rectangle_node_store : Ref[Array[RectangleNodeData]] = Ref::new([])

///|
pub struct RectangleStripOverlapRemover {
  overlap_removal_direction : Direction
  mut gap_vertical : Double
  mut gap_horizontal : Double
  mut start_coordinate : Double
  mut overlap_removal_strategy : IRectangleStripOverlapRemovalStrategy?
  rectangle_nodes : Array[RectangleNode]
}

///|
fn checked_rectangle_node(node : RectangleNode) -> Unit {
  if node.handle < 0 || node.handle >= rectangle_node_store.val.length() {
    abort("Invalid RectangleNode handle")
  }
}

///|
fn new_rectangle_node(
  original_rectangle : ElkRectangle,
  rectangle : ElkRectangle,
) -> RectangleNode {
  let node : RectangleNode = { handle: rectangle_node_store.val.length() }
  rectangle_node_store.val.push({
    original_rectangle,
    rectangle,
    overlapping_nodes: [],
  })
  node
}

///|
pub fn RectangleNode::get_rectangle(self : RectangleNode) -> ElkRectangle {
  checked_rectangle_node(self)
  rectangle_node_store.val[self.handle].rectangle
}

///|
pub fn RectangleNode::set_rectangle_y(self : RectangleNode, y : Double) -> Unit {
  checked_rectangle_node(self)
  rectangle_node_store.val[self.handle].rectangle.y = y
}

///|
pub fn RectangleNode::get_overlapping_nodes(
  self : RectangleNode,
) -> Array[RectangleNode] {
  checked_rectangle_node(self)
  rectangle_node_store.val[self.handle].overlapping_nodes
}

///|
pub fn RectangleNode::clear_overlapping_nodes(self : RectangleNode) -> Unit {
  checked_rectangle_node(self)
  rectangle_node_store.val[self.handle].overlapping_nodes.clear()
}

///|
pub fn RectangleNode::add_overlapping_node(
  self : RectangleNode,
  other : RectangleNode,
) -> Unit {
  checked_rectangle_node(self)
  checked_rectangle_node(other)
  rectangle_node_store.val[self.handle].overlapping_nodes.push(other)
}

///|
pub fn create_rectangle_strip_overlap_remover_for_direction(
  direction : Direction,
) -> RectangleStripOverlapRemover {
  {
    overlap_removal_direction: direction,
    gap_vertical: 5.0,
    gap_horizontal: 5.0,
    start_coordinate: 0.0,
    overlap_removal_strategy: None,
    rectangle_nodes: [],
  }
}

///|
pub fn RectangleStripOverlapRemover::with_gap(
  self : RectangleStripOverlapRemover,
  horizontal_gap : Double,
  vertical_gap : Double,
) -> RectangleStripOverlapRemover {
  self.gap_horizontal = horizontal_gap
  self.gap_vertical = vertical_gap
  self
}

///|
pub fn RectangleStripOverlapRemover::with_start_coordinate(
  self : RectangleStripOverlapRemover,
  coordinate : Double,
) -> RectangleStripOverlapRemover {
  self.start_coordinate = coordinate
  self
}

///|
pub fn RectangleStripOverlapRemover::with_overlap_removal_strategy(
  self : RectangleStripOverlapRemover,
  strategy : IRectangleStripOverlapRemovalStrategy,
) -> RectangleStripOverlapRemover {
  self.overlap_removal_strategy = Some(strategy)
  self
}

///|
fn rectangle_strip_overlap_remover_import_rectangle(
  remover : RectangleStripOverlapRemover,
  rectangle : ElkRectangle,
) -> ElkRectangle {
  match remover.overlap_removal_direction {
    Upward => rectangle
    Downward => rectangle
    Leftward =>
      new_elk_rectangle_xywh(
        rectangle.y,
        0.0,
        rectangle.height,
        rectangle.width,
      )
    Rightward =>
      new_elk_rectangle_xywh(
        rectangle.y,
        0.0,
        rectangle.height,
        rectangle.width,
      )
    Undefined => rectangle
  }
}

///|
pub fn RectangleStripOverlapRemover::add_rectangle(
  self : RectangleStripOverlapRemover,
  rectangle : ElkRectangle,
) -> RectangleStripOverlapRemover {
  let imported = rectangle_strip_overlap_remover_import_rectangle(
    self, rectangle,
  )
  let node = new_rectangle_node(rectangle, imported)
  self.rectangle_nodes.push(node)
  self
}

///|
pub fn RectangleStripOverlapRemover::get_horizontal_gap(
  self : RectangleStripOverlapRemover,
) -> Double {
  self.gap_horizontal
}

///|
pub fn RectangleStripOverlapRemover::get_vertical_gap(
  self : RectangleStripOverlapRemover,
) -> Double {
  self.gap_vertical
}

///|
pub fn RectangleStripOverlapRemover::get_rectangle_nodes(
  self : RectangleStripOverlapRemover,
) -> Array[RectangleNode] {
  self.rectangle_nodes
}

///|
fn rectangle_strip_overlap_remover_compare_left_rectangle_borders(
  left : RectangleNode,
  right : RectangleNode,
) -> Int {
  let left_rect = left.get_rectangle()
  let right_rect = right.get_rectangle()
  left_rect.x.compare(right_rect.x)
}

///|
fn rectangle_strip_overlap_remover_compare_right_rectangle_borders(
  left : RectangleNode,
  right : RectangleNode,
) -> Int {
  let left_rect = left.get_rectangle()
  let right_rect = right.get_rectangle()
  (left_rect.x + left_rect.width).compare(right_rect.x + right_rect.width)
}

///|
fn rectangle_strip_overlap_remover_sort_nodes(
  nodes : Array[RectangleNode],
  compare : (RectangleNode, RectangleNode) -> Int,
) -> Unit {
  let length = nodes.length()
  if length <= 1 {
    return
  }

  for i in 1..<length {
    let key = nodes[i]
    let mut j = i
    while j > 0 && compare(nodes[j - 1], key) > 0 {
      nodes[j] = nodes[j - 1]
      j = j - 1
    }
    nodes[j] = key
  }
}

///|
fn rectangle_strip_overlap_remover_compute_overlaps(
  remover : RectangleStripOverlapRemover,
) -> Unit {
  for node in remover.rectangle_nodes {
    node.clear_overlapping_nodes()
  }

  let intersecting_nodes : Array[RectangleNode] = []
  for current_node in remover.rectangle_nodes {
    let scanline_pos = current_node.get_rectangle().x

    while !intersecting_nodes.is_empty() {
      let intersecting = intersecting_nodes[0]
      let intersecting_rect = intersecting.get_rectangle()
      if intersecting_rect.x + intersecting_rect.width < scanline_pos {
        ignore(intersecting_nodes.remove(0))
      } else {
        break
      }
    }

    for intersecting_node in intersecting_nodes {
      intersecting_node.add_overlapping_node(current_node)
      current_node.add_overlapping_node(intersecting_node)
    }

    intersecting_nodes.push(current_node)
    rectangle_strip_overlap_remover_sort_nodes(
      intersecting_nodes, rectangle_strip_overlap_remover_compare_right_rectangle_borders,
    )
  }
}

///|
fn rectangle_strip_overlap_remover_export_rectangle(
  remover : RectangleStripOverlapRemover,
  node : RectangleNode,
) -> Unit {
  checked_rectangle_node(node)
  let data = rectangle_node_store.val[node.handle]
  let original = data.original_rectangle
  let rectangle = data.rectangle

  match remover.overlap_removal_direction {
    Upward =>
      original.y = remover.start_coordinate - rectangle.height - rectangle.y
    Downward => original.y += remover.start_coordinate
    Leftward =>
      original.x = remover.start_coordinate - rectangle.height - rectangle.y
    Rightward => original.x = remover.start_coordinate + rectangle.y
    Undefined => ()
  }

  rectangle_node_store.val[node.handle].original_rectangle = original
}

///|
pub fn RectangleStripOverlapRemover::remove_overlaps(
  self : RectangleStripOverlapRemover,
) -> Double {
  if self.overlap_removal_strategy is None {
    self.overlap_removal_strategy = Some(
      new_greedy_rectangle_strip_overlap_removal_strategy(),
    )
  }

  rectangle_strip_overlap_remover_sort_nodes(
    self.rectangle_nodes,
    rectangle_strip_overlap_remover_compare_left_rectangle_borders,
  )
  rectangle_strip_overlap_remover_compute_overlaps(self)

  let strip_size = match self.overlap_removal_strategy {
    Some(strategy) => strategy.remove_overlaps(self)
    None => abort("No overlap removal strategy configured")
  }

  for node in self.rectangle_nodes {
    rectangle_strip_overlap_remover_export_rectangle(self, node)
  }
  strip_size
}
