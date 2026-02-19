///|
let reset_graph_model_for_test = @test.reset_graph_model_for_test

///|
let create_graph = @test.create_graph

///|
let create_port = @test.create_port

///|
let create_edge = @test.create_edge

///|
let edge_add_source = @test.edge_add_source

///|
let edge_add_target = @test.edge_add_target

///|
let make_port_shape = @test.make_port_shape

///|
let port_set_location = @graph.port_set_location

///|
let port_set_dimensions = @test.port_set_dimensions

///|
let port_set_layout_option_string_by_id = @test.port_set_layout_option_string_by_id

///|
let port_layout_option_string_value = @test.port_layout_option_string_value

///|
let port_side = @test.port_side

///|
fn new_elk_progress_monitor(task_name? : String = "") -> @core.IElkProgressMonitor {
  @core.new_elk_progress_monitor(task_name=task_name)
}
