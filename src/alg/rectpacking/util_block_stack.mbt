///|
pub struct BlockStack {
  blocks : Array[Block]
  mut x : Double
  mut y : Double
  mut width : Double
  mut height : Double
  node_node_spacing : Double
}

///|
pub fn new_rectpacking_block_stack(
  x : Double,
  y : Double,
  node_node_spacing : Double,
) -> BlockStack {
  { blocks: [], x, y, width: 0.0, height: 0.0, node_node_spacing }
}

///|
fn rectpacking_block_stack_minimum_width(target : BlockStack) -> Double {
  let mut min_width = 0.0
  for block in target.blocks {
    min_width = @cmp.maximum(min_width, block.min_width)
  }
  min_width
}

///|
pub fn BlockStack::add_block(self : BlockStack, block : Block) -> Unit {
  block.stack = Some(self)
  self.width = @cmp.maximum(self.width, block.width)
  self.height += block.height +
    (if self.blocks.is_empty() { 0.0 } else { self.node_node_spacing })
  self.blocks.push(block)
}

///|
pub fn BlockStack::update_dimension(self : BlockStack) -> Unit {
  let mut height = 0.0
  let mut width = 0.0
  let mut index = 0
  for block in self.blocks {
    width = @cmp.maximum(width, block.width)
    height += block.height +
      (if index > 0 { self.node_node_spacing } else { 0.0 })
    index += 1
  }
  self.height = height
  self.width = width
}

///|
pub fn BlockStack::set_location(
  self : BlockStack,
  x : Double,
  y : Double,
) -> Unit {
  let x_diff = x - self.x
  let y_diff = y - self.y
  for block in self.blocks {
    block.set_location(block.x + x_diff, block.y + y_diff)
  }
  self.x = x
  self.y = y
}

///|
pub fn BlockStack::get_width_for_fixed_height(
  self : BlockStack,
  height : Double,
) -> Double {
  if self.blocks.length() == 1 {
    return self.blocks[0].get_width_for_target_height(height)
  }

  let min_width = rectpacking_block_stack_minimum_width(self)
  let mut upper_bound = self.width
  let mut lower_bound = min_width
  let mut viable_width = self.width
  let mut new_width = (upper_bound - lower_bound) / 2.0 + lower_bound
  while lower_bound + 1.0 < upper_bound {
    let mut total_height = 0.0
    for block in self.blocks {
      total_height += block.get_height_for_target_width(new_width)
    }
    if total_height < height {
      viable_width = new_width
      upper_bound = new_width
    } else {
      lower_bound = new_width
    }
    new_width = (upper_bound - lower_bound) / 2.0 + lower_bound
  }
  viable_width
}

///|
pub fn BlockStack::place_rects_in(
  self : BlockStack,
  target_width : Double,
) -> Unit {
  let mut current_y = self.y
  let mut current_height = 0.0
  let mut current_width = 0.0
  for block in self.blocks {
    block.set_location(self.x, current_y)
    ignore(block.place_rects_in_width(target_width))
    current_width = @cmp.maximum(current_width, block.width)
    current_y += block.height + self.node_node_spacing
    current_height = current_y
  }
  self.width = current_width
  self.height = current_height
}

///|
pub fn BlockStack::expand(
  self : BlockStack,
  additional_width : Double,
  additional_height : Double,
) -> Unit {
  if self.blocks.is_empty() {
    return
  }
  let additional_height_per_block = additional_height /
    self.blocks.length().to_double()
  let mut index = 0
  for block in self.blocks {
    block.set_location(
      block.x,
      block.y + index.to_double() * additional_height_per_block,
    )
    block.expand(
      self.width - block.width + additional_width,
      additional_height_per_block,
    )
    index += 1
  }
}
