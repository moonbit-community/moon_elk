///|
pub type ElkNode = @graph.ElkNode

///|
pub type ElkPort = @graph.ElkPort

///|
pub type ElkEdge = @graph.ElkEdge

///|
pub type ElkLabel = @graph.ElkLabel

///|
pub type ElkLabelParent = @graph.ElkLabelParent

///|
pub type IProperty[T] = @graph.IProperty[T]

///|
pub type KVector = @core.KVector

///|
pub type LayoutAlgorithmData = @core.LayoutAlgorithmData

///|
pub type LayoutConfigurator = @core.LayoutConfigurator

///|
pub type CoreDebugGRandomGeneratorOptions = @grandom.CoreDebugGRandomGeneratorOptions

///|
pub let algorithm : @graph.IProperty[String] = @core.algorithm

///|
pub let port_side : @graph.IProperty[String] = @core.port_side

///|
pub let rectpacking_algorithm_id : String = @rectpacking.rectpacking_algorithm_id

///|
pub let spore_compaction_algorithm_id : String = @spore.spore_compaction_algorithm_id

///|
pub let spore_overlap_removal_algorithm_id : String = @spore.spore_overlap_removal_algorithm_id

///|
pub let vertiflex_algorithm_id : String = @vertiflex.vertiflex_algorithm_id

///|
pub let no_layout : @graph.IProperty[Bool] = @core.no_layout

///|
pub let class_node_element : @core.LayoutConfiguratorElementClass = @core.class_node_element

///|
pub let spacing_node_node : @graph.IProperty[Double] = @core.spacing_node_node

///|
pub fn create_graph() -> ElkNode {
  @graph.create_graph()
}

///|
pub fn create_node(parent : ElkNode?) -> ElkNode {
  @graph.create_node(parent)
}

///|
pub fn create_port(parent : ElkNode?) -> ElkPort {
  @graph.create_port(parent)
}

///|
pub fn create_edge(parent : ElkNode?) -> ElkEdge {
  @graph.create_edge(parent)
}

///|
pub fn create_simple_edge(source : ElkNode, target : ElkNode) -> ElkEdge {
  @graph.create_simple_edge(source, target)
}

///|
pub fn create_label(parent : ElkLabelParent?) -> ElkLabel {
  @graph.create_label(parent)
}

///|
pub fn make_node_label_parent(node : ElkNode) -> ElkLabelParent {
  @graph.make_node_label_parent(node)
}

///|
pub fn make_port_shape(port : ElkPort) -> @graph.ElkConnectableShape {
  @graph.make_port_shape(port)
}

///|
pub fn make_edge_label_parent(edge : ElkEdge) -> ElkLabelParent {
  @graph.make_edge_label_parent(edge)
}

///|
pub fn reset_graph_model_for_test() -> Unit {
  @graph.reset_graph_model_for_test()
}

///|
pub fn node_parent(node : ElkNode) -> ElkNode? {
  @graph.node_parent(node)
}

///|
pub fn node_children(node : ElkNode) -> Array[ElkNode] {
  @graph.node_children(node)
}

///|
pub fn node_ports(node : ElkNode) -> Array[ElkPort] {
  @graph.node_ports(node)
}

///|
pub fn node_contained_edges(node : ElkNode) -> Array[ElkEdge] {
  @graph.node_contained_edges(node)
}

///|
pub fn node_outgoing_edges(node : ElkNode) -> Array[ElkEdge] {
  @graph.node_outgoing_edges(node)
}

///|
pub fn node_labels(node : ElkNode) -> Array[ElkLabel] {
  @graph.node_labels(node)
}

///|
pub fn node_x(node : ElkNode) -> Double {
  @graph.node_x(node)
}

///|
pub fn node_y(node : ElkNode) -> Double {
  @graph.node_y(node)
}

///|
pub fn node_width(node : ElkNode) -> Double {
  @graph.node_width(node)
}

///|
pub fn node_height(node : ElkNode) -> Double {
  @graph.node_height(node)
}

///|
pub fn node_set_dimensions(
  node : ElkNode,
  width : Double,
  height : Double,
) -> Unit {
  @graph.node_set_dimensions(node, width, height)
}

///|
pub fn node_identifier(node : ElkNode) -> String {
  @graph.node_identifier(node)
}

///|
pub fn node_set_string_property(
  node : ElkNode,
  property : @graph.IProperty[String],
  value : String,
) -> Unit {
  @graph.node_set_string_property(node, property, value)
}

///|
pub fn node_get_string_property(
  node : ElkNode,
  property : @graph.IProperty[String],
) -> String {
  @graph.node_get_string_property(node, property)
}

///|
pub fn node_set_bool_property(
  node : ElkNode,
  property : @graph.IProperty[Bool],
  value : Bool,
) -> Unit {
  @graph.node_set_bool_property(node, property, value)
}

///|
pub fn node_get_bool_property(
  node : ElkNode,
  property : @graph.IProperty[Bool],
) -> Bool {
  @graph.node_get_bool_property(node, property)
}

