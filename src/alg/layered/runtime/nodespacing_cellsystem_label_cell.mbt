///|
pub type LabelCell = Cell

///|
fn label_cell_max(left : Double, right : Double) -> Double {
  if left >= right {
    left
  } else {
    right
  }
}

///|
fn label_cell_labels(cell : LabelCell) -> Array[@graph.ElkLabel] {
  match cell.labels {
    Some(labels) => labels
    None => {
      let labels = []
      cell.labels = Some(labels)
      labels
    }
  }
}

///|
fn label_cell_l_labels(cell : LabelCell) -> Array[LLabelAdapter] {
  match cell.l_labels {
    Some(labels) => labels
    None => {
      let labels = []
      cell.l_labels = Some(labels)
      labels
    }
  }
}

///|
fn label_cell_content_area_size(cell : LabelCell) -> @core.KVector {
  match cell.minimum_content_area_size {
    Some(size) => size
    None => {
      let size = @core.new_kvector()
      cell.minimum_content_area_size = Some(size)
      size
    }
  }
}

///|
fn label_cell_horizontal_alignment_or_default(
  location : NodeLabelLocation,
) -> HorizontalLabelAlignment {
  match location.horizontal_alignment() {
    Some(alignment) => alignment
    None => Center
  }
}

///|
fn label_cell_vertical_alignment_or_default(
  location : NodeLabelLocation,
) -> VerticalLabelAlignment {
  match location.vertical_alignment() {
    Some(alignment) => alignment
    None => Center
  }
}

///|
pub fn new_label_cell(gap : Double) -> LabelCell {
  new_label_cell_with_layout_mode(gap, true)
}

///|
pub fn new_label_cell_with_layout_mode(
  gap : Double,
  horizontal_layout_mode : Bool,
) -> LabelCell {
  let cell = new_cell()
  cell.kind = LabelCellKind
  cell.label_horizontal_layout_mode = horizontal_layout_mode
  cell.label_horizontal_alignment = Center
  cell.label_vertical_alignment = Center
  cell.label_gap = gap
  cell.labels = Some([])
  cell.minimum_content_area_size = Some(@core.new_kvector())
  cell
}

///|
pub fn new_label_cell_with_node_label_location(
  gap : Double,
  node_label_location : NodeLabelLocation,
) -> LabelCell {
  new_label_cell_full(gap, node_label_location, true)
}

///|
pub fn new_label_cell_full(
  gap : Double,
  node_label_location : NodeLabelLocation,
  horizontal_layout_mode : Bool,
) -> LabelCell {
  let cell = new_label_cell_with_layout_mode(gap, horizontal_layout_mode)
  cell.label_horizontal_alignment = label_cell_horizontal_alignment_or_default(
    node_label_location,
  )
  cell.label_vertical_alignment = label_cell_vertical_alignment_or_default(
    node_label_location,
  )
  cell
}

///|
pub fn LabelCell::get_horizontal_alignment(
  self : LabelCell,
) -> HorizontalLabelAlignment {
  self.label_horizontal_alignment
}

///|
pub fn LabelCell::set_horizontal_alignment(
  self : LabelCell,
  new_horizontal_alignment : HorizontalLabelAlignment,
) -> LabelCell {
  self.label_horizontal_alignment = new_horizontal_alignment
  self
}

///|
pub fn LabelCell::get_vertical_alignment(
  self : LabelCell,
) -> VerticalLabelAlignment {
  self.label_vertical_alignment
}

///|
pub fn LabelCell::set_vertical_alignment(
  self : LabelCell,
  new_vertical_alignment : VerticalLabelAlignment,
) -> LabelCell {
  self.label_vertical_alignment = new_vertical_alignment
  self
}

///|
pub fn LabelCell::get_labels(self : LabelCell) -> Array[@graph.ElkLabel] {
  label_cell_labels(self)
}

///|
pub fn LabelCell::get_l_labels(self : LabelCell) -> Array[LLabelAdapter] {
  label_cell_l_labels(self)
}

///|
pub fn LabelCell::add_label(self : LabelCell, label : @graph.ElkLabel) -> Unit {
  let had_labels = self.label_count() > 0
  let labels = label_cell_labels(self)
  labels.push(label)

  let label_w = @graph.label_width(label)
  let label_h = @graph.label_height(label)
  let minimum_content_area_size = label_cell_content_area_size(self)

  if self.label_horizontal_layout_mode {
    minimum_content_area_size.x = label_cell_max(
      minimum_content_area_size.x,
      label_w,
    )
    minimum_content_area_size.y += label_h
    if had_labels {
      minimum_content_area_size.y += self.label_gap
    }
  } else {
    minimum_content_area_size.x += label_w
    minimum_content_area_size.y = label_cell_max(
      minimum_content_area_size.y,
      label_h,
    )
    if had_labels {
      minimum_content_area_size.x += self.label_gap
    }
  }
}

