///|
let distance_matcher_out_top = 2

///|
let distance_matcher_out_left = 1

///|
let distance_matcher_out_right = 4

///|
let distance_matcher_out_bottom = 8

///|
let distance_matcher_out_top_left : Int = distance_matcher_out_top |
  distance_matcher_out_left

///|
let distance_matcher_out_bottom_left : Int = distance_matcher_out_bottom |
  distance_matcher_out_left

///|
let distance_matcher_out_top_right : Int = distance_matcher_out_top |
  distance_matcher_out_right

///|
let distance_matcher_out_bottom_right : Int = distance_matcher_out_bottom |
  distance_matcher_out_right

///|
fn[C, T] distance_matcher_bounds_provider_or_abort(
  matcher : DistanceMatcher[C, T],
) -> IBoundsProvider[C, T] {
  match matcher.bounds_provider {
    Some(provider) => provider
    None => abort("A bounds provider is required.")
  }
}

///|
fn distance_matcher_outcode(rect : ElkRectangle, x : Double, y : Double) -> Int {
  let mut out = 0

  if rect.width <= 0.0 {
    out = out | distance_matcher_out_left | distance_matcher_out_right
  } else if x < rect.x {
    out = out | distance_matcher_out_left
  } else if x > rect.x + rect.width {
    out = out | distance_matcher_out_right
  }

  if rect.height <= 0.0 {
    out = out | distance_matcher_out_top | distance_matcher_out_bottom
  } else if y < rect.y {
    out = out | distance_matcher_out_top
  } else if y > rect.y + rect.height {
    out = out | distance_matcher_out_bottom
  }

  out
}

///|
fn distance_matcher_point_distance(
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
) -> Double {
  let delta_x = x2 - x1
  let delta_y = y2 - y1
  (delta_x * delta_x + delta_y * delta_y).sqrt()
}

///|
pub fn distance_matcher_distance(
  bounds1 : ElkRectangle,
  bounds2 : ElkRectangle,
) -> Double {
  if bounds1.intersects(bounds2) {
    return 0.0
  }

  let top_left_outcode = distance_matcher_outcode(bounds2, bounds1.x, bounds1.y)
  let bottom_right_outcode = distance_matcher_outcode(
    bounds2,
    bounds1.x + bounds1.width,
    bounds1.y + bounds1.height,
  )

  if (top_left_outcode & distance_matcher_out_top_left) ==
    distance_matcher_out_top_left &&
    (bottom_right_outcode & distance_matcher_out_top_left) ==
    distance_matcher_out_top_left {
    return distance_matcher_point_distance(
      bounds1.x + bounds1.width,
      bounds1.y + bounds1.height,
      bounds2.x,
      bounds2.y,
    )
  } else if (top_left_outcode & distance_matcher_out_bottom_left) ==
    distance_matcher_out_bottom_left &&
    (bottom_right_outcode & distance_matcher_out_bottom_left) ==
    distance_matcher_out_bottom_left {
    return distance_matcher_point_distance(
      bounds1.x + bounds1.width,
      bounds1.y,
      bounds2.x,
      bounds2.y + bounds2.height,
    )
  } else if (top_left_outcode & distance_matcher_out_top_right) ==
    distance_matcher_out_top_right &&
    (bottom_right_outcode & distance_matcher_out_top_right) ==
    distance_matcher_out_top_right {
    return distance_matcher_point_distance(
      bounds1.x,
      bounds1.y + bounds1.height,
      bounds2.x + bounds2.width,
      bounds2.y,
    )
  } else if (top_left_outcode & distance_matcher_out_bottom_right) ==
    distance_matcher_out_bottom_right &&
    (bottom_right_outcode & distance_matcher_out_bottom_right) ==
    distance_matcher_out_bottom_right {
    return distance_matcher_point_distance(
      bounds1.x,
      bounds1.y,
      bounds2.x + bounds2.width,
      bounds2.y + bounds2.height,
    )
  } else if (top_left_outcode & distance_matcher_out_left) != 0 &&
    (bottom_right_outcode & distance_matcher_out_left) != 0 {
    let distance = bounds2.x - bounds1.x + bounds1.width
    return distance
  } else if (top_left_outcode & distance_matcher_out_right) != 0 &&
    (bottom_right_outcode & distance_matcher_out_right) != 0 {
    let distance = bounds1.x - bounds2.x - bounds2.width
    return distance
  } else if (top_left_outcode & distance_matcher_out_top) != 0 &&
    (bottom_right_outcode & distance_matcher_out_top) != 0 {
    let distance = bounds2.y - bounds1.y + bounds1.height
    return distance
  } else if (top_left_outcode & distance_matcher_out_bottom) != 0 &&
    (bottom_right_outcode & distance_matcher_out_bottom) != 0 {
    let distance = bounds1.y - bounds2.y - bounds2.height
    return distance
  }

  if bounds2.x <= bounds1.x + bounds1.width &&
    bounds2.x + bounds2.width >= bounds1.x {
    if bounds2.y + bounds2.height == bounds1.y ||
      bounds2.y == bounds1.y + bounds1.height {
      return 0.0
    }
  } else if bounds2.y <= bounds1.y + bounds1.height &&
    bounds2.y + bounds2.height >= bounds1.y {
    if bounds2.x + bounds2.width == bounds1.x ||
      bounds2.x == bounds1.x + bounds1.width {
      return 0.0
    }
  }

  -1.0
}

