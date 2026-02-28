///|
pub type GridContainerCell = Cell

///|
let grid_container_rows = 3

///|
let grid_container_columns = 3

///|
fn grid_container_area_index(area : ContainerArea) -> Int {
  match area {
    Begin => 0
    Center => 1
    End => 2
  }
}

///|
fn grid_container_is_center(area : ContainerArea) -> Bool {
  match area {
    Center => true
    _ => false
  }
}

///|
fn grid_container_max(left : Double, right : Double) -> Double {
  if left >= right {
    left
  } else {
    right
  }
}

///|
fn grid_container_cells(cell : Cell) -> Array[Array[Cell?]] {
  match cell.grid_cells {
    Some(cells) => cells
    None => {
      let cells = [[None, None, None], [None, None, None], [None, None, None]]
      cell.grid_cells = Some(cells)
      cells
    }
  }
}

///|
fn grid_container_sum_with_gaps(cell : Cell, values : Array[Double]) -> Double {
  let mut sum = 0.0
  let mut active_components = 0
  for value in values {
    if value > 0.0 {
      sum += value
      active_components += 1
    }
  }
  if active_components > 1 {
    sum += cell.grid_gap * (active_components - 1).to_double()
  }
  sum
}

///|
fn grid_container_min_width_of_column(
  cell : Cell,
  column : ContainerArea,
  row : ContainerArea?,
  respect_contribution_flag : Bool,
) -> Double {
  let cells = grid_container_cells(cell)
  let column_index = grid_container_area_index(column)
  let mut max_minimum_width = 0.0

  match row {
    None =>
      for row_index = 0
          row_index < grid_container_rows
          row_index = row_index + 1 {
        max_minimum_width = grid_container_max(
          max_minimum_width,
          container_cell_min_width_of_cell(
            cells[row_index][column_index],
            respect_contribution_flag,
          ),
        )
      }
    Some(only_row) =>
      max_minimum_width = container_cell_min_width_of_cell(
        cells[grid_container_area_index(only_row)][column_index],
        respect_contribution_flag,
      )
  }

  if grid_container_is_center(column) {
    match cell.center_cell_minimum_size {
      Some(size) =>
        max_minimum_width = grid_container_max(max_minimum_width, size.x)
      None => ()
    }
  }

  max_minimum_width
}

///|
fn grid_container_min_column_widths(
  cell : Cell,
  row : ContainerArea?,
  respect_contribution_flag : Bool,
) -> Array[Double] {
  let column_widths = [
    grid_container_min_width_of_column(
      cell,
      Begin,
      row,
      respect_contribution_flag,
    ),
    grid_container_min_width_of_column(
      cell,
      Center,
      row,
      respect_contribution_flag,
    ),
    grid_container_min_width_of_column(
      cell,
      End,
      row,
      respect_contribution_flag,
    ),
  ]

  if cell.grid_symmetrical {
    column_widths[0] = grid_container_max(column_widths[0], column_widths[2])
    column_widths[2] = column_widths[0]
  }

  column_widths
}

///|
fn grid_container_min_height_of_row(
  cell : Cell,
  row : ContainerArea,
  respect_contribution_flag : Bool,
) -> Double {
  let cells = grid_container_cells(cell)
  let row_index = grid_container_area_index(row)
  let mut max_minimum_height = 0.0

  for column = 0; column < grid_container_columns; column = column + 1 {
    max_minimum_height = grid_container_max(
      max_minimum_height,
      container_cell_min_height_of_cell(
        cells[row_index][column],
        respect_contribution_flag,
      ),
    )
  }

  if grid_container_is_center(row) {
    match cell.center_cell_minimum_size {
      Some(size) =>
        max_minimum_height = grid_container_max(max_minimum_height, size.y)
      None => ()
    }
  }

  max_minimum_height
}

///|
fn grid_container_min_row_heights(
  cell : Cell,
  respect_contribution_flag : Bool,
) -> Array[Double] {
  let row_heights = [
    grid_container_min_height_of_row(cell, Begin, respect_contribution_flag),
    grid_container_min_height_of_row(cell, Center, respect_contribution_flag),
    grid_container_min_height_of_row(cell, End, respect_contribution_flag),
  ]

  if cell.grid_symmetrical {
    row_heights[0] = grid_container_max(row_heights[0], row_heights[2])
    row_heights[2] = row_heights[0]
  }

  row_heights
}

