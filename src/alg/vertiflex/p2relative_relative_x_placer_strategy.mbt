///|
pub enum RelativeXPlacerStrategy {
  SIMPLE_X_PLACING
}

///|
pub fn vertiflex_relative_x_placer_phase_factory(
  session : VertiFlexSession,
  strategy : RelativeXPlacerStrategy,
  graph : @graph.ElkNode,
) -> @core.LayoutProcessorFactory {
  match strategy {
    SIMPLE_X_PLACING =>
      @core.new_layout_processor_factory(81001, 1, graph, () => {
        new_vertiflex_relative_x_placer_layout_phase(session)
      })
  }
}
