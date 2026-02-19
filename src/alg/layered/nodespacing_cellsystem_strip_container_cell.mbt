///|
pub(all) enum Strip {
  Vertical
  Horizontal
}

///|
pub type StripContainerCell = Cell

///|
fn strip_container_area_index(area : ContainerArea) -> Int {
  match area {
    Begin => 0
    Center => 1
    End => 2
  }
}

///|
fn strip_container_max(left : Double, right : Double) -> Double {
  if left >= right {
    left
  } else {
    right
  }
}

///|
fn strip_container_mode(cell : Cell) -> Strip {
  match cell.strip_container_mode {
    Some(mode) => mode
    None => Horizontal
  }
}

///|
fn strip_container_cells(cell : Cell) -> Array[Cell?] {
  match cell.strip_cells {
    Some(cells) => cells
    None => {
      let cells = [None, None, None]
      cell.strip_cells = Some(cells)
      cells
    }
  }
}

///|
fn strip_container_is_vertical(mode : Strip) -> Bool {
  match mode {
    Vertical => true
    Horizontal => false
  }
}

///|
pub fn new_strip_container_cell(
  mode : Strip,
  symmetrical : Bool,
  gap : Double,
) -> StripContainerCell {
  let cell = new_container_cell()
  cell.kind = StripContainerCellKind
  cell.strip_container_mode = Some(mode)
  cell.strip_symmetrical = symmetrical
  cell.strip_gap = gap
  cell.strip_cells = Some([None, None, None])
  cell
}

///|
pub fn StripContainerCell::get_container_mode(
  self : StripContainerCell,
) -> Strip {
  strip_container_mode(self)
}

///|
pub fn StripContainerCell::get_gap(self : StripContainerCell) -> Double {
  self.strip_gap
}

///|
pub fn StripContainerCell::get_cell(
  self : StripContainerCell,
  area : ContainerArea,
) -> Cell? {
  let cells = strip_container_cells(self)
  cells[strip_container_area_index(area)]
}

///|
pub fn StripContainerCell::set_cell(
  self : StripContainerCell,
  area : ContainerArea,
  cell : Cell?,
) -> Unit {
  let cells = strip_container_cells(self)
  cells[strip_container_area_index(area)] = cell
}

///|
fn strip_container_cell_min_cell_widths(
  cell : Cell,
  respect_contribution_flag : Bool,
) -> Array[Double] {
  let cells = strip_container_cells(cell)
  let cell_widths = [
    container_cell_min_width_of_cell(cells[0], respect_contribution_flag),
    container_cell_min_width_of_cell(cells[1], respect_contribution_flag),
    container_cell_min_width_of_cell(cells[2], respect_contribution_flag),
  ]

  if cell.strip_symmetrical {
    cell_widths[0] = strip_container_max(cell_widths[0], cell_widths[2])
    cell_widths[2] = cell_widths[0]
  }

  cell_widths
}

///|
fn strip_container_cell_min_cell_heights(
  cell : Cell,
  respect_contribution_flag : Bool,
) -> Array[Double] {
  let cells = strip_container_cells(cell)
  let cell_heights = [
    container_cell_min_height_of_cell(cells[0], respect_contribution_flag),
    container_cell_min_height_of_cell(cells[1], respect_contribution_flag),
    container_cell_min_height_of_cell(cells[2], respect_contribution_flag),
  ]

  if cell.strip_symmetrical {
    cell_heights[0] = strip_container_max(cell_heights[0], cell_heights[2])
    cell_heights[2] = cell_heights[0]
  }

  cell_heights
}

///|
pub fn strip_container_cell_compute_minimum_width(cell : Cell) -> Double {
  let mut width = 0.0

  if strip_container_is_vertical(strip_container_mode(cell)) {
    let cells = strip_container_cells(cell)
    for child_cell in cells {
      match child_cell {
        Some(child) =>
          if child.is_contributing_to_minimum_width() {
            width = strip_container_max(width, child.get_minimum_width())
          }
        None => ()
      }
    }
  } else {
    let cell_widths = strip_container_cell_min_cell_widths(cell, true)
    let mut active_cells = 0
    for cell_width in cell_widths {
      if cell_width > 0.0 {
        width += cell_width
        active_cells += 1
      }
    }
    if active_cells > 1 {
      width += cell.strip_gap * (active_cells - 1).to_double()
    }
  }

  if width > 0.0 {
    width + cell.padding.left + cell.padding.right
  } else {
    0.0
  }
}

