///|
pub struct EndLabelCellLabel {
  elk_label : @graph.ElkLabel
  l_label : LLabel
}

///|
let end_label_cell_arenas : Map[Int, @graph.GraphArena] = Map([])

///|
pub fn new_end_label_cell_label(
  elk_label : @graph.ElkLabel,
  l_label : LLabel,
) -> EndLabelCellLabel {
  { elk_label, l_label }
}

///|
pub struct EndLabelCell {
  label_cell : @nodespacing.LabelCell
  label_side : @core.LabelSide
  labels : Array[EndLabelCellLabel]
}

///|
pub fn new_end_label_cell(
  label_gap : Double,
  horizontal_layout_mode : Bool,
  label_side : @core.LabelSide,
) -> EndLabelCell {
  {
    label_cell: @nodespacing.new_label_cell_with_layout_mode(
      label_gap, horizontal_layout_mode,
    ),
    label_side,
    labels: [],
  }
}

///|
pub fn EndLabelCell::set_horizontal_alignment(
  self : EndLabelCell,
  alignment : @nodespacing.HorizontalLabelAlignment,
) -> Unit {
  ignore(self.label_cell.set_horizontal_alignment(alignment))
}

///|
pub fn EndLabelCell::set_vertical_alignment(
  self : EndLabelCell,
  alignment : @nodespacing.VerticalLabelAlignment,
) -> Unit {
  ignore(self.label_cell.set_vertical_alignment(alignment))
}

///|
pub fn EndLabelCell::get_cell_rectangle(
  self : EndLabelCell,
) -> @core.ElkRectangle {
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
pub fn EndLabelCell::get_label_side(self : EndLabelCell) -> @core.LabelSide {
  self.label_side
}

///|
pub fn EndLabelCell::has_labels(self : EndLabelCell) -> Bool {
  !self.labels.is_empty()
}

///|
pub fn EndLabelCell::add_l_label(self : EndLabelCell, label : LLabel) -> Unit {
  let arena = if self.labels.is_empty() {
    @graph.new_graph_arena()
  } else {
    match end_label_cell_arenas.get(self.labels[0].elk_label) {
      Some(value) => value
      None => @graph.new_graph_arena()
    }
  }
  let adapted = arena.create_label()
  end_label_cell_arenas[adapted] = arena
  @graph.label_set_text(adapted, label.get_text())
  @graph.label_set_dimensions(adapted, label.get_size().x, label.get_size().y)
  self.label_cell.add_label(adapted)
  self.labels.push(new_end_label_cell_label(adapted, label))
}

///|
fn EndLabelCell::dispose(self : EndLabelCell) -> Unit {
  if self.labels.is_empty() {
    return
  }
  match end_label_cell_arenas.get(self.labels[0].elk_label) {
    Some(arena) => {
      // Adapted labels are temporary public graph objects owned by this cell.
      arena.dispose()
      for label_mapping in self.labels {
        ignore(end_label_cell_arenas.remove(label_mapping.elk_label))
      }
    }
    None => ()
  }
}

///|
pub fn EndLabelCell::apply_label_layout(self : EndLabelCell) -> Unit {
  if !self.labels.is_empty() &&
    !end_label_cell_arenas.contains(self.labels[0].elk_label) {
    return
  }
  self.label_cell.apply_label_layout()
  for label_mapping in self.labels {
    let position = label_mapping.l_label.get_position()
    position.x = @graph.label_x(label_mapping.elk_label)
    position.y = @graph.label_y(label_mapping.elk_label)
  }
  self.dispose()
}
