///|
type ElkNode = @graph.ElkNode

///|
type IProperty[T] = @graph.IProperty[T]

///|
let layout_meta_data_service_reset_for_test = @test.layout_meta_data_service_reset_for_test

///|
let plain_java_initialization_reset_for_test = @test.plain_java_initialization_reset_for_test

///|
let plain_java_initialization_initialize_plain_java_layout = @test.plain_java_initialization_initialize_plain_java_layout

///|
let reset_graph_model_for_test = @test.reset_graph_model_for_test

///|
let graph_test_utils_create_simple_graph = @test.graph_test_utils_create_simple_graph

///|
let graph_test_utils_create_hierarchical_graph = @test.graph_test_utils_create_hierarchical_graph

///|
let new_basic_progress_monitor = @test.new_basic_progress_monitor

///|
let new_recursive_graph_layout_engine = @test.new_recursive_graph_layout_engine

///|
fn new_abstract_layout_provider(
  layout_fn : (ElkNode, @core.IElkProgressMonitor) -> Unit,
  initialize_fn? : (String?) -> Unit = _ => (),
  dispose_fn? : () -> Unit = () => (),
) -> @core.AbstractLayoutProvider {
  @core.new_abstract_layout_provider(
    layout_fn,
    initialize_fn=initialize_fn,
    dispose_fn=dispose_fn,
  )
}

///|
let node_set_string_property = @test.node_set_string_property

///|
let node_set_dimensions = @test.node_set_dimensions

///|
let node_set_string_set_property = @graph.node_set_string_set_property

///|
let node_children = @test.node_children

///|
let node_ports = @test.node_ports

///|
let node_labels = @test.node_labels

///|
let node_x = @test.node_x

///|
let node_y = @test.node_y

///|
let label_text = @test.label_text

///|
let port_set_location = @graph.port_set_location

///|
let port_set_layout_option_string_by_id = @test.port_set_layout_option_string_by_id

///|
let algorithm = @core.algorithm

///|
let direction = @core.direction

///|
let port_constraints = @core.port_constraints

///|
let port_side = @core.port_side

///|
let node_size_constraints = @core.node_size_constraints

///|
let node_size_options = @core.node_size_options

///|
let node_labels_placement = @core.node_labels_placement

///|
let port_labels_placement = @core.port_labels_placement

///|
let content_alignment = @core.content_alignment

///|
let spacing_node_node = @core.spacing_node_node

///|
let aspect_ratio = @core.aspect_ratio

///|
let priority = @core.priority

///|
let interactive = @core.interactive

///|
let no_layout = @core.no_layout

///|
let radial_radius = @radial.radial_radius

///|
let radial_compactor = @radial.radial_compactor

///|
let rectpacking_width_approximation_target_width = @rectpacking.rectpacking_width_approximation_target_width

///|
let rectpacking_interactive = @rectpacking.rectpacking_interactive

///|
let spore_compaction_orthogonal = @spore.spore_compaction_orthogonal

///|
let spore_underlying_layout_algorithm = @spore.spore_underlying_layout_algorithm

///|
let vertiflex_consider_node_model_order = @vertiflex.vertiflex_consider_node_model_order

///|
let layout_meta_data_service_option_data_values = @core.layout_meta_data_service_option_data_values
