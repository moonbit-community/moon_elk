///|
pub(all) struct CompoundGraphElementVisitor {
  graph_visitors : Array[@core.IGraphElementVisitor]
  apply_to_full_graph_first : Bool
}

///|
pub fn new_compound_graph_element_visitor(
  visitors? : Array[@core.IGraphElementVisitor] = [],
) -> CompoundGraphElementVisitor {
  { graph_visitors: visitors, apply_to_full_graph_first: false }
}

///|
pub fn new_compound_graph_element_visitor_with_mode(
  apply_to_full_graph_first : Bool,
  visitors? : Array[@core.IGraphElementVisitor] = [],
) -> CompoundGraphElementVisitor {
  { graph_visitors: visitors, apply_to_full_graph_first }
}

///|
fn compound_graph_element_visitor_apply_single_visitor(
  root : @graph.ElkNode,
  visitor : @core.IGraphElementVisitor,
) -> Unit {
  for element in @graph.node_all_descendants_including_self(root) {
    visitor.visit(element)
  }
}

///|
pub fn CompoundGraphElementVisitor::visit(
  self : CompoundGraphElementVisitor,
  element : @graph.ElkNode,
) -> Unit {
  if self.apply_to_full_graph_first {
    if @graph.node_parent(element) is None {
      for graph_visitor in self.graph_visitors {
        compound_graph_element_visitor_apply_single_visitor(
          element, graph_visitor,
        )
      }
    }
  } else {
    for graph_visitor in self.graph_visitors {
      graph_visitor.visit(element)
    }
  }
}

///|
pub fn CompoundGraphElementVisitor::add_graph_visitors(
  self : CompoundGraphElementVisitor,
  visitors : Array[@core.IGraphElementVisitor],
) -> Unit {
  for visitor in visitors {
    self.graph_visitors.push(visitor)
  }
}

///|
pub fn CompoundGraphElementVisitor::get_graph_visitors(
  self : CompoundGraphElementVisitor,
) -> Array[@core.IGraphElementVisitor] {
  self.graph_visitors
}

///|
pub fn CompoundGraphElementVisitor::to_visitor(
  self : CompoundGraphElementVisitor,
) -> @core.IGraphElementVisitor {
  @core.new_graph_element_visitor(node => self.visit(node))
}
