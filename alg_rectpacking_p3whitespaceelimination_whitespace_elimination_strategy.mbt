///|
pub enum RectpackingWhiteSpaceEliminationStrategy {
  EQUAL_BETWEEN_STRUCTURES
  TO_ASPECT_RATIO
  NONE
}

///|
fn rectpacking_whitespace_noop_process(
  graph : ElkNode,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  ignore(graph)
  match progress_monitor {
    Some(monitor) => {
      ignore(monitor.begin("No White Space Elimination", 1.0))
      monitor.done()
    }
    None => ()
  }
}

///|
fn new_rectpacking_whitespace_noop_layout_phase() -> ILayoutProcessor[
  RectPackingLayoutPhases,
  ElkNode,
] {
  new_layout_phase(rectpacking_whitespace_noop_process, _ => None)
}

///|
pub fn rectpacking_whitespace_elimination_strategy_from_string(
  value : String,
) -> RectpackingWhiteSpaceEliminationStrategy {
  if value == "EQUAL_BETWEEN_STRUCTURES" {
    RectpackingWhiteSpaceEliminationStrategy::EQUAL_BETWEEN_STRUCTURES
  } else if value == "TO_ASPECT_RATIO" {
    RectpackingWhiteSpaceEliminationStrategy::TO_ASPECT_RATIO
  } else {
    RectpackingWhiteSpaceEliminationStrategy::NONE
  }
}

///|
pub fn rectpacking_whitespace_elimination_strategy_phase_factory(
  strategy : RectpackingWhiteSpaceEliminationStrategy,
) -> ILayoutPhaseFactory[RectPackingLayoutPhases, ElkNode] {
  match strategy {
    EQUAL_BETWEEN_STRUCTURES =>
      new_layout_processor_factory(84200, 0, () => {
        new_rectpacking_equal_whitespace_eliminator_layout_phase()
      })
    TO_ASPECT_RATIO =>
      new_layout_processor_factory(84201, 1, () => {
        new_rectpacking_to_aspectratio_node_expander_layout_phase()
      })
    NONE =>
      new_layout_processor_factory(84202, 2, () => {
        new_rectpacking_whitespace_noop_layout_phase()
      })
  }
}
