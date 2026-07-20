///|
using @runtime {
  type LGraph,
  internal_properties_graph_properties,
  new_l_graph,
  new_l_node,
}

///|
using @options {
  type GraphProperties,
  graph_properties_to_string,
  graph_properties_values,
}

///|
using @test {
  create_edge,
  create_graph,
  edge_add_source,
  edge_add_target,
  reset_graph_model_for_test,
}

///|
let _pipeline_engine_linked_for_blackbox_tests : Bool = @engine.layered_engine_linked

///|
type ILayoutExecutionListener[T] = @core.ILayoutExecutionListener[T]

///|
let make_node_shape = @graph.make_node_shape

///|
let new_i_label_manager = @core.new_i_label_manager

///|
fn[T] new_layout_execution_listener(
  layout_processor_ready_fn : (Int, T, Bool) -> Unit,
  layout_processor_finished_fn : (Int, T, Bool) -> Unit,
) -> ILayoutExecutionListener[T] {
  @core.new_layout_execution_listener(
    layout_processor_ready_fn, layout_processor_finished_fn,
  )
}

///|
fn new_elk_progress_monitor(
  task_name? : String = "",
) -> @core.IElkProgressMonitor {
  @core.new_elk_progress_monitor(task_name~)
}

///|
fn assert_double_eq(
  actual : Double,
  expected : Double,
  tolerance : Double,
) -> Unit {
  if (actual - expected).abs() > tolerance {
    abort("expected=\{expected} actual=\{actual}")
  }
}
