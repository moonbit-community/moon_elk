///|
let make_node_shape = @graph.make_node_shape

///|
fn new_elk_progress_monitor(
  task_name? : String = "",
) -> @core.IElkProgressMonitor {
  @core.new_elk_progress_monitor(task_name~)
}

///|

///|
let create_graph = @test.create_graph

///|
let create_edge = @test.create_edge

///|
let edge_add_source = @test.edge_add_source

///|
let edge_add_target = @test.edge_add_target

///|
let create_port = @test.create_port

///|
let make_port_shape = @test.make_port_shape

///|
let port_set_dimensions = @test.port_set_dimensions

///|
let port_x = @test.port_x

///|
let port_y = @test.port_y

///|
let port_set_layout_option_string_by_id = @test.port_set_layout_option_string_by_id

///|
let new_recursive_graph_layout_engine = @test.new_recursive_graph_layout_engine

///|
let resolved_algorithm = @core.resolved_algorithm

///|
let port_set_location = @graph.port_set_location

///|
fn new_layout_algorithm_resolver(
  default_layout_algorithm_id? : String = "org.eclipse.elk.layered",
) -> @core.LayoutAlgorithmResolver {
  let metadata = @core.new_option_metadata()
  @test.plain_java_initialization_initialize_plain_java_layout(metadata)
  @core.new_layout_algorithm_resolver(metadata, default_layout_algorithm_id~)
}

///|
let apply_visitors = @test.apply_visitors

///|
let port_width = @test.port_width

///|
let port_height = @test.port_height

///|
let label_side_to_string = @core.label_side_to_string

///|
let new_i_label_manager = @core.new_i_label_manager

///|
fn layered_intermediate_processor_factory(
  graph : @runtime.LGraph,
  strategy : @runtime.IntermediateProcessorStrategy,
) -> @core.LayoutProcessorFactory {
  processor_factory(graph, strategy)
}
