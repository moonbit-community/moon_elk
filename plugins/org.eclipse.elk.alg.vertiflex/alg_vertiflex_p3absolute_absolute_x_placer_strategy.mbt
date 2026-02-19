///|
pub enum AbsoluteXPlacerStrategy {
  ABSOLUTE_XPLACING
}

///|
pub fn vertiflex_absolute_x_placer_phase_factory(
  strategy : AbsoluteXPlacerStrategy,
) -> ILayoutPhaseFactory[VertiFlexLayoutPhases, ElkNode] {
  match strategy {
    ABSOLUTE_XPLACING =>
      new_layout_processor_factory(81002, 2, () => {
        new_vertiflex_absolute_x_placer_layout_phase()
      })
  }
}
