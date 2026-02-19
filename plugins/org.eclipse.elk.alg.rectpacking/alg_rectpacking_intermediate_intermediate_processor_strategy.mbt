///|
pub enum RectpackingIntermediateProcessorStrategy {
  NODE_SIZE_REORDERER
  INTERACTIVE_NODE_REORDERER
  MIN_SIZE_PRE_PROCESSOR
  MIN_SIZE_POST_PROCESSOR
}

///|
fn rectpacking_intermediate_processor_strategy_order(
  strategy : RectpackingIntermediateProcessorStrategy,
) -> Int {
  match strategy {
    NODE_SIZE_REORDERER => 0
    INTERACTIVE_NODE_REORDERER => 1
    MIN_SIZE_PRE_PROCESSOR => 2
    MIN_SIZE_POST_PROCESSOR => 3
  }
}

///|
pub fn rectpacking_intermediate_processor_factory(
  strategy : RectpackingIntermediateProcessorStrategy,
) -> ILayoutProcessorFactory[RectPackingLayoutPhases, ElkNode] {
  let order = rectpacking_intermediate_processor_strategy_order(strategy)
  let id = 84300 + order
  match strategy {
    NODE_SIZE_REORDERER =>
      new_layout_processor_factory(id, order, () => {
        new_rectpacking_node_size_reorderer_layout_processor()
      })
    INTERACTIVE_NODE_REORDERER =>
      new_layout_processor_factory(id, order, () => {
        new_rectpacking_interactive_node_reorderer_layout_processor()
      })
    MIN_SIZE_PRE_PROCESSOR =>
      new_layout_processor_factory(id, order, () => {
        new_rectpacking_min_size_pre_processor_layout_processor()
      })
    MIN_SIZE_POST_PROCESSOR =>
      new_layout_processor_factory(id, order, () => {
        new_rectpacking_min_size_post_processor_layout_processor()
      })
  }
}
