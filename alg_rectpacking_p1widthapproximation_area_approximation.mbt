///|
pub struct RectpackingAreaApproximation {
  aspect_ratio : Double
  goal : RectpackingOptimizationGoal
  last_place_shift : Bool
}

///|
pub fn new_rectpacking_area_approximation(
  aspect_ratio : Double,
  goal : RectpackingOptimizationGoal,
  last_place_shift : Bool,
) -> RectpackingAreaApproximation {
  { aspect_ratio, goal, last_place_shift }
}

///|
fn rectpacking_descriptor_equal(
  a : RectpackingDrawingDataDescriptor,
  b : RectpackingDrawingDataDescriptor,
) -> Bool {
  match (a, b) {
    (
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_LAST_PLACED_RIGHT,
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_LAST_PLACED_RIGHT,
    ) => true
    (
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_LAST_PLACED_BELOW,
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_LAST_PLACED_BELOW,
    ) => true
    (
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_WHOLE_DRAWING_RIGHT,
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_WHOLE_DRAWING_RIGHT,
    ) => true
    (
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_WHOLE_DRAWING_BELOW,
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_WHOLE_DRAWING_BELOW,
    ) => true
    (
      RectpackingDrawingDataDescriptor::WHOLE_DRAWING,
      RectpackingDrawingDataDescriptor::WHOLE_DRAWING,
    ) => true
    _ => false
  }
}

///|
fn rectpacking_area_approximation_filters(
  goal : RectpackingOptimizationGoal,
) -> Array[RectpackingBestCandidateFilter] {
  match goal {
    RectpackingOptimizationGoal::MAX_SCALE_DRIVEN =>
      [
        rectpacking_scale_measure_filter, rectpacking_area_filter, rectpacking_aspect_ratio_filter,
      ]
    RectpackingOptimizationGoal::ASPECT_RATIO_DRIVEN =>
      [
        rectpacking_aspect_ratio_filter, rectpacking_area_filter, rectpacking_scale_measure_filter,
      ]
    RectpackingOptimizationGoal::AREA_DRIVEN =>
      [
        rectpacking_area_filter, rectpacking_scale_measure_filter, rectpacking_aspect_ratio_filter,
      ]
  }
}

