///|
pub type ContainerCell = Cell

///|
fn container_cell_is_atomic(cell : Cell) -> Bool {
  match cell.kind {
    AtomicCellKind => true
    _ => false
  }
}

///|
pub fn new_container_cell() -> ContainerCell {
  let cell = new_cell()
  cell.kind = ContainerCellKind
  cell
}

///|
pub fn ContainerCell::layout_children_horizontally(
  self : ContainerCell,
) -> Unit {
  match self.kind {
    StripContainerCellKind =>
      strip_container_cell_layout_children_horizontally(self)
    GridContainerCellKind =>
      grid_container_cell_layout_children_horizontally(self)
    _ => ()
  }
}

///|
pub fn ContainerCell::layout_children_vertically(self : ContainerCell) -> Unit {
  match self.kind {
    StripContainerCellKind =>
      strip_container_cell_layout_children_vertically(self)
    GridContainerCellKind =>
      grid_container_cell_layout_children_vertically(self)
    _ => ()
  }
}

///|
pub fn container_cell_min_width_of_cell(
  cell : Cell?,
  respect_contribution_flag : Bool,
) -> Double {
  match cell {
    None => 0.0
    Some(value) => {
      if respect_contribution_flag && !value.is_contributing_to_minimum_width() {
        return 0.0
      }
      if container_cell_is_atomic(value) {
        match value.minimum_content_area_size {
          Some(size) if size.x == 0.0 => return 0.0
          _ => ()
        }
      }
      value.get_minimum_width()
    }
  }
}

///|
pub fn container_cell_min_height_of_cell(
  cell : Cell?,
  respect_contribution_flag : Bool,
) -> Double {
  match cell {
    None => 0.0
    Some(value) => {
      if respect_contribution_flag && !value.is_contributing_to_minimum_height() {
        return 0.0
      }
      if container_cell_is_atomic(value) {
        match value.minimum_content_area_size {
          Some(size) if size.y == 0.0 => return 0.0
          _ => ()
        }
      }
      value.get_minimum_height()
    }
  }
}

///|
pub fn ContainerCell::apply_horizontal_layout(
  self : ContainerCell,
  cell : Cell?,
  x : Double,
  width : Double,
) -> Unit {
  ignore(self)
  match cell {
    Some(value) => {
      let cell_rect = value.get_cell_rectangle()
      value.set_cell_rectangle(
        @core.new_elk_rectangle_xywh(x, cell_rect.y, width, cell_rect.height),
      )
    }
    None => ()
  }
}

///|
pub fn ContainerCell::apply_vertical_layout(
  self : ContainerCell,
  cell : Cell?,
  y : Double,
  height : Double,
) -> Unit {
  ignore(self)
  match cell {
    Some(value) => {
      let cell_rect = value.get_cell_rectangle()
      value.set_cell_rectangle(
        @core.new_elk_rectangle_xywh(cell_rect.x, y, cell_rect.width, height),
      )
    }
    None => ()
  }
}
