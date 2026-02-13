///|
pub let orthogonal_routing_generator_tolerance : Double = 0.001

///|
pub fn orthogonal_routing_generator_count_crossings(
  positions : Array[Double],
  start : Double,
  end : Double,
) -> Int {
  let mut crossings = 0
  for position in positions {
    if position > end {
      break
    } else if position >= start {
      crossings = crossings + 1
    }
  }
  crossings
}
