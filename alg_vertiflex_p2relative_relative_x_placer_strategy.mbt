///|
pub enum RelativeXPlacerStrategy {
  SIMPLE_X_PLACING
}

///|
pub fn vertiflex_relative_x_placer_phase_factory(
  strategy : RelativeXPlacerStrategy,
) -> ILayoutPhaseFactory[VertiFlexLayoutPhases, ElkNode] {
  match strategy {
    SIMPLE_X_PLACING =>
      new_layout_processor_factory(81001, 1, () => {
        new_vertiflex_relative_x_placer_layout_phase()
      })
  }
}
