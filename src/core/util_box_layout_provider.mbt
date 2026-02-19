///|
pub(all) struct BoxLayoutProvider {
  initialized : Bool
}

///|
pub(all) enum BoxPackingMode {
  SIMPLE
  GROUP_DEC
  GROUP_MIXED
  GROUP_INC
}

///|
priv struct BoxGroup {
  node : @graph.ElkNode?
  groups : Array[BoxGroup]
  size : KVector
  mut bottom : Array[Int]
  mut right : Array[Int]
}

///|
let box_layout_provider_def_aspect_ratio : Double = 1.3

///|
let box_layout_provider_default_min_width : Double = 20.0

///|
let box_layout_provider_default_min_height : Double = 20.0

///|
fn box_layout_provider_max(a : Double, b : Double) -> Double {
  if a >= b {
    a
  } else {
    b
  }
}

///|
fn box_layout_provider_compare_double(left : Double, right : Double) -> Int {
  if left < right {
    -1
  } else if left > right {
    1
  } else {
    0
  }
}

///|
fn box_layout_provider_parse_padding(
  layout_node : @graph.ElkNode,
) -> ElkPadding {
  let parsed = new_elk_padding()
  parsed.parse(@graph.node_get_string_property(layout_node, padding))
  parsed
}

///|
fn box_layout_provider_contains_value(
  values : Array[String],
  expected : String,
) -> Bool {
  for value in values {
    if value == expected {
      return true
    }
  }
  false
}

///|
fn box_layout_provider_has_minimum_size_constraint(
  node : @graph.ElkNode,
) -> Bool {
  for value in @graph.node_get_string_set_property(node, node_size_constraints) {
    if value == "MINIMUM_SIZE" || value == "MINIMUM_SIZE_WITH_PORTS" {
      return true
    }
  }
  false
}

///|
fn box_layout_provider_effective_min_size_constraint_for(
  node : @graph.ElkNode,
) -> KVector {
  if !box_layout_provider_has_minimum_size_constraint(node) {
    return new_kvector_xy(0.0, 0.0)
  }

  let min_size = new_kvector()
  min_size.parse(@graph.node_get_string_property(node, node_size_minimum))

  if box_layout_provider_contains_value(
      @graph.node_get_string_set_property(node, node_size_options),
      "DEFAULT_MINIMUM_SIZE",
    ) {
    if min_size.x <= 0.0 {
      min_size.x = box_layout_provider_default_min_width
    }
    if min_size.y <= 0.0 {
      min_size.y = box_layout_provider_default_min_height
    }
  }

  min_size
}

///|
fn box_layout_provider_resize_node(
  node : @graph.ElkNode,
  new_width : Double,
  new_height : Double,
  move_ports : Bool,
  move_labels : Bool,
) -> KVector {
  ignore(move_ports)
  ignore(move_labels)

  let old_width = @graph.node_width(node)
  let old_height = @graph.node_height(node)

  let min_size = box_layout_provider_effective_min_size_constraint_for(node)
  let final_width = box_layout_provider_max(new_width, min_size.x)
  let final_height = box_layout_provider_max(new_height, min_size.y)

  @graph.node_set_dimensions(node, final_width, final_height)
  @graph.node_set_string_set_property(node, node_size_constraints, ["FIXED"])

  new_kvector_xy(final_width / old_width, final_height / old_height)
}

///|
fn box_layout_provider_resize_node_to_constraints(
  node : @graph.ElkNode,
) -> Unit {
  ignore(
    box_layout_provider_resize_node(
      node,
      @graph.node_width(node),
      @graph.node_height(node),
      true,
      true,
    ),
  )
}

///|
fn box_layout_provider_mode_from_string(value : String) -> BoxPackingMode {
  if value == "GROUP_DEC" {
    GROUP_DEC
  } else if value == "GROUP_MIXED" {
    GROUP_MIXED
  } else if value == "GROUP_INC" {
    GROUP_INC
  } else {
    SIMPLE
  }
}

///|
fn box_layout_provider_new_group_from_node(node : @graph.ElkNode) -> BoxGroup {
  @graph.node_set_location(node, 0.0, 0.0)
  { node: Some(node), groups: [], size: new_kvector(), bottom: [], right: [] }
}

///|
fn box_layout_provider_copy_groups(groups : Array[BoxGroup]) -> Array[BoxGroup] {
  let copied = []
  for group in groups {
    copied.push(group)
  }
  copied
}

