///|
fn rectpacking_compaction_get_next_block(
  rows : Array[RectRow],
  row : RectRow,
  block_id : Int,
  next_row_index : Int,
) -> (Block?, Bool) {
  if block_id < row.number_of_assigned_blocks() - 1 {
    (Some(row.children[block_id + 1]), false)
  } else if next_row_index < rows.length() &&
    !rows[next_row_index].children.is_empty() {
    (Some(rows[next_row_index].children[0]), true)
  } else {
    (None, false)
  }
}

///|
fn rectpacking_compaction_use_row_height(row : RectRow, block : Block) -> Bool {
  let mut something_was_changed = false
  match block.stack {
    Some(stack) => {
      let previous_width = stack.width
      if block.height < row.height {
        let target_width = stack.get_width_for_fixed_height(row.height)
        if stack.width > target_width {
          stack.place_rects_in(target_width)
          something_was_changed = previous_width != stack.width
        }
      }
    }
    None => ()
  }
  something_was_changed
}

///|
fn rectpacking_compaction_use_row_width(
  block : Block,
  bounding_width : Double,
) -> Unit {
  ignore(block.place_rects_in_width(bounding_width - block.x))
  match block.stack {
    Some(stack) => stack.update_dimension()
    None => ()
  }
}

///|
fn rectpacking_compaction_absorb_blocks(
  row : RectRow,
  block : Block,
  next_block : Block,
  bounding_width : Double,
  node_node_spacing : Double,
) -> Bool {
  ignore(row)
  let mut something_was_changed = false
  if next_block.children.is_empty() {
    return false
  }
  let mut rect = next_block.children[0]
  while rectpacking_initial_placement_place_rect_in_block(
          row, block, rect, bounding_width, node_node_spacing,
        ) {
    something_was_changed = true
    next_block.remove_child(rect)
    if next_block.children.is_empty() {
      break
    }
    rect = next_block.children[0]
  }

  if next_block.children.is_empty() {
    next_block.parent_row.remove_block(next_block)
  }
  if something_was_changed {
    match block.stack {
      Some(stack) => stack.update_dimension()
      None => ()
    }
  }

  something_was_changed
}

///|
fn rectpacking_compaction_place_below(
  rows : Array[RectRow],
  row : RectRow,
  block : Block,
  next_block : Block,
  was_from_next_row : Bool,
  bounding_width : Double,
  next_row_index : Int,
  node_node_spacing : Double,
) -> Bool {
  let remaining_width = bounding_width - block.x
  let current_block_min_height = block.y -
    row.y +
    block.get_height_for_target_width(remaining_width)
  if next_block.min_width + node_node_spacing > remaining_width {
    return false
  }
  let next_block_min_height = next_block.get_height_for_target_width(
    remaining_width,
  )

  if current_block_min_height + node_node_spacing + next_block_min_height <=
    row.height {
    ignore(block.place_rects_in_width(bounding_width - block.x))
    block.fixed = true
    ignore(next_block.place_rects_in_width(bounding_width - block.x))
    next_block.set_location(block.x, block.y + block.height + node_node_spacing)
    next_block.position_fixed = true
    match block.stack {
      Some(stack) => stack.add_block(next_block)
      None => ()
    }

    if was_from_next_row {
      row.add_block(next_block)
      next_block.parent_row = row
      if rows.length() > next_row_index {
        rows[next_row_index].remove_block(next_block)
        if rows[next_row_index].children.is_empty() {
          let keep_rows = []
          let mut index = 0
          for candidate in rows {
            if index != next_row_index {
              keep_rows.push(candidate)
            }
            index += 1
          }
          rows.clear()
          for candidate in keep_rows {
            rows.push(candidate)
          }
        }
      }
    }
    true
  } else {
    false
  }
}

///|
fn rectpacking_compaction_place_beside(
  rows : Array[RectRow],
  row : RectRow,
  block : Block,
  next_block : Block,
  was_from_next_row : Bool,
  bounding_width : Double,
  next_row_index : Int,
  node_node_spacing : Double,
  row_height_reevaluation : Bool,
) -> Bool {
  ignore(was_from_next_row)
  let current_block_min_width = match block.stack {
    Some(stack) =>
      stack.get_width_for_fixed_height(row.y + row.height - stack.y)
    None => block.width
  }
  let should_row_height_be_reevaluated = next_block.min_height > row.height &&
    row_height_reevaluation

  let mut target_width_of_next_block = bounding_width -
    (match block.stack {
      Some(stack) => stack.x + current_block_min_width - node_node_spacing
      None => block.x + current_block_min_width - node_node_spacing
    })

  let next_block_height = next_block.get_height_for_target_width(
    target_width_of_next_block,
  )
  if should_row_height_be_reevaluated &&
    next_block_height > next_block.min_height {
    return false
  }

  if should_row_height_be_reevaluated {
    let mut potential_width = 0.0
    for stack in row.stacks {
      potential_width += stack.get_width_for_fixed_height(next_block.min_height) +
        node_node_spacing
    }
    target_width_of_next_block = bounding_width - potential_width
  }

  if target_width_of_next_block < next_block.min_width {
    return false
  }

  let last_row_optimization = next_row_index == rows.length() - 1 &&
    target_width_of_next_block >= rows[next_row_index].width

  if !should_row_height_be_reevaluated &&
    next_block_height > row.height &&
    !last_row_optimization {
    return false
  }

  if last_row_optimization ||
    should_row_height_be_reevaluated ||
    next_block_height <= row.height {
    if last_row_optimization && next_block_height > row.height {
      block.height = next_block_height
      ignore(
        block.place_rects_in_width(
          block.get_width_for_target_height(next_block_height),
        ),
      )
    } else {
      match block.stack {
        Some(stack) => {
          stack.place_rects_in(current_block_min_width)
          block.fixed = true
        }
        None => ()
      }
    }

    ignore(
      next_block.place_rects_in_width(bounding_width - (block.x + block.width)),
    )
    let new_x = match block.stack {
      Some(stack) => stack.x + stack.width
      None => block.x + block.width
    }
    next_block.set_location(new_x, row.y)
    row.add_block(next_block)

    if rows.length() > next_row_index {
      rows[next_row_index].remove_block(next_block)
      if rows[next_row_index].children.is_empty() {
        let keep_rows = []
        let mut index = 0
        for candidate in rows {
          if index != next_row_index {
            keep_rows.push(candidate)
          }
          index += 1
        }
        rows.clear()
        for candidate in keep_rows {
          rows.push(candidate)
        }
      }
    }
    true
  } else {
    false
  }
}