///|
pub fn strip_container_cell_compute_minimum_height(cell : Cell) -> Double {
  let mut height = 0.0

  if strip_container_is_vertical(strip_container_mode(cell)) {
    let cell_heights = strip_container_cell_min_cell_heights(cell, true)
    let mut active_cells = 0
    for cell_height in cell_heights {
      if cell_height > 0.0 {
        height += cell_height
        active_cells += 1
      }
    }
    if active_cells > 1 {
      height += cell.strip_gap * (active_cells - 1).to_double()
    }
  } else {
    let cells = strip_container_cells(cell)
    for child_cell in cells {
      match child_cell {
        Some(child) =>
          if child.is_contributing_to_minimum_height() {
            height = strip_container_max(height, child.get_minimum_height())
          }
        None => ()
      }
    }
  }

  if height > 0.0 {
    height + cell.padding.top + cell.padding.bottom
  } else {
    0.0
  }
}

///|
pub fn strip_container_cell_layout_children_horizontally(cell : Cell) -> Unit {
  let cell_rectangle = cell.get_cell_rectangle()
  let cell_padding = cell.get_padding()
  let cells = strip_container_cells(cell)

  if strip_container_is_vertical(strip_container_mode(cell)) {
    let x_pos = cell_rectangle.x + cell_padding.left
    let width = cell_rectangle.width - cell_padding.left - cell_padding.right
    for child_cell in cells {
      cell.apply_horizontal_layout(child_cell, x_pos, width)
    }
  } else {
    let cell_widths = strip_container_cell_min_cell_widths(cell, false)

    cell.apply_horizontal_layout(
      cells[0],
      cell_rectangle.x + cell_padding.left,
      cell_widths[0],
    )
    cell.apply_horizontal_layout(
      cells[2],
      cell_rectangle.x +
      cell_rectangle.width -
      cell_padding.right -
      cell_widths[2],
      cell_widths[2],
    )

    let mut free_content_area_width = cell_rectangle.width -
      cell_padding.left -
      cell_padding.right

    if cell_widths[0] > 0.0 {
      free_content_area_width -= cell_widths[0] + cell.strip_gap
      cell_widths[0] += cell.strip_gap
    }

    if cell_widths[2] > 0.0 {
      free_content_area_width -= cell_widths[2] + cell.strip_gap
    }

    cell_widths[1] = strip_container_max(
      cell_widths[1],
      free_content_area_width,
    )

    cell.apply_horizontal_layout(
      cells[1],
      cell_rectangle.x +
      cell_padding.left +
      cell_widths[0] -
      (cell_widths[1] - free_content_area_width) / 2.0,
      cell_widths[1],
    )
  }

  for child_cell in cells {
    match child_cell {
      Some(cell) =>
        match cell.kind {
          StripContainerCellKind =>
            strip_container_cell_layout_children_horizontally(cell)
          GridContainerCellKind =>
            grid_container_cell_layout_children_horizontally(cell)
          _ => ()
        }
      None => ()
    }
  }
}

///|
pub fn strip_container_cell_layout_children_vertically(cell : Cell) -> Unit {
  let cell_rectangle = cell.get_cell_rectangle()
  let cell_padding = cell.get_padding()
  let cells = strip_container_cells(cell)

  if strip_container_is_vertical(strip_container_mode(cell)) {
    let cell_heights = strip_container_cell_min_cell_heights(cell, false)

    cell.apply_vertical_layout(
      cells[0],
      cell_rectangle.y + cell_padding.top,
      cell_heights[0],
    )
    cell.apply_vertical_layout(
      cells[2],
      cell_rectangle.y +
      cell_rectangle.height -
      cell_padding.bottom -
      cell_heights[2],
      cell_heights[2],
    )

    let content_area_height = cell_rectangle.height -
      cell_padding.top -
      cell_padding.bottom
    let mut content_area_free_height = content_area_height

    if cell_heights[0] > 0.0 {
      cell_heights[0] += cell.strip_gap
      content_area_free_height -= cell_heights[0]
    }

    if cell_heights[2] > 0.0 {
      content_area_free_height -= cell_heights[2] + cell.strip_gap
    }

    cell_heights[1] = strip_container_max(
      cell_heights[1],
      content_area_free_height,
    )

    cell.apply_vertical_layout(
      cells[1],
      cell_rectangle.y +
      cell_padding.top +
      cell_heights[0] -
      (cell_heights[1] - content_area_free_height) / 2.0,
      cell_heights[1],
    )
  } else {
    let y_pos = cell_rectangle.y + cell_padding.top
    let height = cell_rectangle.height - cell_padding.top - cell_padding.bottom
    for child_cell in cells {
      cell.apply_vertical_layout(child_cell, y_pos, height)
    }
  }

  for child_cell in cells {
    match child_cell {
      Some(cell) =>
        match cell.kind {
          StripContainerCellKind =>
            strip_container_cell_layout_children_vertically(cell)
          GridContainerCellKind =>
            grid_container_cell_layout_children_vertically(cell)
          _ => ()
        }
      None => ()
    }
  }
}
