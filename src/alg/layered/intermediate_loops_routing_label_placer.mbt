///|
priv suberror LabelPlacerException {
  IllegalStateException(String)
} derive(Debug, ToJson)

///|
fn[T] label_placer_raise_illegal_state(
  message : String,
) -> T raise LabelPlacerException {
  raise LabelPlacerException::IllegalStateException(message)
}

///|
fn label_placer_exception_message(error : LabelPlacerException) -> String {
  match error {
    LabelPlacerException::IllegalStateException(message) => message
  }
}

///|
fn label_placer_port_side_equals(
  left : @core.PortSide,
  right : @core.PortSide,
) -> Bool {
  match (left, right) {
    (@core.PortSide::SideUndefined, @core.PortSide::SideUndefined) => true
    (North, North) => true
    (East, East) => true
    (South, South) => true
    (West, West) => true
    _ => false
  }
}

///|
fn label_placer_parse_ordering(value : String) -> SelfLoopOrderingStrategy {
  match value {
    "STACKED" => SelfLoopOrderingStrategy::Stacked
    "REVERSE_STACKED" => SelfLoopOrderingStrategy::ReverseStacked
    "SEQUENCED" => SelfLoopOrderingStrategy::Sequenced
    _ => SelfLoopOrderingStrategy::Stacked
  }
}

///|
fn label_placer_ordering_equals(
  left : SelfLoopOrderingStrategy,
  right : SelfLoopOrderingStrategy,
) -> Bool {
  match (left, right) {
    (SelfLoopOrderingStrategy::Stacked, SelfLoopOrderingStrategy::Stacked) =>
      true
    (
      SelfLoopOrderingStrategy::ReverseStacked,
      SelfLoopOrderingStrategy::ReverseStacked,
    ) => true
    (SelfLoopOrderingStrategy::Sequenced, SelfLoopOrderingStrategy::Sequenced) =>
      true
    _ => false
  }
}

///|
fn label_placer_require_labels(
  sl_loop : SelfHyperLoop,
) -> SelfHyperLoopLabels raise LabelPlacerException {
  match sl_loop.get_sl_labels() {
    Some(labels) => labels
    None => label_placer_raise_illegal_state("self loop has no labels")
  }
}

///|
fn label_placer_require_leftmost(
  sl_loop : SelfHyperLoop,
) -> SelfLoopPort raise LabelPlacerException {
  match sl_loop.get_leftmost_port() {
    Some(port) => port
    None => label_placer_raise_illegal_state("self loop has no leftmost port")
  }
}

///|
fn label_placer_require_rightmost(
  sl_loop : SelfHyperLoop,
) -> SelfLoopPort raise LabelPlacerException {
  match sl_loop.get_rightmost_port() {
    Some(port) => port
    None => label_placer_raise_illegal_state("self loop has no rightmost port")
  }
}

///|
fn label_placer_require_alignment_reference(
  sl_labels : SelfHyperLoopLabels,
) -> SelfLoopPort raise LabelPlacerException {
  match sl_labels.get_alignment_reference_sl_port() {
    Some(port) => port
    None => label_placer_raise_illegal_state("missing alignment reference port")
  }
}

///|
fn label_placer_side_and_alignment(
  sl_loop : SelfHyperLoop,
  side : @core.PortSide,
  alignment : SelfHyperLoopLabelAlignment,
  alignment_reference : SelfLoopPort?,
) -> Unit raise LabelPlacerException {
  let sl_labels = label_placer_require_labels(sl_loop)
  sl_labels.set_side(side)
  sl_labels.set_alignment(alignment)
  sl_labels.set_alignment_reference_sl_port(alignment_reference)
}

///|
fn label_placer_clear_inline_property(
  sl_loop : SelfHyperLoop,
) -> Unit raise LabelPlacerException {
  for label in label_placer_require_labels(sl_loop).get_l_labels() {
    label.set_property_bool(@core.edge_labels_inline, false)
  }
}

