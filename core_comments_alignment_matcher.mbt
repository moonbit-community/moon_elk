///|
let alignment_matcher_out_top = 2

///|
let alignment_matcher_out_left = 1

///|
let alignment_matcher_out_right = 4

///|
let alignment_matcher_out_bottom = 8

///|
let alignment_matcher_out_top_left : Int = alignment_matcher_out_top |
  alignment_matcher_out_left

///|
let alignment_matcher_out_bottom_left : Int = alignment_matcher_out_bottom |
  alignment_matcher_out_left

///|
let alignment_matcher_out_top_right : Int = alignment_matcher_out_top |
  alignment_matcher_out_right

///|
let alignment_matcher_out_bottom_right : Int = alignment_matcher_out_bottom |
  alignment_matcher_out_right

///|
fn[C, T] alignment_matcher_bounds_provider_or_abort(
  matcher : AlignmentMatcher[C, T],
) -> IBoundsProvider[C, T] {
  match matcher.bounds_provider {
    Some(provider) => provider
    None => abort("A bounds provider is required.")
  }
}

///|
fn alignment_matcher_outcode(
  rect : ElkRectangle,
  x : Double,
  y : Double,
) -> Int {
  let mut out = 0

  if rect.width <= 0.0 {
    out = out | alignment_matcher_out_left | alignment_matcher_out_right
  } else if x < rect.x {
    out = out | alignment_matcher_out_left
  } else if x > rect.x + rect.width {
    out = out | alignment_matcher_out_right
  }

  if rect.height <= 0.0 {
    out = out | alignment_matcher_out_top | alignment_matcher_out_bottom
  } else if y < rect.y {
    out = out | alignment_matcher_out_top
  } else if y > rect.y + rect.height {
    out = out | alignment_matcher_out_bottom
  }

  out
}

///|
pub fn alignment_matcher_alignment(
  bounds1 : ElkRectangle,
  bounds2 : ElkRectangle,
) -> Double {
  let top_left_outcode = alignment_matcher_outcode(
    bounds2,
    bounds1.x,
    bounds1.y,
  )
  let bottom_right_outcode = alignment_matcher_outcode(
    bounds2,
    bounds1.x + bounds1.width,
    bounds1.y + bounds1.height,
  )

  if (bottom_right_outcode & top_left_outcode & alignment_matcher_out_top_left) ==
    alignment_matcher_out_top_left ||
    (bottom_right_outcode & top_left_outcode & alignment_matcher_out_top_right) ==
    alignment_matcher_out_top_right ||
    (
      bottom_right_outcode &
      top_left_outcode &
      alignment_matcher_out_bottom_left
    ) ==
    alignment_matcher_out_bottom_left ||
    (
      bottom_right_outcode &
      top_left_outcode &
      alignment_matcher_out_bottom_right
    ) ==
    alignment_matcher_out_bottom_right {
    -1.0
  } else {
    let horizontal_alignment_left = (bounds2.x - bounds1.x).abs()
    let horizontal_alignment_right = (bounds2.x +
    bounds2.width -
    bounds1.x -
    bounds1.width).abs()
    let horizontal_alignment_offset = if horizontal_alignment_left <
      horizontal_alignment_right {
      horizontal_alignment_left
    } else {
      horizontal_alignment_right
    }

    let vertical_alignment_top = (bounds2.y - bounds1.y).abs()
    let vertical_alignment_bottom = (bounds2.y +
    bounds2.height -
    bounds1.y -
    bounds1.height).abs()
    let vertical_alignment_offset = if vertical_alignment_top <
      vertical_alignment_bottom {
      vertical_alignment_top
    } else {
      vertical_alignment_bottom
    }

    if bounds2.intersects(bounds1) {
      if horizontal_alignment_offset < vertical_alignment_offset {
        horizontal_alignment_offset
      } else {
        vertical_alignment_offset
      }
    } else if (bottom_right_outcode & alignment_matcher_out_top) != 0 ||
      (top_left_outcode & alignment_matcher_out_bottom) != 0 {
      horizontal_alignment_offset
    } else if (bottom_right_outcode & alignment_matcher_out_left) != 0 ||
      (top_left_outcode & alignment_matcher_out_right) != 0 {
      vertical_alignment_offset
    } else if bounds1.y == bounds2.y + bounds2.height ||
      bounds1.y + bounds1.height == bounds2.y {
      horizontal_alignment_offset
    } else if bounds1.x == bounds2.x + bounds2.width ||
      bounds1.x + bounds1.width == bounds2.x {
      vertical_alignment_offset
    } else {
      -1.0
    }
  }
}

///|
pub struct AlignmentMatcher[C, T] {
  mut bounds_provider : IBoundsProvider[C, T]?
  mut worst_raw_value : Double
  mut best_raw_value : Double
  mut normalization_function : NormalizationFunction
}

