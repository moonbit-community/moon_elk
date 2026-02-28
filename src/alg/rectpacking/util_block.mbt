///|
let rectpacking_next_block_id_ref : Ref[Int] = Ref::new(0)

///|
fn rectpacking_next_block_id() -> Int {
  let id = rectpacking_next_block_id_ref.val
  rectpacking_next_block_id_ref.val = id + 1
  id
}

///|
pub struct Block {
  id : Int
  mut smallest_rect_width : Double
  mut min_width : Double
  mut width : Double
  mut min_height : Double
  mut smallest_rect_height : Double
  mut average_height : Double
  mut max_height : Double
  mut height : Double
  children : Array[@graph.ElkNode]
  mut rows : Array[BlockRow]
  mut x : Double
  mut y : Double
  mut parent_row : RectRow
  mut stack : BlockStack?
  node_node_spacing : Double
  mut fixed : Bool
  mut position_fixed : Bool
}

///|
pub fn new_rectpacking_block(
  x : Double,
  y : Double,
  parent_row : RectRow,
  node_node_spacing : Double,
) -> Block {
  {
    id: rectpacking_next_block_id(),
    smallest_rect_width: @double.infinity,
    min_width: 0.0,
    width: 0.0,
    min_height: 0.0,
    smallest_rect_height: @double.infinity,
    average_height: 0.0,
    max_height: 0.0,
    height: 0.0,
    children: [],
    rows: [],
    x,
    y,
    parent_row,
    stack: None,
    node_node_spacing,
    fixed: false,
    position_fixed: false,
  }
}

///|
fn rectpacking_block_adjust_children_xy(
  block : Block,
  x_change : Double,
  y_change : Double,
) -> Unit {
  for rect in block.children {
    @graph.node_set_location(
      rect,
      @graph.node_x(rect) + x_change,
      @graph.node_y(rect) + y_change,
    )
  }
}

///|
fn rectpacking_block_adjust_size_add(
  block : Block,
  rect : @graph.ElkNode,
) -> Unit {
  let width_of_last_row = block.last_row().width
  block.smallest_rect_width = @cmp.minimum(
    block.smallest_rect_width,
    @graph.node_width(rect),
  )
  block.width = @cmp.maximum(block.width, width_of_last_row)
  block.min_width = @cmp.maximum(
    block.min_width,
    @graph.node_width(rect) +
    (if block.children.length() == 1 { 0.0 } else { block.node_node_spacing }),
  )

  block.smallest_rect_height = @cmp.minimum(
    block.smallest_rect_height,
    @graph.node_height(rect),
  )
  block.max_height += @graph.node_height(rect) +
    (if block.children.length() == 1 { 0.0 } else { block.node_node_spacing })
  block.min_height = @cmp.maximum(block.min_height, @graph.node_height(rect))
  let mut total_height = if block.rows.length() > 0 {
    (block.rows.length() - 1).to_double() * block.node_node_spacing
  } else {
    0.0
  }
  for row in block.rows {
    total_height += row.height
  }
  block.height = total_height
  block.average_height = block.max_height / block.children.length().to_double() -
    block.node_node_spacing *
    (block.children.length() - 1).to_double() /
    block.children.length().to_double()
  block.parent_row.notify_about_node_change()
}

