///|
type ElkNode = @graph.ElkNode

///|
type ElkPort = @graph.ElkPort

///|
type ElkLabel = @graph.ElkLabel

///|
type ElkRectangle = @core.ElkRectangle

///|
type Direction = @core.Direction

///|
type PortSide = @core.PortSide

///|
type KVector = @core.KVector

///|
let create_graph = @graph.create_graph

///|
let reset_graph_model_for_test = @graph.reset_graph_model_for_test

///|
let create_node = @graph.create_node

///|
let create_port = @graph.create_port

///|
let create_edge = @graph.create_edge

///|
let create_label = @graph.create_label

///|
let make_node_label_parent = @graph.make_node_label_parent

///|
let make_port_label_parent = @graph.make_port_label_parent

///|
let make_port_shape = @graph.make_port_shape

///|
let make_node_shape = @graph.make_node_shape

///|
let node_children = @graph.node_children

///|
let node_ports = @graph.node_ports

///|
let node_labels = @graph.node_labels

///|
let node_identifier = @graph.node_identifier

///|
let node_set_identifier = @graph.node_set_identifier

///|
let node_width = @graph.node_width

///|
let node_height = @graph.node_height

///|
let node_x = @graph.node_x

///|
let node_y = @graph.node_y

///|
let node_set_dimensions = @graph.node_set_dimensions

///|
let node_set_location = @graph.node_set_location

///|
let node_set_bool_property = @graph.node_set_bool_property

///|
let node_get_bool_property = @graph.node_get_bool_property

///|
let node_has_bool_property = @graph.node_has_bool_property

///|
let node_side_to_string = @core.port_side_to_string

///|
let node_set_string_set_property = @graph.node_set_string_set_property

///|
let port_parent = @graph.port_parent

///|
let port_x = @graph.port_x

///|
let port_y = @graph.port_y

///|
let port_set_dimensions = @graph.port_set_dimensions

///|
let port_set_layout_option_string_by_id = @graph.port_set_layout_option_string_by_id

///|
let port_layout_option_string_value = @graph.port_layout_option_string_value

///|
let port_labels = @graph.port_labels

///|
let port_outgoing_edges = @graph.port_outgoing_edges

///|
let port_incoming_edges = @graph.port_incoming_edges

///|
let port_side = @core.port_side

///|
let port_side_values = @core.port_side_values

///|
let port_side_to_string = @core.port_side_to_string

///|
let sides_east_west = @core.sides_east_west

///|
let sides_north_south = @core.sides_north_south

///|
let sides_south_west = @core.sides_south_west

///|
let edge_add_source = @graph.edge_add_source

///|
let edge_add_target = @graph.edge_add_target

///|
let edge_sources = @graph.edge_sources

///|
let edge_targets = @graph.edge_targets

///|
let label_x = @graph.label_x

///|
let label_y = @graph.label_y

///|
let label_width = @graph.label_width

///|
let label_height = @graph.label_height

///|
let label_text = @graph.label_text

///|
let label_set_text = @graph.label_set_text

///|
let label_set_location = @graph.label_set_location

///|
let label_set_dimensions = @graph.label_set_dimensions

///|
let direction_values = @core.direction_values

///|
let new_kvector_xy = @core.new_kvector_xy

///|
let new_elk_rectangle = @core.new_elk_rectangle

///|
let new_elk_rectangle_xywh = @core.new_elk_rectangle_xywh

///|
let new_elk_rectangle_copy = @core.new_elk_rectangle_copy

///|
let new_elk_padding_values = @core.new_elk_padding_values

///|
let shortest_distance = @core.shortest_distance

///|
let is_descendant = @graph.is_descendant

///|
let connectable_shape_to_node = @graph.connectable_shape_to_node

///|
let node_size_fixed_graph_size = @core.node_size_fixed_graph_size

///|
let node_label_placement_value_of = @core.node_label_placement_value_of

///|
let omit_node_micro_layout = @core.omit_node_micro_layout

fn assert_double_eq(
  actual : Double,
  expected : Double,
  epsilon : Double,
) -> Unit {
  if (actual - expected).abs() > epsilon {
    abort("expected=\{expected} actual=\{actual}")
  }
}
