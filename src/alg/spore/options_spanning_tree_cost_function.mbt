///|
pub enum SporeSpanningTreeCostFunction {
  CENTER_DISTANCE
  CIRCLE_UNDERLAP
  RECTANGLE_UNDERLAP
  INVERTED_OVERLAP
  MINIMUM_ROOT_DISTANCE
}

///|
pub fn spore_spanning_tree_cost_function_from_string(
  value : String,
) -> SporeSpanningTreeCostFunction {
  if value == "CENTER_DISTANCE" {
    CENTER_DISTANCE
  } else if value == "CIRCLE_UNDERLAP" {
    CIRCLE_UNDERLAP
  } else if value == "RECTANGLE_UNDERLAP" {
    RECTANGLE_UNDERLAP
  } else if value == "INVERTED_OVERLAP" {
    INVERTED_OVERLAP
  } else if value == "MINIMUM_ROOT_DISTANCE" {
    MINIMUM_ROOT_DISTANCE
  } else {
    CIRCLE_UNDERLAP
  }
}
