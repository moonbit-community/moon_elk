///|
/// Per-layout ownership for VertiFlex outlines and placement scratch data.
pub struct VertiFlexSession {
  priv left_outlines : Map[@graph.ElkNode, OutlineNode]
  priv right_outlines : Map[@graph.ElkNode, OutlineNode]
  priv outline_max_depths : Map[@graph.ElkNode, Double]
  priv min_x : Map[@graph.ElkNode, Double]
  priv max_x : Map[@graph.ElkNode, Double]
  priv min_y : Map[@graph.ElkNode, Double]
  priv max_y : Map[@graph.ElkNode, Double]
  priv roots : Map[@graph.ElkNode, @graph.ElkNode]
  priv edge_bend_heights : Map[@graph.ElkNode, Double]
  priv node_model_orders : Map[@graph.ElkNode, Int]
}

///|
pub fn new_vertiflex_session() -> VertiFlexSession {
  {
    left_outlines: Map([]),
    right_outlines: Map([]),
    outline_max_depths: Map([]),
    min_x: Map([]),
    max_x: Map([]),
    min_y: Map([]),
    max_y: Map([]),
    roots: Map([]),
    edge_bend_heights: Map([]),
    node_model_orders: Map([]),
  }
}

///|
pub fn VertiFlexSession::clear(self : VertiFlexSession) -> Unit {
  self.left_outlines.clear()
  self.right_outlines.clear()
  self.outline_max_depths.clear()
  self.min_x.clear()
  self.max_x.clear()
  self.min_y.clear()
  self.max_y.clear()
  self.roots.clear()
  self.edge_bend_heights.clear()
  self.node_model_orders.clear()
}

///|
fn vertiflex_expect_outline(value : OutlineNode?) -> OutlineNode raise {
  match value {
    Some(outline) => outline
    None => {
      @core.layout_runtime_raise_unsupported_configuration(
        "VertiFlex internal outline is missing.",
      )
      new_outline_node(0.0, 0.0, None)
    }
  }
}

///|
fn vertiflex_expect_node(value : @graph.ElkNode?) -> @graph.ElkNode raise {
  match value {
    Some(node) => node
    None => {
      @core.layout_runtime_raise_unsupported_configuration(
        "VertiFlex internal root is missing.",
      )
      @graph.create_node(None)
    }
  }
}

///|
pub fn vertiflex_internal_set_left_outline(
  session : VertiFlexSession,
  node : @graph.ElkNode,
  outline : OutlineNode,
) -> Unit {
  session.left_outlines[node] = outline
}

///|
pub fn vertiflex_internal_left_outline(
  session : VertiFlexSession,
  node : @graph.ElkNode,
) -> OutlineNode raise {
  vertiflex_expect_outline(session.left_outlines.get(node))
}

///|
pub fn vertiflex_internal_set_right_outline(
  session : VertiFlexSession,
  node : @graph.ElkNode,
  outline : OutlineNode,
) -> Unit {
  session.right_outlines[node] = outline
}

///|
pub fn vertiflex_internal_right_outline(
  session : VertiFlexSession,
  node : @graph.ElkNode,
) -> OutlineNode raise {
  vertiflex_expect_outline(session.right_outlines.get(node))
}

///|
pub fn vertiflex_internal_set_outline_max_depth(
  session : VertiFlexSession,
  node : @graph.ElkNode,
  value : Double,
) -> Unit {
  session.outline_max_depths[node] = value
}

///|
pub fn vertiflex_internal_outline_max_depth(
  session : VertiFlexSession,
  node : @graph.ElkNode,
) -> Double {
  match session.outline_max_depths.get(node) {
    Some(value) => value
    None => 0.0
  }
}

///|
pub fn vertiflex_internal_set_min_x(
  session : VertiFlexSession,
  node : @graph.ElkNode,
  value : Double,
) -> Unit {
  session.min_x[node] = value
}

///|
pub fn vertiflex_internal_min_x(
  session : VertiFlexSession,
  node : @graph.ElkNode,
) -> Double {
  match session.min_x.get(node) {
    Some(value) => value
    None => 0.0
  }
}

///|
pub fn vertiflex_internal_set_max_x(
  session : VertiFlexSession,
  node : @graph.ElkNode,
  value : Double,
) -> Unit {
  session.max_x[node] = value
}

///|
pub fn vertiflex_internal_max_x(
  session : VertiFlexSession,
  node : @graph.ElkNode,
) -> Double {
  match session.max_x.get(node) {
    Some(value) => value
    None => 0.0
  }
}

///|
pub fn vertiflex_internal_set_min_y(
  session : VertiFlexSession,
  node : @graph.ElkNode,
  value : Double,
) -> Unit {
  session.min_y[node] = value
}

///|
pub fn vertiflex_internal_min_y(
  session : VertiFlexSession,
  node : @graph.ElkNode,
) -> Double {
  match session.min_y.get(node) {
    Some(value) => value
    None => 0.0
  }
}

///|
pub fn vertiflex_internal_set_max_y(
  session : VertiFlexSession,
  node : @graph.ElkNode,
  value : Double,
) -> Unit {
  session.max_y[node] = value
}

///|
pub fn vertiflex_internal_max_y(
  session : VertiFlexSession,
  node : @graph.ElkNode,
) -> Double {
  match session.max_y.get(node) {
    Some(value) => value
    None => 0.0
  }
}

///|
pub fn vertiflex_internal_set_root_node(
  session : VertiFlexSession,
  graph : @graph.ElkNode,
  root : @graph.ElkNode,
) -> Unit {
  session.roots[graph] = root
}

///|
pub fn vertiflex_internal_root_node(
  session : VertiFlexSession,
  graph : @graph.ElkNode,
) -> @graph.ElkNode raise {
  vertiflex_expect_node(session.roots.get(graph))
}

///|
pub fn vertiflex_internal_set_edge_bend_height(
  session : VertiFlexSession,
  node : @graph.ElkNode,
  value : Double,
) -> Unit {
  session.edge_bend_heights[node] = value
}

///|
pub fn vertiflex_internal_edge_bend_height(
  session : VertiFlexSession,
  node : @graph.ElkNode,
) -> Double {
  match session.edge_bend_heights.get(node) {
    Some(value) => value
    None => 0.0
  }
}

///|
pub fn vertiflex_internal_set_node_model_order(
  session : VertiFlexSession,
  node : @graph.ElkNode,
  order : Int,
) -> Unit {
  session.node_model_orders[node] = order
}

///|
pub fn vertiflex_internal_node_model_order(
  session : VertiFlexSession,
  node : @graph.ElkNode,
) -> Int {
  match session.node_model_orders.get(node) {
    Some(order) => order
    None => 0
  }
}

///|
pub fn vertiflex_internal_node_margins(
  node : @graph.ElkNode,
) -> @core.ElkMargin raise {
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
) -> @graph.ElkNode raise {
  let targets = @graph.edge_targets(edge)
  if targets.is_empty() {
    @core.layout_runtime_raise_unsupported_configuration(
      "VertiFlex expects every tree edge to have a target.",
    )
    return @graph.create_node(None)
  }
  try @graph.connectable_shape_to_node(Some(targets[0])) catch {
    _ => {
      @core.layout_runtime_raise_unsupported_configuration(
        "VertiFlex target shape is not attached to a node.",
      )
      @graph.create_node(None)
    }
  } noraise {
    value => value
  }
}
