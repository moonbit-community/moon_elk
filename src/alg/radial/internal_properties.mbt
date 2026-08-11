///|
let radial_internal_order_id_property : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.radial.internal.orderId", 0.0,
)

///|
let radial_internal_position_x_property : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.radial.internal.position.x", 0.0,
)

///|
let radial_internal_position_y_property : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.radial.internal.position.y", 0.0,
)

///|
pub fn radial_internal_root(graph : @graph.ElkNode) -> @graph.ElkNode? {
  radial_find_root(graph)
}

///|
pub fn radial_internal_set_order_id(
  node : @graph.ElkNode,
  order_id : Int,
) -> Unit {
  @graph.node_set_double_property(
    node,
    radial_internal_order_id_property,
    order_id.to_double(),
  )
}

///|
pub fn radial_internal_order_id(node : @graph.ElkNode) -> Int {
  if radial_internal_has_order_id(node) {
    @graph.node_get_double_property(node, radial_internal_order_id_property).to_int()
  } else {
    @graph.node_get_double_property(node, radial_order_id).to_int()
  }
}

///|
pub fn radial_internal_has_order_id(node : @graph.ElkNode) -> Bool {
  @graph.node_has_double_property(node, radial_internal_order_id_property)
}

///|
fn radial_parse_position(text : String) -> @core.KVector? raise {
  let parsed = @core.new_kvector()
  parsed.parse(text)
  Some(parsed)
}

///|
pub fn radial_internal_set_position(
  node : @graph.ElkNode,
  value : @core.KVector,
) -> Unit {
  @graph.node_set_double_property(
    node,
    radial_internal_position_x_property,
    value.x,
  )
  @graph.node_set_double_property(
    node,
    radial_internal_position_y_property,
    value.y,
  )
}

///|
pub fn radial_internal_position(node : @graph.ElkNode) -> @core.KVector raise {
  if @graph.node_has_double_property(node, radial_internal_position_x_property) {
    @core.new_kvector_xy(
      @graph.node_get_double_property(node, radial_internal_position_x_property),
      @graph.node_get_double_property(node, radial_internal_position_y_property),
    )
  } else {
    match
      @graph.node_layout_option_string_value(node, radial_option_position_id) {
      Some(text) =>
        match radial_parse_position(text) {
          Some(parsed) => {
            radial_internal_set_position(node, parsed)
            parsed
          }
          None => @core.new_kvector()
        }
      None => @core.new_kvector()
    }
  }
}

///|
pub fn radial_internal_node_margins(
  node : @graph.ElkNode,
) -> @core.ElkMargin raise {
  match @graph.node_layout_option_string_value(node, radial_option_margins_id) {
    Some(text) => {
      let margins = @core.new_elk_margin()
      margins.parse(text)
      margins
    }
    None => @core.new_elk_margin()
  }
}

///|
pub fn radial_internal_graph_padding(
  graph : @graph.ElkNode,
) -> @core.ElkPadding raise {
  let parsed = @core.new_elk_padding()
  parsed.parse(@graph.node_get_string_property(graph, @core.padding))
  parsed
}