///|
pub fn[C, T] new_alignment_matcher() -> AlignmentMatcher[C, T] {
  {
    bounds_provider: None,
    worst_raw_value: 0.0,
    best_raw_value: 1.0,
    normalization_function: NormalizationFunction::Linear,
  }
}

///|
pub fn[C, T] AlignmentMatcher::with_maximum_alignment_offset(
  self : AlignmentMatcher[C, T],
  offset : Double,
) -> AlignmentMatcher[C, T] {
  if offset <= 0.0 {
    abort("Maximum alignment offset must be > 0.")
  }

  self.worst_raw_value = offset
  self.best_raw_value = 0.0
  self
}

///|
pub fn[C, T] AlignmentMatcher::with_bounds_provider(
  self : AlignmentMatcher[C, T],
  provider : IBoundsProvider[C, T],
) -> AlignmentMatcher[C, T] {
  self.bounds_provider = Some(provider)
  self
}

///|
pub fn[C, T] AlignmentMatcher::with_normalization_function(
  self : AlignmentMatcher[C, T],
  normalization_function : NormalizationFunction,
) -> AlignmentMatcher[C, T] {
  self.normalization_function = normalization_function
  self
}

///|
pub fn[C, T] AlignmentMatcher::get_worst_raw_value(
  self : AlignmentMatcher[C, T],
) -> Double {
  self.worst_raw_value
}

///|
pub fn[C, T] AlignmentMatcher::get_best_raw_value(
  self : AlignmentMatcher[C, T],
) -> Double {
  self.best_raw_value
}

///|
pub fn[C, T] AlignmentMatcher::check_configuration(
  self : AlignmentMatcher[C, T],
) -> Unit {
  ignore(alignment_matcher_bounds_provider_or_abort(self))
}

///|
pub fn[C, T] AlignmentMatcher::preprocess(
  self : AlignmentMatcher[C, T],
  _data_provider : IDataProvider[C, T],
  _include_hierarchy : Bool,
) -> Unit {
  self.check_configuration()
}

///|
pub fn[C, T] AlignmentMatcher::raw(
  self : AlignmentMatcher[C, T],
  comment : C,
  target : T,
) -> Double {
  let bounds_provider = alignment_matcher_bounds_provider_or_abort(self)
  let comment_bounds = match bounds_provider.bounds_for_comment(comment) {
    Some(bounds) => bounds
    None => abort("Bounds for comment are unavailable.")
  }
  let target_bounds = match bounds_provider.bounds_for_target(target) {
    Some(bounds) => bounds
    None => abort("Bounds for target are unavailable.")
  }

  let alignment = alignment_matcher_alignment(comment_bounds, target_bounds)
  if alignment == -1.0 {
    self.get_worst_raw_value()
  } else {
    alignment
  }
}

///|
pub fn[C, T] AlignmentMatcher::normalize_linear(
  self : AlignmentMatcher[C, T],
  raw : Double,
) -> Double {
  if self.worst_raw_value < self.best_raw_value {
    if raw <= self.worst_raw_value {
      0.0
    } else if raw >= self.best_raw_value {
      1.0
    } else {
      (raw - self.worst_raw_value) /
      (self.best_raw_value - self.worst_raw_value)
    }
  } else if self.best_raw_value < self.worst_raw_value {
    if raw <= self.best_raw_value {
      1.0
    } else if raw >= self.worst_raw_value {
      0.0
    } else {
      1.0 -
      (raw - self.best_raw_value) / (self.worst_raw_value - self.best_raw_value)
    }
  } else if raw == self.best_raw_value {
    1.0
  } else {
    0.0
  }
}

///|
pub fn[C, T] AlignmentMatcher::normalize_binary(
  self : AlignmentMatcher[C, T],
  raw : Double,
) -> Double {
  if self.worst_raw_value < self.best_raw_value {
    if raw <= self.worst_raw_value {
      0.0
    } else {
      1.0
    }
  } else if self.best_raw_value < self.worst_raw_value {
    if raw >= self.worst_raw_value {
      0.0
    } else {
      1.0
    }
  } else if raw == self.best_raw_value {
    1.0
  } else {
    0.0
  }
}

///|
pub fn[C, T] AlignmentMatcher::normalized(
  self : AlignmentMatcher[C, T],
  comment : C,
  target : T,
) -> Double {
  let raw_value = self.raw(comment, target)
  match self.normalization_function {
    NormalizationFunction::Linear => self.normalize_linear(raw_value)
    NormalizationFunction::Binary => self.normalize_binary(raw_value)
  }
}

///|
pub fn[C, T] AlignmentMatcher::as_matcher(
  self : AlignmentMatcher[C, T],
) -> IMatcher[C, T] {
  new_matcher(
    (comment, target) => self.raw(comment, target),
    (comment, target) => self.normalized(comment, target),
    (data_provider, include_hierarchy) => {
      self.preprocess(data_provider, include_hierarchy)
    },
    () => (),
  )
}
