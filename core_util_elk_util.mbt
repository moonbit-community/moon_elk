///|
pub fn apply_visitors(
  graph : ElkNode,
  visitors : Array[IGraphElementVisitor],
) -> Unit {
  for element in node_all_descendants_including_self(graph) {
    for visitor in visitors {
      visitor.visit(element)
    }
  }
}

///|
pub fn apply_visitor(graph : ElkNode, visitor : IGraphElementVisitor) -> Unit {
  apply_visitors(graph, [visitor])
}

///|
fn contains_alignment(alignments : Array[String], value : String) -> Bool {
  for alignment in alignments {
    if alignment == value {
      return true
    }
  }
  false
}

///|
pub fn translate(
  parent : ElkNode,
  new_size : KVector,
  old_size : KVector,
) -> Unit {
  let content_alignment_value = node_get_string_set_property(
    parent, content_alignment,
  )
  let mut x_translate = 0.0
  let mut y_translate = 0.0
  if new_size.x > old_size.x {
    if contains_alignment(content_alignment_value, "H_CENTER") {
      x_translate = (new_size.x - old_size.x) / 2.0
    } else if contains_alignment(content_alignment_value, "H_RIGHT") {
      x_translate = new_size.x - old_size.x
    }
  }
  if new_size.y > old_size.y {
    if contains_alignment(content_alignment_value, "V_CENTER") {
      y_translate = (new_size.y - old_size.y) / 2.0
    } else if contains_alignment(content_alignment_value, "V_BOTTOM") {
      y_translate = new_size.y - old_size.y
    }
  }
  translate_xy(parent, x_translate, y_translate)
}

///|
pub fn translate_xy(
  parent : ElkNode,
  x_translate : Double,
  y_translate : Double,
) -> Unit {
  for child in node_children(parent) {
    node_set_location(
      child,
      node_x(child) + x_translate,
      node_y(child) + y_translate,
    )
  }
}
