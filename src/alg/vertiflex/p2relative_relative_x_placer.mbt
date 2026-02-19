///|
let vertiflex_relative_x_placer_minimal_y : Double = -100.0

///|
fn vertiflex_outline_require(outline : OutlineNode?) -> OutlineNode {
  match outline {
    Some(value) => value
    None => abort("VertiFlex outline unexpectedly missing.")
  }
}

///|
fn vertiflex_outline_require_next(outline : OutlineNode) -> OutlineNode {
  vertiflex_outline_require(outline.next)
}

///|
fn vertiflex_outline_distance(
  outline1 : OutlineNode,
  outline2 : OutlineNode,
) -> Double {
  let changed_outline1 = new_outline_node(
    outline1.relative_x,
    vertiflex_relative_x_placer_minimal_y,
    Some(new_outline_node(0.0, outline1.absolute_y, outline1.next)),
  )
  let changed_outline2 = new_outline_node(
    outline2.relative_x,
    vertiflex_relative_x_placer_minimal_y,
    Some(new_outline_node(0.0, outline2.absolute_y, outline2.next)),
  )

  let mut dist = changed_outline1.relative_x - changed_outline2.relative_x

  let mut o1 : OutlineNode? = Some(changed_outline1)
  let mut o2 : OutlineNode? = Some(changed_outline2)
  let mut x1 = changed_outline1.relative_x
  let mut x2 = changed_outline2.relative_x
  while o1 is Some(o1_value) && o2 is Some(o2_value) && !o2_value.is_last() {
    let o2_next = vertiflex_outline_require_next(o2_value)
    if o2_next.absolute_y > o1_value.absolute_y {
      let delta_x = o2_next.relative_x
      let delta_y = o2_next.absolute_y - o2_value.absolute_y
      let new_dist = x1 -
        x2 -
        (o1_value.absolute_y - o2_value.absolute_y) * delta_x / delta_y
      dist = @math.maximum(dist, new_dist)
      o1 = o1_value.next
      if o1 is Some(next_o1) {
        x1 += next_o1.relative_x
      }
    } else {
      o2 = o2_value.next
      if o2 is Some(next_o2) {
        x2 += next_o2.relative_x
      }
    }
  }

  o1 = Some(changed_outline1)
  o2 = Some(changed_outline2)
  x1 = changed_outline1.relative_x
  x2 = changed_outline2.relative_x
  while o2 is Some(o2_value) && o1 is Some(o1_value) && !o1_value.is_last() {
    let o1_next = vertiflex_outline_require_next(o1_value)
    if o1_next.absolute_y > o2_value.absolute_y {
      let delta_x = o1_next.relative_x
      let delta_y = o1_next.absolute_y - o1_value.absolute_y
      let new_dist = x1 -
        x2 +
        (o2_value.absolute_y - o1_value.absolute_y) * delta_x / delta_y
      dist = @math.maximum(dist, new_dist)
      o2 = o2_value.next
      if o2 is Some(next_o2) {
        x2 += next_o2.relative_x
      }
    } else {
      o1 = o1_value.next
      if o1 is Some(next_o1) {
        x1 += next_o1.relative_x
      }
    }
  }
  dist
}

///|
fn vertiflex_sort_sub_trees(
  children : Array[@graph.ElkNode],
  consider_node_model_order : Bool,
) -> Unit {
  @radial.radial_sort_nodes(children, (a, b) => {
    vertiflex_node_comparator_compare(a, b, false)
  })
  let left : Array[@graph.ElkNode] = []
  let right : Array[@graph.ElkNode] = []

  if consider_node_model_order {
    vertiflex_split_nodes_with_model_order(children, left, right)
  } else if !children.is_empty() {
    left.push(children[children.length() - 1])
    let mut width_left = 0.0
    let mut width_right = 0.0
    let mut i = 1
    while i < children.length() {
      let current = children[children.length() - 1 - i]
      if width_left <= width_right {
        left.push(current)
        width_left += @graph.node_width(current)
      } else {
        right.push(current)
        width_right += @graph.node_width(current)
      }
      i += 1
    }
    let reversed : Array[@graph.ElkNode] = []
    let mut k = left.length() - 1
    while k >= 0 {
      reversed.push(left[k])
      k -= 1
    }
    left.clear()
    for node in reversed {
      left.push(node)
    }
  }

  @radial.radial_sort_nodes(right, (a, b) => {
    vertiflex_node_comparator_compare(a, b, true)
  })
  for node in right {
    left.push(node)
  }
  for i = 0; i < children.length(); i = i + 1 {
    children[i] = left[i]
  }
}

