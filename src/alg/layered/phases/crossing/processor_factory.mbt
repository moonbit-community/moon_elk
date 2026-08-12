///|
fn layered_intermediate_processor_factory(
  graph : @runtime.LGraph,
  strategy : @runtime.IntermediateProcessorStrategy,
) -> @core.LayoutProcessorFactory {
  @intermediate.processor_factory(graph, strategy)
}