///|
fn box_layout_provider_copy_group_range(
  groups : Array[BoxGroup],
  start : Int,
  end_index : Int,
) -> Array[BoxGroup] {
  let copied = []
  let mut index = start
  while index < end_index {
    copied.push(groups[index])
    index = index + 1
  }
  copied
}

///|
fn box_layout_provider_new_group_from_groups(
  groups : Array[BoxGroup],
) -> BoxGroup {
  {
    node: None,
    groups: box_layout_provider_copy_groups(groups),
    size: new_kvector(),
    bottom: [],
    right: [],
  }
}

///|
fn box_layout_provider_group_get_width(group : BoxGroup) -> Double {
  if group.node is Some(node) {
    @graph.node_width(node)
  } else {
    group.size.x
  }
}

///|
fn box_layout_provider_group_get_height(group : BoxGroup) -> Double {
  if group.node is Some(node) {
    @graph.node_height(node)
  } else {
    group.size.y
  }
}

///|
fn box_layout_provider_group_area(group : BoxGroup) -> Double {
  box_layout_provider_group_get_width(group) *
  box_layout_provider_group_get_height(group)
}

///|
fn box_layout_provider_group_set_width(
  group : BoxGroup,
  width : Double,
) -> BoxGroup {
  if group.node is Some(node) {
    @graph.node_set_dimensions(node, width, @graph.node_height(node))
    group
  } else {
    let delta = width - box_layout_provider_group_get_width(group)
    for child_index in group.right {
      group.groups[child_index] = box_layout_provider_group_set_width(
        group.groups[child_index],
        box_layout_provider_group_get_width(group.groups[child_index]) + delta,
      )
    }
    group
  }
}

///|
fn box_layout_provider_group_set_height(
  group : BoxGroup,
  height : Double,
) -> BoxGroup {
  if group.node is Some(node) {
    @graph.node_set_dimensions(node, @graph.node_width(node), height)
    group
  } else {
    let delta = height - box_layout_provider_group_get_height(group)
    for child_index in group.bottom {
      group.groups[child_index] = box_layout_provider_group_set_height(
        group.groups[child_index],
        box_layout_provider_group_get_height(group.groups[child_index]) + delta,
      )
    }
    group
  }
}

///|
fn box_layout_provider_group_translate(
  group : BoxGroup,
  x : Double,
  y : Double,
) -> BoxGroup {
  if group.node is Some(node) {
    @graph.node_set_location(
      node,
      @graph.node_x(node) + x,
      @graph.node_y(node) + y,
    )
    group
  } else {
    let mut index = 0
    while index < group.groups.length() {
      group.groups[index] = box_layout_provider_group_translate(
        group.groups[index],
        x,
        y,
      )
      index = index + 1
    }
    group
  }
}

///|
fn box_layout_provider_group_translate_inner_nodes(
  group : BoxGroup,
  x : Double,
  y : Double,
) -> BoxGroup {
  if group.node is Some(node) {
    translate_xy(node, x, y)
    group
  } else {
    let mut index = 0
    while index < group.groups.length() {
      group.groups[index] = box_layout_provider_group_translate_inner_nodes(
        group.groups[index],
        x,
        y,
      )
      index = index + 1
    }
    group
  }
}

///|
fn box_layout_provider_compare_nodes(
  child1 : @graph.ElkNode,
  child2 : @graph.ElkNode,
  interactive_mode : Bool,
) -> Int {
  let prio1 = @graph.node_get_double_property(child1, priority)
  let prio2 = @graph.node_get_double_property(child2, priority)

  if prio1 > prio2 {
    return -1
  }
  if prio1 < prio2 {
    return 1
  }

  if interactive_mode {
    let compare_y = box_layout_provider_compare_double(
      @graph.node_y(child1),
      @graph.node_y(child2),
    )
    if compare_y != 0 {
      return compare_y
    }

    let compare_x = box_layout_provider_compare_double(
      @graph.node_x(child1),
      @graph.node_x(child2),
    )
    if compare_x != 0 {
      return compare_x
    }
  }

  let size1 = @graph.node_width(child1) * @graph.node_height(child1)
  let size2 = @graph.node_width(child2) * @graph.node_height(child2)
  box_layout_provider_compare_double(size1, size2)
}