///|
fn vertiflex_split_group(
  group : Array[@graph.ElkNode],
  width_left_ref : Ref[Double],
  width_right_ref : Ref[Double],
) -> Int {
  if group.length() == 1 {
    return 0
  }
  let width_left = width_left_ref.val
  let width_right = width_right_ref.val
  let mut total_new_width = 0.0
  for node in group {
    total_new_width += @graph.node_width(node)
  }
  let desired_left = (total_new_width - width_left + width_right) / 2.0
  let mut i = 0
  let mut new_left_width = 0.0
  while desired_left < new_left_width && i < group.length() {
    new_left_width += @graph.node_width(group[i])
    i += 1
  }
  let exceed = new_left_width - desired_left
  let under = desired_left - (new_left_width - @graph.node_width(group[i]))
  let result_index = if exceed > under { i } else { i - 1 }
  width_left_ref.val = width_left + exceed
  let mut new_right_width = 0.0
  for j = result_index + 1; j < group.length(); j = j + 1 {
    new_right_width += @graph.node_width(group[j])
  }
  width_right_ref.val = width_right + new_right_width
  result_index
}

///|
fn vertiflex_split_nodes_with_model_order(
  original : Array[@graph.ElkNode],
  left : Array[@graph.ElkNode],
  right : Array[@graph.ElkNode],
) -> Unit {
  if original.length() == 0 {
    return
  }
  if original.length() == 1 {
    left.push(original[0])
    return
  }
  if original.length() == 2 {
    let first = original[0]
    let second = original[1]
    if vertiflex_internal_node_model_order(first) >
      vertiflex_internal_node_model_order(second) {
      left.push(second)
      right.push(first)
    } else {
      left.push(first)
      right.push(second)
    }
    return
  }

  let mut current_group : Array[@graph.ElkNode] = []
  let width_left_ref : Ref[Double] = Ref::new(0.0)
  let width_right_ref : Ref[Double] = Ref::new(0.0)
  let mut current = original[0]
  current_group.push(current)
  for i = 1; i < original.length(); i = i + 1 {
    let next = original[i]
    if @graph.node_y(current) == @graph.node_y(next) {
      current_group.push(next)
    } else {
      let final_index_of_left = vertiflex_split_group(
        current_group, width_left_ref, width_right_ref,
      )
      for j = 0; j <= final_index_of_left; j = j + 1 {
        left.push(current_group[j])
      }
      for j = final_index_of_left + 1; j < current_group.length(); j = j + 1 {
        right.push(current_group[j])
      }
      current_group = []
      current_group.push(next)
    }
    current = next
    if i == original.length() - 1 {
      let final_index_of_left = vertiflex_split_group(
        current_group, width_left_ref, width_right_ref,
      )
      for j = 0; j <= final_index_of_left; j = j + 1 {
        left.push(current_group[j])
      }
      for j = final_index_of_left + 1; j < current_group.length(); j = j + 1 {
        right.push(current_group[j])
      }
    }
  }
}

