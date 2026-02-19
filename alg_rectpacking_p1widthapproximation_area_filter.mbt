///|
pub fn rectpacking_area_filter(
  candidates : Array[RectpackingDrawingData],
  aspect_ratio : Double,
  padding : Spacing,
) -> Array[RectpackingDrawingData] {
  ignore(aspect_ratio)
  let remaining_candidates = []
  let mut min_area = @double.infinity
  for opt in candidates {
    min_area = @math.minimum(
      min_area,
      (opt.drawing_width + padding.get_horizontal()) *
      (opt.drawing_height + padding.get_vertical()),
    )
  }
  for candidate in candidates {
    if (candidate.drawing_width + padding.get_horizontal()) *
      (candidate.drawing_height + padding.get_vertical()) ==
      min_area {
      remaining_candidates.push(candidate)
    }
  }
  remaining_candidates
}
