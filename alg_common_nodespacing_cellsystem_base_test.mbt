///|
fn cellsystem_rect_tuple(
  rect : ElkRectangle,
) -> (Double, Double, Double, Double) {
  (rect.x, rect.y, rect.width, rect.height)
}

///|
test "Cell defaults and contribution flags" {
  let cell = new_cell()
  assert_eq(
    cellsystem_rect_tuple(cell.get_cell_rectangle()),
    (0.0, 0.0, 0.0, 0.0),
  )
  assert_false(cell.is_contributing_to_minimum_width())
  assert_false(cell.is_contributing_to_minimum_height())

  cell.set_contributes_to_minimum_width(true)
  cell.set_contributes_to_minimum_height(true)
  assert_true(cell.is_contributing_to_minimum_width())
  assert_true(cell.is_contributing_to_minimum_height())
  assert_eq((cell.get_minimum_width(), cell.get_minimum_height()), (0.0, 0.0))
}

///|
test "AtomicCell minimum size follows content and padding semantics" {
  let cell = new_atomic_cell()

  cell.set_minimum_content_area_size(new_kvector_xy(10.0, 6.0), false)
  assert_eq((cell.get_minimum_width(), cell.get_minimum_height()), (10.0, 6.0))

  cell.set_padding(new_elk_padding_values(1.0, 2.0, 3.0, 4.0))
  assert_eq((cell.get_minimum_width(), cell.get_minimum_height()), (16.0, 10.0))

  cell.set_minimum_content_area_size(new_kvector_xy(20.0, 20.0), true)
  assert_eq((cell.get_minimum_width(), cell.get_minimum_height()), (20.0, 20.0))
}

///|
test "ContainerCell utility methods follow upstream guard rules" {
  assert_eq(container_cell_min_width_of_cell(None, true), 0.0)
  assert_eq(container_cell_min_height_of_cell(None, true), 0.0)

  let atomic_cell = new_atomic_cell()
  atomic_cell.set_minimum_content_area_size(new_kvector_xy(5.0, 7.0), false)
  atomic_cell.set_contributes_to_minimum_width(true)
  atomic_cell.set_contributes_to_minimum_height(true)
  assert_eq(container_cell_min_width_of_cell(Some(atomic_cell), true), 5.0)
  assert_eq(container_cell_min_height_of_cell(Some(atomic_cell), true), 7.0)

  atomic_cell.set_contributes_to_minimum_width(false)
  atomic_cell.set_contributes_to_minimum_height(false)
  assert_eq(container_cell_min_width_of_cell(Some(atomic_cell), true), 0.0)
  assert_eq(container_cell_min_height_of_cell(Some(atomic_cell), true), 0.0)
  assert_eq(container_cell_min_width_of_cell(Some(atomic_cell), false), 5.0)
  assert_eq(container_cell_min_height_of_cell(Some(atomic_cell), false), 7.0)

  let zero_atomic = new_atomic_cell()
  zero_atomic.set_contributes_to_minimum_width(true)
  zero_atomic.set_contributes_to_minimum_height(true)
  assert_eq(container_cell_min_width_of_cell(Some(zero_atomic), true), 0.0)
  assert_eq(container_cell_min_height_of_cell(Some(zero_atomic), true), 0.0)

  let container = new_container_cell()
  let target = new_cell()
  target.set_cell_rectangle(new_elk_rectangle_xywh(0.0, 0.0, 1.0, 1.0))
  container.apply_horizontal_layout(Some(target), 3.0, 8.0)
  container.apply_vertical_layout(Some(target), 4.0, 9.0)
  assert_eq(
    cellsystem_rect_tuple(target.get_cell_rectangle()),
    (3.0, 4.0, 8.0, 9.0),
  )
}

