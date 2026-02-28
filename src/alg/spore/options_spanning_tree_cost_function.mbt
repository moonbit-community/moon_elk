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
    SporeSpanningTreeCostFunction::CENTER_DISTANCE
  } else if value == "CIRCLE_UNDERLAP" {
    SporeSpanningTreeCostFunction::CIRCLE_UNDERLAP
  } else if value == "RECTANGLE_UNDERLAP" {
    SporeSpanningTreeCostFunction::RECTANGLE_UNDERLAP
  } else if value == "INVERTED_OVERLAP" {
    SporeSpanningTreeCostFunction::INVERTED_OVERLAP
  } else if value == "MINIMUM_ROOT_DISTANCE" {
    SporeSpanningTreeCostFunction::MINIMUM_ROOT_DISTANCE
  } else {
    SporeSpanningTreeCostFunction::CIRCLE_UNDERLAP
  }
}
