///|
pub struct GridElkNode {
  node : @graph.ElkNode
  mut grid : Array[Array[@graph.ElkNode?]]
  mut rows : Int
  mut cols : Int
}

///|
pub fn new_grid_elk_node(elk_node : @graph.ElkNode) -> GridElkNode {
  { node: elk_node, grid: [], rows: 0, cols: 0 }
}

///|
pub fn GridElkNode::put(
  self : GridElkNode,
  col : Int,
  row : Int,
  item : @graph.ElkNode,
) -> Unit {
  if col >= self.cols || row >= self.rows {
    abort(
      "The grid has a size of (\{self.cols} x \{self.rows}). The requested index of (\{col} x \{row}) is out of bounds.",
    )
  }
  self.grid[row].insert(col, Some(item))
}

///|
pub fn GridElkNode::get(
  self : GridElkNode,
  col : Int,
  row : Int,
) -> @graph.ElkNode? {
  if col >= self.cols || row >= self.rows {
    abort(
      "The grid has a size of (\{self.cols} x \{self.rows}). The requested index of (\{col} x \{row}) is out of bounds.",
    )
  }
  self.grid[row][col]
}

///|
pub fn GridElkNode::get_row(
  self : GridElkNode,
  row : Int,
) -> Array[@graph.ElkNode?] {
  if row >= self.rows {
    abort(
      "The grid has a size of (\{self.cols} x \{self.rows}). The requested row \{row}) is out of bounds.",
    )
  }
  self.grid[row]
}

///|
pub fn GridElkNode::get_column(
  self : GridElkNode,
  col : Int,
) -> Array[@graph.ElkNode?] {
  if col >= self.cols {
    abort(
      "The grid has a size of (\{self.cols} x \{self.rows}). The requested column \{col}) is out of bounds.",
    )
  }
  let result_list = []
  let mut i = 0
  while i < self.rows {
    result_list.push(self.grid[i][col])
    i += 1
  }
  result_list
}

///|
pub fn GridElkNode::get_columns(self : GridElkNode) -> Int {
  self.cols
}

///|
pub fn GridElkNode::get_rows(self : GridElkNode) -> Int {
  self.rows
}

///|
pub fn GridElkNode::set_grid_size(
  self : GridElkNode,
  cols : Int,
  rows : Int,
) -> Unit {
  self.cols = cols
  self.rows = rows
  self.grid = []
  let mut i = 0
  while i < rows {
    let row = []
    let mut j = 0
    while j < cols {
      row.push(None)
      j += 1
    }
    self.grid.push(row)
    i += 1
  }
}

///|
pub fn GridElkNode::get_width(self : GridElkNode) -> Double {
  @graph.node_width(self.node)
}

///|
pub fn GridElkNode::set_width(self : GridElkNode, value : Double) -> Unit {
  @graph.node_set_dimensions(self.node, value, @graph.node_height(self.node))
}

///|
pub fn GridElkNode::get_height(self : GridElkNode) -> Double {
  @graph.node_height(self.node)
}

///|
pub fn GridElkNode::set_height(self : GridElkNode, value : Double) -> Unit {
  @graph.node_set_dimensions(self.node, @graph.node_width(self.node), value)
}

///|
pub fn GridElkNode::get_x(self : GridElkNode) -> Double {
  @graph.node_x(self.node)
}

///|
pub fn GridElkNode::set_x(self : GridElkNode, value : Double) -> Unit {
  @graph.node_set_location(self.node, value, @graph.node_y(self.node))
}

///|
pub fn GridElkNode::get_y(self : GridElkNode) -> Double {
  @graph.node_y(self.node)
}

///|
pub fn GridElkNode::set_y(self : GridElkNode, value : Double) -> Unit {
  @graph.node_set_location(self.node, @graph.node_x(self.node), value)
}

///|
pub fn GridElkNode::set_dimensions(
  self : GridElkNode,
  width : Double,
  height : Double,
) -> Unit {
  @graph.node_set_dimensions(self.node, width, height)
}

///|
pub fn GridElkNode::set_location(
  self : GridElkNode,
  x : Double,
  y : Double,
) -> Unit {
  @graph.node_set_location(self.node, x, y)
}

///|
pub fn GridElkNode::get_identifier(self : GridElkNode) -> String {
  @graph.node_identifier(self.node)
}

///|
pub fn GridElkNode::get_children(self : GridElkNode) -> Array[@graph.ElkNode] {
  @graph.node_children(self.node)
}

///|
pub fn GridElkNode::get_node(self : GridElkNode) -> @graph.ElkNode {
  self.node
}

///|
pub fn GridElkNode::get_string_property(
  self : GridElkNode,
  property : @graph.IProperty[String],
) -> String {
  @graph.node_get_string_property(self.node, property)
}

///|
pub fn GridElkNode::get_double_property(
  self : GridElkNode,
  property : @graph.IProperty[Double],
) -> Double {
  @graph.node_get_double_property(self.node, property)
}

///|
pub fn GridElkNode::get_bool_property(
  self : GridElkNode,
  property : @graph.IProperty[Bool],
) -> Bool {
  @graph.node_get_bool_property(self.node, property)
}