///|
test "StripContainerCell computes size and child layout" {
  let strip = new_strip_container_cell(Horizontal, true, 1.0)

  let left = new_atomic_cell()
  left.set_minimum_content_area_size(new_kvector_xy(2.0, 1.0), false)
  left.set_contributes_to_minimum_width(true)
  left.set_contributes_to_minimum_height(true)

  let center = new_atomic_cell()
  center.set_minimum_content_area_size(new_kvector_xy(3.0, 2.0), false)
  center.set_contributes_to_minimum_width(true)
  center.set_contributes_to_minimum_height(true)

  let right = new_atomic_cell()
  right.set_minimum_content_area_size(new_kvector_xy(5.0, 4.0), false)
  right.set_contributes_to_minimum_width(true)
  right.set_contributes_to_minimum_height(true)

  strip.set_cell(Begin, Some(left))
  strip.set_cell(Center, Some(center))
  strip.set_cell(End, Some(right))

  assert_eq(
    (strip.get_minimum_width(), strip.get_minimum_height()),
    (15.0, 4.0),
  )

  strip.set_cell_rectangle(new_elk_rectangle_xywh(0.0, 0.0, 20.0, 10.0))

  strip.layout_children_horizontally()
  strip.layout_children_vertically()

  assert_eq(
    cellsystem_rect_tuple(left.get_cell_rectangle()),
    (0.0, 0.0, 5.0, 10.0),
  )
  assert_eq(
    cellsystem_rect_tuple(center.get_cell_rectangle()),
    (6.0, 0.0, 8.0, 10.0),
  )
  assert_eq(
    cellsystem_rect_tuple(right.get_cell_rectangle()),
    (15.0, 0.0, 5.0, 10.0),
  )
}

///|
test "GridContainerCell computes tabular size and center rectangle" {
  let grid = new_grid_container_cell(true, false, 1.0)

  let top_left = new_atomic_cell()
  top_left.set_minimum_content_area_size(new_kvector_xy(2.0, 2.0), false)
  top_left.set_contributes_to_minimum_width(true)
  top_left.set_contributes_to_minimum_height(true)
  grid_container_cell_set_cell(grid, Begin, Begin, Some(top_left))

  let top_center = new_atomic_cell()
  top_center.set_minimum_content_area_size(new_kvector_xy(4.0, 1.0), false)
  top_center.set_contributes_to_minimum_width(true)
  top_center.set_contributes_to_minimum_height(true)
  grid_container_cell_set_cell(grid, Begin, Center, Some(top_center))

  let center_center = new_atomic_cell()
  center_center.set_minimum_content_area_size(new_kvector_xy(3.0, 3.0), false)
  center_center.set_contributes_to_minimum_width(true)
  center_center.set_contributes_to_minimum_height(true)
  grid_container_cell_set_cell(grid, Center, Center, Some(center_center))

  let bottom_right = new_atomic_cell()
  bottom_right.set_minimum_content_area_size(new_kvector_xy(5.0, 4.0), false)
  bottom_right.set_contributes_to_minimum_width(true)
  bottom_right.set_contributes_to_minimum_height(true)
  grid_container_cell_set_cell(grid, End, End, Some(bottom_right))

  assert_eq((grid.get_minimum_width(), grid.get_minimum_height()), (13.0, 11.0))

  grid.set_cell_rectangle(new_elk_rectangle_xywh(0.0, 0.0, 20.0, 18.0))

  grid.layout_children_horizontally()
  grid.layout_children_vertically()

  assert_eq(
    cellsystem_rect_tuple(center_center.get_cell_rectangle()),
    (3.0, 3.0, 11.0, 10.0),
  )
  assert_eq(
    cellsystem_rect_tuple(grid_container_cell_get_center_cell_rectangle(grid)),
    (0.0, 0.0, 9.0, 10.0),
  )
}

///|
test "LabelCell lays out labels in horizontal mode" {
  let label_a = create_label(None)
  label_set_dimensions(label_a, 4.0, 2.0)
  let label_b = create_label(None)
  label_set_dimensions(label_b, 2.0, 2.0)

  let cell = new_label_cell(1.0)
  ignore(cell.set_horizontal_alignment(Right))
  ignore(cell.set_vertical_alignment(Bottom))
  cell.add_label(label_a)
  cell.add_label(label_b)

  cell.set_padding(new_elk_padding_values(3.0, 2.0, 1.0, 1.0))
  cell.set_cell_rectangle(new_elk_rectangle_xywh(10.0, 20.0, 12.0, 9.0))

  assert_eq((cell.get_minimum_width(), cell.get_minimum_height()), (7.0, 9.0))

  cell.apply_label_layout()

  assert_eq((label_x(label_a), label_y(label_a)), (16.0, 24.0))
  assert_eq((label_x(label_b), label_y(label_b)), (18.0, 27.0))
}