///|
fn box_layout_provider_sort_nodes(
  nodes : Array[@graph.ElkNode],
  interactive_mode : Bool,
) -> Unit {
  let mut index = 1
  while index < nodes.length() {
    let current = nodes[index]
    let mut insert_index = index - 1

    while insert_index >= 0 &&
          box_layout_provider_compare_nodes(
            nodes[insert_index],
            current,
            interactive_mode,
          ) >
          0 {
      nodes[insert_index + 1] = nodes[insert_index]
      insert_index = insert_index - 1
    }

    nodes[insert_index + 1] = current
    index = index + 1
  }
}

///|
fn box_layout_provider_sort_groups(
  groups : Array[BoxGroup],
  descending : Bool,
) -> Unit {
  let mut index = 1
  while index < groups.length() {
    let current = groups[index]
    let mut insert_index = index - 1

    while insert_index >= 0 {
      let cmp = box_layout_provider_compare_double(
        box_layout_provider_group_area(groups[insert_index]),
        box_layout_provider_group_area(current),
      )
      let should_shift = if descending { cmp < 0 } else { cmp > 0 }
      if !should_shift {
        break
      }
      groups[insert_index + 1] = groups[insert_index]
      insert_index = insert_index - 1
    }

    groups[insert_index + 1] = current
    index = index + 1
  }
}

///|
fn box_layout_provider_area_std_dev(
  boxes : Array[@graph.ElkNode],
  mean : Double,
) -> Double {
  let mut variance = 0.0
  for box in boxes {
    let area = @graph.node_width(box) * @graph.node_height(box)
    variance = variance + (area - mean) * (area - mean)
  }
  (variance / (boxes.length() - 1).to_double()).sqrt()
}

///|
fn box_layout_provider_area_std_dev2(
  boxes : Array[BoxGroup],
  mean : Double,
) -> Double {
  let mut variance = 0.0
  for box in boxes {
    let area = box_layout_provider_group_area(box)
    variance = variance + (area - mean) * (area - mean)
  }
  (variance / (boxes.length() - 1).to_double()).sqrt()
}

///|
fn box_layout_provider_sorted_boxes(
  parent_node : @graph.ElkNode,
  interactive_mode : Bool,
) -> Array[@graph.ElkNode] {
  let sorted_boxes = []
  for child in @graph.node_children(parent_node) {
    sorted_boxes.push(child)
  }
  box_layout_provider_sort_nodes(sorted_boxes, interactive_mode)
  sorted_boxes
}

///|
fn box_layout_provider_place_boxes_sorted(
  sorted_boxes : Array[@graph.ElkNode],
  min_spacing : Double,
  padding_value : ElkPadding,
  min_total_width : Double,
  min_total_height : Double,
  expand_nodes_value : Bool,
  aspect_ratio_value : Double,
) -> KVector {
  let mut max_row_width = 0.0
  let mut total_area = 0.0
  for box in sorted_boxes {
    box_layout_provider_resize_node_to_constraints(box)
    max_row_width = box_layout_provider_max(
      max_row_width,
      @graph.node_width(box),
    )
    total_area = total_area + @graph.node_width(box) * @graph.node_height(box)
  }

  let mean = total_area / sorted_boxes.length().to_double()
  let stddev = box_layout_provider_area_std_dev(sorted_boxes, mean)
  total_area = total_area + sorted_boxes.length().to_double() * stddev
  total_area = total_area +
    total_area.sqrt() * (padding_value.bottom + padding_value.top)
  total_area = total_area + total_area.sqrt() * padding_value.right

  max_row_width = box_layout_provider_max(
      max_row_width,
      (total_area * aspect_ratio_value).sqrt(),
    ) +
    padding_value.left

  let mut xpos = padding_value.left
  let mut ypos = padding_value.top
  let mut highest_box = 0.0
  let mut broadest_row = padding_value.get_horizontal()
  let row_indices = [0]
  let row_heights = []

  let mut index = 0
  while index < sorted_boxes.length() {
    let box = sorted_boxes[index]
    let width = @graph.node_width(box)
    let height = @graph.node_height(box)

    if xpos + width > max_row_width {
      if expand_nodes_value {
        row_heights.push(highest_box)
        row_indices.push(index)
      }
      xpos = padding_value.left
      ypos = ypos + highest_box + min_spacing
      highest_box = 0.0
      broadest_row = box_layout_provider_max(
        broadest_row,
        padding_value.get_horizontal() + width,
      )
    }

    @graph.node_set_location(box, xpos, ypos)
    broadest_row = box_layout_provider_max(
      broadest_row,
      xpos + width + padding_value.right,
    )
    highest_box = box_layout_provider_max(highest_box, height)
    xpos = xpos + width + min_spacing

    index = index + 1
  }

  broadest_row = box_layout_provider_max(broadest_row, min_total_width)
  let mut total_height = ypos + highest_box + padding_value.bottom
  if total_height < min_total_height {
    highest_box = highest_box + (min_total_height - total_height)
    total_height = min_total_height
  }

  if expand_nodes_value {
    xpos = padding_value.left
    row_indices.push(sorted_boxes.length())

    let mut row_index_index = 0
    let mut next_row_index = row_indices[row_index_index]
    row_index_index = row_index_index + 1

    row_heights.push(highest_box)
    let mut row_height_index = 0
    let mut row_height = 0.0

    index = 0
    while index < sorted_boxes.length() {
      if index == next_row_index {
        xpos = padding_value.left
        row_height = row_heights[row_height_index]
        row_height_index = row_height_index + 1
        next_row_index = row_indices[row_index_index]
        row_index_index = row_index_index + 1
      }

      let box = sorted_boxes[index]
      let old_height = @graph.node_height(box)
      @graph.node_set_dimensions(box, @graph.node_width(box), row_height)
      let new_height = row_height

      if index + 1 == next_row_index {
        let new_width = broadest_row - xpos - padding_value.right
        let old_width = @graph.node_width(box)
        @graph.node_set_dimensions(box, new_width, new_height)
        translate(
          box,
          new_kvector_xy(new_width, new_height),
          new_kvector_xy(old_width, old_height),
        )
      }

      xpos = xpos + @graph.node_width(box) + min_spacing
      index = index + 1
    }
  }

  new_kvector_xy(broadest_row, total_height)
}