///|
pub fn LabelCell::add_l_label(self : LabelCell, label : LLabelAdapter) -> Unit {
  let had_labels = self.label_count() > 0
  let labels = label_cell_l_labels(self)
  labels.push(label)

  let label_w = label.get_size().x
  let label_h = label.get_size().y
  let minimum_content_area_size = label_cell_content_area_size(self)

  if self.label_horizontal_layout_mode {
    minimum_content_area_size.x = label_cell_max(
      minimum_content_area_size.x,
      label_w,
    )
    minimum_content_area_size.y += label_h
    if had_labels {
      minimum_content_area_size.y += self.label_gap
    }
  } else {
    minimum_content_area_size.x += label_w
    minimum_content_area_size.y = label_cell_max(
      minimum_content_area_size.y,
      label_h,
    )
    if had_labels {
      minimum_content_area_size.x += self.label_gap
    }
  }
}

///|
pub fn LabelCell::label_count(self : LabelCell) -> Int {
  label_cell_labels(self).length() + label_cell_l_labels(self).length()
}

///|
pub fn LabelCell::has_labels(self : LabelCell) -> Bool {
  self.label_count() > 0
}

///|
fn label_cell_apply_horizontal_mode_layout(cell : LabelCell) -> Unit {
  let cell_rectangle = cell.get_cell_rectangle()
  let cell_padding = cell.get_padding()
  let minimum_content_area_size = label_cell_content_area_size(cell)

  let mut y_pos = cell_rectangle.y
  match cell.label_vertical_alignment {
    Center =>
      y_pos += (cell_rectangle.height - minimum_content_area_size.y) / 2.0
    Bottom => y_pos += cell_rectangle.height - minimum_content_area_size.y
    _ => ()
  }

  for label in label_cell_labels(cell) {
    let label_w = @graph.label_width(label)
    let label_h = @graph.label_height(label)

    let label_y = y_pos
    y_pos += label_h + cell.label_gap

    let label_x = match cell.label_horizontal_alignment {
      Left => cell_rectangle.x + cell_padding.left
      Center =>
        cell_rectangle.x +
        cell_padding.left +
        (cell_rectangle.width - label_w) / 2.0
      Right =>
        cell_rectangle.x + cell_rectangle.width - cell_padding.right - label_w
    }

    @graph.label_set_location(label, label_x, label_y)
  }

  for label in label_cell_l_labels(cell) {
    let label_w = label.get_size().x
    let label_h = label.get_size().y

    let label_y = y_pos
    y_pos += label_h + cell.label_gap

    let label_x = match cell.label_horizontal_alignment {
      Left => cell_rectangle.x + cell_padding.left
      Center =>
        cell_rectangle.x +
        cell_padding.left +
        (cell_rectangle.width - label_w) / 2.0
      Right =>
        cell_rectangle.x + cell_rectangle.width - cell_padding.right - label_w
    }

    label.set_position(@core.new_kvector_xy(label_x, label_y))
  }
}

///|
fn label_cell_apply_vertical_mode_layout(cell : LabelCell) -> Unit {
  let cell_rectangle = cell.get_cell_rectangle()
  let cell_padding = cell.get_padding()
  let minimum_content_area_size = label_cell_content_area_size(cell)

  let mut x_pos = cell_rectangle.x
  match cell.label_horizontal_alignment {
    Center =>
      x_pos += (cell_rectangle.width - minimum_content_area_size.x) / 2.0
    Right => x_pos += cell_rectangle.width - minimum_content_area_size.x
    _ => ()
  }

  for label in label_cell_labels(cell) {
    let label_w = @graph.label_width(label)
    let label_h = @graph.label_height(label)

    let label_x = x_pos
    x_pos += label_w + cell.label_gap

    let label_y = match cell.label_vertical_alignment {
      Top => cell_rectangle.y + cell_padding.top
      Center =>
        cell_rectangle.y +
        cell_padding.top +
        (cell_rectangle.height - label_h) / 2.0
      Bottom =>
        cell_rectangle.y + cell_rectangle.height - cell_padding.bottom - label_h
    }

    @graph.label_set_location(label, label_x, label_y)
  }

  for label in label_cell_l_labels(cell) {
    let label_w = label.get_size().x
    let label_h = label.get_size().y

    let label_x = x_pos
    x_pos += label_w + cell.label_gap

    let label_y = match cell.label_vertical_alignment {
      Top => cell_rectangle.y + cell_padding.top
      Center =>
        cell_rectangle.y +
        cell_padding.top +
        (cell_rectangle.height - label_h) / 2.0
      Bottom =>
        cell_rectangle.y + cell_rectangle.height - cell_padding.bottom - label_h
    }

    label.set_position(@core.new_kvector_xy(label_x, label_y))
  }
}

///|
pub fn LabelCell::apply_label_layout(self : LabelCell) -> Unit {
  if self.label_horizontal_layout_mode {
    label_cell_apply_horizontal_mode_layout(self)
  } else {
    label_cell_apply_vertical_mode_layout(self)
  }
}