///|
fn label_placer_has_inline_labels(
  sl_loop : SelfHyperLoop,
) -> Bool raise LabelPlacerException {
  for label in label_placer_require_labels(sl_loop).get_l_labels() {
    if label.get_property_bool(@core.edge_labels_inline) {
      return true
    }
  }
  false
}

///|
pub struct LabelPlacer {
  _reserved : Int
}

///|
pub fn new_label_placer() -> LabelPlacer {
  { _reserved: 0 }
}

///|
fn label_placer_sort_loops_by_leftmost_id(
  sl_loops : Array[SelfHyperLoop],
  ascending : Bool,
) -> Unit raise LabelPlacerException {
  let mut i = 1
  while i < sl_loops.length() {
    let mut j = i
    while j > 0 {
      let left_id = label_placer_require_leftmost(sl_loops[j - 1])
        .get_l_port()
        .get_id()
      let right_id = label_placer_require_leftmost(sl_loops[j])
        .get_l_port()
        .get_id()
      let should_swap = if ascending {
        left_id > right_id
      } else {
        left_id < right_id
      }
      if !should_swap {
        break
      }
      let temp = sl_loops[j - 1]
      sl_loops[j - 1] = sl_loops[j]
      sl_loops[j] = temp
      j -= 1
    }
    i += 1
  }
}

///|
fn LabelPlacer::assign_one_sided_simple_side_and_alignment(
  self : LabelPlacer,
  sl_loop : SelfHyperLoop,
  loop_side : @core.PortSide,
) -> Unit raise LabelPlacerException {
  ignore(self)
  label_placer_clear_inline_property(sl_loop)
  match loop_side {
    East => {
      let mut topmost_port = label_placer_require_leftmost(sl_loop)
      if label_placer_require_rightmost(sl_loop).get_l_port().get_position().y <
        topmost_port.get_l_port().get_position().y {
        topmost_port = label_placer_require_rightmost(sl_loop)
      }
      label_placer_side_and_alignment(
        sl_loop,
        loop_side,
        SelfHyperLoopLabelAlignment::Top,
        Some(topmost_port),
      )
    }
    West => {
      let mut topmost_port = label_placer_require_leftmost(sl_loop)
      if label_placer_require_rightmost(sl_loop).get_l_port().get_position().y <
        topmost_port.get_l_port().get_position().y {
        topmost_port = label_placer_require_rightmost(sl_loop)
      }
      label_placer_side_and_alignment(
        sl_loop,
        loop_side,
        SelfHyperLoopLabelAlignment::Top,
        Some(topmost_port),
      )
    }
    North =>
      label_placer_side_and_alignment(
        sl_loop,
        loop_side,
        SelfHyperLoopLabelAlignment::Center,
        None,
      )
    South =>
      label_placer_side_and_alignment(
        sl_loop,
        loop_side,
        SelfHyperLoopLabelAlignment::Center,
        None,
      )
    @core.PortSide::SideUndefined =>
      label_placer_raise_illegal_state("one-sided loop side undefined")
  }
}

