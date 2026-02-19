///|
pub enum WhitespaceEliminationStrategy {
  BOTTOM_ROW_EQUAL_WHITESPACE_ELIMINATOR
}

///|
pub fn topdownpacking_whitespace_elimination_strategy_from_string(
  value : String,
) -> WhitespaceEliminationStrategy {
  if value == "BOTTOM_ROW_EQUAL_WHITESPACE_ELIMINATOR" {
    WhitespaceEliminationStrategy::BOTTOM_ROW_EQUAL_WHITESPACE_ELIMINATOR
  } else {
    WhitespaceEliminationStrategy::BOTTOM_ROW_EQUAL_WHITESPACE_ELIMINATOR
  }
}

///|
pub fn topdownpacking_whitespace_elimination_strategy_phase_factory(
  strategy : WhitespaceEliminationStrategy,
) -> ILayoutPhaseFactory[TopdownPackingPhases, GridElkNode] {
  match strategy {
    BOTTOM_ROW_EQUAL_WHITESPACE_ELIMINATOR =>
      new_layout_processor_factory(80001, 1, () => {
        new_topdownpacking_bottom_row_equal_whitespace_eliminator_layout_phase()
      })
  }
}
