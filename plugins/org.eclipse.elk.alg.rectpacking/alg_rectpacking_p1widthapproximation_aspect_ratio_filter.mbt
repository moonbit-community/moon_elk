///|
pub fn rectpacking_aspect_ratio_filter(
  candidates : Array[RectpackingDrawingData],
  aspect_ratio : Double,
  padding : Spacing,
) -> Array[RectpackingDrawingData] {
  let remaining_candidates = []
  let mut smallest_deviation = @double.infinity
  for opt in candidates {
    smallest_deviation = @math.minimum(
      smallest_deviation,
      ((opt.drawing_width + padding.get_horizontal()) /
      (opt.drawing_height + padding.get_vertical()) -
      aspect_ratio).abs(),
    )
  }
  for candidate in candidates {
    if ((candidate.drawing_width + padding.get_horizontal()) /
      (candidate.drawing_height + padding.get_vertical()) -
      aspect_ratio).abs() ==
      smallest_deviation {
      remaining_candidates.push(candidate)
    }
  }
  remaining_candidates
}
