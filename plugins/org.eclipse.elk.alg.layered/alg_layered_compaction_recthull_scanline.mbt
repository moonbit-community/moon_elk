///|
pub type LayeredScanlineEventHandler[T] = (T) -> Unit

///|
fn[T] layered_scanline_sort_in_place(
  points : Array[T],
  comparator : (T, T) -> Int,
) -> Unit {
  let length = points.length()
  for i in 1..<length {
    let current = points[i]
    let mut j = i
    while j > 0 && comparator(current, points[j - 1]) < 0 {
      points[j] = points[j - 1]
      j -= 1
    }
    points[j] = current
  }
}

///|
pub fn[T] layered_scanline_execute(
  points : Array[T],
  comparator : (T, T) -> Int,
  event_handlers : Array[LayeredScanlineEventHandler[T]],
) -> Unit {
  let copy = points.copy()
  layered_scanline_sort_in_place(copy, comparator)
  for point in copy {
    for handler in event_handlers {
      handler(point)
    }
  }
}

///|
pub fn[T] layered_scanline_execute_single(
  points : Array[T],
  comparator : (T, T) -> Int,
  event_handler : LayeredScanlineEventHandler[T],
) -> Unit {
  layered_scanline_execute(points, comparator, [event_handler])
}
