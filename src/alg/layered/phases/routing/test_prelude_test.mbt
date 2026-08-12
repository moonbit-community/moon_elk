///|
fn new_elk_progress_monitor(
  task_name? : String = "",
) -> @core.IElkProgressMonitor {
  @core.new_elk_progress_monitor(task_name~)
}

///|

///|
let new_kvector_chain_from_array = @core.new_kvector_chain_from_array

///|
fn layered_intermediate_processor_factory(
  graph : @runtime.LGraph,
  strategy : @runtime.IntermediateProcessorStrategy,
) -> @core.LayoutProcessorFactory {
  processor_factory(graph, strategy, None)
}