///|
fn box_layout_provider_place_boxes(
  parent_node : @graph.ElkNode,
  obj_spacing : Double,
  padding_value : ElkPadding,
  expand_nodes_value : Bool,
  interactive_mode : Bool,
) -> Unit {
  let sorted_boxes = box_layout_provider_sorted_boxes(
    parent_node, interactive_mode,
  )

  let min_size = box_layout_provider_effective_min_size_constraint_for(
    parent_node,
  )

  let configured_aspect_ratio = @graph.node_get_double_property(
    parent_node, aspect_ratio,
  )
  let aspect_ratio_value = if configured_aspect_ratio <= 0.0 {
    box_layout_provider_def_aspect_ratio
  } else {
    configured_aspect_ratio
  }

  let parent_size = box_layout_provider_place_boxes_sorted(
    sorted_boxes,
    obj_spacing,
    padding_value,
    min_size.x,
    min_size.y,
    expand_nodes_value,
    aspect_ratio_value,
  )

  ignore(
    box_layout_provider_resize_node(
      parent_node,
      parent_size.x,
      parent_size.y,
      false,
      true,
    ),
  )
}

///|
fn box_layout_provider_place_inner_boxes(
  group : BoxGroup,
  min_spacing : Double,
  padding_value : ElkPadding,
  min_total_width : Double,
  min_total_height : Double,
  expand_nodes_value : Bool,
  aspect_ratio_value : Double,
) -> (BoxGroup, KVector) {
  let updated_group = group
  updated_group.bottom = []
  updated_group.right = []

  let mut max_row_width = 0.0
  let mut total_area = 0.0
  for index in 0..<updated_group.groups.length() {
    let box = updated_group.groups[index]
    if box.node is Some(node) {
      box_layout_provider_resize_node_to_constraints(node)
      updated_group.groups[index] = box
    }
    max_row_width = box_layout_provider_max(
      max_row_width,
      box_layout_provider_group_get_width(box),
    )
    total_area = total_area +
      box_layout_provider_group_get_width(box) *
      box_layout_provider_group_get_height(box)
  }

  let mean = total_area / updated_group.groups.length().to_double()
  let stddev = box_layout_provider_area_std_dev2(updated_group.groups, mean)
  total_area = total_area + updated_group.groups.length().to_double() * stddev

  max_row_width = box_layout_provider_max(
      max_row_width,
      (total_area * aspect_ratio_value).sqrt(),
    ) +
    padding_value.left

  let mut xpos = padding_value.left
  let mut ypos = padding_value.top
  let mut highest_box = 0.0
  let mut broadest_row = padding_value.get_horizontal()
  let row_indices = [0]
  let row_heights = []
  let bottoms = []

  let mut index = 0
  let mut last_index : Int? = None
  while index < updated_group.groups.length() {
    let mut box = updated_group.groups[index]
    let width = box_layout_provider_group_get_width(box)
    let height = box_layout_provider_group_get_height(box)

    if xpos + width > max_row_width {
      if expand_nodes_value {
        row_heights.push(highest_box)
        row_indices.push(index)
        if last_index is Some(last_value) {
          updated_group.right.push(last_value)
        }
        bottoms.clear()
      }
      xpos = padding_value.left
      ypos = ypos + highest_box + min_spacing
      highest_box = 0.0
      broadest_row = box_layout_provider_max(
        broadest_row,
        padding_value.get_horizontal() + width,
      )
    }

    bottoms.push(index)
    box = box_layout_provider_group_translate(box, xpos, ypos)
    updated_group.groups[index] = box

    broadest_row = box_layout_provider_max(
      broadest_row,
      xpos + width + padding_value.right,
    )
    highest_box = box_layout_provider_max(highest_box, height)
    xpos = xpos + width + min_spacing
    last_index = Some(index)
    index = index + 1
  }

  for bottom_index in bottoms {
    updated_group.bottom.push(bottom_index)
  }
  if !bottoms.is_empty() {
    updated_group.right.push(bottoms[bottoms.length() - 1])
  }

  broadest_row = box_layout_provider_max(broadest_row, min_total_width)
  let mut total_height = ypos + highest_box + padding_value.bottom
  if total_height < min_total_height {
    highest_box = highest_box + (min_total_height - total_height)
    total_height = min_total_height
  }

  if expand_nodes_value {
    xpos = padding_value.left
    row_indices.push(updated_group.groups.length())

    let mut row_index_index = 0
    let mut next_row_index = row_indices[row_index_index]
    row_index_index = row_index_index + 1

    row_heights.push(highest_box)
    let mut row_height_index = 0
    let mut row_height = 0.0

    index = 0
    while index < updated_group.groups.length() {
      if index == next_row_index {
        xpos = padding_value.left
        row_height = row_heights[row_height_index]
        row_height_index = row_height_index + 1
        next_row_index = row_indices[row_index_index]
        row_index_index = row_index_index + 1
      }

      let mut box = updated_group.groups[index]
      box = box_layout_provider_group_set_height(box, row_height)

      if index + 1 == next_row_index {
        let new_width = broadest_row - xpos - padding_value.right
        let old_width = box_layout_provider_group_get_width(box)
        box = box_layout_provider_group_set_width(box, new_width)
        box = box_layout_provider_group_translate_inner_nodes(
          box,
          (new_width - old_width) / 2.0,
          0.0,
        )
      }

      xpos = xpos + box_layout_provider_group_get_width(box) + min_spacing
      updated_group.groups[index] = box
      index = index + 1
    }
  }

  (updated_group, new_kvector_xy(broadest_row, total_height))
}

