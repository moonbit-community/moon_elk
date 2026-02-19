///|
pub enum EdgerouterStrategy {
  DIRECT_ROUTING
  BEND_ROUTING
}

///|
pub fn vertiflex_edgerouter_phase_factory(
  strategy : EdgerouterStrategy,
) -> @core.ILayoutPhaseFactory[VertiFlexLayoutPhases, @graph.ElkNode] {
  match strategy {
    DIRECT_ROUTING =>
      @core.new_layout_processor_factory(81003, 3, () => {
        new_vertiflex_straight_edge_router_layout_phase()
      })
    BEND_ROUTING =>
      @core.new_layout_processor_factory(81004, 3, () => {
        new_vertiflex_bend_edge_router_layout_phase()
      })
  }
}