///|
fn LabelPlacer::assign_one_sided_sequenced_side_and_alignment(
  self : LabelPlacer,
  sl_loops : Array[SelfHyperLoop],
  port_side : @core.PortSide,
) -> Unit raise LabelPlacerException {
  ignore(self)
  if sl_loops.is_empty() {
    return
  }

  let mut id = 0
  for l_port in sl_loops[0].get_sl_holder().get_l_node().get_ports() {
    l_port.set_id(id)
    id += 1
  }

  if label_placer_port_side_equals(port_side, North) {
    label_placer_sort_loops_by_leftmost_id(sl_loops, true)
  } else {
    label_placer_sort_loops_by_leftmost_id(sl_loops, false)
  }

  let mut left_loop_index = 0
  let mut right_loop_index = sl_loops.length() - 1

  while left_loop_index < right_loop_index {
    let left_loop = sl_loops[left_loop_index]
    let right_loop = sl_loops[right_loop_index]

    let left_loop_alignment_reference = if label_placer_port_side_equals(
        port_side,
        North,
      ) {
      label_placer_require_rightmost(left_loop)
    } else {
      label_placer_require_leftmost(left_loop)
    }
    let right_loop_alignment_reference = if label_placer_port_side_equals(
        port_side,
        North,
      ) {
      label_placer_require_leftmost(right_loop)
    } else {
      label_placer_require_rightmost(right_loop)
    }

    label_placer_side_and_alignment(
      left_loop,
      port_side,
      SelfHyperLoopLabelAlignment::Right,
      Some(left_loop_alignment_reference),
    )
    label_placer_side_and_alignment(
      right_loop,
      port_side,
      SelfHyperLoopLabelAlignment::Left,
      Some(right_loop_alignment_reference),
    )

    left_loop_index += 1
    right_loop_index -= 1
  }

  if left_loop_index == right_loop_index {
    label_placer_side_and_alignment(
      sl_loops[left_loop_index],
      port_side,
      SelfHyperLoopLabelAlignment::Center,
      None,
    )
  }
}

///|
fn LabelPlacer::assign_two_sides_corner_side_and_alignment(
  self : LabelPlacer,
  sl_loop : SelfHyperLoop,
) -> Unit raise LabelPlacerException {
  ignore(self)
  let leftmost_port_side = label_placer_require_leftmost(sl_loop)
    .get_l_port()
    .get_side()
  let rightmost_port_side = label_placer_require_rightmost(sl_loop)
    .get_l_port()
    .get_side()

  label_placer_clear_inline_property(sl_loop)

  if label_placer_port_side_equals(leftmost_port_side, North) {
    label_placer_side_and_alignment(
      sl_loop,
      North,
      SelfHyperLoopLabelAlignment::Left,
      Some(label_placer_require_leftmost(sl_loop)),
    )
  } else if label_placer_port_side_equals(rightmost_port_side, North) {
    label_placer_side_and_alignment(
      sl_loop,
      North,
      SelfHyperLoopLabelAlignment::Right,
      Some(label_placer_require_rightmost(sl_loop)),
    )
  } else if label_placer_port_side_equals(leftmost_port_side, South) {
    label_placer_side_and_alignment(
      sl_loop,
      South,
      SelfHyperLoopLabelAlignment::Right,
      Some(label_placer_require_leftmost(sl_loop)),
    )
  } else if label_placer_port_side_equals(rightmost_port_side, South) {
    label_placer_side_and_alignment(
      sl_loop,
      South,
      SelfHyperLoopLabelAlignment::Left,
      Some(label_placer_require_rightmost(sl_loop)),
    )
  }
}

///|
fn label_placer_has_side(
  sides : Array[@core.PortSide],
  side : @core.PortSide,
) -> Bool {
  for existing in sides {
    if label_placer_port_side_equals(existing, side) {
      return true
    }
  }
  false
}