///|
pub fn node_has_string_property(
  node : ElkNode,
  property : @graph.IProperty[String],
) -> Bool {
  @graph.node_has_string_property(node, property)
}

///|
pub fn node_set_double_property(
  node : ElkNode,
  property : @graph.IProperty[Double],
  value : Double,
) -> Unit {
  @graph.node_set_double_property(node, property, value)
}

///|
pub fn node_get_double_property(
  node : ElkNode,
  property : @graph.IProperty[Double],
) -> Double {
  @graph.node_get_double_property(node, property)
}

///|
pub fn node_set_location(node : ElkNode, x : Double, y : Double) -> Unit {
  @graph.node_set_location(node, x, y)
}

///|
pub fn port_parent(port : ElkPort) -> ElkNode? {
  @graph.port_parent(port)
}

///|
pub fn port_identifier(port : ElkPort) -> String {
  @graph.port_identifier(port)
}

///|
pub fn port_x(port : ElkPort) -> Double {
  @graph.port_x(port)
}

///|
pub fn port_y(port : ElkPort) -> Double {
  @graph.port_y(port)
}

///|
pub fn port_width(port : ElkPort) -> Double {
  @graph.port_width(port)
}

///|
pub fn port_height(port : ElkPort) -> Double {
  @graph.port_height(port)
}

///|
pub fn port_labels(port : ElkPort) -> Array[ElkLabel] {
  @graph.port_labels(port)
}

///|
pub fn port_incoming_edges(port : ElkPort) -> Array[ElkEdge] {
  @graph.port_incoming_edges(port)
}

///|
pub fn port_outgoing_edges(port : ElkPort) -> Array[ElkEdge] {
  @graph.port_outgoing_edges(port)
}

///|
pub fn port_set_dimensions(
  port : ElkPort,
  width : Double,
  height : Double,
) -> Unit {
  @graph.port_set_dimensions(port, width, height)
}

///|
pub fn port_set_layout_option_string_by_id(
  port : ElkPort,
  id : String,
  value : String,
) -> Unit {
  @graph.port_set_layout_option_string_by_id(port, id, value)
}

///|
pub fn port_layout_option_string_value(
  port : ElkPort,
  id : String,
) -> String? {
  @graph.port_layout_option_string_value(port, id)
}

///|
pub fn edge_labels(edge : ElkEdge) -> Array[ElkLabel] {
  @graph.edge_labels(edge)
}

///|
pub fn edge_identifier(edge : ElkEdge) -> String {
  @graph.edge_identifier(edge)
}

///|
pub fn edge_containing_node(edge : ElkEdge) -> ElkNode? {
  @graph.edge_containing_node(edge)
}

///|
pub fn edge_add_source(edge : ElkEdge, shape : @graph.ElkConnectableShape) -> Unit {
  @graph.edge_add_source(edge, shape)
}

///|
pub fn edge_add_target(edge : ElkEdge, shape : @graph.ElkConnectableShape) -> Unit {
  @graph.edge_add_target(edge, shape)
}

///|
pub fn edge_set_layout_option_string_by_id(
  edge : ElkEdge,
  id : String,
  value : String,
) -> Unit {
  @graph.edge_set_layout_option_string_by_id(edge, id, value)
}

///|
pub fn edge_set_identifier(edge : ElkEdge, identifier : String) -> Unit {
  @graph.edge_set_identifier(edge, identifier)
}

///|
pub fn label_parent(label : ElkLabel) -> ElkLabelParent? {
  @graph.label_parent(label)
}

///|
pub fn label_x(label : ElkLabel) -> Double {
  @graph.label_x(label)
}

///|
pub fn label_y(label : ElkLabel) -> Double {
  @graph.label_y(label)
}

///|
pub fn label_width(label : ElkLabel) -> Double {
  @graph.label_width(label)
}

///|
pub fn label_height(label : ElkLabel) -> Double {
  @graph.label_height(label)
}

///|
pub fn label_text(label : ElkLabel) -> String {
  @graph.label_text(label)
}

///|
pub fn label_set_text(label : ElkLabel, text : String) -> Unit {
  @graph.label_set_text(label, text)
}

///|
pub fn label_set_dimensions(
  label : ElkLabel,
  width : Double,
  height : Double,
) -> Unit {
  @graph.label_set_dimensions(label, width, height)
}

///|
pub fn find_lowest_common_ancestor(
  first : ElkNode,
  second : ElkNode,
) -> ElkNode? {
  @graph.find_lowest_common_ancestor(first, second)
}

///|
pub fn new_kvector() -> KVector {
  @core.new_kvector()
}

///|
pub fn new_kvector_xy(x : Double, y : Double) -> KVector {
  @core.new_kvector_xy(x, y)
}

///|
pub fn compare_fuzzy_ge(first : Double, second : Double) -> Bool {
  @common.compare_fuzzy_ge(first, second)
}

///|
pub fn elk_graph_json_for_graph(json : String) -> @json.ElkGraphJsonImportBuilder {
  @json.elk_graph_json_for_graph(json)
}

