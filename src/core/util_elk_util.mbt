///|
pub fn apply_visitors(
  graph : @graph.ElkNode,
  visitors : Array[IGraphElementVisitor],
) -> Unit {
  for element in @graph.node_all_descendants_including_self(graph) {
    for visitor in visitors {
      visitor.visit(element)
    }
  }
}

///|
pub fn apply_visitor(
  graph : @graph.ElkNode,
  visitor : IGraphElementVisitor,
) -> Unit {
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
  parent : @graph.ElkNode,
  new_size : KVector,
  old_size : KVector,
) -> Unit {
  let content_alignment_value = @graph.node_get_string_set_property(
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
  parent : @graph.ElkNode,
  x_translate : Double,
  y_translate : Double,
) -> Unit {
  for child in @graph.node_children(parent) {
    @graph.node_set_location(
      child,
      @graph.node_x(child) + x_translate,
      @graph.node_y(child) + y_translate,
    )
  }
}

///|
fn parse_shape_margins(value : String?) -> ElkMargin {
  let margins = new_elk_margin()
  if value is Some(text) {
    margins.parse(text)
  }
  margins
}

///|
fn update_bounds(
  min_x : Ref[Double],
  min_y : Ref[Double],
  max_x : Ref[Double],
  max_y : Ref[Double],
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  margins : ElkMargin,
) -> Unit {
  let left = x - margins.left
  let top = y - margins.top
  let right = x + width + margins.right
  let bottom = y + height + margins.bottom
  if left < min_x.val {
    min_x.val = left
  }
  if top < min_y.val {
    min_y.val = top
  }
  if right > max_x.val {
    max_x.val = right
  }
  if bottom > max_y.val {
    max_y.val = bottom
  }
}

///|
pub fn compute_child_area_dimensions(node : @graph.ElkNode) -> Unit {
  let min_x : Ref[Double] = Ref::new(@double.infinity)
  let min_y : Ref[Double] = Ref::new(@double.infinity)
  let max_x : Ref[Double] = Ref::new(0.0)
  let max_y : Ref[Double] = Ref::new(0.0)

  for label in @graph.node_labels(node) {
    update_bounds(
      min_x,
      min_y,
      max_x,
      max_y,
      @graph.label_x(label),
      @graph.label_y(label),
      @graph.label_width(label),
      @graph.label_height(label),
      parse_shape_margins(
        @graph.label_layout_option_string_value(
          label, "org.eclipse.elk.margins",
        ),
      ),
    )
  }

  for child in @graph.node_children(node) {
    update_bounds(
      min_x,
      min_y,
      max_x,
      max_y,
      @graph.node_x(child),
      @graph.node_y(child),
      @graph.node_width(child),
      @graph.node_height(child),
      parse_shape_margins(
        @graph.node_layout_option_string_value(child, "org.eclipse.elk.margins"),
      ),
    )
  }

  for edge in @graph.node_contained_edges(node) {
    for label in @graph.edge_labels(edge) {
      update_bounds(
        min_x,
        min_y,
        max_x,
        max_y,
        @graph.label_x(label),
        @graph.label_y(label),
        @graph.label_width(label),
        @graph.label_height(label),
        parse_shape_margins(
          @graph.label_layout_option_string_value(
            label, "org.eclipse.elk.margins",
          ),
        ),
      )
    }
  }

  for edge in @graph.node_contained_edges(node) {
    for section in @graph.edge_sections(edge) {
      let sx = @graph.edge_section_start_x(section)
      let sy = @graph.edge_section_start_y(section)
      let ex = @graph.edge_section_end_x(section)
      let ey = @graph.edge_section_end_y(section)

      if sx < min_x.val {
        min_x.val = sx
      }
      if ex < min_x.val {
        min_x.val = ex
      }
      if sy < min_y.val {
        min_y.val = sy
      }
      if ey < min_y.val {
        min_y.val = ey
      }

      if sx > max_x.val {
        max_x.val = sx
      }
      if ex > max_x.val {
        max_x.val = ex
      }
      if sy > max_y.val {
        max_y.val = sy
      }
      if ey > max_y.val {
        max_y.val = ey
      }
    }
  }

  @graph.node_set_double_property(node, child_area_width, max_x.val - min_x.val)
  @graph.node_set_double_property(
    node,
    child_area_height,
    max_y.val - min_y.val,
  )
}
