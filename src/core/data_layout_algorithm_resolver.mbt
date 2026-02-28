///|
pub(all) struct LayoutAlgorithmResolver {
  default_layout_algorithm_id : String
}

///|
pub fn new_layout_algorithm_resolver(
  default_layout_algorithm_id? : String = "org.eclipse.elk.layered",
) -> LayoutAlgorithmResolver {
  { default_layout_algorithm_id, }
}

///|
fn resolved_algorithm_id(node : @graph.ElkNode) -> String {
  @graph.node_get_string_property(node, resolved_algorithm)
}

///|
fn must_resolve(node : @graph.ElkNode) -> Bool {
  resolved_algorithm_id(node).is_empty() &&
  (
    !@graph.node_children(node).is_empty() ||
    @graph.node_get_bool_property(node, inside_self_loops_activate)
  )
}

///|
pub fn LayoutAlgorithmResolver::resolve_and_set_algorithm(
  self : LayoutAlgorithmResolver,
  algorithm_id : String,
  node : @graph.ElkNode,
) -> Bool {
  ignore(self)
  match layout_meta_data_service_get_algorithm_data_by_suffix(algorithm_id) {
    Some(algorithm_data) => {
      @graph.node_set_string_property(
        node,
        resolved_algorithm,
        algorithm_data.get_id(),
      )
      true
    }
    None => false
  }
}

///|
pub fn LayoutAlgorithmResolver::resolve_algorithm(
  self : LayoutAlgorithmResolver,
  node : @graph.ElkNode,
) -> Unit {
  let algorithm_id = @graph.node_get_string_property(node, algorithm)
  if self.resolve_and_set_algorithm(algorithm_id, node) {
    return
  }
  if must_resolve(node) {
    if algorithm_id.trim().is_empty() {
      if !self.resolve_and_set_algorithm(self.default_layout_algorithm_id, node) {
        let message = "Unable to load default layout algorithm " +
          self.default_layout_algorithm_id +
          " for unconfigured node"
        layout_runtime_report_unsupported_configuration(message)
        return
      }
    } else {
      let message = "Layout algorithm '" + algorithm_id + "' not found"
      layout_runtime_report_unsupported_configuration(message)
      return
    }
  }
}

///|
pub fn LayoutAlgorithmResolver::visit(
  self : LayoutAlgorithmResolver,
  node : @graph.ElkNode,
) -> Unit {
  if @graph.node_get_bool_property(node, no_layout) {
    return
  }
  self.resolve_algorithm(node)
}

///|
pub fn LayoutAlgorithmResolver::to_visitor(
  self : LayoutAlgorithmResolver,
) -> IGraphElementVisitor {
  new_graph_element_visitor(node => self.visit(node))
}
