///|
let radial_internal_root_store : Ref[Map[@graph.ElkNode, @graph.ElkNode]] = Ref::new({},
)

///|
let radial_internal_order_id_store : Ref[Map[@graph.ElkNode, Int]] = Ref::new({})

///|
let radial_internal_position_store : Ref[Map[@graph.ElkNode, @core.KVector]] = Ref::new({},
)

///|
pub fn radial_internal_set_root(
  graph : @graph.ElkNode,
  root : @graph.ElkNode,
) -> Unit {
  radial_internal_root_store.val[graph] = root
}

///|
pub fn radial_internal_clear_root(graph : @graph.ElkNode) -> Unit {
  ignore(radial_internal_root_store.val.remove(graph))
}

///|
pub fn radial_internal_root(graph : @graph.ElkNode) -> @graph.ElkNode? {
  radial_internal_root_store.val.get(graph)
}

///|
pub fn radial_internal_clear_transient_state() -> Unit {
  radial_internal_order_id_store.val.clear()
  radial_internal_position_store.val.clear()
}

///|
pub fn radial_internal_set_order_id(
  node : @graph.ElkNode,
  order_id : Int,
) -> Unit {
  radial_internal_order_id_store.val[node] = order_id
}

///|
pub fn radial_internal_order_id(node : @graph.ElkNode) -> Int {
  match radial_internal_order_id_store.val.get(node) {
    Some(value) => value
    None => @graph.node_get_double_property(node, radial_order_id).to_int()
  }
}

///|
pub fn radial_internal_has_order_id(node : @graph.ElkNode) -> Bool {
  radial_internal_order_id_store.val.contains(node)
}

///|
fn radial_parse_position(text : String) -> @core.KVector? {
  let parsed = @core.new_kvector()
  parsed.parse(text)
  Some(parsed)
}

///|
pub fn radial_internal_set_position(
  node : @graph.ElkNode,
  value : @core.KVector,
) -> Unit {
  radial_internal_position_store.val[node] = @core.new_kvector_copy(value)
}

///|
pub fn radial_internal_position(node : @graph.ElkNode) -> @core.KVector {
  match radial_internal_position_store.val.get(node) {
    Some(value) => @core.new_kvector_copy(value)
    None =>
      match
        @graph.node_layout_option_string_value(node, radial_option_position_id) {
        Some(text) =>
          match radial_parse_position(text) {
            Some(parsed) => {
              radial_internal_position_store.val[node] = @core.new_kvector_copy(
                parsed,
              )
              parsed
            }
            None => @core.new_kvector()
          }
        None => @core.new_kvector()
      }
  }
}

///|
pub fn radial_internal_node_margins(node : @graph.ElkNode) -> @core.ElkMargin {
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
) -> @core.ElkPadding {
  let parsed = @core.new_elk_padding()
  parsed.parse(@graph.node_get_string_property(graph, @core.padding))
  parsed
}
