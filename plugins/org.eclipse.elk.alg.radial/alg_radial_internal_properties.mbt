///|
let radial_internal_root_store : Ref[Map[ElkNode, ElkNode]] = Ref::new({})

///|
let radial_internal_order_id_store : Ref[Map[ElkNode, Int]] = Ref::new({})

///|
let radial_internal_position_store : Ref[Map[ElkNode, KVector]] = Ref::new({})

///|
pub fn radial_internal_set_root(graph : ElkNode, root : ElkNode) -> Unit {
  radial_internal_root_store.val[graph] = root
}

///|
pub fn radial_internal_clear_root(graph : ElkNode) -> Unit {
  ignore(radial_internal_root_store.val.remove(graph))
}

///|
pub fn radial_internal_root(graph : ElkNode) -> ElkNode? {
  radial_internal_root_store.val.get(graph)
}

///|
pub fn radial_internal_clear_transient_state() -> Unit {
  radial_internal_order_id_store.val.clear()
  radial_internal_position_store.val.clear()
}

///|
pub fn radial_internal_set_order_id(node : ElkNode, order_id : Int) -> Unit {
  radial_internal_order_id_store.val[node] = order_id
}

///|
pub fn radial_internal_order_id(node : ElkNode) -> Int {
  match radial_internal_order_id_store.val.get(node) {
    Some(value) => value
    None => node_get_double_property(node, radial_order_id).to_int()
  }
}

///|
pub fn radial_internal_has_order_id(node : ElkNode) -> Bool {
  radial_internal_order_id_store.val.contains(node)
}

///|
fn radial_parse_position(text : String) -> KVector? {
  let parsed = new_kvector()
  parsed.parse(text)
  Some(parsed)
}

///|
pub fn radial_internal_set_position(node : ElkNode, value : KVector) -> Unit {
  radial_internal_position_store.val[node] = new_kvector_copy(value)
}

///|
pub fn radial_internal_position(node : ElkNode) -> KVector {
  match radial_internal_position_store.val.get(node) {
    Some(value) => new_kvector_copy(value)
    None =>
      match node_layout_option_string_value(node, radial_option_position_id) {
        Some(text) =>
          match radial_parse_position(text) {
            Some(parsed) => {
              radial_internal_position_store.val[node] = new_kvector_copy(
                parsed,
              )
              parsed
            }
            None => new_kvector()
          }
        None => new_kvector()
      }
  }
}

///|
pub fn radial_internal_node_margins(node : ElkNode) -> ElkMargin {
  match node_layout_option_string_value(node, radial_option_margins_id) {
    Some(text) => {
      let margins = new_elk_margin()
      margins.parse(text)
      margins
    }
    None => new_elk_margin()
  }
}

///|
pub fn radial_internal_graph_padding(graph : ElkNode) -> ElkPadding {
  let parsed = new_elk_padding()
  parsed.parse(node_get_string_property(graph, padding))
  parsed
}
