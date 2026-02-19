///|
let core_ui_zoom_per_wheel_unit : Double = 1.01

///|
pub struct CoreUiPoint {
  x : Int
  y : Int
}

///|
pub struct CoreUiPaintEvent {
  x : Int
  y : Int
  width : Int
  height : Int
  graphics : CoreUiGraphics
}

///|
pub fn new_core_ui_paint_event(
  x : Int,
  y : Int,
  width : Int,
  height : Int,
  graphics : CoreUiGraphics,
) -> CoreUiPaintEvent {
  { x, y, width, height, graphics }
}

///|
pub struct GraphRenderingCanvas {
  mut layout_graph : ElkNode?
  graph_renderer : GraphRenderer
  background_color : CoreUiColor
  display : CoreUiDisplay
  mut redraw_count : Int
  mut width : Int
  mut height : Int
  mut mouse_interaction_enabled : Bool
  mut is_dragging : Bool
  mut last_x : Int
  mut last_y : Int
}

///|
pub fn new_graph_rendering_canvas(
  display : CoreUiDisplay,
) -> GraphRenderingCanvas {
  new_graph_rendering_canvas_with_configurator(
    display,
    new_graph_rendering_configurator(display),
  )
}

///|
pub fn new_graph_rendering_canvas_with_configurator(
  display : CoreUiDisplay,
  configurator : GraphRenderingConfigurator,
) -> GraphRenderingCanvas {
  if configurator.get_display() != display {
    abort("configurator and parent composite must use the same display.")
  }
  let graph_renderer = new_graph_renderer(configurator)
  let background_color = new_core_ui_color(display, 255, 255, 255)
  {
    layout_graph: None,
    graph_renderer,
    background_color,
    display,
    redraw_count: 0,
    width: 0,
    height: 0,
    mouse_interaction_enabled: false,
    is_dragging: false,
    last_x: 0,
    last_y: 0,
  }
}

///|
pub fn GraphRenderingCanvas::dispose(self : GraphRenderingCanvas) -> Unit {
  self.graph_renderer.dispose()
  core_ui_color_dispose(self.background_color)
}

///|
pub fn GraphRenderingCanvas::compute_size(
  self : GraphRenderingCanvas,
  w_hint : Int,
  h_hint : Int,
  _changed? : Bool = false,
) -> CoreUiPoint {
  match self.layout_graph {
    Some(graph) => {
      let mut width = node_width(graph).round().to_int()
      let mut height = node_height(graph).round().to_int()
      if w_hint > width {
        width = w_hint
      }
      if h_hint > height {
        height = h_hint
      }
      { x: width, y: height }
    }
    None => { x: w_hint, y: h_hint }
  }
}

///|
pub fn GraphRenderingCanvas::get_renderer(
  self : GraphRenderingCanvas,
) -> GraphRenderer {
  self.graph_renderer
}

///|
pub fn GraphRenderingCanvas::get_layout_graph(
  self : GraphRenderingCanvas,
) -> ElkNode? {
  self.layout_graph
}

///|
pub fn GraphRenderingCanvas::set_layout_graph(
  self : GraphRenderingCanvas,
  graph : ElkNode?,
) -> Unit {
  let base_offset = self.calculate_required_canvas_size_and_base_offset(graph)
  self.layout_graph = graph
  self.graph_renderer.set_base_offset(Some(base_offset))
  self.redraw()
}

///|
fn graph_rendering_canvas_scan_edge_points(
  section : ElkEdgeSection,
  min_x : Ref[Double],
  max_x : Ref[Double],
  min_y : Ref[Double],
  max_y : Ref[Double],
) -> Unit {
  let start_x = edge_section_start_x(section)
  let start_y = edge_section_start_y(section)
  let end_x = edge_section_end_x(section)
  let end_y = edge_section_end_y(section)
  min_x.val = @cmp.minimum(min_x.val, @cmp.minimum(start_x, end_x))
  min_y.val = @cmp.minimum(min_y.val, @cmp.minimum(start_y, end_y))
  max_x.val = @cmp.maximum(max_x.val, @cmp.maximum(start_x, end_x))
  max_y.val = @cmp.maximum(max_y.val, @cmp.maximum(start_y, end_y))
}

