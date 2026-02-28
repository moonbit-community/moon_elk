///|
pub enum NodeYPlacerStrategy {
  SIMPLE_Y_PLACING
}

///|
pub fn vertiflex_node_y_placer_phase_factory(
  strategy : NodeYPlacerStrategy,
) -> @core.ILayoutPhaseFactory[VertiFlexLayoutPhases, @graph.ElkNode] {
  match strategy {
    SIMPLE_Y_PLACING =>
      @core.new_layout_processor_factory(81000, 0, () => {
        new_vertiflex_node_y_placer_layout_phase()
      })
  }
}