///|
fn grid_container_apply_width_to_column(
  cell : Cell,
  column : ContainerArea,
  x : Double,
  column_widths : Array[Double],
) -> Unit {
  let cells = grid_container_cells(cell)
  let column_index = grid_container_area_index(column)
  for row = 0; row < grid_container_rows; row = row + 1 {
    cell.apply_horizontal_layout(
      cells[row][column_index],
      x,
      column_widths[column_index],
    )
  }
}

///|
fn grid_container_apply_height_to_row(
  cell : Cell,
  row : ContainerArea,
  y : Double,
  row_heights : Array[Double],
) -> Unit {
  let cells = grid_container_cells(cell)
  let row_index = grid_container_area_index(row)
  for column = 0; column < grid_container_columns; column = column + 1 {
    cell.apply_vertical_layout(
      cells[row_index][column],
      y,
      row_heights[row_index],
    )
  }
}

///|
fn grid_container_apply_widths_to_row(
  cell : Cell,
  row : ContainerArea,
  column_widths : Array[Double],
) -> Unit {
  let cell_rectangle = cell.get_cell_rectangle()
  let cell_padding = cell.get_padding()

  grid_container_apply_width_to_column(
    cell,
    Begin,
    cell_rectangle.x + cell_padding.left,
    column_widths,
  )
  grid_container_apply_width_to_column(
    cell,
    End,
    cell_rectangle.x +
    cell_rectangle.width -
    cell_padding.right -
    column_widths[2],
    column_widths,
  )

  let mut free_content_area_width = cell_rectangle.width -
    cell_padding.left -
    cell_padding.right

  if column_widths[0] > 0.0 {
    column_widths[0] += cell.grid_gap
    free_content_area_width -= column_widths[0]
  }
  if column_widths[2] > 0.0 {
    column_widths[2] += cell.grid_gap
    free_content_area_width -= column_widths[2]
  }

  let center_width = grid_container_max(0.0, free_content_area_width)
  column_widths[1] = grid_container_max(
    column_widths[1],
    free_content_area_width,
  )

  grid_container_apply_width_to_column(
    cell,
    Center,
    cell_rectangle.x +
    cell_padding.left +
    column_widths[0] -
    (column_widths[1] - free_content_area_width) / 2.0,
    column_widths,
  )

  if grid_container_is_center(row) {
    cell.center_cell_rect.width = center_width
    cell.center_cell_rect.x = cell_rectangle.x +
      cell_padding.left +
      (center_width - free_content_area_width) / 2.0
  }
}

///|
pub fn new_grid_container_cell(
  tabular : Bool,
  symmetrical : Bool,
  gap : Double,
) -> GridContainerCell {
  let cell = new_container_cell()
  cell.kind = GridContainerCellKind
  cell.grid_tabular = tabular
  cell.grid_symmetrical = symmetrical
  cell.grid_gap = gap
  cell.grid_cells = Some([
    [None, None, None],
    [None, None, None],
    [None, None, None],
  ])
  cell.center_cell_rect = @core.new_elk_rectangle()
  cell
}

///|
pub fn grid_container_cell_get_gap(cell : GridContainerCell) -> Double {
  cell.grid_gap
}

///|
pub fn grid_container_cell_get_cell(
  cell : GridContainerCell,
  row : ContainerArea,
  col : ContainerArea,
) -> Cell? {
  let cells = grid_container_cells(cell)
  cells[grid_container_area_index(row)][grid_container_area_index(col)]
}

///|
pub fn grid_container_cell_set_cell(
  cell : GridContainerCell,
  row : ContainerArea,
  col : ContainerArea,
  child : Cell?,
) -> Unit {
  let cells = grid_container_cells(cell)
  cells[grid_container_area_index(row)][grid_container_area_index(col)] = child
}

///|
pub fn grid_container_cell_set_center_cell_minimum_size(
  cell : GridContainerCell,
  minimum_size : @core.KVector,
) -> Unit {
  cell.center_cell_minimum_size = Some(@core.new_kvector_copy(minimum_size))
}