///|
fn rectpacking_block_adjust_size_after_remove(block : Block) -> Unit {
  let mut new_width = 0.0
  let mut new_height = 0.0
  let kept_rows : Array[BlockRow] = []
  let mut index = 0
  for row in block.rows {
    if !row.nodes.is_empty() {
      kept_rows.push(row)
      new_width = @cmp.maximum(new_width, row.width)
      new_height += row.height +
        (if index > 0 { block.node_node_spacing } else { 0.0 })
      index += 1
    }
  }
  block.rows = kept_rows
  block.height = new_height
  block.width = new_width

  block.min_width = 0.0
  block.min_height = 0.0
  block.max_height = 0.0
  block.smallest_rect_height = @double.infinity
  block.smallest_rect_width = @double.infinity
  for rect in block.children {
    block.smallest_rect_width = @cmp.minimum(
      block.smallest_rect_width,
      @graph.node_width(rect),
    )
    block.min_width = @cmp.maximum(block.min_width, @graph.node_width(rect))
    block.min_height = @cmp.maximum(block.min_height, @graph.node_height(rect))
    block.smallest_rect_height = @cmp.minimum(
      block.smallest_rect_height,
      @graph.node_height(rect),
    )
    block.max_height += @graph.node_height(rect) + block.node_node_spacing
  }
  if !block.children.is_empty() {
    block.average_height = block.max_height /
      block.children.length().to_double() -
      block.node_node_spacing *
      (block.children.length() - 1).to_double() /
      block.children.length().to_double()
  } else {
    block.average_height = 0.0
  }

  block.parent_row.notify_about_node_change()
}

///|
fn rectpacking_block_place_rects_in_width_internal(
  block : Block,
  width : Double,
  place_rects : Bool,
) -> @core.ElkRectangle {
  let mut current_x = 0.0
  let mut current_y = block.y
  let mut current_width = 0.0
  let mut current_height = 0.0
  let mut max_height_in_row = 0.0
  let mut width_in_row = 0.0
  let mut row = 0

  if place_rects {
    block.rows.clear()
    block.rows.push(
      new_rectpacking_block_row(block.x, block.y, block.node_node_spacing),
    )
  }

  let mut index = 0
  for rect in block.children {
    if current_x +
      @graph.node_width(rect) +
      (if index > 0 { block.node_node_spacing } else { 0.0 }) >
      width &&
      max_height_in_row > 0.0 {
      current_x = 0.0
      current_y += max_height_in_row + block.node_node_spacing
      current_width = @cmp.maximum(current_width, width_in_row)
      current_height += max_height_in_row + block.node_node_spacing
      max_height_in_row = 0.0
      width_in_row = 0.0
      if place_rects {
        row += 1
        block.rows.push(
          new_rectpacking_block_row(block.x, current_y, block.node_node_spacing),
        )
      }
      index = 0
    }
    width_in_row += @graph.node_width(rect) +
      (if index > 0 { block.node_node_spacing } else { 0.0 })
    max_height_in_row = @cmp.maximum(
      max_height_in_row,
      @graph.node_height(rect),
    )
    if place_rects {
      ignore(block.rows[row].add_rectangle(rect))
    }
    current_x += @graph.node_width(rect) +
      (if index > 0 { block.node_node_spacing } else { 0.0 })
    index += 1
  }

  current_width = @cmp.maximum(current_width, width_in_row)
  current_height += max_height_in_row

  if place_rects {
    block.width = current_width
    block.height = current_height
    block.parent_row.notify_about_node_change()
  }

  @core.new_elk_rectangle_xywh(block.x, block.y, current_width, current_height)
}

///|
fn rectpacking_block_place_rects_in_width_height_internal(
  block : Block,
  width : Double,
  height : Double,
  place_rects : Bool,
) -> Bool {
  let bounds = rectpacking_block_place_rects_in_width_internal(
    block, width, place_rects,
  )
  bounds.width <= width && bounds.height <= height
}

///|
pub fn Block::add_child(self : Block, rect : @graph.ElkNode) -> Unit {
  if self.rows.is_empty() {
    self.rows.push(
      new_rectpacking_block_row(self.x, self.y, self.node_node_spacing),
    )
  }
  self.children.push(rect)
  ignore(self.rows[self.rows.length() - 1].add_rectangle(rect))
  rectpacking_block_adjust_size_add(self, rect)
}

