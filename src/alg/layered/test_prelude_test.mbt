///|
type GraphTestShape = @test.GraphTestShape

///|
type ILayoutExecutionListener[T] = @core.ILayoutExecutionListener[T]

///|
type NodeLabelPlacement = @core.NodeLabelPlacement

///|
type ElkLabelParent = @graph.ElkLabelParent

///|
type SizeConstraint = @core.SizeConstraint

///|
let make_node_shape = @graph.make_node_shape

///|
fn new_elk_progress_monitor(task_name? : String = "") -> @core.IElkProgressMonitor {
  @core.new_elk_progress_monitor(task_name=task_name)
}

///|
let reset_graph_model_for_test = @test.reset_graph_model_for_test

///|
let create_graph = @test.create_graph

///|
let create_edge = @test.create_edge

///|
let edge_add_source = @test.edge_add_source

///|
let edge_add_target = @test.edge_add_target

///|
let update_containment = @graph.update_containment

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
let new_basic_progress_monitor = @test.new_basic_progress_monitor

///|
let resolved_algorithm = @core.resolved_algorithm

///|
let port_set_location = @graph.port_set_location

///|
fn new_layout_algorithm_resolver(
  default_layout_algorithm_id? : String = "org.eclipse.elk.layered",
) -> @core.LayoutAlgorithmResolver {
  @core.new_layout_algorithm_resolver(
    default_layout_algorithm_id=default_layout_algorithm_id,
  )
}

///|
let apply_visitors = @test.apply_visitors

///|
let port_width = @test.port_width

///|
let port_height = @test.port_height

///|
let make_node_label_parent = @test.make_node_label_parent

///|
let make_edge_label_parent = @test.make_edge_label_parent

///|
let label_side_to_string = @core.label_side_to_string

///|
let node_set_string_set_property = @graph.node_set_string_set_property

///|
let port_set_identifier = @graph.port_set_identifier

///|
let node_labels = @graph.node_labels

///|
let make_port_label_parent = @graph.make_port_label_parent

///|
let label_set_layout_option_string_by_id = @graph.label_set_layout_option_string_by_id

///|
let port_label_placement_fixed = @core.port_label_placement_fixed

///|
let edge_set_identifier = @graph.edge_set_identifier

///|
let edge_containing_node = @graph.edge_containing_node

///|
let port_label_placement_inside = @core.port_label_placement_inside

///|
let port_label_placement_outside = @core.port_label_placement_outside

///|
let new_i_label_manager = @core.new_i_label_manager

///|
let graph_test_utils_all_nodes = @test.graph_test_utils_all_nodes

///|
let graph_test_shape_label = @test.graph_test_shape_label

///|
let graph_test_utils_have_overlaps = @test.graph_test_utils_have_overlaps

///|
let node_all_descendants_including_self = @graph.node_all_descendants_including_self

///|
let port_layout_option_string_value = @test.port_layout_option_string_value

///|
let new_elk_padding_any = @core.new_elk_padding_any

///|
let new_kvector_chain_from_array = @core.new_kvector_chain_from_array

///|
fn[T] new_layout_execution_listener(
  layout_processor_ready_fn : (Int, T, Bool) -> Unit,
  layout_processor_finished_fn : (Int, T, Bool) -> Unit,
) -> ILayoutExecutionListener[T] {
  @core.new_layout_execution_listener(
    layout_processor_ready_fn,
    layout_processor_finished_fn,
  )
}

///|
let layout_meta_data_service_reset_for_test = @test.layout_meta_data_service_reset_for_test

///|
let plain_java_initialization_reset_for_test = @test.plain_java_initialization_reset_for_test

///|
let plain_java_initialization_initialize_plain_java_layout = @test.plain_java_initialization_initialize_plain_java_layout

///|
let edge_identifier = @test.edge_identifier

///|
let edge_section_incoming_shape = @graph.edge_section_incoming_shape

///|
let edge_section_outgoing_shape = @graph.edge_section_outgoing_shape

///|
let edge_set_layout_option_string_by_id = @test.edge_set_layout_option_string_by_id

///|
let node_label_placement_inside_top_center = @core.node_label_placement_inside_top_center

///|
let label_parent = @test.label_parent

///|
let port_labels = @test.port_labels

///|
let new_elk_graph_parser = @test.new_elk_graph_parser

///|
let size_constraint_to_string = @core.size_constraint_to_string

///|
let size_constraint_fixed = @core.size_constraint_fixed

///|
fn assert_double_eq(
  actual : Double,
  expected : Double,
  epsilon : Double,
) -> Unit {
  if (actual - expected).abs() > epsilon {
    abort("expected=\{expected} actual=\{actual}")
  }
}