///|
pub fn GraphRenderingCanvas::calculate_required_canvas_size_and_base_offset(
  self : GraphRenderingCanvas,
  graph : ElkNode?,
) -> KVector {
  match graph {
    Some(layout_graph) => {
      let min_x : Ref[Double] = Ref::new(@float.max_value.to_double())
      let max_x : Ref[Double] = Ref::new(-@float.max_value.to_double())
      let min_y : Ref[Double] = Ref::new(@float.max_value.to_double())
      let max_y : Ref[Double] = Ref::new(-@float.max_value.to_double())

      for node in node_children(layout_graph) {
        min_x.val = @cmp.minimum(min_x.val, node_x(node))
        max_x.val = @cmp.maximum(max_x.val, node_x(node) + node_width(node))
        min_y.val = @cmp.minimum(min_y.val, node_y(node))
        max_y.val = @cmp.maximum(max_y.val, node_y(node) + node_height(node))

        for node_label in node_labels(node) {
          min_x.val = @cmp.minimum(
            min_x.val,
            node_x(node) + label_x(node_label),
          )
          max_x.val = @cmp.maximum(
            max_x.val,
            node_x(node) + label_x(node_label) + label_width(node_label),
          )
          min_y.val = @cmp.minimum(
            min_y.val,
            node_y(node) + label_y(node_label),
          )
          max_y.val = @cmp.maximum(
            max_y.val,
            node_y(node) + label_y(node_label) + label_height(node_label),
          )
        }
      }

      for edge in node_contained_edges(layout_graph) {
        for section in edge_sections(edge) {
          graph_rendering_canvas_scan_edge_points(
            section, min_x, max_x, min_y, max_y,
          )
        }
        for edge_label in edge_labels(edge) {
          min_x.val = @cmp.minimum(min_x.val, label_x(edge_label))
          max_x.val = @cmp.maximum(
            max_x.val,
            label_x(edge_label) + label_width(edge_label),
          )
          min_y.val = @cmp.minimum(min_y.val, label_y(edge_label))
          max_y.val = @cmp.maximum(
            max_y.val,
            label_y(edge_label) + label_height(edge_label),
          )
        }
      }

      if min_x.val == @float.max_value.to_double() {
        min_x.val = 0.0
        min_y.val = 0.0
        max_x.val = node_width(layout_graph)
        max_y.val = node_height(layout_graph)
      }

      self.width = (@cmp.maximum(node_width(layout_graph), max_x.val) -
        @cmp.minimum(0.0, min_x.val)).to_int() +
        1
      self.height = (@cmp.maximum(node_height(layout_graph), max_y.val) -
        @cmp.minimum(0.0, min_y.val)).to_int() +
        1

      new_kvector_xy(
        -@cmp.minimum(0.0, min_x.val),
        -@cmp.minimum(0.0, min_y.val),
      )
    }
    None => new_kvector()
  }
}

///|
pub fn GraphRenderingCanvas::setup_mouse_interaction(
  self : GraphRenderingCanvas,
) -> Unit {
  self.mouse_interaction_enabled = true
}

///|
pub fn GraphRenderingCanvas::handle_mouse_wheel(
  self : GraphRenderingCanvas,
  count : Int,
  x : Int,
  y : Int,
) -> Unit {
  if !self.mouse_interaction_enabled {
    return
  }
  let zoom = @math.pow(core_ui_zoom_per_wheel_unit, -count.to_double())
  self.zoom(zoom, new_kvector_xy(x.to_double(), y.to_double()))
  self.redraw()
}

///|
pub fn GraphRenderingCanvas::mouse_down(
  self : GraphRenderingCanvas,
  x : Int,
  y : Int,
) -> Unit {
  if !self.mouse_interaction_enabled {
    return
  }
  self.is_dragging = true
  self.last_x = x
  self.last_y = y
}

///|
pub fn GraphRenderingCanvas::mouse_up(
  self : GraphRenderingCanvas,
  x : Int,
  y : Int,
) -> Unit {
  if !self.mouse_interaction_enabled {
    return
  }
  self.is_dragging = false
  self.last_x = x
  self.last_y = y
}

///|
pub fn GraphRenderingCanvas::mouse_move(
  self : GraphRenderingCanvas,
  x : Int,
  y : Int,
) -> Unit {
  if !self.mouse_interaction_enabled {
    return
  }
  if self.is_dragging {
    let delta = new_kvector_xy(
      (x - self.last_x).to_double(),
      (y - self.last_y).to_double(),
    )
    self.pan(delta)
    self.redraw()
  }
  self.last_x = x
  self.last_y = y
}

///|
pub fn GraphRenderingCanvas::zoom(
  self : GraphRenderingCanvas,
  zoom : Double,
  focus_point : KVector,
) -> Unit {
  let new_scale = self.graph_renderer.get_scale() * zoom
  self.graph_renderer.set_scale(new_scale)
  let abs_focus = kvector_diff(
    focus_point,
    self.graph_renderer.get_base_offset(),
  )
  self.graph_renderer.set_base_offset(
    Some(abs_focus.scale(zoom).sub(focus_point).negate()),
  )
}

///|
pub fn GraphRenderingCanvas::pan(
  self : GraphRenderingCanvas,
  delta : KVector,
) -> Unit {
  let offset = self.graph_renderer.get_base_offset().add(delta)
  self.graph_renderer.set_base_offset(Some(offset))
}

///|
pub fn GraphRenderingCanvas::paint_control(
  self : GraphRenderingCanvas,
  event : CoreUiPaintEvent,
) -> Unit {
  match self.layout_graph {
    Some(graph) => {
      let area = new_core_ui_paint_rectangle(
        event.x,
        event.y,
        event.width,
        event.height,
      )
      self.graph_renderer.mark_dirty(Some(area))
      self.graph_renderer.render(graph, event.graphics, area)
    }
    None => ()
  }
}

///|
pub fn GraphRenderingCanvas::redraw(self : GraphRenderingCanvas) -> Unit {
  self.redraw_count = self.redraw_count + 1
}

///|
pub fn GraphRenderingCanvas::get_redraw_count(
  self : GraphRenderingCanvas,
) -> Int {
  self.redraw_count
}

///|
pub fn GraphRenderingCanvas::get_display(
  self : GraphRenderingCanvas,
) -> CoreUiDisplay {
  self.display
}

///|
pub fn GraphRenderingCanvas::get_size_for_test(
  self : GraphRenderingCanvas,
) -> (Int, Int) {
  (self.width, self.height)
}
