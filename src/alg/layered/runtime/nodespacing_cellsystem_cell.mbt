///|
pub enum CellKind {
  BaseCellKind
  AtomicCellKind
  ContainerCellKind
  StripContainerCellKind
  GridContainerCellKind
  LabelCellKind
}

///|
pub struct Cell {
  mut kind : CellKind
  mut padding : @core.ElkPadding
  mut cell_rectangle : @core.ElkRectangle
  mut contributes_to_minimum_width : Bool
  mut contributes_to_minimum_height : Bool
  mut minimum_content_area_size : @core.KVector?
  mut strip_container_mode : Strip?
  mut strip_symmetrical : Bool
  mut strip_gap : Double
  mut strip_cells : Array[Cell?]?
  mut grid_tabular : Bool
  mut grid_symmetrical : Bool
  mut grid_gap : Double
  mut grid_cells : Array[Array[Cell?]]?
  mut center_cell_minimum_size : @core.KVector?
  mut only_center_cell_contributes_to_minimum_size : Bool
  mut center_cell_rect : @core.ElkRectangle
  mut label_horizontal_layout_mode : Bool
  mut label_horizontal_alignment : HorizontalLabelAlignment
  mut label_vertical_alignment : VerticalLabelAlignment
  mut label_gap : Double
  mut labels : Array[@graph.ElkLabel]?
  mut l_labels : Array[LLabelAdapter]?
}

///|
pub fn new_cell() -> Cell {
  {
    kind: BaseCellKind,
    padding: @core.new_elk_padding(),
    cell_rectangle: @core.new_elk_rectangle(),
    contributes_to_minimum_width: false,
    contributes_to_minimum_height: false,
    minimum_content_area_size: None,
    strip_container_mode: None,
    strip_symmetrical: false,
    strip_gap: 0.0,
    strip_cells: None,
    grid_tabular: false,
    grid_symmetrical: false,
    grid_gap: 0.0,
    grid_cells: None,
    center_cell_minimum_size: None,
    only_center_cell_contributes_to_minimum_size: false,
    center_cell_rect: @core.new_elk_rectangle(),
    label_horizontal_layout_mode: true,
    label_horizontal_alignment: Center,
    label_vertical_alignment: Center,
    label_gap: 0.0,
    labels: None,
    l_labels: None,
  }
}

///|
fn cell_content_area_size(cell : Cell) -> @core.KVector {
  match cell.minimum_content_area_size {
    Some(size) => size
    None => @core.new_kvector()
  }
}

///|
fn cell_minimum_width_from_content(cell : Cell) -> Double {
  let size = cell_content_area_size(cell)
  size.x + cell.padding.left + cell.padding.right
}

///|
fn cell_minimum_height_from_content(cell : Cell) -> Double {
  let size = cell_content_area_size(cell)
  size.y + cell.padding.top + cell.padding.bottom
}

///|
pub fn Cell::get_padding(self : Cell) -> @core.ElkPadding {
  self.padding
}

///|
pub fn Cell::set_padding(self : Cell, padding : @core.ElkPadding) -> Unit {
  self.padding = @core.new_elk_padding_copy(padding)
}

///|
pub fn Cell::get_cell_rectangle(self : Cell) -> @core.ElkRectangle {
  self.cell_rectangle
}

///|
pub fn Cell::set_cell_rectangle(
  self : Cell,
  cell_rectangle : @core.ElkRectangle,
) -> Unit {
  self.cell_rectangle = @core.new_elk_rectangle_copy(cell_rectangle)
}

///|
pub fn Cell::is_contributing_to_minimum_width(self : Cell) -> Bool {
  self.contributes_to_minimum_width
}

///|
pub fn Cell::set_contributes_to_minimum_width(
  self : Cell,
  contributes_to_minimum_width : Bool,
) -> Unit {
  self.contributes_to_minimum_width = contributes_to_minimum_width
}

///|
pub fn Cell::is_contributing_to_minimum_height(self : Cell) -> Bool {
  self.contributes_to_minimum_height
}

///|
pub fn Cell::set_contributes_to_minimum_height(
  self : Cell,
  contributes_to_minimum_height : Bool,
) -> Unit {
  self.contributes_to_minimum_height = contributes_to_minimum_height
}

///|
pub fn Cell::get_minimum_width(self : Cell) -> Double {
  match self.kind {
    AtomicCellKind => cell_minimum_width_from_content(self)
    LabelCellKind => cell_minimum_width_from_content(self)
    StripContainerCellKind => strip_container_cell_compute_minimum_width(self)
    GridContainerCellKind => grid_container_cell_compute_minimum_width(self)
    _ => 0.0
  }
}

///|
pub fn Cell::get_minimum_height(self : Cell) -> Double {
  match self.kind {
    AtomicCellKind => cell_minimum_height_from_content(self)
    LabelCellKind => cell_minimum_height_from_content(self)
    StripContainerCellKind => strip_container_cell_compute_minimum_height(self)
    GridContainerCellKind => grid_container_cell_compute_minimum_height(self)
    _ => 0.0
  }
}
