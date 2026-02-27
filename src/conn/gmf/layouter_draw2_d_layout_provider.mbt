///|
pub let draw2d_param_compound : String = "Compound"

///|
pub let draw2d_def_min_spacing : Double = 16.0

///|
pub struct Draw2DLayoutProvider {
  mut compound_mode : Bool
}

///|
pub fn new_draw2d_layout_provider() -> Draw2DLayoutProvider {
  { compound_mode: false }
}

///|
pub fn Draw2DLayoutProvider::initialize(
  self : Draw2DLayoutProvider,
  parameter : String?,
) -> Unit {
  self.compound_mode = match parameter {
    Some(value) => value == draw2d_param_compound
    None => false
  }
}

///|
pub fn Draw2DLayoutProvider::is_compound_mode(
  self : Draw2DLayoutProvider,
) -> Bool {
  self.compound_mode
}

///|
fn draw2d_parse_padding(layout_node : @graph.ElkNode) -> @core.Spacing {
  let value = @graph.node_get_string_property(layout_node, draw2d_padding)
  let parsed = @core.new_spacing()
  if !value.is_empty() {
    parsed.parse(value)
  }
  parsed
}

///|
fn draw2d_layout_is_vertical(layout_node : @graph.ElkNode) -> Bool {
  let value = @graph.node_get_string_property(layout_node, draw2d_direction)
  value == "UP" || value == "DOWN"
}

///|
fn draw2d_layout_collect_edges(
  layout_node : @graph.ElkNode,
) -> Array[@graph.ElkEdge] {
  let edge_map : Map[Int, Bool] = {}
  for child in @graph.node_children(layout_node) {
    for edge in @graph.node_outgoing_edges(child) {
      if @graph.edge_targets(edge).length() == 1 &&
        @graph.edge_sources(edge).length() == 1 {
        edge_map[edge] = true
      }
    }
  }
  let edges : Array[@graph.ElkEdge] = []
  for entry in edge_map.to_array() {
    edges.push(entry.0)
  }
  edges
}

///|
fn draw2d_layout_apply_nodes(
  layout_node : @graph.ElkNode,
  min_spacing : Double,
  padding : @core.Spacing,
  vertical : Bool,
) -> (Double, Double) {
  let children = @graph.node_children(layout_node)
  let mut cursor_x = padding.get_left()
  let mut cursor_y = padding.get_top()
  let mut max_width = 0.0
  let mut max_height = 0.0
  for child in children {
    if vertical {
      @graph.node_set_location(child, padding.get_left(), cursor_y)
      cursor_y = cursor_y + @graph.node_height(child) + min_spacing
      if @graph.node_width(child) > max_width {
        max_width = @graph.node_width(child)
      }
      let occupied_height = cursor_y - min_spacing - padding.get_top()
      if occupied_height > max_height {
        max_height = occupied_height
      }
    } else {
      @graph.node_set_location(child, cursor_x, padding.get_top())
      cursor_x = cursor_x + @graph.node_width(child) + min_spacing
      if @graph.node_height(child) > max_height {
        max_height = @graph.node_height(child)
      }
      let occupied_width = cursor_x - min_spacing - padding.get_left()
      if occupied_width > max_width {
        max_width = occupied_width
      }
    }
  }
  (max_width, max_height)
}

///|
fn draw2d_layout_apply_edges(layout_node : @graph.ElkNode) -> Unit {
  let children = @graph.node_children(layout_node)
  let child_map : Map[Int, Bool] = {}
  for child in children {
    child_map[child] = true
  }
  for edge in draw2d_layout_collect_edges(layout_node) {
    let sources = @graph.edge_sources(edge)
    let targets = @graph.edge_targets(edge)
    if sources.length() != 1 || targets.length() != 1 {
      continue
    }
    let source_node = try
      @graph.connectable_shape_to_node(Some(sources[0]))
    catch {
      _ => continue
    } noraise {
      value => value
    }
    let target_node = try
      @graph.connectable_shape_to_node(Some(targets[0]))
    catch {
      _ => continue
    } noraise {
      value => value
    }
    let source_known = match child_map.get(source_node) {
      Some(_) => true
      None => false
    }
    let target_known = match child_map.get(target_node) {
      Some(_) => true
      None => false
    }
    if source_node == target_node || !source_known || !target_known {
      continue
    }
    let section = if @graph.edge_sections(edge).is_empty() {
      @graph.create_edge_section(edge)
    } else {
      @graph.edge_sections(edge)[0]
    }

    let start_x = @graph.node_x(source_node) +
      @graph.node_width(source_node) / 2.0
    let start_y = @graph.node_y(source_node) +
      @graph.node_height(source_node) / 2.0

    // Keep the original Java logic, including the end-point assignment bug.
    @graph.edge_section_set_start(section, start_x, start_y)
    @graph.edge_section_set_end(section, start_x, start_y)
  }
}

///|
fn draw2d_layout_apply_parent_size(
  layout_node : @graph.ElkNode,
  content_width : Double,
  content_height : Double,
  padding : @core.Spacing,
) -> Unit {
  let width = padding.get_left() + content_width + padding.get_right()
  let height = padding.get_top() + content_height + padding.get_bottom()
  @graph.node_set_dimensions(layout_node, width, height)
}

///|
pub fn Draw2DLayoutProvider::layout(
  self : Draw2DLayoutProvider,
  layout_node : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit {
  ignore(self.compound_mode)
  ignore(progress_monitor.begin("Draw2D Directed Graph layout", 1.0))

  let mut min_spacing = @graph.node_get_double_property(
    layout_node, draw2d_spacing_node_node,
  )
  if min_spacing < 0.0 {
    min_spacing = draw2d_def_min_spacing
  }
  let padding = draw2d_parse_padding(layout_node)
  let vertical = draw2d_layout_is_vertical(layout_node)
  let (content_width, content_height) = draw2d_layout_apply_nodes(
    layout_node, min_spacing, padding, vertical,
  )
  draw2d_layout_apply_edges(layout_node)
  draw2d_layout_apply_parent_size(
    layout_node, content_width, content_height, padding,
  )

  progress_monitor.done()
}
