///|
pub enum AbsoluteXPlacerStrategy {
  ABSOLUTE_XPLACING
}

///|
pub fn vertiflex_absolute_x_placer_phase_factory(
  session : VertiFlexSession,
  strategy : AbsoluteXPlacerStrategy,
  graph : @graph.ElkNode,
) -> @core.LayoutProcessorFactory {
  match strategy {
    ABSOLUTE_XPLACING =>
      @core.new_layout_processor_factory(81002, 2, graph, () => {
        new_vertiflex_absolute_x_placer_layout_phase(session)
      })
  }
}
