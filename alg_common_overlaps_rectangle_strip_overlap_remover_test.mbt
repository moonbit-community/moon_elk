///|
fn overlaps_rect_eq(
  value : Double,
  expected : Double,
  eps? : Double = 0.0001,
) -> Unit raise {
  if (value - expected).abs() > eps {
    fail("Expected \{expected}, got \{value}")
  }
}

///|
fn overlap_dir_right() -> Direction {
  direction_values()[1]
}

///|
fn overlap_dir_down() -> Direction {
  direction_values()[3]
}

///|
test "RectangleStripOverlapRemover downward removal" {
  let rectangle1 = new_elk_rectangle_xywh(0.0, 0.0, 10.0, 10.0)
  let rectangle2 = new_elk_rectangle_xywh(5.0, 0.0, 10.0, 10.0)

  let strip_size = create_rectangle_strip_overlap_remover_for_direction(
      overlap_dir_down(),
    )
    .with_gap(0.0, 0.0)
    .with_start_coordinate(0.0)
    .add_rectangle(rectangle1)
    .add_rectangle(rectangle2)
    .remove_overlaps()

  overlaps_rect_eq(strip_size, 20.0)
  overlaps_rect_eq(rectangle1.y, 0.0)
  overlaps_rect_eq(rectangle2.y, 10.0)
}

///|
test "RectangleStripOverlapRemover rightward removal" {
  let rectangle1 = new_elk_rectangle_xywh(0.0, 0.0, 10.0, 10.0)
  let rectangle2 = new_elk_rectangle_xywh(0.0, 5.0, 10.0, 10.0)

  let strip_size = create_rectangle_strip_overlap_remover_for_direction(
      overlap_dir_right(),
    )
    .with_gap(0.0, 0.0)
    .with_start_coordinate(0.0)
    .add_rectangle(rectangle1)
    .add_rectangle(rectangle2)
    .remove_overlaps()

  overlaps_rect_eq(strip_size, 20.0)
  overlaps_rect_eq(rectangle1.x, 0.0)
  overlaps_rect_eq(rectangle2.x, 10.0)
}

///|
fn overlaps_test_strategy(
  _overlap_remover : RectangleStripOverlapRemover,
) -> Double {
  77.0
}

///|
test "RectangleStripOverlapRemover custom strategy" {
  let rectangle = new_elk_rectangle_xywh(0.0, 0.0, 10.0, 10.0)

  let strip_size = create_rectangle_strip_overlap_remover_for_direction(
      overlap_dir_down(),
    )
    .with_overlap_removal_strategy(overlaps_test_strategy)
    .add_rectangle(rectangle)
    .remove_overlaps()

  overlaps_rect_eq(strip_size, 77.0)
}