///|
pub fn rectpacking_compaction_compact(
  row_idx : Int,
  rows : Array[RectRow],
  bounding_width : Double,
  node_node_spacing : Double,
  row_height_reevaluation : Bool,
) -> (Bool, Bool) {
  let mut something_was_changed = false
  let mut compact_row_again = false
  let next_row_index = row_idx + 1
  let row = rows[row_idx]
  let mut current_stack : BlockStack? = None

  let mut block_id = 0
  while block_id < row.number_of_assigned_blocks() {
    let block = row.children[block_id]
    if block.fixed {
      block_id += 1
      continue
    }
    if block.children.is_empty() {
      row.remove_block(block)
      block_id -= 1
      something_was_changed = true
      block_id += 1
      continue
    }

    if !block.position_fixed {
      match current_stack {
        Some(stack) => stack.update_dimension()
        None => ()
      }
      let new_x = match current_stack {
        None => 0.0
        Some(stack) => stack.x + stack.width + node_node_spacing
      }
      current_stack = Some(
        new_rectpacking_block_stack(new_x, row.y, node_node_spacing),
      )
      block.set_location(new_x, row.y)
      match current_stack {
        Some(stack) => {
          row.stacks.push(stack)
          stack.add_block(block)
        }
        None => ()
      }
      block.position_fixed = true
    }

    let (next_block_opt, was_from_next_row) = rectpacking_compaction_get_next_block(
      rows, row, block_id, next_row_index,
    )

    let mut next_block_ref = next_block_opt

    match next_block_ref {
      Some(next_block) => {
        if !next_block.children.is_empty() &&
          !@graph.node_get_bool_property(
            next_block.children[0],
            rectpacking_in_new_row,
          ) {
          rectpacking_compaction_use_row_width(block, bounding_width)
          something_was_changed = rectpacking_compaction_absorb_blocks(
              row, block, next_block, bounding_width, node_node_spacing,
            ) ||
            something_was_changed
        } else {
          row.remove_block(next_block)
          break
        }

        if next_block.children.is_empty() {
          if rows.length() > next_row_index {
            rows[next_row_index].remove_block(next_block)
          }
          next_block_ref = None
          while rows.length() > next_row_index &&
                rows[next_row_index].children.is_empty() {
            let keep_rows = []
            let mut index = 0
            for candidate in rows {
              if index != next_row_index {
                keep_rows.push(candidate)
              }
              index += 1
            }
            rows.clear()
            for candidate in keep_rows {
              rows.push(candidate)
            }
          }
        }

        match next_block_ref {
          None => {
            block_id -= 1
            block_id += 1
            continue
          }
          Some(next_block_after_absorb) => {
            if !next_block_after_absorb.children.is_empty() &&
              !@graph.node_get_bool_property(
                next_block_after_absorb.children[0],
                rectpacking_in_new_row,
              ) &&
              rectpacking_compaction_place_below(
                rows, row, block, next_block_after_absorb, was_from_next_row, bounding_width,
                next_row_index, node_node_spacing,
              ) {
              something_was_changed = true
              block_id += 1
              continue
            }

            if was_from_next_row {
              let old_row_height = row.height
              let next_block_min_height = next_block_after_absorb.min_height
              if !next_block_after_absorb.children.is_empty() &&
                !@graph.node_get_bool_property(
                  next_block_after_absorb.children[0],
                  rectpacking_in_new_row,
                ) &&
                rectpacking_compaction_place_beside(
                  rows, row, block, next_block_after_absorb, was_from_next_row, bounding_width,
                  next_row_index, node_node_spacing, row_height_reevaluation,
                ) {
                something_was_changed = true
                if old_row_height < next_block_min_height {
                  compact_row_again = true
                  next_block_after_absorb.parent_row = row
                  break
                }
                block_id += 1
                continue
              } else if rectpacking_compaction_use_row_height(row, block) {
                block.fixed = true
                something_was_changed = true
                block_id += 1
                continue
              }
            } else if rectpacking_compaction_use_row_height(row, block) {
              block.fixed = true
              something_was_changed = true
              block_id += 1
              continue
            }

            if something_was_changed {
              block_id += 1
              continue
            }
          }
        }
      }
      None => ()
    }

    if rectpacking_compaction_use_row_height(row, block) {
      block.fixed = true
      something_was_changed = true
      match next_block_ref {
        Some(next_block) => next_block.position_fixed = false
        None => ()
      }
      block_id += 1
      continue
    } else {
      match block.stack {
        Some(stack) => stack.update_dimension()
        None => ()
      }
    }

    block_id += 1
  }

  (something_was_changed, compact_row_again)
}
