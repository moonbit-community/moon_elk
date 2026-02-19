///|
pub type AtomicCell = Cell

///|
fn atomic_cell_content_area_size(cell : AtomicCell) -> @core.KVector {
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
pub fn new_atomic_cell() -> AtomicCell {
  let cell = new_cell()
  cell.kind = AtomicCellKind
  cell.minimum_content_area_size = Some(@core.new_kvector())
  cell
}

///|
pub fn AtomicCell::get_minimum_content_area_size(self : AtomicCell) -> @core.KVector {
  atomic_cell_content_area_size(self)
}

///|
pub fn AtomicCell::set_minimum_content_area_size(
  self : AtomicCell,
  new_minimum_content_area_size : @core.KVector,
  includes_padding : Bool,
) -> Unit {
  let content_area_size = atomic_cell_content_area_size(self)
  if includes_padding {
    let padding = self.get_padding()
    content_area_size.x = new_minimum_content_area_size.x -
      padding.left -
      padding.right
    content_area_size.y = new_minimum_content_area_size.y -
      padding.top -
      padding.bottom
  } else {
    content_area_size.x = new_minimum_content_area_size.x
    content_area_size.y = new_minimum_content_area_size.y
  }
}