///|
pub fn Block::add_child_in_new_row(self : Block, rect : @graph.ElkNode) -> Unit {
  self.children.push(rect)
  let last_row = self.last_row()
  self.rows.push(
    new_rectpacking_block_row(
      self.x,
      last_row.y + last_row.height + self.node_node_spacing,
      self.node_node_spacing,
    ),
  )
  ignore(self.last_row().add_rectangle(rect))
  rectpacking_block_adjust_size_add(self, rect)
}

///|
pub fn Block::remove_child(self : Block, rect : @graph.ElkNode) -> Unit {
  let filtered = []
  for node in self.children {
    if node != rect {
      filtered.push(node)
    }
  }
  self.children.clear()
  for node in filtered {
    self.children.push(node)
  }
  let mut row_index = 0
  while row_index < self.rows.length() {
    let row = self.rows[row_index]
    let mut contains = false
    for node in row.nodes {
      if node == rect {
        contains = true
        break
      }
    }
    if contains {
      row.remove_rectangle(rect, true)
      if row.nodes.is_empty() {
        let keep_rows = []
        let mut i = 0
        for r in self.rows {
          if i != row_index {
            keep_rows.push(r)
          }
          i += 1
        }
        self.rows = keep_rows
      }
      break
    }
    row_index += 1
  }
  rectpacking_block_adjust_size_after_remove(self)
}

///|
pub fn Block::set_location(self : Block, x : Double, y : Double) -> Unit {
  rectpacking_block_adjust_children_xy(self, x - self.x, y - self.y)
  for row in self.rows {
    row.x = row.x + x - self.x
    row.y = row.y + y - self.y
  }
  self.x = x
  self.y = y
}

///|
pub fn Block::get_width_for_target_height(
  self : Block,
  height : Double,
) -> Double {
  if self.max_height <= height {
    return self.min_width
  }

  if rectpacking_block_place_rects_in_width_height_internal(
      self,
      self.min_width,
      height,
      false,
    ) {
    return self.min_width
  }

  let mut upper_bound = self.width
  let mut lower_bound = self.min_width
  let mut viable_width = self.width
  let mut new_width = (upper_bound - lower_bound) / 2.0 + lower_bound

  while lower_bound + 1.0 < upper_bound {
    if rectpacking_block_place_rects_in_width_height_internal(
        self, new_width, height, false,
      ) {
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
pub fn Block::get_height_for_target_width(
  self : Block,
  width : Double,
) -> Double {
  rectpacking_block_place_rects_in_width_internal(self, width, false).height
}

///|
pub fn Block::place_rects_in(
  self : Block,
  width : Double,
  height : Double,
) -> Bool {
  rectpacking_block_place_rects_in_width_height_internal(
    self, width, height, true,
  )
}

///|
pub fn Block::place_rects_in_width(self : Block, width : Double) -> Bool {
  let old_width = self.width
  let old_height = self.height
  let bounds = rectpacking_block_place_rects_in_width_internal(
    self, width, true,
  )
  bounds.width != old_width || bounds.height != old_height
}

///|
pub fn Block::expand(
  self : Block,
  additional_width_per_block : Double,
  additional_height_for_block : Double,
) -> Unit {
  if self.rows.is_empty() {
    return
  }
  let width_for_row = self.width + additional_width_per_block
  self.width += additional_width_per_block
  self.height += additional_height_for_block
  let additional_height_for_row = additional_height_for_block /
    self.rows.length().to_double()
  let mut index = 0
  for row in self.rows {
    row.expand(width_for_row, additional_height_for_row, index)
    index += 1
  }
}

///|
pub fn Block::last_row_new_x(self : Block) -> Double {
  let last_row = self.last_row()
  last_row.x + last_row.width
}

///|
pub fn Block::last_row_y(self : Block) -> Double {
  self.last_row().y
}

///|
pub fn Block::last_row(self : Block) -> BlockRow {
  self.rows[self.rows.length() - 1]
}

///|
pub fn Block::reset_block(self : Block) -> Unit {
  rectpacking_block_adjust_size_after_remove(self)
}