///|
pub struct DistanceMatcher[C, T] {
  mut bounds_provider : IBoundsProvider[C, T]?
  mut worst_raw_value : Double
  mut best_raw_value : Double
  mut normalization_function : NormalizationFunction
}

///|
pub fn[C, T] new_distance_matcher() -> DistanceMatcher[C, T] {
  {
    bounds_provider: None,
    worst_raw_value: 0.0,
    best_raw_value: 1.0,
    normalization_function: NormalizationFunction::Linear,
  }
}

///|
pub fn[C, T] DistanceMatcher::with_maximum_attachment_distance(
  self : DistanceMatcher[C, T],
  distance : Double,
) -> DistanceMatcher[C, T] {
  if distance < 0.0 {
    abort("Maximum attachment distance must be >= 0.")
  }

  self.worst_raw_value = distance
  self.best_raw_value = 0.0
  self
}

///|
pub fn[C, T] DistanceMatcher::with_bounds_provider(
  self : DistanceMatcher[C, T],
  provider : IBoundsProvider[C, T],
) -> DistanceMatcher[C, T] {
  self.bounds_provider = Some(provider)
  self
}

///|
pub fn[C, T] DistanceMatcher::with_normalization_function(
  self : DistanceMatcher[C, T],
  normalization_function : NormalizationFunction,
) -> DistanceMatcher[C, T] {
  self.normalization_function = normalization_function
  self
}

///|
pub fn[C, T] DistanceMatcher::get_worst_raw_value(
  self : DistanceMatcher[C, T],
) -> Double {
  self.worst_raw_value
}

///|
pub fn[C, T] DistanceMatcher::get_best_raw_value(
  self : DistanceMatcher[C, T],
) -> Double {
  self.best_raw_value
}

///|
pub fn[C, T] DistanceMatcher::check_configuration(
  self : DistanceMatcher[C, T],
) -> Unit {
  ignore(distance_matcher_bounds_provider_or_abort(self))
}

///|
pub fn[C, T] DistanceMatcher::preprocess(
  self : DistanceMatcher[C, T],
  _data_provider : IDataProvider[C, T],
  _include_hierarchy : Bool,
) -> Unit {
  self.check_configuration()
}

///|
pub fn[C, T] DistanceMatcher::raw(
  self : DistanceMatcher[C, T],
  comment : C,
  target : T,
) -> Double {
  let bounds_provider = distance_matcher_bounds_provider_or_abort(self)
  let comment_bounds = match bounds_provider.bounds_for_comment(comment) {
    Some(bounds) => bounds
    None => abort("Bounds for comment are unavailable.")
  }
  let target_bounds = match bounds_provider.bounds_for_target(target) {
    Some(bounds) => bounds
    None => abort("Bounds for target are unavailable.")
  }

  let distance = distance_matcher_distance(comment_bounds, target_bounds)
  if distance == -1.0 {
    self.get_worst_raw_value()
  } else {
    distance
  }
}

///|
pub fn[C, T] DistanceMatcher::normalize_linear(
  self : DistanceMatcher[C, T],
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
pub fn[C, T] DistanceMatcher::normalize_binary(
  self : DistanceMatcher[C, T],
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
pub fn[C, T] DistanceMatcher::normalized(
  self : DistanceMatcher[C, T],
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
pub fn[C, T] DistanceMatcher::as_matcher(
  self : DistanceMatcher[C, T],
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