///|
fn box_layout_provider_merge_and_place_dec(
  groups : Array[BoxGroup],
  obj_spacing : Double,
  min_width : Double,
  min_height : Double,
  expand_nodes_value : Bool,
  aspect_ratio_value : Double,
) -> Array[BoxGroup] {
  ignore(aspect_ratio_value)

  let sorted_groups = box_layout_provider_copy_groups(groups)
  box_layout_provider_sort_groups(sorted_groups, true)

  let to_be_placed = []
  let maybe_group = []
  let mut box_to_beat : BoxGroup? = None
  let mut collected_area = 0.0

  let mut queue_index = 0
  while queue_index < sorted_groups.length() {
    let box = sorted_groups[queue_index]
    queue_index = queue_index + 1

    let should_place_alone = if box_to_beat is Some(beat) {
      box_layout_provider_group_area(beat) / 2.0 <
      box_layout_provider_group_area(box)
    } else {
      true
    }

    if should_place_alone {
      box_to_beat = Some(box)
      to_be_placed.push(box)
    } else {
      collected_area = collected_area + box_layout_provider_group_area(box)
      maybe_group.push(box)

      if maybe_group.length() > 1 {
        let beat = match box_to_beat {
          Some(value) => value
          None => abort("boxToBeat should be defined")
        }
        if collected_area > box_layout_provider_group_area(beat) / 2.0 ||
          queue_index >= sorted_groups.length() {
          let inner_group = box_layout_provider_new_group_from_groups(
            maybe_group,
          )
          let inner_aspect_ratio = box_layout_provider_group_get_width(beat) /
            box_layout_provider_group_get_height(beat)
          let (placed_inner_group, group_size) = box_layout_provider_place_inner_boxes(
            inner_group,
            obj_spacing,
            new_elk_padding(),
            min_width,
            min_height,
            expand_nodes_value,
            inner_aspect_ratio,
          )
          let updated_inner_group = placed_inner_group
          updated_inner_group.size.x = group_size.x
          updated_inner_group.size.y = group_size.y

          box_to_beat = Some(updated_inner_group)
          to_be_placed.push(updated_inner_group)

          collected_area = 0.0
          maybe_group.clear()
        }
      }
    }
  }

  for group in maybe_group {
    to_be_placed.push(group)
  }
  to_be_placed
}