///|
fn rectpacking_area_approximation_check_special_cases(
  drawing1 : RectpackingDrawingData,
  drawing2 : RectpackingDrawingData,
  last_placed : ElkNode,
  to_place : ElkNode,
) -> RectpackingDrawingData {
  let first_opt = drawing1.placement_option
  let second_opt = drawing2.placement_option

  let first_opt_lpb_or_cdb = rectpacking_descriptor_equal(
      first_opt,
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_LAST_PLACED_BELOW,
    ) ||
    rectpacking_descriptor_equal(
      first_opt,
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_WHOLE_DRAWING_BELOW,
    )
  let second_opt_lpb_or_cdb = rectpacking_descriptor_equal(
      second_opt,
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_LAST_PLACED_BELOW,
    ) ||
    rectpacking_descriptor_equal(
      second_opt,
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_WHOLE_DRAWING_BELOW,
    )

  let first_opt_lpr_or_cdr = rectpacking_descriptor_equal(
      first_opt,
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_LAST_PLACED_RIGHT,
    ) ||
    rectpacking_descriptor_equal(
      first_opt,
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_WHOLE_DRAWING_RIGHT,
    )
  let second_opt_lpr_or_cdr = rectpacking_descriptor_equal(
      second_opt,
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_LAST_PLACED_RIGHT,
    ) ||
    rectpacking_descriptor_equal(
      second_opt,
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_WHOLE_DRAWING_RIGHT,
    )

  let first_opt_lpr_or_lpb = rectpacking_descriptor_equal(
      first_opt,
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_LAST_PLACED_RIGHT,
    ) ||
    rectpacking_descriptor_equal(
      first_opt,
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_LAST_PLACED_BELOW,
    )
  let second_opt_lpr_or_lpb = rectpacking_descriptor_equal(
      second_opt,
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_LAST_PLACED_RIGHT,
    ) ||
    rectpacking_descriptor_equal(
      second_opt,
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_LAST_PLACED_BELOW,
    )

  if first_opt_lpb_or_cdb && second_opt_lpb_or_cdb {
    if rectpacking_descriptor_equal(
        drawing1.placement_option,
        RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_WHOLE_DRAWING_BELOW,
      ) {
      return drawing1
    } else {
      return drawing2
    }
  } else if first_opt_lpr_or_cdr && second_opt_lpr_or_cdr {
    if rectpacking_descriptor_equal(
        drawing1.placement_option,
        RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_WHOLE_DRAWING_RIGHT,
      ) {
      return drawing1
    } else {
      return drawing2
    }
  } else if first_opt_lpr_or_lpb && second_opt_lpr_or_lpb {
    let lpr_opt = if rectpacking_descriptor_equal(
        first_opt,
        RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_LAST_PLACED_RIGHT,
      ) {
      drawing1
    } else {
      drawing2
    }
    let lpb_opt = if rectpacking_descriptor_equal(
        first_opt,
        RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_LAST_PLACED_RIGHT,
      ) {
      drawing2
    } else {
      drawing1
    }

    let area_lpr = rectpacking_calculations_area_lpr(
      last_placed, to_place, lpr_opt,
    )
    let area_lpb = rectpacking_calculations_area_lpb(
      last_placed, to_place, lpb_opt,
    )

    if area_lpr <= area_lpb {
      if rectpacking_descriptor_equal(
          drawing1.placement_option,
          RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_LAST_PLACED_RIGHT,
        ) {
        return drawing1
      } else {
        return drawing2
      }
    } else if rectpacking_descriptor_equal(
        drawing1.placement_option,
        RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_LAST_PLACED_BELOW,
      ) {
      return drawing1
    } else {
      return drawing2
    }
  }

  drawing1
}

///|
fn rectpacking_area_approximation_calc_values_for_opt(
  approximation : RectpackingAreaApproximation,
  option : RectpackingDrawingDataDescriptor,
  to_place : ElkNode,
  last_placed : ElkNode,
  drawing : RectpackingDrawingData,
  placed_rects : Array[ElkNode],
  node_node_spacing : Double,
) -> RectpackingDrawingData {
  let mut x = 0.0
  let mut y = 0.0
  let drawing_width = drawing.drawing_width
  let drawing_height = drawing.drawing_height
  let height_to_place = node_height(to_place)
  let width_to_place = node_width(to_place)

  let mut width = 0.0
  let mut height = 0.0
  match option {
    RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_LAST_PLACED_RIGHT => {
      x = node_x(last_placed) + node_width(last_placed) + node_node_spacing
      if approximation.last_place_shift {
        y = rectpacking_calculations_y_for_lpr(
          x, placed_rects, last_placed, node_node_spacing,
        )
      } else {
        y = node_y(last_placed)
      }
      width = rectpacking_calculations_width_lpr_or_lpb(
        drawing_width, x, width_to_place,
      )
      height = rectpacking_calculations_height_lpr_or_lpb(
        drawing_height, y, height_to_place,
      )
    }
    RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_LAST_PLACED_BELOW => {
      y = node_y(last_placed) + node_height(last_placed) + node_node_spacing
      if approximation.last_place_shift {
        x = rectpacking_calculations_x_for_lpb(
          y, placed_rects, last_placed, node_node_spacing,
        )
      } else {
        x = node_x(last_placed)
      }
      width = rectpacking_calculations_width_lpr_or_lpb(
        drawing_width, x, width_to_place,
      )
      height = rectpacking_calculations_height_lpr_or_lpb(
        drawing_height, y, height_to_place,
      )
    }
    RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_WHOLE_DRAWING_RIGHT => {
      x = drawing_width + node_node_spacing
      y = 0.0
      width = drawing_width + node_node_spacing + width_to_place
      height = @cmp.maximum(drawing_height, height_to_place)
    }
    RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_WHOLE_DRAWING_BELOW => {
      x = 0.0
      y = drawing_height + node_node_spacing
      width = @cmp.maximum(drawing_width, width_to_place)
      height = drawing_height + node_node_spacing + height_to_place
    }
    _ => abort("Illegal placement option")
  }

  new_rectpacking_drawing_data(
    approximation.aspect_ratio,
    width,
    height,
    option,
    next_x_coordinate=x,
    next_y_coordinate=y,
  )
}

