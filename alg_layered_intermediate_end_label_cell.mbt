///|
pub struct EndLabelCellLabel {
  elk_label : ElkLabel
  l_label : LLabel
}

///|
pub fn new_end_label_cell_label(
  elk_label : ElkLabel,
  l_label : LLabel,
) -> EndLabelCellLabel {
  { elk_label, l_label }
}

///|
pub struct EndLabelCell {
  label_cell : LabelCell
  label_side : LabelSide
  labels : Array[EndLabelCellLabel]
}

///|
pub fn new_end_label_cell(
  label_gap : Double,
  horizontal_layout_mode : Bool,
  label_side : LabelSide,
) -> EndLabelCell {
  {
    label_cell: new_label_cell_with_layout_mode(
      label_gap, horizontal_layout_mode,
    ),
    label_side,
    labels: [],
  }
}

///|
pub fn EndLabelCell::set_horizontal_alignment(
  self : EndLabelCell,
  alignment : HorizontalLabelAlignment,
) -> Unit {
  ignore(self.label_cell.set_horizontal_alignment(alignment))
}

///|
pub fn EndLabelCell::set_vertical_alignment(
  self : EndLabelCell,
  alignment : VerticalLabelAlignment,
) -> Unit {
  ignore(self.label_cell.set_vertical_alignment(alignment))
}

///|
pub fn EndLabelCell::get_cell_rectangle(self : EndLabelCell) -> ElkRectangle {
  self.label_cell.get_cell_rectangle()
}

///|
pub fn EndLabelCell::get_minimum_width(self : EndLabelCell) -> Double {
  self.label_cell.get_minimum_width()
}

///|
pub fn EndLabelCell::get_minimum_height(self : EndLabelCell) -> Double {
  self.label_cell.get_minimum_height()
}

///|
pub fn EndLabelCell::get_label_side(self : EndLabelCell) -> LabelSide {
  self.label_side
}

///|
pub fn EndLabelCell::has_labels(self : EndLabelCell) -> Bool {
  !self.labels.is_empty()
}

///|
pub fn EndLabelCell::add_l_label(self : EndLabelCell, label : LLabel) -> Unit {
  let adapted = create_label(None)
  label_set_text(adapted, label.get_text())
  label_set_dimensions(adapted, label.get_size().x, label.get_size().y)
  self.label_cell.add_label(adapted)
  self.labels.push(new_end_label_cell_label(adapted, label))
}

///|
pub fn EndLabelCell::apply_label_layout(self : EndLabelCell) -> Unit {
  self.label_cell.apply_label_layout()
  for label_mapping in self.labels {
    let position = label_mapping.l_label.get_position()
    position.x = label_x(label_mapping.elk_label)
    position.y = label_y(label_mapping.elk_label)
  }
}
