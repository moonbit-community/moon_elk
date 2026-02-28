///|
pub suberror AggregatedMatchDeciderException {
  AggregatedMatchDeciderException(String)
} derive(Show, ToJson)

///|
fn[T] aggregated_match_decider_raise(
  message : String,
) -> T raise AggregatedMatchDeciderException {
  raise AggregatedMatchDeciderException(message)
}

///|
fn aggregated_match_decider_exception_message(
  err : AggregatedMatchDeciderException,
) -> String {
  match err {
    AggregatedMatchDeciderException(message) => message
  }
}

///|
fn aggregated_match_decider_heuristic_values(
  matcher_results : Array[(Int, Double)],
) -> Array[Double] {
  let values = []
  for matcher_result in matcher_results {
    let (_, value) = matcher_result
    values.push(value)
  }
  values
}

///|
fn aggregated_match_decider_max_impl(
  values : Array[Double],
) -> Double raise AggregatedMatchDeciderException {
  if values.is_empty() {
    aggregated_match_decider_raise("Cannot aggregate an empty value list.")
  }
  let mut result = values[0]
  for i = 1; i < values.length(); i = i + 1 {
    if values[i] > result {
      result = values[i]
    }
  }
  result
}

///|
pub fn aggregated_match_decider_max(values : Array[Double]) -> Double {
  try aggregated_match_decider_max_impl(values) catch {
    err => {
      layout_runtime_report_unsupported_configuration(
        aggregated_match_decider_exception_message(err),
      )
      0.0
    }
  } noraise {
    value => value
  }
}

///|
fn aggregated_match_decider_min_impl(
  values : Array[Double],
) -> Double raise AggregatedMatchDeciderException {
  if values.is_empty() {
    aggregated_match_decider_raise("Cannot aggregate an empty value list.")
  }
  let mut result = values[0]
  for i = 1; i < values.length(); i = i + 1 {
    if values[i] < result {
      result = values[i]
    }
  }
  result
}

///|
pub fn aggregated_match_decider_min(values : Array[Double]) -> Double {
  try aggregated_match_decider_min_impl(values) catch {
    err => {
      layout_runtime_report_unsupported_configuration(
        aggregated_match_decider_exception_message(err),
      )
      0.0
    }
  } noraise {
    value => value
  }
}

///|
pub fn aggregated_match_decider_avg(values : Array[Double]) -> Double {
  if values.is_empty() {
    return 0.0
  }
  aggregated_match_decider_sum(values) / values.length().to_double()
}

///|
pub fn aggregated_match_decider_sum(values : Array[Double]) -> Double {
  let mut total = 0.0
  for value in values {
    total += value
  }
  total
}

///|
pub(all) struct AggregatedMatchDecider[T] {
  mut aggregator : (Array[Double]) -> Double
  mut lower_boundary : Double
  mut include_lower_boundary : Bool
  _phantom : T?
}

///|
pub fn[T] new_aggregated_match_decider() -> AggregatedMatchDecider[T] {
  {
    aggregator: aggregated_match_decider_max,
    lower_boundary: 0.0,
    include_lower_boundary: false,
    _phantom: None,
  }
}

///|
pub fn[T] AggregatedMatchDecider::with_aggregator(
  self : AggregatedMatchDecider[T],
  aggregator : (Array[Double]) -> Double,
) -> AggregatedMatchDecider[T] {
  self.aggregator = aggregator
  self
}

///|
pub fn[T] AggregatedMatchDecider::with_lower_attachment_boundary(
  self : AggregatedMatchDecider[T],
  lower : Double,
) -> AggregatedMatchDecider[T] raise AggregatedMatchDeciderException {
  if lower < 0.0 {
    aggregated_match_decider_raise("Lower boundary must be >= 0.")
  }
  self.lower_boundary = lower
  self
}

///|
pub fn[T] AggregatedMatchDecider::with_lower_boundary_included(
  self : AggregatedMatchDecider[T],
  include_boundary : Bool,
) -> AggregatedMatchDecider[T] {
  self.include_lower_boundary = include_boundary
  self
}

///|
fn[T] aggregated_match_decider_make_attachment_decision_impl(
  decider : AggregatedMatchDecider[T],
  normalized_heuristics : DeciderHeuristicResult[T],
) -> T? raise AggregatedMatchDeciderException {
  let mut max_aggregate = -1.0
  let mut max_target : T? = None

  for normalized_heuristic in normalized_heuristics {
    let (target, matcher_results) = normalized_heuristic
    let aggregate = (decider.aggregator)(
      aggregated_match_decider_heuristic_values(matcher_results),
    )
    if aggregate < 0.0 {
      aggregated_match_decider_raise("The aggregator provided a value < 0.")
    }

    if max_target is None || aggregate > max_aggregate {
      max_aggregate = aggregate
      max_target = Some(target)
    }
  }

  match max_target {
    Some(target) =>
      if decider.include_lower_boundary {
        if max_aggregate >= decider.lower_boundary {
          Some(target)
        } else {
          None
        }
      } else if max_aggregate > decider.lower_boundary {
        Some(target)
      } else {
        None
      }
    None => None
  }
}

///|
pub fn[T] AggregatedMatchDecider::make_attachment_decision(
  self : AggregatedMatchDecider[T],
  normalized_heuristics : DeciderHeuristicResult[T],
) -> T? {
  try
    aggregated_match_decider_make_attachment_decision_impl(
      self, normalized_heuristics,
    )
  catch {
    err => {
      layout_runtime_report_unsupported_configuration(
        aggregated_match_decider_exception_message(err),
      )
      None
    }
  } noraise {
    value => value
  }
}

///|
pub fn[T] AggregatedMatchDecider::as_decider(
  self : AggregatedMatchDecider[T],
) -> IDecider[T] {
  new_decider(heuristics => self.make_attachment_decision(heuristics))
}