///|
fn rectpacking_area_approximation_find_best_candidate(
  approximation : RectpackingAreaApproximation,
  opt1 : RectpackingDrawingData,
  opt2 : RectpackingDrawingData,
  opt3 : RectpackingDrawingData,
  opt4 : RectpackingDrawingData,
  to_place : ElkNode,
  last_placed : ElkNode,
  padding : Spacing,
) -> RectpackingDrawingData {
  let mut candidates = [opt1, opt2, opt3, opt4]
  let filters = rectpacking_area_approximation_filters(approximation.goal)

  for filter in filters {
    if candidates.length() > 1 {
      candidates = filter(candidates, approximation.aspect_ratio, padding)
    }
  }

  if candidates.length() == 1 {
    return candidates[candidates.length() - 1]
  }
  if candidates.length() == 2 {
    return rectpacking_area_approximation_check_special_cases(
      candidates[0],
      candidates[1],
      last_placed,
      to_place,
    )
  }
  candidates[0]
}

///|
pub fn RectpackingAreaApproximation::approx_bounding_box(
  self : RectpackingAreaApproximation,
  rectangles : Array[ElkNode],
  node_node_spacing : Double,
  padding : Spacing,
) -> RectpackingDrawingData {
  let first_rect = rectangles[0]
  node_set_location(first_rect, 0.0, 0.0)

  let placed_rects = [first_rect]
  let mut last_placed = first_rect
  let mut current_values = new_rectpacking_drawing_data(
    self.aspect_ratio,
    node_width(first_rect),
    node_height(first_rect),
    RectpackingDrawingDataDescriptor::WHOLE_DRAWING,
  )

  let mut rectangle_idx = 1
  while rectangle_idx < rectangles.length() {
    let to_place = rectangles[rectangle_idx]

    let opt1 = rectpacking_area_approximation_calc_values_for_opt(
      self,
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_LAST_PLACED_RIGHT,
      to_place,
      last_placed,
      current_values,
      placed_rects,
      node_node_spacing,
    )
    let opt2 = rectpacking_area_approximation_calc_values_for_opt(
      self,
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_LAST_PLACED_BELOW,
      to_place,
      last_placed,
      current_values,
      placed_rects,
      node_node_spacing,
    )
    let opt3 = rectpacking_area_approximation_calc_values_for_opt(
      self,
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_WHOLE_DRAWING_RIGHT,
      to_place,
      last_placed,
      current_values,
      placed_rects,
      node_node_spacing,
    )
    let opt4 = rectpacking_area_approximation_calc_values_for_opt(
      self,
      RectpackingDrawingDataDescriptor::CANDIDATE_POSITION_WHOLE_DRAWING_BELOW,
      to_place,
      last_placed,
      current_values,
      placed_rects,
      node_node_spacing,
    )

    let best_opt = rectpacking_area_approximation_find_best_candidate(
      self, opt1, opt2, opt3, opt4, to_place, last_placed, padding,
    )

    node_set_location(
      to_place,
      best_opt.next_x_coordinate,
      best_opt.next_y_coordinate,
    )
    best_opt.placement_option = RectpackingDrawingDataDescriptor::WHOLE_DRAWING
    current_values = best_opt
    last_placed = to_place
    placed_rects.push(to_place)
    rectangle_idx += 1
  }

  current_values
}