///|
fn vertiflex_make_simple_outlines(
  graph : @graph.ElkNode,
  spacing_node_node : Double,
) -> Unit {
  let margins = vertiflex_internal_node_margins(graph)
  let left_end = new_outline_node(
    0.0,
    @graph.node_y(graph) +
    @graph.node_height(graph) +
    margins.bottom +
    spacing_node_node / 2.0,
    Some(
      new_outline_node(
        @graph.node_width(graph) / 2.0,
        @graph.node_y(graph) +
        @graph.node_height(graph) +
        margins.bottom +
        spacing_node_node / 2.0,
        None,
      ),
    ),
  )
  vertiflex_internal_set_left_outline(
    graph,
    new_outline_node(
      -margins.left - spacing_node_node / 2.0 + @graph.node_width(graph) / 2.0,
      @graph.node_y(graph) - margins.top - spacing_node_node / 2.0,
      Some(
        new_outline_node(
          -@graph.node_width(graph) / 2.0,
          @graph.node_y(graph) - margins.top,
          Some(left_end),
        ),
      ),
    ),
  )
  let right_end = new_outline_node(
    0.0,
    @graph.node_y(graph) + @graph.node_height(graph) + margins.bottom,
    Some(
      new_outline_node(
        -@graph.node_width(graph) / 2.0,
        @graph.node_y(graph) +
        @graph.node_height(graph) +
        margins.bottom +
        spacing_node_node / 2.0,
        None,
      ),
    ),
  )
  vertiflex_internal_set_right_outline(
    graph,
    new_outline_node(
      @graph.node_width(graph) / 2.0 + margins.right + spacing_node_node / 2.0,
      @graph.node_y(graph) - margins.top,
      Some(
        new_outline_node(
          @graph.node_width(graph) / 2.0,
          @graph.node_y(graph) - margins.top - spacing_node_node / 2.0,
          Some(right_end),
        ),
      ),
    ),
  )
  vertiflex_internal_set_min_x(graph, @graph.node_x(graph) - margins.left)
  vertiflex_internal_set_max_x(
    graph,
    @graph.node_x(graph) + margins.right + @graph.node_width(graph),
  )
  vertiflex_internal_set_min_y(graph, @graph.node_y(graph) - margins.top)
  vertiflex_internal_set_max_y(
    graph,
    @graph.node_y(graph) + margins.bottom + @graph.node_height(graph),
  )
  vertiflex_internal_set_outline_max_depth(
    graph,
    vertiflex_outline_require_next(
      vertiflex_outline_require_next(vertiflex_internal_left_outline(graph)),
    ).absolute_y,
  )
}

///|
fn vertiflex_bundle_children(
  left_subtree : @graph.ElkNode,
  a : @graph.ElkNode,
  b : @graph.ElkNode,
) -> Unit {
  let dist = vertiflex_outline_distance(
    vertiflex_internal_right_outline(a),
    vertiflex_internal_left_outline(b),
  )
  @graph.node_set_location(b, @graph.node_x(a) + dist, @graph.node_y(b))

  if vertiflex_internal_outline_max_depth(left_subtree) <
    vertiflex_internal_outline_max_depth(b) {
    let mut last_l = vertiflex_internal_left_outline(left_subtree)
    let mut l_abs_x = last_l.relative_x + @graph.node_x(left_subtree)
    while !last_l.is_last() {
      last_l = vertiflex_outline_require_next(last_l)
      l_abs_x += last_l.relative_x
    }
    let mut b_iterator = new_outline_node(
      vertiflex_internal_left_outline(b).relative_x,
      vertiflex_relative_x_placer_minimal_y,
      vertiflex_internal_left_outline(b).next,
    )
    let mut r_abs_x = b_iterator.relative_x + @graph.node_x(b)
    while vertiflex_outline_require_next(b_iterator).absolute_y <=
          last_l.absolute_y {
      b_iterator = vertiflex_outline_require_next(b_iterator)
      r_abs_x += b_iterator.relative_x
    }
    let b_next = vertiflex_outline_require_next(b_iterator)
    let delta_x = b_next.relative_x
    let delta_y = b_next.absolute_y - b_iterator.absolute_y
    let change = (last_l.absolute_y - b_iterator.absolute_y) * delta_x / delta_y
    let new_x = -l_abs_x + r_abs_x + change
    let new_next = new_outline_node(
      b_next.relative_x - change,
      b_next.absolute_y,
      b_next.next,
    )
    last_l.next = Some(
      new_outline_node(new_x, last_l.absolute_y, Some(new_next)),
    )
    vertiflex_internal_set_outline_max_depth(
      left_subtree,
      vertiflex_internal_outline_max_depth(b),
    )
  }

  if vertiflex_internal_outline_max_depth(b) <
    vertiflex_internal_outline_max_depth(a) {
    let mut last_b = vertiflex_internal_right_outline(b)
    let mut r_abs_x = last_b.relative_x + @graph.node_x(b)
    while !last_b.is_last() {
      last_b = vertiflex_outline_require_next(last_b)
      r_abs_x += last_b.relative_x
    }
    let mut a_iterator = new_outline_node(
      vertiflex_internal_right_outline(a).relative_x,
      vertiflex_relative_x_placer_minimal_y,
      vertiflex_internal_right_outline(a).next,
    )
    let mut a_abs_x = a_iterator.relative_x + @graph.node_x(a)
    while vertiflex_outline_require_next(a_iterator).absolute_y <=
          last_b.absolute_y {
      a_iterator = vertiflex_outline_require_next(a_iterator)
      a_abs_x += a_iterator.relative_x
    }
    let a_next = vertiflex_outline_require_next(a_iterator)
    let delta_x = a_next.relative_x
    let delta_y = a_next.absolute_y - a_iterator.absolute_y
    let change = (last_b.absolute_y - a_iterator.absolute_y) * delta_x / delta_y
    let new_x = a_abs_x - r_abs_x + change
    let new_next = new_outline_node(
      a_next.relative_x - change,
      a_next.absolute_y,
      a_next.next,
    )
    last_b.next = Some(
      new_outline_node(new_x, last_b.absolute_y, Some(new_next)),
    )
    vertiflex_internal_set_outline_max_depth(
      b,
      vertiflex_internal_outline_max_depth(a),
    )
  }
}