///|
fn box_layout_provider_merge_and_place_mixed(
  groups : Array[BoxGroup],
  obj_spacing : Double,
  min_width : Double,
  min_height : Double,
  expand_nodes_value : Bool,
  aspect_ratio_value : Double,
) -> Array[BoxGroup] {
  ignore(aspect_ratio_value)

  let cum_area_array = []
  for _ in 0..<groups.length() {
    cum_area_array.push(0.0)
  }

  let pq = box_layout_provider_copy_groups(groups)
  let to_be_placed = []
  let mut index = 0

  while !pq.is_empty() {
    box_layout_provider_sort_groups(pq, false)
    let box = pq[0]

    if index > 1 &&
      box_layout_provider_group_area(box) / 2.0 > cum_area_array[0] {
      let mut an_index = 0
      while an_index < to_be_placed.length() - 1 &&
            box_layout_provider_group_area(box) / 2.0 > cum_area_array[an_index] {
        an_index = an_index + 1
      }

      let select = box_layout_provider_copy_group_range(
        to_be_placed,
        0,
        an_index + 1,
      )
      let inner_group = box_layout_provider_new_group_from_groups(select)
      let inner_aspect_ratio = box_layout_provider_group_get_width(box) /
        box_layout_provider_group_get_height(box)

      let (placed_inner_group, group_size) = box_layout_provider_place_inner_boxes(
        inner_group,
        obj_spacing,
        new_elk_padding(),
        min_width,
        min_height,
        expand_nodes_value,
        inner_aspect_ratio,
      )
      let updated_inner_group = placed_inner_group
      updated_inner_group.size.x = group_size.x
      updated_inner_group.size.y = group_size.y

      pq.push(updated_inner_group)
      let mut remain_index = an_index + 1
      while remain_index < to_be_placed.length() {
        pq.push(to_be_placed[remain_index])
        remain_index = remain_index + 1
      }

      to_be_placed.clear()
      index = 0
      for reset_index in 0..<cum_area_array.length() {
        cum_area_array[reset_index] = 0.0
      }
    } else {
      ignore(pq.remove(0))

      if index > 0 {
        cum_area_array[index] = cum_area_array[index - 1]
      }
      cum_area_array[index] = cum_area_array[index] +
        box_layout_provider_group_area(box)
      index = index + 1
      to_be_placed.push(box)
    }
  }

  to_be_placed
}

///|
fn box_layout_provider_merge_and_place_inc(
  groups : Array[BoxGroup],
  obj_spacing : Double,
  min_width : Double,
  min_height : Double,
  expand_nodes_value : Bool,
  aspect_ratio_value : Double,
) -> Array[BoxGroup] {
  ignore(aspect_ratio_value)

  let sorted_groups = box_layout_provider_copy_groups(groups)
  box_layout_provider_sort_groups(sorted_groups, false)

  let to_be_placed = []
  let mut common_area = 0.0

  for group in sorted_groups {
    if !to_be_placed.is_empty() &&
      box_layout_provider_group_area(group) > common_area * 2.0 {
      let merged = box_layout_provider_new_group_from_groups(to_be_placed)
      let inner_aspect_ratio = box_layout_provider_group_get_width(group) /
        box_layout_provider_group_get_height(group)

      let (placed_group, group_size) = box_layout_provider_place_inner_boxes(
        merged,
        obj_spacing,
        new_elk_padding(),
        min_width,
        min_height,
        expand_nodes_value,
        inner_aspect_ratio,
      )
      let updated_group = placed_group
      updated_group.size.x = group_size.x
      updated_group.size.y = group_size.y

      to_be_placed.clear()
      common_area = 0.0

      to_be_placed.push(updated_group)
      to_be_placed.push(group)
      common_area = box_layout_provider_group_area(updated_group) +
        box_layout_provider_group_area(group)
    } else {
      to_be_placed.push(group)
      common_area = common_area + box_layout_provider_group_area(group)
    }
  }

  to_be_placed
}

