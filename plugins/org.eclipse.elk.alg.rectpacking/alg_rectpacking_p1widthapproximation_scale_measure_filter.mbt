///|
pub fn rectpacking_scale_measure_filter(
  candidates : Array[RectpackingDrawingData],
  aspect_ratio : Double,
  padding : Spacing,
) -> Array[RectpackingDrawingData] {
  ignore(aspect_ratio)
  let remaining_candidates = []
  let mut max_scale = @double.neg_infinity
  for opt in candidates {
    max_scale = @math.maximum(
      max_scale,
      rectpacking_compute_scale_measure(
        opt.drawing_width + padding.get_horizontal(),
        opt.drawing_height + padding.get_vertical(),
        opt.desired_aspect_ratio,
      ),
    )
  }
  for candidate in candidates {
    if rectpacking_compute_scale_measure(
        candidate.drawing_width + padding.get_horizontal(),
        candidate.drawing_height + padding.get_vertical(),
        candidate.desired_aspect_ratio,
      ) ==
      max_scale {
      remaining_candidates.push(candidate)
    }
  }
  remaining_candidates
}
