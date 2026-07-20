///|
using @runtime {
  type LEdge,
  type LGraph,
  type LNode,
  type LPort,
  type NodeType,
  internal_properties_ext_port_connections,
  internal_properties_graph_properties,
  internal_properties_origin_l_port,
  internal_properties_original_port_constraints,
  internal_properties_port_dummy,
  internal_properties_random_next_boolean,
  internal_properties_spacings,
  new_l_edge,
  new_l_graph,
  new_l_label_text,
  new_l_node,
  new_l_port,
  new_layer,
  node_type_values,
}

///|
using @options {
  type GraphProperties,
  type PortType,
  graph_properties_to_string,
  graph_properties_values,
  port_type_values,
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
