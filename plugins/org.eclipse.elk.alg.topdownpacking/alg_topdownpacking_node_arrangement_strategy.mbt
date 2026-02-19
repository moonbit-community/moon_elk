///|
pub enum NodeArrangementStrategy {
  LEFT_RIGHT_TOP_DOWN_NODE_PLACER
}

///|
pub fn topdownpacking_node_arrangement_strategy_from_string(
  value : String,
) -> NodeArrangementStrategy {
  if value == "LEFT_RIGHT_TOP_DOWN_NODE_PLACER" {
    NodeArrangementStrategy::LEFT_RIGHT_TOP_DOWN_NODE_PLACER
  } else {
    NodeArrangementStrategy::LEFT_RIGHT_TOP_DOWN_NODE_PLACER
  }
}

///|
pub fn topdownpacking_node_arrangement_strategy_phase_factory(
  strategy : NodeArrangementStrategy,
) -> ILayoutPhaseFactory[TopdownPackingPhases, GridElkNode] {
  match strategy {
    LEFT_RIGHT_TOP_DOWN_NODE_PLACER =>
      new_layout_processor_factory(80000, 0, () => {
        new_topdownpacking_left_right_top_down_node_placer_layout_phase()
      })
  }
}

///|
pub fn topdownpacking_node_arrangement_strategy_create_node_arranger(
  strategy : NodeArrangementStrategy,
) -> INodeArranger {
  match strategy {
    LEFT_RIGHT_TOP_DOWN_NODE_PLACER =>
      new_topdownpacking_left_right_top_down_node_placer_node_arranger()
  }
}
