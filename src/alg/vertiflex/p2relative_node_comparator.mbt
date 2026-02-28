///|
fn vertiflex_node_comparator_compare(
  a : @graph.ElkNode,
  b : @graph.ElkNode,
  invert : Bool,
) -> Int {
  let sort_y_result = if !invert {
    if @graph.node_y(a) < @graph.node_y(b) {
      -1
    } else if @graph.node_y(a) > @graph.node_y(b) {
      1
    } else {
      0
    }
  } else if @graph.node_y(b) < @graph.node_y(a) {
    -1
  } else if @graph.node_y(b) > @graph.node_y(a) {
    1
  } else {
    0
  }
  if sort_y_result == 0 {
    let order_a = vertiflex_internal_node_model_order(a)
    let order_b = vertiflex_internal_node_model_order(b)
    if order_a < order_b {
      -1
    } else if order_a > order_b {
      1
    } else {
      0
    }
  } else {
    sort_y_result
  }
}