///|
fn box_layout_provider_place_boxes_grouping(
  parent_node : @graph.ElkNode,
  obj_spacing : Double,
  padding_value : ElkPadding,
  expand_nodes_value : Bool,
) -> Unit {
  let min_size = new_kvector()
  min_size.parse(
    @graph.node_get_string_property(parent_node, node_size_minimum),
  )
  min_size.x = box_layout_provider_max(
    min_size.x - padding_value.left - padding_value.right,
    0.0,
  )
  min_size.y = box_layout_provider_max(
    min_size.y - padding_value.top - padding_value.bottom,
    0.0,
  )

  let configured_aspect_ratio = @graph.node_get_double_property(
    parent_node, aspect_ratio,
  )
  let aspect_ratio_value = if configured_aspect_ratio <= 0.0 {
    box_layout_provider_def_aspect_ratio
  } else {
    configured_aspect_ratio
  }

  let groups = []
  for node in @graph.node_children(parent_node) {
    groups.push(box_layout_provider_new_group_from_node(node))
  }

  let mode = box_layout_provider_mode_from_string(
    @graph.node_get_string_property(parent_node, box_packing_mode),
  )

  let to_be_placed = match mode {
    GROUP_INC =>
      box_layout_provider_merge_and_place_inc(
        groups,
        obj_spacing,
        min_size.x,
        min_size.y,
        expand_nodes_value,
        aspect_ratio_value,
      )
    GROUP_DEC =>
      box_layout_provider_merge_and_place_dec(
        groups,
        obj_spacing,
        min_size.x,
        min_size.y,
        expand_nodes_value,
        aspect_ratio_value,
      )
    GROUP_MIXED =>
      box_layout_provider_merge_and_place_mixed(
        groups,
        obj_spacing,
        min_size.x,
        min_size.y,
        expand_nodes_value,
        aspect_ratio_value,
      )
    SIMPLE =>
      box_layout_provider_merge_and_place_mixed(
        groups,
        obj_spacing,
        min_size.x,
        min_size.y,
        expand_nodes_value,
        aspect_ratio_value,
      )
  }

  let final_group = box_layout_provider_new_group_from_groups(to_be_placed)
  let (placed_final_group, parent_size) = box_layout_provider_place_inner_boxes(
    final_group,
    obj_spacing,
    padding_value,
    min_size.x,
    min_size.y,
    expand_nodes_value,
    aspect_ratio_value,
  )
  ignore(placed_final_group)

  ignore(
    box_layout_provider_resize_node(
      parent_node,
      parent_size.x,
      parent_size.y,
      false,
      true,
    ),
  )
}

///|
pub fn new_box_layout_provider() -> BoxLayoutProvider {
  { initialized: true }
}

///|
pub fn BoxLayoutProvider::layout(
  self : BoxLayoutProvider,
  layout_node : @graph.ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  ignore(self.initialized)
  ignore(progress_monitor.begin("Box layout", 2.0))

  let obj_spacing = @graph.node_get_double_property(
    layout_node, spacing_node_node,
  )
  let padding_value = box_layout_provider_parse_padding(layout_node)
  let expand_nodes_value = @graph.node_get_bool_property(
    layout_node, expand_nodes,
  )
  let interactive_mode = @graph.node_get_bool_property(layout_node, interactive)

  let mode = box_layout_provider_mode_from_string(
    @graph.node_get_string_property(layout_node, box_packing_mode),
  )

  match mode {
    SIMPLE =>
      box_layout_provider_place_boxes(
        layout_node, obj_spacing, padding_value, expand_nodes_value, interactive_mode,
      )
    _ =>
      box_layout_provider_place_boxes_grouping(
        layout_node, obj_spacing, padding_value, expand_nodes_value,
      )
  }

  progress_monitor.done()
}

///|
pub fn box_layout_provider_as_layout_provider(
  provider : BoxLayoutProvider,
) -> AbstractLayoutProvider {
  new_abstract_layout_provider((graph, monitor) => {
    provider.layout(graph, monitor)
  })
}
