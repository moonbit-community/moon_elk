///|
let vertiflex_left_outline_store : Ref[Map[@graph.ElkNode, OutlineNode]] = Ref({})

///|
let vertiflex_right_outline_store : Ref[Map[@graph.ElkNode, OutlineNode]] = Ref({},
)

///|
let vertiflex_outline_max_depth_store : Ref[Map[@graph.ElkNode, Double]] = Ref({})

///|
let vertiflex_min_x_store : Ref[Map[@graph.ElkNode, Double]] = Ref({})

///|
let vertiflex_max_x_store : Ref[Map[@graph.ElkNode, Double]] = Ref({})

///|
let vertiflex_min_y_store : Ref[Map[@graph.ElkNode, Double]] = Ref({})

///|
let vertiflex_max_y_store : Ref[Map[@graph.ElkNode, Double]] = Ref({})

///|
let vertiflex_root_node_store : Ref[Map[@graph.ElkNode, @graph.ElkNode]] = Ref({})

///|
let vertiflex_edge_bend_height_store : Ref[Map[@graph.ElkNode, Double]] = Ref({})

///|
let vertiflex_node_model_order_store : Ref[Map[@graph.ElkNode, Int]] = Ref({})

///|
pub fn vertiflex_internal_reset() -> Unit {
  vertiflex_left_outline_store.val.clear()
  vertiflex_right_outline_store.val.clear()
  vertiflex_outline_max_depth_store.val.clear()
  vertiflex_min_x_store.val.clear()
  vertiflex_max_x_store.val.clear()
  vertiflex_min_y_store.val.clear()
  vertiflex_max_y_store.val.clear()
  vertiflex_root_node_store.val.clear()
  vertiflex_edge_bend_height_store.val.clear()
  vertiflex_node_model_order_store.val.clear()
}

///|
fn vertiflex_expect_outline(value : OutlineNode?) -> OutlineNode {
  match value {
    Some(outline) => outline
    None => {
      @core.layout_runtime_report_unsupported_configuration(
        "VertiFlex internal outline is missing.",
      )
      new_outline_node(0.0, 0.0, None)
    }
  }
}

///|
fn vertiflex_expect_node(value : @graph.ElkNode?) -> @graph.ElkNode {
  match value {
    Some(node) => node
    None => {
      @core.layout_runtime_report_unsupported_configuration(
        "VertiFlex internal root is missing.",
      )
      @graph.create_node(None)
    }
  }
}

///|
pub fn vertiflex_internal_set_left_outline(
  node : @graph.ElkNode,
  outline : OutlineNode,
) -> Unit {
  vertiflex_left_outline_store.val[node] = outline
}

///|
pub fn vertiflex_internal_left_outline(node : @graph.ElkNode) -> OutlineNode {
  vertiflex_expect_outline(vertiflex_left_outline_store.val.get(node))
}

///|
pub fn vertiflex_internal_set_right_outline(
  node : @graph.ElkNode,
  outline : OutlineNode,
) -> Unit {
  vertiflex_right_outline_store.val[node] = outline
}

///|
pub fn vertiflex_internal_right_outline(node : @graph.ElkNode) -> OutlineNode {
  vertiflex_expect_outline(vertiflex_right_outline_store.val.get(node))
}

///|
pub fn vertiflex_internal_set_outline_max_depth(
  node : @graph.ElkNode,
  value : Double,
) -> Unit {
  vertiflex_outline_max_depth_store.val[node] = value
}

///|
pub fn vertiflex_internal_outline_max_depth(node : @graph.ElkNode) -> Double {
  match vertiflex_outline_max_depth_store.val.get(node) {
    Some(value) => value
    None => 0.0
  }
}

///|
pub fn vertiflex_internal_set_min_x(
  node : @graph.ElkNode,
  value : Double,
) -> Unit {
  vertiflex_min_x_store.val[node] = value
}

///|
pub fn vertiflex_internal_min_x(node : @graph.ElkNode) -> Double {
  match vertiflex_min_x_store.val.get(node) {
    Some(value) => value
    None => 0.0
  }
}

///|
pub fn vertiflex_internal_set_max_x(
  node : @graph.ElkNode,
  value : Double,
) -> Unit {
  vertiflex_max_x_store.val[node] = value
}

///|
pub fn vertiflex_internal_max_x(node : @graph.ElkNode) -> Double {
  match vertiflex_max_x_store.val.get(node) {
    Some(value) => value
    None => 0.0
  }
}

///|
pub fn vertiflex_internal_set_min_y(
  node : @graph.ElkNode,
  value : Double,
) -> Unit {
  vertiflex_min_y_store.val[node] = value
}

///|
pub fn vertiflex_internal_min_y(node : @graph.ElkNode) -> Double {
  match vertiflex_min_y_store.val.get(node) {
    Some(value) => value
    None => 0.0
  }
}

///|
pub fn vertiflex_internal_set_max_y(
  node : @graph.ElkNode,
  value : Double,
) -> Unit {
  vertiflex_max_y_store.val[node] = value
}

///|
pub fn vertiflex_internal_max_y(node : @graph.ElkNode) -> Double {
  match vertiflex_max_y_store.val.get(node) {
    Some(value) => value
    None => 0.0
  }
}

///|
pub fn vertiflex_internal_set_root_node(
  graph : @graph.ElkNode,
  root : @graph.ElkNode,
) -> Unit {
  vertiflex_root_node_store.val[graph] = root
}

///|
pub fn vertiflex_internal_root_node(graph : @graph.ElkNode) -> @graph.ElkNode {
  vertiflex_expect_node(vertiflex_root_node_store.val.get(graph))
}

///|
pub fn vertiflex_internal_set_edge_bend_height(
  node : @graph.ElkNode,
  value : Double,
) -> Unit {
  vertiflex_edge_bend_height_store.val[node] = value
}

///|
pub fn vertiflex_internal_edge_bend_height(node : @graph.ElkNode) -> Double {
  match vertiflex_edge_bend_height_store.val.get(node) {
    Some(value) => value
    None => 0.0
  }
}

///|
pub fn vertiflex_internal_set_node_model_order(
  node : @graph.ElkNode,
  order : Int,
) -> Unit {
  vertiflex_node_model_order_store.val[node] = order
}

///|
pub fn vertiflex_internal_node_model_order(node : @graph.ElkNode) -> Int {
  match vertiflex_node_model_order_store.val.get(node) {
    Some(order) => order
    None => 0
  }
}

///|
pub fn vertiflex_internal_node_margins(
  node : @graph.ElkNode,
) -> @core.ElkMargin {
  match
    @graph.node_layout_option_string_value(node, vertiflex_option_margins_id) {
    Some(text) => {
      let margins = @core.new_elk_margin()
      margins.parse(text)
      margins
    }
    None => @core.new_elk_margin()
  }
}

///|
pub fn vertiflex_internal_child_of_edge(
  edge : @graph.ElkEdge,
) -> @graph.ElkNode {
  let targets = @graph.edge_targets(edge)
  if targets.is_empty() {
    @core.layout_runtime_report_unsupported_configuration(
      "VertiFlex expects every tree edge to have a target.",
    )
    return @graph.create_node(None)
  }
  try @graph.connectable_shape_to_node(Some(targets[0])) catch {
    _ => {
      @core.layout_runtime_report_unsupported_configuration(
        "VertiFlex target shape is not attached to a node.",
      )
      @graph.create_node(None)
    }
  } noraise {
    value => value
  }
}