///|
fn LabelPlacer::assign_two_sides_opposing_and_three_sides_side_and_alignment(
  self : LabelPlacer,
  sl_loop : SelfHyperLoop,
) -> Unit raise LabelPlacerException {
  ignore(self)
  let occupied_sides = sl_loop.get_occupied_port_sides()
  let has_inline_labels = label_placer_has_inline_labels(sl_loop)

  if !label_placer_has_side(occupied_sides, North) {
    label_placer_side_and_alignment(
      sl_loop,
      South,
      SelfHyperLoopLabelAlignment::Center,
      None,
    )
  } else if !label_placer_has_side(occupied_sides, South) {
    label_placer_side_and_alignment(
      sl_loop,
      North,
      SelfHyperLoopLabelAlignment::Center,
      None,
    )
  } else if !label_placer_has_side(occupied_sides, West) {
    if has_inline_labels {
      label_placer_side_and_alignment(
        sl_loop,
        East,
        SelfHyperLoopLabelAlignment::Center,
        None,
      )
    } else {
      label_placer_side_and_alignment(
        sl_loop,
        North,
        SelfHyperLoopLabelAlignment::Left,
        Some(label_placer_require_leftmost(sl_loop)),
      )
    }
  } else if !label_placer_has_side(occupied_sides, East) {
    if has_inline_labels {
      label_placer_side_and_alignment(
        sl_loop,
        West,
        SelfHyperLoopLabelAlignment::Center,
        None,
      )
    } else {
      label_placer_side_and_alignment(
        sl_loop,
        North,
        SelfHyperLoopLabelAlignment::Right,
        Some(label_placer_require_rightmost(sl_loop)),
      )
    }
  }
}

///|
fn LabelPlacer::assign_four_sides_side_and_alignment(
  self : LabelPlacer,
  sl_loop : SelfHyperLoop,
) -> Unit raise LabelPlacerException {
  ignore(self)
  let leftmost_port_side = label_placer_require_leftmost(sl_loop)
    .get_l_port()
    .get_side()
  let rightmost_port_side = label_placer_require_leftmost(sl_loop)
    .get_l_port()
    .get_side()

  label_placer_clear_inline_property(sl_loop)

  if label_placer_port_side_equals(leftmost_port_side, North) ||
    label_placer_port_side_equals(rightmost_port_side, North) {
    label_placer_side_and_alignment(
      sl_loop,
      South,
      SelfHyperLoopLabelAlignment::Center,
      None,
    )
  } else {
    label_placer_side_and_alignment(
      sl_loop,
      North,
      SelfHyperLoopLabelAlignment::Center,
      None,
    )
  }
}

///|
fn LabelPlacer::assign_side_and_alignment(
  self : LabelPlacer,
  sl_holder : SelfLoopHolder,
) -> Unit raise LabelPlacerException {
  let ordering_strategy = label_placer_parse_ordering(
    sl_holder
    .get_l_node()
    .get_property_string(layered_options_edge_routing_self_loop_ordering),
  )
  let northern_one_sided = []
  let southern_one_sided = []
  let use_sequenced = label_placer_ordering_equals(
    ordering_strategy,
    SelfLoopOrderingStrategy::Sequenced,
  )

  for sl_loop in sl_holder.get_sl_hyper_loops() {
    match sl_loop.get_sl_labels() {
      Some(sl_labels) => if sl_labels.get_l_labels().is_empty() { continue }
      None => continue
    }

    match sl_loop.get_self_loop_type() {
      Some(OneSide) => {
        let loop_side = sl_loop.get_occupied_port_sides()[0]
        if use_sequenced && label_placer_port_side_equals(loop_side, North) {
          northern_one_sided.push(sl_loop)
        } else if use_sequenced &&
          label_placer_port_side_equals(loop_side, South) {
          southern_one_sided.push(sl_loop)
        } else {
          self.assign_one_sided_simple_side_and_alignment(sl_loop, loop_side)
        }
      }
      Some(TwoSidesCorner) =>
        self.assign_two_sides_corner_side_and_alignment(sl_loop)
      Some(TwoSidesOpposing) =>
        self.assign_two_sides_opposing_and_three_sides_side_and_alignment(
          sl_loop,
        )
      Some(ThreeSides) =>
        self.assign_two_sides_opposing_and_three_sides_side_and_alignment(
          sl_loop,
        )
      Some(FourSides) => self.assign_four_sides_side_and_alignment(sl_loop)
      None => ()
    }
  }

  if !northern_one_sided.is_empty() {
    self.assign_one_sided_sequenced_side_and_alignment(
      northern_one_sided,
      North,
    )
  }
  if !southern_one_sided.is_empty() {
    self.assign_one_sided_sequenced_side_and_alignment(
      southern_one_sided,
      South,
    )
  }
}

