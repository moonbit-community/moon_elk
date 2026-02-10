///|
pub fn greedy_rectangle_strip_overlap_remover_compare_by_y_coordinate(
  node1 : RectangleNode,
  node2 : RectangleNode,
) -> Int {
  node1.get_rectangle().y.compare(node2.get_rectangle().y)
}

///|
pub fn greedy_rectangle_strip_overlap_remover_remove_overlaps(
  overlap_remover : RectangleStripOverlapRemover,
) -> Double {
  let vertical_gap = overlap_remover.get_vertical_gap()
  let already_placed_nodes : Array[RectangleNode] = []
  let mut strip_size = 0.0

  for current_node in overlap_remover.get_rectangle_nodes() {
    let mut y_pos = 0.0
    let overlapping_nodes = current_node.get_overlapping_nodes()
    rectangle_strip_overlap_remover_sort_nodes(
      overlapping_nodes, greedy_rectangle_strip_overlap_remover_compare_by_y_coordinate,
    )

    for overlap_node in overlapping_nodes {
      let mut overlap_placed = false
      for placed_node in already_placed_nodes {
        if placed_node == overlap_node {
          overlap_placed = true
          break
        }
      }

      if overlap_placed {
        let current_rect = current_node.get_rectangle()
        let overlap_rect = overlap_node.get_rectangle()
        if y_pos < overlap_rect.y + overlap_rect.height + vertical_gap &&
          y_pos + current_rect.height + vertical_gap > overlap_rect.y {
          y_pos = overlap_rect.y + overlap_rect.height + vertical_gap
        }
      }
    }

    current_node.set_rectangle_y(y_pos)
    already_placed_nodes.push(current_node)

    let current_rect = current_node.get_rectangle()
    let candidate_size = current_rect.y + current_rect.height
    if candidate_size > strip_size {
      strip_size = candidate_size
    }
  }

  strip_size
}
