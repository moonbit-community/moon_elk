///|
pub enum DotSwitchTarget {
  DotGraphvizModelTarget(DotGraphvizModel)
  DotGraphTarget(DotGraph)
  DotStatementTarget(DotStatement)
  DotAttributeTarget(DotAttribute)
  DotNodeStatementTarget(DotNodeStatement)
  DotNodeTarget(DotNode)
  DotEdgeStatementTarget(DotEdgeStatement)
  DotEdgeTargetTarget(DotEdgeTarget)
  DotAttributeStatementTarget(DotAttributeStatement)
  DotSubgraphTarget(DotSubgraph)
  DotPortTarget(DotPort)
}

///|
pub fn dot_switch_target_graphviz_model(
  object : DotGraphvizModel,
) -> DotSwitchTarget {
  DotGraphvizModelTarget(object)
}

///|
pub fn dot_switch_target_graph(object : DotGraph) -> DotSwitchTarget {
  DotGraphTarget(object)
}

///|
pub fn dot_switch_target_statement(object : DotStatement) -> DotSwitchTarget {
  DotStatementTarget(object)
}

///|
pub fn dot_switch_target_attribute(object : DotAttribute) -> DotSwitchTarget {
  DotAttributeTarget(object)
}

///|
pub fn dot_switch_target_node_statement(
  object : DotNodeStatement,
) -> DotSwitchTarget {
  DotNodeStatementTarget(object)
}

///|
pub fn dot_switch_target_node(object : DotNode) -> DotSwitchTarget {
  DotNodeTarget(object)
}

///|
pub fn dot_switch_target_edge_statement(
  object : DotEdgeStatement,
) -> DotSwitchTarget {
  DotEdgeStatementTarget(object)
}

///|
pub fn dot_switch_target_edge_target(object : DotEdgeTarget) -> DotSwitchTarget {
  DotEdgeTargetTarget(object)
}

///|
pub fn dot_switch_target_attribute_statement(
  object : DotAttributeStatement,
) -> DotSwitchTarget {
  DotAttributeStatementTarget(object)
}

///|
pub fn dot_switch_target_subgraph(object : DotSubgraph) -> DotSwitchTarget {
  DotSubgraphTarget(object)
}

///|
pub fn dot_switch_target_port(object : DotPort) -> DotSwitchTarget {
  DotPortTarget(object)
}

///|
pub struct DotSwitch[T] {
  model_package : DotPackage
  case_graphviz_model_fn : (DotGraphvizModel) -> T?
  case_graph_fn : (DotGraph) -> T?
  case_statement_fn : (DotStatement) -> T?
  case_attribute_fn : (DotAttribute) -> T?
  case_node_statement_fn : (DotNodeStatement) -> T?
  case_node_fn : (DotNode) -> T?
  case_edge_statement_fn : (DotEdgeStatement) -> T?
  case_edge_target_fn : (DotEdgeTarget) -> T?
  case_attribute_statement_fn : (DotAttributeStatement) -> T?
  case_subgraph_fn : (DotSubgraph) -> T?
  case_port_fn : (DotPort) -> T?
  default_case_fn : () -> T?
}

///|
pub fn[T] new_dot_switch(
  case_graphviz_model? : (DotGraphvizModel) -> T? = _ => None,
  case_graph? : (DotGraph) -> T? = _ => None,
  case_statement? : (DotStatement) -> T? = _ => None,
  case_attribute? : (DotAttribute) -> T? = _ => None,
  case_node_statement? : (DotNodeStatement) -> T? = _ => None,
  case_node? : (DotNode) -> T? = _ => None,
  case_edge_statement? : (DotEdgeStatement) -> T? = _ => None,
  case_edge_target? : (DotEdgeTarget) -> T? = _ => None,
  case_attribute_statement? : (DotAttributeStatement) -> T? = _ => None,
  case_subgraph? : (DotSubgraph) -> T? = _ => None,
  case_port? : (DotPort) -> T? = _ => None,
  default_case? : () -> T? = () => None,
) -> DotSwitch[T] {
  {
    model_package: dot_package_instance,
    case_graphviz_model_fn: case_graphviz_model,
    case_graph_fn: case_graph,
    case_statement_fn: case_statement,
    case_attribute_fn: case_attribute,
    case_node_statement_fn: case_node_statement,
    case_node_fn: case_node,
    case_edge_statement_fn: case_edge_statement,
    case_edge_target_fn: case_edge_target,
    case_attribute_statement_fn: case_attribute_statement,
    case_subgraph_fn: case_subgraph,
    case_port_fn: case_port,
    default_case_fn: default_case,
  }
}

///|
pub fn[T] DotSwitch::is_switch_for(
  self : DotSwitch[T],
  package_id : DotPackage,
) -> Bool {
  package_id == self.model_package
}

///|
pub fn[T] DotSwitch::do_switch(
  self : DotSwitch[T],
  target : DotSwitchTarget,
) -> T? {
  fn chain(result : T?, fallback : () -> T?) -> T? {
    match result {
      Some(_) => result
      None => fallback()
    }
  }

  match target {
    DotGraphvizModelTarget(object) =>
      chain((self.case_graphviz_model_fn)(object), self.default_case_fn)
    DotGraphTarget(object) =>
      chain((self.case_graph_fn)(object), self.default_case_fn)
    DotStatementTarget(object) =>
      chain((self.case_statement_fn)(object), self.default_case_fn)
    DotAttributeTarget(object) =>
      chain((self.case_attribute_fn)(object), () => {
        chain(
          (self.case_statement_fn)(dot_statement_attribute(object)),
          self.default_case_fn,
        )
      })
    DotNodeStatementTarget(object) =>
      chain((self.case_node_statement_fn)(object), () => {
        chain(
          (self.case_statement_fn)(dot_statement_node_statement(object)),
          self.default_case_fn,
        )
      })
    DotNodeTarget(object) =>
      chain((self.case_node_fn)(object), self.default_case_fn)
    DotEdgeStatementTarget(object) =>
      chain((self.case_edge_statement_fn)(object), () => {
        chain(
          (self.case_statement_fn)(dot_statement_edge_statement(object)),
          self.default_case_fn,
        )
      })
    DotEdgeTargetTarget(object) =>
      chain((self.case_edge_target_fn)(object), self.default_case_fn)
    DotAttributeStatementTarget(object) =>
      chain((self.case_attribute_statement_fn)(object), () => {
        chain(
          (self.case_statement_fn)(dot_statement_attribute_statement(object)),
          self.default_case_fn,
        )
      })
    DotSubgraphTarget(object) =>
      chain((self.case_subgraph_fn)(object), () => {
        chain(
          (self.case_statement_fn)(dot_statement_subgraph(object)),
          self.default_case_fn,
        )
      })
    DotPortTarget(object) =>
      chain((self.case_port_fn)(object), self.default_case_fn)
  }
}
