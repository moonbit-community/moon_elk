///|
pub fn rectpacking_initial_placement_place(
  rectangles : Array[ElkNode],
  bounding_width : Double,
  node_node_spacing : Double,
) -> Array[RectRow] {
  let rows : Array[RectRow] = []
  let mut row = new_rectpacking_rect_row(0.0, node_node_spacing)
  let mut drawing_height = 0.0
  row.add_block(new_rectpacking_block(0.0, 0.0, row, node_node_spacing))
  let mut current_width = 0.0

  for rect in rectangles {
    let mut block = row.last_block()
    let potential_row_width = current_width +
      node_width(rect) +
      (if row.children[0].children.is_empty() {
        0.0
      } else {
        node_node_spacing
      })
    if potential_row_width > bounding_width ||
      node_get_bool_property(rect, rectpacking_in_new_row) {
      current_width = 0.0
      drawing_height += row.height + node_node_spacing
      rows.push(row)
      row = new_rectpacking_rect_row(drawing_height, node_node_spacing)
      block = new_rectpacking_block(0.0, row.y, row, node_node_spacing)
      row.add_block(block)
      current_width = 0.0
    }

    let parent_row_height_reevaluation = match node_parent(rect) {
      Some(parent) =>
        node_get_bool_property(
          parent, rectpacking_packing_compaction_row_height_reevaluation,
        )
      None => false
    }

    if block.children.is_empty() ||
      (
        !parent_row_height_reevaluation &&
        rectpacking_initial_placement_is_similar_height(
          block, rect, node_node_spacing,
        )
      ) {
      block.add_child(rect)
    } else {
      let new_block = new_rectpacking_block(
        block.x + block.width + node_node_spacing,
        row.y,
        row,
        node_node_spacing,
      )
      row.add_block(new_block)
      new_block.add_child(rect)
    }
    current_width = node_x(rect) + node_width(rect)
  }
  rows.push(row)
  rows
}

///|
pub fn rectpacking_initial_placement_place_rect_in_block(
  row : RectRow,
  block : Block,
  rect : ElkNode,
  bounding_width : Double,
  node_node_spacing : Double,
) -> Bool {
  if rectpacking_initial_placement_is_similar_height(
      block, rect, node_node_spacing,
    ) {
    if block.last_row_new_x() + node_width(rect) + node_node_spacing <=
      bounding_width &&
      (
        block.last_row_y() - row.y + node_height(rect) <= row.height ||
        row.children.length() == 1
      ) {
      block.add_child(rect)
      return true
    } else if block.x + node_width(rect) <= bounding_width &&
      block.y + block.height + node_height(rect) + node_node_spacing <=
      row.y + row.height {
      block.add_child_in_new_row(rect)
      return true
    }
  }
  false
}

///|
pub fn rectpacking_initial_placement_is_similar_height(
  block : Block,
  rect : ElkNode,
  node_node_spacing : Double,
) -> Bool {
  ignore(node_node_spacing)
  if node_height(rect) >= block.smallest_rect_height &&
    node_height(rect) <= block.min_height {
    true
  } else {
    block.average_height * 0.5 <= node_height(rect) &&
    block.average_height * 1.5 >= node_height(rect)
  }
}
