///|
pub struct BlockRow {
  mut x : Double
  mut y : Double
  mut width : Double
  mut height : Double
  node_node_spacing : Double
  nodes : Array[@graph.ElkNode]
}

///|
pub fn new_rectpacking_block_row(
  x : Double,
  y : Double,
  node_node_spacing : Double,
) -> BlockRow {
  { x, y, width: 0.0, height: 0.0, node_node_spacing, nodes: [] }
}

///|
pub fn BlockRow::add_rectangle(self : BlockRow, rect : @graph.ElkNode) -> Bool {
  @graph.node_set_location(
    rect,
    self.x +
    self.width +
    (if self.nodes.is_empty() { 0.0 } else { self.node_node_spacing }),
    self.y,
  )
  self.height = @cmp.maximum(self.height, @graph.node_height(rect))
  self.width += @graph.node_width(rect) +
    (if self.nodes.is_empty() { 0.0 } else { self.node_node_spacing })
  self.nodes.push(rect)
  true
}

///|
pub fn BlockRow::remove_rectangle(
  self : BlockRow,
  rect : @graph.ElkNode,
  update : Bool,
) -> Unit {
  let filtered = []
  for node in self.nodes {
    if node != rect {
      filtered.push(node)
    }
  }
  self.nodes.clear()
  for node in filtered {
    self.nodes.push(node)
  }
  if update {
    self.update_row()
  }
}

///|
pub fn BlockRow::update_row(self : BlockRow) -> Unit {
  let mut width = 0.0
  let mut height = 0.0
  for rect in self.nodes {
    @graph.node_set_location(rect, self.x + width, self.y)
    width += @graph.node_width(rect) + self.node_node_spacing
    height = @cmp.maximum(
      height,
      @graph.node_height(rect) + self.node_node_spacing,
    )
  }
  self.width = width - self.node_node_spacing
  self.height = height - self.node_node_spacing
}

///|
pub fn BlockRow::expand(
  self : BlockRow,
  width_for_row : Double,
  additional_height_for_row : Double,
  index : Int,
) -> Unit {
  if self.nodes.is_empty() {
    self.width = width_for_row
    self.height += additional_height_for_row
    return
  }
  let additional_width_for_rect = (width_for_row - self.width) /
    self.nodes.length().to_double()
  let mut i = 0
  self.height += additional_height_for_row
  self.width = width_for_row
  for rect in self.nodes {
    let old_width = @graph.node_width(rect)
    let old_height = @graph.node_height(rect)
    @graph.node_set_location(
      rect,
      @graph.node_x(rect) + i.to_double() * additional_width_for_rect,
      @graph.node_y(rect) + index.to_double() * additional_height_for_row,
    )
    @graph.node_set_dimensions(
      rect,
      @graph.node_width(rect) + additional_width_for_rect,
      self.height,
    )
    let new_width = @graph.node_width(rect)
    let new_height = @graph.node_height(rect)
    @core.translate(
      rect,
      @core.new_kvector_xy(new_width, new_height),
      @core.new_kvector_xy(old_width, old_height),
    )
    i += 1
  }
}
