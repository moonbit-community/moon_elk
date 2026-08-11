///|
pub enum NodeYPlacerStrategy {
  SIMPLE_Y_PLACING
}

///|
pub fn vertiflex_node_y_placer_phase_factory(
  session : VertiFlexSession,
  strategy : NodeYPlacerStrategy,
  graph : @graph.ElkNode,
) -> @core.LayoutProcessorFactory {
  match strategy {
    SIMPLE_Y_PLACING =>
      @core.new_layout_processor_factory(81000, 0, graph, () => {
        new_vertiflex_node_y_placer_layout_phase(session)
      })
  }
}
