///|
pub struct RectRow {
  mut height : Double
  mut width : Double
  mut y : Double
  node_node_spacing : Double
  children : Array[Block]
  mut stacks : Array[BlockStack]
  potential_additional_width_to_get_last_block : Double
}

///|
pub fn new_rectpacking_rect_row(
  y : Double,
  node_node_spacing : Double,
) -> RectRow {
  {
    height: 0.0,
    width: 0.0,
    y,
    node_node_spacing,
    children: [],
    stacks: [],
    potential_additional_width_to_get_last_block: 0.0,
  }
}

///|
pub fn RectRow::notify_about_node_change(self : RectRow) -> Unit {
  let mut total_stack_width = 0.0
  let mut new_max_height = @double.neg_infinity
  let mut index = 0
  for child in self.children {
    total_stack_width += child.width +
      (if index > 0 { self.node_node_spacing } else { 0.0 })
    new_max_height = @cmp.maximum(new_max_height, child.height)
    index += 1
  }
  self.width = total_stack_width
  self.height = new_max_height
}

///|
pub fn RectRow::expand(
  self : RectRow,
  width : Double,
  additional_height : Double,
) -> Unit {
  if self.stacks.is_empty() {
    return
  }
  let additional_width = width - self.width
  let additional_width_per_stack = additional_width /
    self.stacks.length().to_double()
  let mut index = 0
  for stack in self.stacks {
    let additional_height_for_stack = self.height -
      stack.height +
      additional_height
    stack.set_location(
      stack.x + index.to_double() * additional_width_per_stack,
      stack.y,
    )
    stack.expand(additional_width_per_stack, additional_height_for_stack)
    index += 1
  }
}

///|
pub fn RectRow::calculate_block_stacks(self : RectRow) -> Unit {
  let mut current_x = -1.0
  for block in self.children {
    if block.x != current_x {
      self.stacks.push(
        new_rectpacking_block_stack(block.x, self.y, self.node_node_spacing),
      )
      self.stacks[self.stacks.length() - 1].add_block(block)
      current_x = block.x
    } else {
      self.stacks[self.stacks.length() - 1].add_block(block)
    }
  }
}

///|
pub fn RectRow::first_block(self : RectRow) -> Block {
  self.children[0]
}

///|
pub fn RectRow::last_block(self : RectRow) -> Block {
  self.children[self.children.length() - 1]
}

///|
pub fn RectRow::number_of_assigned_blocks(self : RectRow) -> Int {
  self.children.length()
}

///|
pub fn RectRow::add_block(self : RectRow, block : Block) -> Unit {
  self.height = @cmp.maximum(self.height, block.height)
  self.width += block.width +
    (if self.children.is_empty() { 0.0 } else { self.node_node_spacing })
  self.children.push(block)
}

///|
pub fn RectRow::remove_block(self : RectRow, block : Block) -> Unit {
  let filtered = []
  for child in self.children {
    if child.id != block.id {
      filtered.push(child)
    }
  }
  self.children.clear()
  for child in filtered {
    self.children.push(child)
  }
  self.width -= block.width +
    (if self.children.is_empty() { 0.0 } else { self.node_node_spacing })
  let mut new_max_height = @double.min_value
  for child in self.children {
    new_max_height = @cmp.maximum(new_max_height, child.height)
  }
  self.height = new_max_height
}

///|
pub fn RectRow::set_y(self : RectRow, y : Double) -> Unit {
  let y_change = y - self.y
  for stack in self.stacks {
    stack.set_location(stack.x, stack.y + y_change)
  }
  self.y = y
}

///|
pub fn RectRow::reset_stacks(self : RectRow) -> Unit {
  self.stacks = []
}