///|
fn vertiflex_recursive_straightline_placement(
  graph : @graph.ElkNode,
  spacing_node_node : Double,
  consider_node_model_order : Bool,
) -> Unit {
  vertiflex_make_simple_outlines(graph, spacing_node_node)
  let outgoing = @graph.node_outgoing_edges(graph)
  if outgoing.is_empty() {
    return
  }

  let children : Array[@graph.ElkNode] = []
  for edge in outgoing {
    let child = vertiflex_internal_child_of_edge(edge)
    vertiflex_recursive_straightline_placement(
      child, spacing_node_node, consider_node_model_order,
    )
    children.push(child)
  }
  vertiflex_sort_sub_trees(children, consider_node_model_order)
  for i = 0; i < children.length() - 1; i = i + 1 {
    vertiflex_bundle_children(children[0], children[i], children[i + 1])
  }

  let mut pos = 0
  let mut max_depth = 0.0
  let mut max_depth_start_pos = 0
  while pos < children.length() && @graph.node_y(children[pos]) >= max_depth {
    if @graph.node_y(children[pos]) > max_depth {
      max_depth_start_pos = pos
      max_depth = @graph.node_y(children[pos])
    }
    pos += 1
  }
  let mut move_root = 0.0
  if pos > 0 {
    move_root = (
        @graph.node_x(children[max_depth_start_pos]) +
        @graph.node_x(children[pos - 1]) +
        @graph.node_width(children[pos - 1])
      ) /
      2.0 -
      @graph.node_x(graph) -
      @graph.node_width(graph) / 2.0
  }

  if !consider_node_model_order {
    let mut better_move_root = (
        @graph.node_x(children[0]) +
        @graph.node_x(children[children.length() - 1]) +
        @graph.node_width(children[children.length() - 1]) -
        @graph.node_width(graph)
      ) /
      2.0 -
      @graph.node_x(graph)
    if better_move_root < move_root {
      for i = 0; i < max_depth_start_pos; i = i + 1 {
        for j = i + 1; j < max_depth_start_pos + 1; j = j + 1 {
          let mut right_outline = vertiflex_internal_right_outline(children[i])
          let mut right_outline_x = @graph.node_x(children[i]) +
            right_outline.relative_x
          let pos_x = @graph.node_x(children[j]) + @graph.node_width(children[j]) / 2.0
          while right_outline.absolute_y < max_depth {
            let new_move_root = pos_x -
              @graph.node_width(graph) / 2.0 +
              (pos_x - right_outline_x) *
              (@graph.node_y(graph) + @graph.node_height(graph) - max_depth) /
              (max_depth - right_outline.absolute_y)
            better_move_root = @math.maximum(better_move_root, new_move_root)
            match right_outline.next {
              Some(next_outline) => {
                right_outline = next_outline
                right_outline_x += right_outline.relative_x
              }
              None => break
            }
          }
        }
      }
      move_root = better_move_root
    }
    if better_move_root > move_root {
      for i = pos; i < children.length(); i = i + 1 {
        for j = pos - 1; j < i; j = j + 1 {
          let mut left_outline = vertiflex_internal_left_outline(children[i])
          let mut left_outline_x = @graph.node_x(children[i]) + left_outline.relative_x
          let pos_x = @graph.node_x(children[j]) + @graph.node_width(children[j]) / 2.0
          while left_outline.absolute_y < max_depth {
            let new_move_root = pos_x -
              @graph.node_width(graph) / 2.0 +
              (pos_x - left_outline_x) *
              (@graph.node_y(graph) + @graph.node_height(graph) - max_depth) /
              (max_depth - left_outline.absolute_y)
            better_move_root = @math.minimum(better_move_root, new_move_root)
            match left_outline.next {
              Some(next_outline) => {
                left_outline = next_outline
                left_outline_x += left_outline.relative_x
              }
              None => break
            }
          }
        }
      }
      move_root = better_move_root
    }
  }

  for child in children {
    @graph.node_set_location(child, @graph.node_x(child) - move_root, @graph.node_y(child))
  }

  let graph_left_outline = vertiflex_internal_left_outline(graph)
  let left_child_outline = vertiflex_internal_left_outline(children[0])
  let new_x_left = @graph.node_x(children[0]) +
    left_child_outline.relative_x -
    graph_left_outline.relative_x
  let graph_left_o2 = vertiflex_outline_require_next(graph_left_outline)
  let graph_left_o3 = vertiflex_outline_require_next(graph_left_o2)
  graph_left_o3.next = Some(
    new_outline_node(
      new_x_left,
      left_child_outline.absolute_y,
      left_child_outline.next,
    ),
  )

  let graph_right_outline = vertiflex_internal_right_outline(graph)
  let right_child_outline = vertiflex_internal_right_outline(
    children[children.length() - 1],
  )
  let new_x_right = @graph.node_x(children[children.length() - 1]) +
    right_child_outline.relative_x -
    graph_right_outline.relative_x
  let graph_right_o2 = vertiflex_outline_require_next(graph_right_outline)
  let graph_right_o3 = vertiflex_outline_require_next(graph_right_o2)
  graph_right_o3.next = Some(
    new_outline_node(
      new_x_right,
      right_child_outline.absolute_y,
      right_child_outline.next,
    ),
  )

  for child in children {
    vertiflex_internal_set_outline_max_depth(
      graph,
      @math.maximum(
        vertiflex_internal_outline_max_depth(graph),
        vertiflex_internal_outline_max_depth(child),
      ),
    )
    vertiflex_internal_set_min_x(
      graph,
      @math.minimum(
        vertiflex_internal_min_x(graph),
        @graph.node_x(child) + vertiflex_internal_min_x(child),
      ),
    )
    vertiflex_internal_set_max_x(
      graph,
      @math.maximum(
        vertiflex_internal_max_x(graph),
        @graph.node_x(child) + vertiflex_internal_max_x(child),
      ),
    )
  }
  vertiflex_internal_set_max_y(
    graph,
    vertiflex_internal_outline_max_depth(graph),
  )
}

