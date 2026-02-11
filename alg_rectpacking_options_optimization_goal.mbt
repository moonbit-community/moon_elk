///|
pub enum RectpackingOptimizationGoal {
  ASPECT_RATIO_DRIVEN
  MAX_SCALE_DRIVEN
  AREA_DRIVEN
}

///|
pub fn rectpacking_optimization_goal_from_string(
  value : String,
) -> RectpackingOptimizationGoal {
  if value == "ASPECT_RATIO_DRIVEN" {
    RectpackingOptimizationGoal::ASPECT_RATIO_DRIVEN
  } else if value == "AREA_DRIVEN" {
    RectpackingOptimizationGoal::AREA_DRIVEN
  } else {
    RectpackingOptimizationGoal::MAX_SCALE_DRIVEN
  }
}