///|
pub fn elk_graph_json_for_elk_graph(
  graph : ElkNode,
) -> @json.ElkGraphJsonExportBuilder {
  @json.elk_graph_json_for_elk_graph(graph)
}

///|
pub fn new_elk_graph_parser() -> @text.ElkGraphParser {
  @text.new_elk_graph_parser()
}

///|
pub fn apply_visitors(
  graph : ElkNode,
  visitors : Array[@core.IGraphElementVisitor],
) -> Unit {
  @core.apply_visitors(graph, visitors)
}

///|
pub fn new_graph_element_visitor(visit_fn : (ElkNode) -> Unit) -> @core.IGraphElementVisitor {
  @core.new_graph_element_visitor(visit_fn)
}

///|
pub fn new_recursive_graph_layout_engine() -> @core.RecursiveGraphLayoutEngine {
  @core.new_recursive_graph_layout_engine()
}

///|
pub fn new_basic_progress_monitor() -> @core.IElkProgressMonitor {
  @core.new_basic_progress_monitor()
}

///|
pub fn layout_meta_data_service_get_algorithm_data(id : String) -> LayoutAlgorithmData? {
  @core.layout_meta_data_service_get_algorithm_data(id)
}

///|
pub fn layout_meta_data_service_algorithm_data_values() -> Array[LayoutAlgorithmData] {
  @core.layout_meta_data_service_algorithm_data_values()
}

///|
pub fn layout_meta_data_service_register_algorithm(
  algorithm_data : LayoutAlgorithmData,
) -> Unit {
  @core.layout_meta_data_service_register_algorithm(algorithm_data)
}

///|
pub fn layout_meta_data_service_reset_for_test() -> Unit {
  @core.layout_meta_data_service_reset_for_test()
}

///|
pub fn new_layout_algorithm_data(algorithm_id : String) -> LayoutAlgorithmData {
  @core.new_layout_algorithm_data(algorithm_id)
}

///|
pub fn layout_meta_data_service_register_default_options() -> Unit {
  @core.layout_meta_data_service_register_default_options()
}

///|
pub fn layout_meta_data_service_register_default_algorithms() -> Unit {
  @core.layout_meta_data_service_register_default_algorithms()
}

///|
pub fn layout_meta_data_service_register_layout_meta_data_providers(
  providers : Array[@core.ILayoutMetaDataProvider],
) -> Unit {
  @core.layout_meta_data_service_register_layout_meta_data_providers(providers)
}

///|
pub fn force_layout_meta_data_providers() -> Array[@core.ILayoutMetaDataProvider] {
  @force.force_layout_meta_data_providers()
}

///|
pub fn new_layout_configurator() -> LayoutConfigurator {
  @core.new_layout_configurator()
}

///|
pub fn core_debug_is_directory(path : String) -> Bool {
  @debug.core_debug_is_directory(path)
}

///|
pub fn core_debug_is_regular_file(path : String) -> Bool {
  @debug.core_debug_is_regular_file(path)
}

///|
pub fn core_debug_path_file_name(path : String) -> String {
  @debug.core_debug_path_file_name(path)
}

///|
pub fn core_debug_directory_children(path : String) -> Array[String] {
  @debug.core_debug_directory_children(path)
}

///|
pub fn core_debug_register_directory_for_test(
  path : String,
  children : Array[String],
) -> Unit {
  @debug.core_debug_register_directory_for_test(path, children)
}

///|
pub fn core_debug_register_regular_file_for_test(path : String) -> Unit {
  @debug.core_debug_register_regular_file_for_test(path)
}

///|
pub fn core_debug_reset_foundation_for_test() -> Unit {
  @debug.core_debug_reset_foundation_for_test()
}

///|
pub fn new_core_debug_grandom_parser() -> @ide.CoreDebugGRandomParser {
  @ide.new_core_debug_grandom_parser()
}

///|
pub fn new_core_debug_grandom_random_graph_generator(
  random_generator : @random.Rand?,
) -> @grandom.CoreDebugGRandomRandomGraphGenerator {
  @grandom.new_core_debug_grandom_random_graph_generator(random_generator)
}

///|
pub fn new_core_debug_grandom_generator_options() -> CoreDebugGRandomGeneratorOptions {
  @grandom.new_core_debug_grandom_generator_options()
}

///|
pub fn[T] new_property(id : String, default_value : T) -> IProperty[T] {
  @graph.new_property(id, default_value)
}

///|
pub fn core_debug_grandom_random_graph_generator_generate(
  generator : @grandom.CoreDebugGRandomRandomGraphGenerator,
  options : CoreDebugGRandomGeneratorOptions,
) -> ElkNode {
  @grandom.core_debug_grandom_random_graph_generator_generate(generator, options)
}

///|
pub fn core_debug_grandom_random_graph_generator_generate_from_configuration(
  generator : @grandom.CoreDebugGRandomRandomGraphGenerator,
  configuration : @grandom.CoreDebugGRandomConfiguration,
) -> Array[ElkNode] {
  @grandom.core_debug_grandom_random_graph_generator_generate_from_configuration(
    generator, configuration,
  )
}
