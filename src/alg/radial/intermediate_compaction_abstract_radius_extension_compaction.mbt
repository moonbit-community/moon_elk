///|
pub struct AbstractRadiusExtensionCompaction {
  mut compaction_step : Int
  mut spacing : Double
  mut root : @graph.ElkNode?
}

///|
pub fn new_abstract_radius_extension_compaction() -> AbstractRadiusExtensionCompaction {
  { compaction_step: 1, spacing: 0.0, root: None }
}

///|
pub fn AbstractRadiusExtensionCompaction::contract_layer(
  self : AbstractRadiusExtensionCompaction,
  layer_nodes : Array[@graph.ElkNode],
  is_contracting : Bool,
) -> Unit {
  let root = self.root.unwrap()
  for node in layer_nodes {
    let mut x_pos = @graph.node_x(node) + @graph.node_width(node) / 2.0
    let mut y_pos = @graph.node_y(node) + @graph.node_height(node) / 2.0
    let parent_x = @graph.node_x(root) + @graph.node_width(root) / 2.0
    let parent_y = @graph.node_y(root) + @graph.node_height(root) / 2.0
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
    @graph.node_set_location(
      node,
      x_pos - @graph.node_width(node) / 2.0,
      y_pos - @graph.node_height(node) / 2.0,
    )
  }
}

///|
pub fn AbstractRadiusExtensionCompaction::move_node(
  self : AbstractRadiusExtensionCompaction,
  node : @graph.ElkNode,
  distance : Double,
) -> Unit {
  let root = self.root.unwrap()
  let root_x = @graph.node_x(root) + @graph.node_width(root) / 2.0
  let root_y = @graph.node_y(root) + @graph.node_height(root) / 2.0
  let node_x_value = @graph.node_x(node) + @graph.node_width(node) / 2.0
  let node_y_value = @graph.node_y(node) + @graph.node_height(node) / 2.0
  let difference_x = node_x_value - root_x
  let difference_y = node_y_value - root_y
  let length = (difference_x * difference_x + difference_y * difference_y).sqrt()
  let unit_x = difference_x / length
  let unit_y = difference_y / length
  @graph.node_set_location(
    node,
    @graph.node_x(node) + unit_x * distance,
    @graph.node_y(node) + unit_y * distance,
  )
}

///|
pub fn AbstractRadiusExtensionCompaction::overlap(
  self : AbstractRadiusExtensionCompaction,
  node1 : @graph.ElkNode,
  node2 : @graph.ElkNode,
) -> Bool {
  let x1 = @graph.node_x(node1) - self.spacing / 2.0
  let x2 = @graph.node_x(node2) - self.spacing / 2.0
  let y1 = @graph.node_y(node1) - self.spacing / 2.0
  let y2 = @graph.node_y(node2) - self.spacing / 2.0
  let width1 = @graph.node_width(node1) + self.spacing
  let width2 = @graph.node_width(node2) + self.spacing
  let height1 = @graph.node_height(node1) + self.spacing
  let height2 = @graph.node_height(node2) + self.spacing
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
  nodes : Array[@graph.ElkNode],
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
  root : @graph.ElkNode,
) -> Unit {
  self.root = Some(root)
}

///|
pub fn AbstractRadiusExtensionCompaction::root(
  self : AbstractRadiusExtensionCompaction,
) -> @graph.ElkNode? {
  self.root
}
