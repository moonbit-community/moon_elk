///|
type ElkNode = @graph.ElkNode

///|
type ElkRectangle = @core.ElkRectangle

///|
type KVector = @core.KVector

///|
let create_graph = @graph.create_graph

///|
let reset_graph_model_for_test = @graph.reset_graph_model_for_test

///|
let create_node = @graph.create_node

///|
let node_children = @graph.node_children

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
let _node_side_to_string = @core.port_side_to_string

///|
let _node_set_string_set_property = @graph.node_set_string_set_property

///|
let _port_x = @graph.port_x

///|
let _port_y = @graph.port_y

///|
let _port_set_dimensions = @graph.port_set_dimensions

///|
let new_kvector_xy = @core.new_kvector_xy

///|
let new_elk_rectangle_xywh = @core.new_elk_rectangle_xywh

///|
let new_elk_rectangle_copy = @core.new_elk_rectangle_copy

///|
let shortest_distance = @core.shortest_distance

///|
let node_size_fixed_graph_size = @core.node_size_fixed_graph_size

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
