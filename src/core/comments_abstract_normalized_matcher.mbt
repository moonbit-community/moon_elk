///|
pub(all) enum NormalizationFunction {
  Linear
  Binary
}

///|
pub(all) struct AbstractNormalizedMatcher[C, T] {
  raw_fn : (C, T) -> Double
  mut worst_raw_value : Double
  mut best_raw_value : Double
  mut normalization_function : NormalizationFunction
}

///|
pub fn[C, T] new_abstract_normalized_matcher(
  raw_fn : (C, T) -> Double,
) -> AbstractNormalizedMatcher[C, T] {
  {
    raw_fn,
    worst_raw_value: 0.0,
    best_raw_value: 1.0,
    normalization_function: NormalizationFunction::Linear,
  }
}

///|
pub fn[C, T] AbstractNormalizedMatcher::with_bounds(
  self : AbstractNormalizedMatcher[C, T],
  worst_raw_val : Double,
  best_raw_val : Double,
) -> AbstractNormalizedMatcher[C, T] {
  self.worst_raw_value = worst_raw_val
  self.best_raw_value = best_raw_val
  self
}

///|
pub fn[C, T] AbstractNormalizedMatcher::with_normalization_function(
  self : AbstractNormalizedMatcher[C, T],
  normalization_function : NormalizationFunction,
) -> AbstractNormalizedMatcher[C, T] {
  self.normalization_function = normalization_function
  self
}

///|
pub fn[C, T] AbstractNormalizedMatcher::get_worst_raw_value(
  self : AbstractNormalizedMatcher[C, T],
) -> Double {
  self.worst_raw_value
}

///|
pub fn[C, T] AbstractNormalizedMatcher::get_best_raw_value(
  self : AbstractNormalizedMatcher[C, T],
) -> Double {
  self.best_raw_value
}

///|
pub fn[C, T] AbstractNormalizedMatcher::raw(
  self : AbstractNormalizedMatcher[C, T],
  comment : C,
  target : T,
) -> Double {
  (self.raw_fn)(comment, target)
}

///|
pub fn[C, T] AbstractNormalizedMatcher::normalized(
  self : AbstractNormalizedMatcher[C, T],
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
pub fn[C, T] AbstractNormalizedMatcher::normalize_linear(
  self : AbstractNormalizedMatcher[C, T],
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
pub fn[C, T] AbstractNormalizedMatcher::normalize_binary(
  self : AbstractNormalizedMatcher[C, T],
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
pub fn[C, T] AbstractNormalizedMatcher::as_matcher(
  self : AbstractNormalizedMatcher[C, T],
) -> IMatcher[C, T] {
  new_matcher_with_default_lifecycle(
    (comment, target) => self.raw(comment, target),
    (comment, target) => self.normalized(comment, target),
  )
}