///|
pub fn grid_container_cell_set_only_center_cell_contributes_to_minimum_size(
  cell : GridContainerCell,
  contribution : Bool,
) -> Unit {
  cell.only_center_cell_contributes_to_minimum_size = contribution
}

///|
pub fn grid_container_cell_get_center_cell_rectangle(
  cell : GridContainerCell,
) -> @core.ElkRectangle {
  @core.new_elk_rectangle_copy(cell.center_cell_rect)
}

///|
pub fn grid_container_cell_compute_minimum_width(cell : Cell) -> Double {
  let cells = grid_container_cells(cell)
  let mut width = 0.0

  if cell.only_center_cell_contributes_to_minimum_size {
    match cell.center_cell_minimum_size {
      Some(size) => width = size.x
      None =>
        match cells[1][1] {
          Some(center_cell) => width = center_cell.get_minimum_width()
          None => ()
        }
    }
  } else if cell.grid_tabular {
    width = grid_container_sum_with_gaps(
      cell,
      grid_container_min_column_widths(cell, None, true),
    )
  } else {
    for area in container_area_values() {
      width = grid_container_max(
        width,
        grid_container_sum_with_gaps(
          cell,
          grid_container_min_column_widths(cell, Some(area), true),
        ),
      )
    }
  }

  if width > 0.0 {
    width + cell.get_padding().left + cell.get_padding().right
  } else {
    0.0
  }
}

///|
pub fn grid_container_cell_compute_minimum_height(cell : Cell) -> Double {
  let cells = grid_container_cells(cell)
  let mut height = 0.0

  if cell.only_center_cell_contributes_to_minimum_size {
    match cell.center_cell_minimum_size {
      Some(size) => height = size.y
      None =>
        match cells[1][1] {
          Some(center_cell) => height = center_cell.get_minimum_height()
          None => ()
        }
    }
  } else {
    height = grid_container_sum_with_gaps(
      cell,
      grid_container_min_row_heights(cell, true),
    )
  }

  if height > 0.0 {
    height + cell.get_padding().top + cell.get_padding().bottom
  } else {
    0.0
  }
}

///|
pub fn grid_container_cell_layout_children_horizontally(cell : Cell) -> Unit {
  if cell.grid_tabular {
    let column_widths = grid_container_min_column_widths(cell, None, false)
    for row in container_area_values() {
      grid_container_apply_widths_to_row(cell, row, column_widths)
    }
  } else {
    for row in container_area_values() {
      let column_widths = grid_container_min_column_widths(
        cell,
        Some(row),
        false,
      )
      grid_container_apply_widths_to_row(cell, row, column_widths)
    }
  }
}

///|
pub fn grid_container_cell_layout_children_vertically(cell : Cell) -> Unit {
  let cell_rectangle = cell.get_cell_rectangle()
  let cell_padding = cell.get_padding()
  let row_heights = grid_container_min_row_heights(cell, false)

  grid_container_apply_height_to_row(
    cell,
    Begin,
    cell_rectangle.y + cell_padding.top,
    row_heights,
  )
  grid_container_apply_height_to_row(
    cell,
    End,
    cell_rectangle.y +
    cell_rectangle.height -
    cell_padding.bottom -
    row_heights[2],
    row_heights,
  )

  let mut free_content_area_height = cell_rectangle.height -
    cell_padding.top -
    cell_padding.bottom

  if row_heights[0] > 0.0 {
    row_heights[0] += cell.grid_gap
    free_content_area_height -= row_heights[0]
  }
  if row_heights[2] > 0.0 {
    row_heights[2] += cell.grid_gap
    free_content_area_height -= row_heights[2]
  }

  cell.center_cell_rect.height = grid_container_max(
    0.0, free_content_area_height,
  )
  cell.center_cell_rect.y = cell_rectangle.y +
    cell_padding.top +
    (cell.center_cell_rect.height - free_content_area_height) / 2.0

  row_heights[1] = grid_container_max(row_heights[1], free_content_area_height)

  grid_container_apply_height_to_row(
    cell,
    Center,
    cell_rectangle.y +
    cell_padding.top +
    row_heights[0] -
    (row_heights[1] - free_content_area_height) / 2.0,
    row_heights,
  )
}
