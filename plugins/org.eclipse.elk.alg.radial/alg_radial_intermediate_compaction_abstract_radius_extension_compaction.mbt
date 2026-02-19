///|
pub struct AbstractRadiusExtensionCompaction {
  mut compaction_step : Int
  mut spacing : Double
  mut root : ElkNode?
}

///|
pub fn new_abstract_radius_extension_compaction() -> AbstractRadiusExtensionCompaction {
  { compaction_step: 1, spacing: 0.0, root: None }
}

///|
pub fn AbstractRadiusExtensionCompaction::contract_layer(
  self : AbstractRadiusExtensionCompaction,
  layer_nodes : Array[ElkNode],
  is_contracting : Bool,
) -> Unit {
  let root = match self.root {
    Some(r) => r
    None => abort("radial root node is missing")
  }
  for node in layer_nodes {
    let mut x_pos = node_x(node) + node_width(node) / 2.0
    let mut y_pos = node_y(node) + node_height(node) / 2.0
    let parent_x = node_x(root) + node_width(root) / 2.0
    let parent_y = node_y(root) + node_height(root) / 2.0
    let mut x = x_pos - parent_x
    let mut y = y_pos - parent_y
    let length = (x * x + y * y).sqrt()
    x *= self.compaction_step.to_double() / length
    y *= self.compaction_step.to_double() / length
    if is_contracting {
      x_pos -= x
      y_pos -= y
    } else {
      x_pos += x
      y_pos += y
    }
    node_set_location(
      node,
      x_pos - node_width(node) / 2.0,
      y_pos - node_height(node) / 2.0,
    )
  }
}

///|
pub fn AbstractRadiusExtensionCompaction::move_node(
  self : AbstractRadiusExtensionCompaction,
  node : ElkNode,
  distance : Double,
) -> Unit {
  let root = match self.root {
    Some(r) => r
    None => abort("radial root node is missing")
  }
  let root_x = node_x(root) + node_width(root) / 2.0
  let root_y = node_y(root) + node_height(root) / 2.0
  let node_x_value = node_x(node) + node_width(node) / 2.0
  let node_y_value = node_y(node) + node_height(node) / 2.0
  let difference_x = node_x_value - root_x
  let difference_y = node_y_value - root_y
  let length = (difference_x * difference_x + difference_y * difference_y).sqrt()
  let unit_x = difference_x / length
  let unit_y = difference_y / length
  node_set_location(
    node,
    node_x(node) + unit_x * distance,
    node_y(node) + unit_y * distance,
  )
}

///|
pub fn AbstractRadiusExtensionCompaction::overlap(
  self : AbstractRadiusExtensionCompaction,
  node1 : ElkNode,
  node2 : ElkNode,
) -> Bool {
  let x1 = node_x(node1) - self.spacing / 2.0
  let x2 = node_x(node2) - self.spacing / 2.0
  let y1 = node_y(node1) - self.spacing / 2.0
  let y2 = node_y(node2) - self.spacing / 2.0
  let width1 = node_width(node1) + self.spacing
  let width2 = node_width(node2) + self.spacing
  let height1 = node_height(node1) + self.spacing
  let height2 = node_height(node2) + self.spacing
  if (x1 < x2 + width2 && x2 < x1) && y1 < y2 + height2 && y2 < y1 {
    return true
  }
  if (x2 < x1 + width1 && x1 < x2) && y2 < y1 + height1 && y1 < y2 {
    return true
  }
  if (x1 < x2 + width2 && x2 < x1) && y1 < y2 && y2 < y1 + height1 {
    return true
  }
  if (x2 < x1 + width1 && x1 < x2) && y1 < y2 + height2 && y2 < y1 {
    return true
  }
  false
}

///|
pub fn AbstractRadiusExtensionCompaction::overlap_layer(
  self : AbstractRadiusExtensionCompaction,
  nodes : Array[ElkNode],
) -> Bool {
  if nodes.length() < 2 {
    return false
  }
  let mut overlapping = false
  let mut i = 0
  while i < nodes.length() {
    if i < nodes.length() - 1 {
      overlapping = overlapping || self.overlap(nodes[i], nodes[i + 1])
    } else {
      overlapping = overlapping || self.overlap(nodes[i], nodes[0])
    }
    i += 1
  }
  overlapping
}

///|
pub fn AbstractRadiusExtensionCompaction::set_compaction_step(
  self : AbstractRadiusExtensionCompaction,
  compaction_step : Int,
) -> Unit {
  self.compaction_step = compaction_step
}

///|
pub fn AbstractRadiusExtensionCompaction::compaction_step(
  self : AbstractRadiusExtensionCompaction,
) -> Int {
  self.compaction_step
}

///|
pub fn AbstractRadiusExtensionCompaction::set_spacing(
  self : AbstractRadiusExtensionCompaction,
  spacing : Double,
) -> Unit {
  self.spacing = spacing
}

///|
pub fn AbstractRadiusExtensionCompaction::spacing(
  self : AbstractRadiusExtensionCompaction,
) -> Double {
  self.spacing
}

///|
pub fn AbstractRadiusExtensionCompaction::set_root(
  self : AbstractRadiusExtensionCompaction,
  root : ElkNode,
) -> Unit {
  self.root = Some(root)
}

///|
pub fn AbstractRadiusExtensionCompaction::root(
  self : AbstractRadiusExtensionCompaction,
) -> ElkNode? {
  self.root
}