///|
fn vertiflex_recursive_bentline_placement(
  graph : @graph.ElkNode,
  spacing_node_node : Double,
) -> Unit {
  vertiflex_make_simple_outlines(graph, spacing_node_node)
  let outgoing = @graph.node_outgoing_edges(graph)
  if outgoing.is_empty() {
    return
  }
  let children : Array[@graph.ElkNode] = []
  for edge in outgoing {
    let child = vertiflex_internal_child_of_edge(edge)
    vertiflex_recursive_bentline_placement(child, spacing_node_node)
    children.push(child)
  }
  let children_size = children.length()
  for i = 0; i < children.length() - 1; i = i + 1 {
    vertiflex_bundle_children(children[0], children[i], children[i + 1])
  }
  let move_root = (
      @graph.node_x(children[0]) +
      @graph.node_width(children[0]) / 2.0 +
      @graph.node_x(children[children.length() - 1]) +
      @graph.node_width(children[children.length() - 1]) / 2.0 -
      @graph.node_width(graph)
    ) /
    2.0 -
    @graph.node_x(graph)
  for child in children {
    @graph.node_set_location(child, @graph.node_x(child) - move_root, @graph.node_y(child))
    vertiflex_internal_set_edge_bend_height(
      child,
      vertiflex_internal_left_outline(child).absolute_y,
    )
  }

  let mut i = 0
  while i < children_size - 1 &&
        @graph.node_x(children[i]) +
        @graph.node_width(children[i]) +
        vertiflex_internal_node_margins(children[i]).right -
        @graph.node_width(graph) / 2.0 <=
        0.0 {
    i += 1
  }
  let mut global_bend_height = vertiflex_internal_edge_bend_height(children[i])
  for a = 0; a < children_size; a = a + 1 {
    if global_bend_height < vertiflex_internal_edge_bend_height(children[a]) {
      vertiflex_internal_set_edge_bend_height(children[a], global_bend_height)
    } else {
      global_bend_height = vertiflex_internal_edge_bend_height(children[a])
    }
  }

  i = children_size - 1
  while i > 0 &&
        @graph.node_x(children[i]) -
        vertiflex_internal_node_margins(children[i]).left -
        @graph.node_width(graph) / 2.0 >=
        0.0 {
    i -= 1
  }
  if i < children_size {
    for a = i; a >= 0; a = a - 1 {
      if global_bend_height < vertiflex_internal_edge_bend_height(children[a]) {
        vertiflex_internal_set_edge_bend_height(children[a], global_bend_height)
      } else {
        global_bend_height = vertiflex_internal_edge_bend_height(children[a])
      }
    }
  }

  let left_child_outline = vertiflex_internal_left_outline(children[0])
  let graph_left_outline = vertiflex_internal_left_outline(graph)
  let new_x_left = @graph.node_x(children[0]) +
    left_child_outline.relative_x -
    graph_left_outline.relative_x
  let new_outline_part_left = new_outline_node(
    0.0,
    left_child_outline.absolute_y,
    left_child_outline.next,
  )
  let graph_left_o2 = vertiflex_outline_require_next(graph_left_outline)
  let graph_left_o3 = vertiflex_outline_require_next(graph_left_o2)
  graph_left_o3.next = Some(
    new_outline_node(
      new_x_left,
      vertiflex_internal_edge_bend_height(children[0]),
      Some(new_outline_part_left),
    ),
  )

  let graph_right_outline = vertiflex_internal_right_outline(graph)
  let right_child_outline = vertiflex_internal_right_outline(
    children[children_size - 1],
  )
  let new_x_right = @graph.node_x(children[children_size - 1]) +
    right_child_outline.relative_x -
    graph_right_outline.relative_x
  let new_outline_part_right = new_outline_node(
    0.0,
    right_child_outline.absolute_y,
    right_child_outline.next,
  )
  let graph_right_o2 = vertiflex_outline_require_next(graph_right_outline)
  let graph_right_o3 = vertiflex_outline_require_next(graph_right_o2)
  graph_right_o3.next = Some(
    new_outline_node(
      new_x_right,
      vertiflex_internal_edge_bend_height(children[children_size - 1]),
      Some(new_outline_part_right),
    ),
  )

  for child in children {
    vertiflex_internal_set_outline_max_depth(
      graph,
      @math.maximum(
        vertiflex_internal_outline_max_depth(graph),
        vertiflex_internal_outline_max_depth(child),
      ),
    )
    vertiflex_internal_set_min_x(
      graph,
      @math.minimum(
        vertiflex_internal_min_x(graph),
        @graph.node_x(child) + vertiflex_internal_min_x(child),
      ),
    )
    vertiflex_internal_set_max_x(
      graph,
      @math.maximum(
        vertiflex_internal_max_x(graph),
        @graph.node_x(child) + vertiflex_internal_max_x(child),
      ),
    )
  }
  vertiflex_internal_set_max_y(
    graph,
    vertiflex_internal_outline_max_depth(graph),
  )
}

///|
fn vertiflex_relative_x_placer_process(
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(existing) => existing
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("XPlacer", 1.0))
  let spacing_node_node = @graph.node_get_double_property(
    graph, vertiflex_spacing_node_node,
  )
  let consider_node_model_order = @graph.node_get_bool_property(
    graph, vertiflex_consider_node_model_order,
  )
  if !@graph.node_children(graph).is_empty() {
    let parent = vertiflex_internal_root_node(graph)
    match
      vertiflex_edge_routing_strategy_from_string(
        @graph.node_get_string_property(graph, vertiflex_layout_strategy),
      ) {
      STRAIGHT =>
        vertiflex_recursive_straightline_placement(
          parent, spacing_node_node, consider_node_model_order,
        )
      BEND => vertiflex_recursive_bentline_placement(parent, spacing_node_node)
    }
  }
  monitor.done()
}

///|
pub fn new_vertiflex_relative_x_placer_layout_phase() -> @core.ILayoutProcessor[
  VertiFlexLayoutPhases,
  @graph.ElkNode,
] {
  @core.new_layout_phase(vertiflex_relative_x_placer_process, _ => None)
}