///|
fn LabelPlacer::manage_labels(
  self : LabelPlacer,
  sl_loop : SelfHyperLoop,
  label_manager : @core.ILabelManager,
) -> Unit raise LabelPlacerException {
  ignore(self)
  let sl_labels = label_placer_require_labels(sl_loop)
  let l_node = sl_loop.get_sl_holder().get_l_node()
  let l_node_size = l_node.get_size()
  let l_node_margin = l_node.get_margin()

  let mut target_width = 0.0
  match sl_labels.get_alignment() {
    Some(SelfHyperLoopLabelAlignment::Center) =>
      target_width = l_node_margin.left + l_node_size.x + l_node_margin.right
    Some(SelfHyperLoopLabelAlignment::Left) => {
      let align_ref = label_placer_require_alignment_reference(sl_labels)
      target_width = l_node_size.x -
        align_ref.get_l_port().get_position().x -
        align_ref.get_l_port().get_anchor().x +
        l_node_margin.right
    }
    Some(SelfHyperLoopLabelAlignment::Right) => {
      let align_ref = label_placer_require_alignment_reference(sl_labels)
      target_width = l_node_margin.left +
        align_ref.get_l_port().get_position().x +
        align_ref.get_l_port().get_anchor().x
    }
    Some(SelfHyperLoopLabelAlignment::Top) =>
      target_width = label_management_processor_min_width_edge_labels
    None => ()
  }

  if target_width < label_management_processor_min_width_edge_labels {
    target_width = label_management_processor_min_width_edge_labels
  }
  sl_labels.apply_label_management(label_manager, target_width)
}

///|
fn LabelPlacer::compute_coordinates(
  self : LabelPlacer,
  sl_loop : SelfHyperLoop,
) -> Unit raise LabelPlacerException {
  ignore(self)
  let sl_labels = label_placer_require_labels(sl_loop)
  let size = sl_labels.get_size()
  let pos = sl_labels.get_position()

  match sl_labels.get_alignment() {
    Some(SelfHyperLoopLabelAlignment::Center) =>
      pos.x = (sl_loop.get_sl_holder().get_l_node().get_size().x - size.x) / 2.0
    Some(SelfHyperLoopLabelAlignment::Left) => {
      let align_ref = label_placer_require_alignment_reference(sl_labels)
      pos.x = align_ref.get_l_port().get_position().x +
        align_ref.get_l_port().get_anchor().x
    }
    Some(SelfHyperLoopLabelAlignment::Right) => {
      let align_ref = label_placer_require_alignment_reference(sl_labels)
      pos.x = align_ref.get_l_port().get_position().x +
        align_ref.get_l_port().get_anchor().x -
        size.x
    }
    Some(SelfHyperLoopLabelAlignment::Top) => {
      let align_ref = label_placer_require_alignment_reference(sl_labels)
      pos.y = align_ref.get_l_port().get_position().y +
        align_ref.get_l_port().get_anchor().y
    }
    None => ()
  }
}

///|
pub fn LabelPlacer::place_labels(
  self : LabelPlacer,
  sl_holder : SelfLoopHolder,
  label_manager : @core.ILabelManager?,
  monitor : @core.IElkProgressMonitor?,
) -> Unit {
  ignore(monitor)
  try {
    self.assign_side_and_alignment(sl_holder)
    for sl_loop in sl_holder.get_sl_hyper_loops() {
      if sl_loop.get_sl_labels() is Some(_) {
        if label_manager is Some(manager) {
          self.manage_labels(sl_loop, manager)
        }
        self.compute_coordinates(sl_loop)
      }
    }
  } catch {
    error =>
      @core.layout_runtime_report_unsupported_configuration(
        label_placer_exception_message(error),
      )
  }
}
