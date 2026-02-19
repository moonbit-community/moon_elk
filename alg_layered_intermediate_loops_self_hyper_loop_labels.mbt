///|
pub enum SelfHyperLoopLabelAlignment {
  Center
  Left
  Right
  Top
}

///|
pub struct SelfHyperLoopLabels {
  mut id : Int
  l_labels : Array[LLabel]
  size : KVector
  position : KVector
  layout_direction : Direction
  label_label_spacing : Double
  mut side : PortSide?
  mut alignment : SelfHyperLoopLabelAlignment?
  mut alignment_reference_sl_port : SelfLoopPort?
}

///|
fn self_hyper_loop_labels_layout_direction(
  sl_loop : SelfHyperLoop,
) -> Direction {
  let l_node = sl_loop.get_sl_holder().get_l_node()
  l_node.get_graph().get_property_direction(layered_components_direction)
}

///|
fn self_hyper_loop_labels_spacing(sl_loop : SelfHyperLoop) -> Double {
  let l_node = sl_loop.get_sl_holder().get_l_node()
  get_individual_or_inherited(l_node, spacing_label_label)
}

///|
pub fn new_self_hyper_loop_labels(
  sl_loop : SelfHyperLoop,
) -> SelfHyperLoopLabels {
  {
    id: 0,
    l_labels: [],
    size: new_kvector(),
    position: new_kvector(),
    layout_direction: self_hyper_loop_labels_layout_direction(sl_loop),
    label_label_spacing: self_hyper_loop_labels_spacing(sl_loop),
    side: None,
    alignment: None,
    alignment_reference_sl_port: None,
  }
}

///|
pub fn SelfHyperLoopLabels::get_id(self : SelfHyperLoopLabels) -> Int {
  self.id
}

///|
pub fn SelfHyperLoopLabels::set_id(
  self : SelfHyperLoopLabels,
  id : Int,
) -> Unit {
  self.id = id
}

///|
fn self_hyper_loop_labels_update_size(
  labels : SelfHyperLoopLabels,
  new_label : LLabel,
) -> Unit {
  let label_size = new_label.get_size()

  if labels.layout_direction.is_horizontal() {
    if labels.size.x < label_size.x {
      labels.size.x = label_size.x
    }
    labels.size.y += label_size.y
    if labels.l_labels.length() > 1 {
      labels.size.y += labels.label_label_spacing
    }
  } else {
    labels.size.x += label_size.x
    if labels.size.y < label_size.y {
      labels.size.y = label_size.y
    }
    if labels.l_labels.length() > 1 {
      labels.size.x += labels.label_label_spacing
    }
  }
}

///|
pub fn SelfHyperLoopLabels::add_l_labels(
  self : SelfHyperLoopLabels,
  new_l_labels : Array[LLabel],
) -> Unit {
  for new_label in new_l_labels {
    self.l_labels.push(new_label)
    self_hyper_loop_labels_update_size(self, new_label)
  }
}

///|
pub fn SelfHyperLoopLabels::get_l_labels(
  self : SelfHyperLoopLabels,
) -> Array[LLabel] {
  self.l_labels
}

///|
pub fn SelfHyperLoopLabels::apply_label_management(
  self : SelfHyperLoopLabels,
  label_manager : ILabelManager,
  target_width : Double,
) -> Unit {
  let managed_size = label_management_processor_do_manage_labels(
    label_manager,
    self.l_labels,
    target_width,
    self.label_label_spacing,
    self.layout_direction.is_vertical(),
  )
  ignore(self.size.set(managed_size))
}

///|
fn self_hyper_loop_labels_apply_horizontal_layout(
  labels : SelfHyperLoopLabels,
  offset : KVector,
) -> Unit {
  let x = labels.position.x
  let mut y = labels.position.y

  for l_label in labels.l_labels {
    let label_pos = l_label.get_position()
    let label_size = l_label.get_size()

    match (labels.alignment, labels.side) {
      (Some(SelfHyperLoopLabelAlignment::Left), _) => label_pos.x = x
      (_, Some(East)) => label_pos.x = x
      (Some(SelfHyperLoopLabelAlignment::Right), _) =>
        label_pos.x = x + labels.size.x - label_size.x
      (_, Some(West)) => label_pos.x = x + labels.size.x - label_size.x
      _ => label_pos.x = x + (labels.size.x - label_size.x) / 2.0
    }

    label_pos.y = y
    ignore(label_pos.add(offset))
    y += label_size.y + labels.label_label_spacing
  }
}

///|
fn self_hyper_loop_labels_apply_vertical_layout(
  labels : SelfHyperLoopLabels,
  offset : KVector,
) -> Unit {
  let mut x = labels.position.x
  let y = labels.position.y

  for l_label in labels.l_labels {
    let label_pos = l_label.get_position()
    let label_size = l_label.get_size()

    label_pos.x = x

    match labels.side {
      Some(North) => label_pos.y = y + labels.size.y - label_size.y
      _ => label_pos.y = y
    }

    ignore(label_pos.add(offset))
    x += label_size.x + labels.label_label_spacing
  }
}

///|
pub fn SelfHyperLoopLabels::apply_placement(
  self : SelfHyperLoopLabels,
  offset : KVector,
) -> Unit {
  if self.layout_direction.is_horizontal() {
    self_hyper_loop_labels_apply_horizontal_layout(self, offset)
  } else {
    self_hyper_loop_labels_apply_vertical_layout(self, offset)
  }
}

///|
pub fn SelfHyperLoopLabels::get_size(self : SelfHyperLoopLabels) -> KVector {
  self.size
}

///|
pub fn SelfHyperLoopLabels::get_position(self : SelfHyperLoopLabels) -> KVector {
  self.position
}

///|
pub fn SelfHyperLoopLabels::get_side(self : SelfHyperLoopLabels) -> PortSide {
  match self.side {
    Some(side) => side
    None => SideUndefined
  }
}

///|
pub fn SelfHyperLoopLabels::set_side(
  self : SelfHyperLoopLabels,
  side : PortSide,
) -> Unit {
  self.side = Some(side)
}

///|
pub fn SelfHyperLoopLabels::get_alignment(
  self : SelfHyperLoopLabels,
) -> SelfHyperLoopLabelAlignment? {
  self.alignment
}

///|
pub fn SelfHyperLoopLabels::set_alignment(
  self : SelfHyperLoopLabels,
  alignment : SelfHyperLoopLabelAlignment,
) -> Unit {
  self.alignment = Some(alignment)
}

///|
pub fn SelfHyperLoopLabels::get_alignment_reference_sl_port(
  self : SelfHyperLoopLabels,
) -> SelfLoopPort? {
  self.alignment_reference_sl_port
}

///|
pub fn SelfHyperLoopLabels::set_alignment_reference_sl_port(
  self : SelfHyperLoopLabels,
  alignment_reference_sl_port : SelfLoopPort?,
) -> Unit {
  self.alignment_reference_sl_port = alignment_reference_sl_port
}
