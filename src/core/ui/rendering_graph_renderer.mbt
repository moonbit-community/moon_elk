///|
let core_ui_graph_renderer_arrow_length : Double = 8.0

///|
let core_ui_graph_renderer_arrow_width : Double = 7.0

///|
let core_ui_graph_renderer_edge_routing_option_id : String = "org.eclipse.elk.edgeRouting"

///|
let core_ui_graph_renderer_edge_type_option_id : String = "org.eclipse.elk.edgeType"

///|
pub(all) struct CoreUiPaintRectangle {
  x : Int
  y : Int
  width : Int
  height : Int
  mut painted : Bool
}

///|
pub fn new_core_ui_paint_rectangle(
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> CoreUiPaintRectangle {
  { x, y, width, height, painted: false }
}

///|
fn core_ui_paint_rectangle_intersects(
  rect : CoreUiPaintRectangle,
  other : CoreUiPaintRectangle,
) -> Bool {
  other.x < rect.x + rect.width &&
  other.y < rect.y + rect.height &&
  other.x + other.width > rect.x &&
  other.y + other.height > rect.y
}

///|
fn core_ui_paint_rectangle_from_shape(
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  offset : @core.KVector,
  scale : Double,
) -> CoreUiPaintRectangle {
  new_core_ui_paint_rectangle(
    (x * scale + offset.x).round().to_int(),
    (y * scale + offset.y).round().to_int(),
    @cmp.maximum((width * scale).round().to_int(), 1),
    @cmp.maximum((height * scale).round().to_int(), 1),
  )
}

///|
fn core_ui_paint_rectangle_from_edge(
  edge : @graph.ElkEdge,
  offset : @core.KVector,
  scale : Double,
) -> CoreUiPaintRectangle {
  let mut min_x = @float.max_value.to_double()
  let mut min_y = @float.max_value.to_double()
  let mut max_x = -@float.max_value.to_double()
  let mut max_y = -@float.max_value.to_double()

  for section in @graph.edge_sections(edge) {
    let start_x = @graph.edge_section_start_x(section)
    let start_y = @graph.edge_section_start_y(section)
    let end_x = @graph.edge_section_end_x(section)
    let end_y = @graph.edge_section_end_y(section)
    min_x = @cmp.minimum(min_x, @cmp.minimum(start_x, end_x))
    min_y = @cmp.minimum(min_y, @cmp.minimum(start_y, end_y))
    max_x = @cmp.maximum(max_x, @cmp.maximum(start_x, end_x))
    max_y = @cmp.maximum(max_y, @cmp.maximum(start_y, end_y))
  }

  if min_x == @float.max_value.to_double() {
    min_x = 0.0
    min_y = 0.0
    max_x = 0.0
    max_y = 0.0
  }
  new_core_ui_paint_rectangle(
    (min_x * scale + offset.x).round().to_int(),
    (min_y * scale + offset.y).round().to_int(),
    ((max_x - min_x) * scale).round().to_int(),
    ((max_y - min_y) * scale).round().to_int(),
  )
}

///|
pub(all) struct CoreUiGraphics {
  operations : Array[String]
  mut alpha : Int
  mut font : CoreUiFont?
}

///|
pub fn new_core_ui_graphics() -> CoreUiGraphics {
  { operations: [], alpha: 255, font: None }
}

///|
pub fn CoreUiGraphics::set_alpha(self : CoreUiGraphics, alpha : Int) -> Unit {
  self.alpha = alpha
}

///|
pub fn CoreUiGraphics::set_font(
  self : CoreUiGraphics,
  font : CoreUiFont?,
) -> Unit {
  self.font = font
}

///|
pub fn CoreUiGraphics::font_height(self : CoreUiGraphics) -> Int {
  match self.font {
    Some(font) => font.size
    None => 0
  }
}

///|
fn core_ui_graphics_record(
  graphics : CoreUiGraphics,
  operation : String,
) -> Unit {
  graphics.operations.push(operation)
}

///|
pub(all) struct GraphRenderer {
  bounds_map : Map[String, CoreUiPaintRectangle]
  configurator : GraphRenderingConfigurator
  mut scale : Double
  mut base_offset : @core.KVector
  mut most_recently_drawn_graph : @graph.ElkNode?
}

///|
pub fn new_graph_renderer(
  configurator : GraphRenderingConfigurator,
) -> GraphRenderer {
  {
    bounds_map: {},
    configurator,
    scale: 1.0,
    base_offset: @core.new_kvector(),
    most_recently_drawn_graph: None,
  }
}

///|
pub fn GraphRenderer::dispose(self : GraphRenderer) -> Unit {
  self.flush_cache()
  self.most_recently_drawn_graph = None
  self.configurator.dispose()
}

///|
pub fn GraphRenderer::get_base_offset(self : GraphRenderer) -> @core.KVector {
  self.base_offset
}

///|
pub fn GraphRenderer::set_base_offset(
  self : GraphRenderer,
  base_offset : @core.KVector?,
) -> Unit {
  self.base_offset = match base_offset {
    Some(value) => value
    None => @core.new_kvector()
  }
  self.flush_cache()
}

///|
pub fn GraphRenderer::get_scale(self : GraphRenderer) -> Double {
  self.scale
}

///|
pub fn GraphRenderer::set_scale(self : GraphRenderer, scale : Double) -> Unit {
  self.scale = scale
  self.configurator.set_scale(scale)
  self.flush_cache()
}

///|
fn core_ui_graph_renderer_scale(
  renderer : GraphRenderer,
  value : Double,
) -> Int {
  (renderer.scale * value).round().to_int()
}

///|
fn core_ui_graph_renderer_mark_dirty_rect(
  renderer : GraphRenderer,
  key : String,
  area : CoreUiPaintRectangle?,
) -> Unit {
  match renderer.bounds_map.get(key) {
    Some(rectangle) =>
      if area is None ||
        core_ui_paint_rectangle_intersects(
          rectangle,
          match area {
            Some(value) => value
            None => new_core_ui_paint_rectangle(0, 0, 0, 0)
          },
        ) {
        rectangle.painted = false
        renderer.bounds_map[key] = rectangle
      }
    None => ()
  }
}

///|
pub fn GraphRenderer::mark_dirty(
  self : GraphRenderer,
  area : CoreUiPaintRectangle?,
) -> Unit {
  for entry in self.bounds_map.to_array() {
    core_ui_graph_renderer_mark_dirty_rect(self, entry.0, area)
  }
}

///|
pub fn GraphRenderer::flush_cache(self : GraphRenderer) -> Unit {
  self.bounds_map.clear()
}

///|
fn core_ui_graph_renderer_key_node(node : @graph.ElkNode) -> String {
  "n:\{node}"
}

///|
fn core_ui_graph_renderer_key_port(port : @graph.ElkPort) -> String {
  "p:\{port}"
}

///|
fn core_ui_graph_renderer_key_edge(edge : @graph.ElkEdge) -> String {
  "e:\{edge}"
}

///|
fn core_ui_graph_renderer_key_label(label : @graph.ElkLabel) -> String {
  "l:\{label}"
}

///|
fn core_ui_graph_renderer_put_if_absent(
  renderer : GraphRenderer,
  key : String,
  rect : CoreUiPaintRectangle,
) -> CoreUiPaintRectangle {
  match renderer.bounds_map.get(key) {
    Some(existing) => existing
    None => {
      renderer.bounds_map[key] = rect
      rect
    }
  }
}

///|
fn core_ui_graph_renderer_set_rect(
  renderer : GraphRenderer,
  key : String,
  rect : CoreUiPaintRectangle,
) -> Unit {
  renderer.bounds_map[key] = rect
}

///|
fn core_ui_graph_renderer_max_depth(parent : @graph.ElkNode) -> Int {
  let mut max_depth = 0
  for child in @graph.node_children(parent) {
    let depth = core_ui_graph_renderer_max_depth(child) + 1
    if depth > max_depth {
      max_depth = depth
    }
  }
  max_depth
}

///|
fn core_ui_graph_renderer_render_label(
  renderer : GraphRenderer,
  label : @graph.ElkLabel,
  graphics : CoreUiGraphics,
  area : CoreUiPaintRectangle,
  offset : @core.KVector,
  label_alpha : Int,
) -> Unit {
  if graphics.font_height() < core_ui_min_font_height {
    return
  }
  let key = core_ui_graph_renderer_key_label(label)
  let rect = core_ui_graph_renderer_put_if_absent(
    renderer,
    key,
    core_ui_paint_rectangle_from_shape(
      @graph.label_x(label),
      @graph.label_y(label),
      @graph.label_width(label),
      @graph.label_height(label),
      offset,
      renderer.scale,
    ),
  )
  if !rect.painted && core_ui_paint_rectangle_intersects(rect, area) {
    graphics.set_alpha(label_alpha)
    core_ui_graphics_record(
      graphics,
      "draw-label-box@\{rect.x},\{rect.y},\{rect.width},\{rect.height}",
    )
    let text = @graph.label_text(label)
    if !text.is_empty() {
      graphics.set_alpha(255)
      core_ui_graphics_record(graphics, "draw-text@\{rect.x},\{rect.y}:\{text}")
    }
    rect.painted = true
    core_ui_graph_renderer_set_rect(renderer, key, rect)
  }
}

///|
fn core_ui_graph_renderer_render_port(
  renderer : GraphRenderer,
  port : @graph.ElkPort,
  graphics : CoreUiGraphics,
  area : CoreUiPaintRectangle,
  offset : @core.KVector,
  label_alpha : Int,
) -> Unit {
  let key = core_ui_graph_renderer_key_port(port)
  let rect = core_ui_graph_renderer_put_if_absent(
    renderer,
    key,
    core_ui_paint_rectangle_from_shape(
      @graph.port_x(port),
      @graph.port_y(port),
      @graph.port_width(port),
      @graph.port_height(port),
      offset,
      renderer.scale,
    ),
  )
  if !rect.painted && core_ui_paint_rectangle_intersects(rect, area) {
    core_ui_graphics_record(
      graphics,
      "draw-port@\{rect.x},\{rect.y},\{rect.width},\{rect.height}",
    )
    rect.painted = true
    core_ui_graph_renderer_set_rect(renderer, key, rect)
  }
  match renderer.configurator.get_port_label_font() {
    Some(font) => {
      graphics.set_font(Some(font))
      let port_offset = @core.new_kvector_xy(
        rect.x.to_double(),
        rect.y.to_double(),
      )
      for label in @graph.port_labels(port) {
        core_ui_graph_renderer_render_label(
          renderer, label, graphics, area, port_offset, label_alpha,
        )
      }
    }
    None => ()
  }
}

///|
fn core_ui_graph_renderer_is_descendant_or_self(
  node : @graph.ElkNode,
  ancestor : @graph.ElkNode,
) -> Bool {
  node == ancestor || @graph.is_descendant(node, ancestor)
}

///|
fn core_ui_graph_renderer_are_descendants_of(
  renderer : GraphRenderer,
  shapes : Array[@graph.ElkConnectableShape],
) -> Bool {
  match renderer.most_recently_drawn_graph {
    Some(graph) => {
      for shape in shapes {
        let node = try @graph.connectable_shape_to_node(Some(shape)) catch {
          _ => return false
        } noraise {
          value => value
        }
        if !core_ui_graph_renderer_is_descendant_or_self(node, graph) {
          return false
        }
      }
      true
    }
    None => false
  }
}

///|
fn core_ui_graph_renderer_is_edge_fully_contained(
  renderer : GraphRenderer,
  edge : @graph.ElkEdge,
) -> Bool {
  core_ui_graph_renderer_are_descendants_of(renderer, @graph.edge_sources(edge)) &&
  core_ui_graph_renderer_are_descendants_of(renderer, @graph.edge_targets(edge))
}

///|
fn core_ui_graph_renderer_is_spline_edge(edge : @graph.ElkEdge) -> Bool {
  match
    @graph.edge_layout_option_string_value(
      edge, core_ui_graph_renderer_edge_routing_option_id,
    ) {
    Some(value) => value == "SPLINES"
    None => false
  }
}

///|
fn core_ui_graph_renderer_is_directed_edge(edge : @graph.ElkEdge) -> Bool {
  match
    @graph.edge_layout_option_string_value(
      edge, core_ui_graph_renderer_edge_type_option_id,
    ) {
    Some(value) => value != "UNDIRECTED"
    None => true
  }
}

///|
fn core_ui_graph_renderer_make_arrow(
  renderer : GraphRenderer,
  point1 : @core.KVector,
  point2 : @core.KVector,
) -> Array[Int]? {
  if point1.x == point2.x && point1.y == point2.y {
    return None
  }
  if core_ui_graph_renderer_arrow_width * renderer.scale < 2.0 {
    return None
  }
  let arrow = [0, 0, 0, 0, 0, 0]
  arrow[0] = point2.x.round().to_int()
  arrow[1] = point2.y.round().to_int()

  let vect_x = point1.x - point2.x
  let vect_y = point1.y - point2.y
  let length = (vect_x * vect_x + vect_y * vect_y).sqrt()
  let norm_x = vect_x / length
  let norm_y = vect_y / length
  let neck_x = point2.x +
    core_ui_graph_renderer_arrow_length * norm_x * renderer.scale
  let neck_y = point2.y +
    core_ui_graph_renderer_arrow_length * norm_y * renderer.scale
  let orth_x = norm_y *
    core_ui_graph_renderer_arrow_width /
    2.0 *
    renderer.scale
  let orth_y = -norm_x *
    core_ui_graph_renderer_arrow_width /
    2.0 *
    renderer.scale

  arrow[2] = (neck_x + orth_x).round().to_int()
  arrow[3] = (neck_y + orth_y).round().to_int()
  arrow[4] = (neck_x - orth_x).round().to_int()
  arrow[5] = (neck_y - orth_y).round().to_int()
  Some(arrow)
}

///|
fn core_ui_graph_renderer_join_ints(values : Array[Int]) -> String {
  let rendered : Array[String] = []
  for value in values {
    rendered.push(value.to_string())
  }
  rendered.join(",")
}

///|
pub fn GraphRenderer::make_arrow_for_test(
  self : GraphRenderer,
  point1 : @core.KVector,
  point2 : @core.KVector,
) -> Array[Int]? {
  core_ui_graph_renderer_make_arrow(self, point1, point2)
}

///|
fn core_ui_graph_renderer_render_edge(
  renderer : GraphRenderer,
  edge : @graph.ElkEdge,
  graphics : CoreUiGraphics,
  area : CoreUiPaintRectangle,
  offset : @core.KVector,
  label_alpha : Int,
) -> Unit {
  if renderer.configurator.get_edge_color() is None {
    return
  }
  if !core_ui_graph_renderer_is_edge_fully_contained(renderer, edge) {
    return
  }
  let key = core_ui_graph_renderer_key_edge(edge)
  let rect = core_ui_graph_renderer_put_if_absent(
    renderer,
    key,
    core_ui_paint_rectangle_from_edge(edge, offset, renderer.scale),
  )
  if !rect.painted && core_ui_paint_rectangle_intersects(rect, area) {
    let _spline_edge = core_ui_graph_renderer_is_spline_edge(edge)
    let directed_edge = core_ui_graph_renderer_is_directed_edge(edge)
    for section in @graph.edge_sections(edge) {
      let start = @core.new_kvector_xy(
          @graph.edge_section_start_x(section),
          @graph.edge_section_start_y(section),
        )
        .scale(renderer.scale)
        .add(offset)
      let end_ = @core.new_kvector_xy(
          @graph.edge_section_end_x(section),
          @graph.edge_section_end_y(section),
        )
        .scale(renderer.scale)
        .add(offset)
      core_ui_graphics_record(
        graphics,
        "draw-edge:\{start.to_string()}->\{end_.to_string()}",
      )
      if directed_edge {
        match core_ui_graph_renderer_make_arrow(renderer, start, end_) {
          Some(arrow) =>
            core_ui_graphics_record(
              graphics,
              "fill-arrow:" + core_ui_graph_renderer_join_ints(arrow),
            )
          None => ()
        }
      }
    }
    rect.painted = true
    core_ui_graph_renderer_set_rect(renderer, key, rect)
  }
  match renderer.configurator.get_edge_label_font() {
    Some(font) => {
      graphics.set_font(Some(font))
      for label in @graph.edge_labels(edge) {
        core_ui_graph_renderer_render_label(
          renderer, label, graphics, area, offset, label_alpha,
        )
      }
    }
    None => ()
  }
}

///|
fn core_ui_graph_renderer_render_node_children(
  renderer : GraphRenderer,
  parent : @graph.ElkNode,
  graphics : CoreUiGraphics,
  area : CoreUiPaintRectangle,
  offset : @core.KVector,
  node_alpha : Int,
) -> Unit {
  for child_node in @graph.node_children(parent) {
    let key = core_ui_graph_renderer_key_node(child_node)
    let rect = core_ui_graph_renderer_put_if_absent(
      renderer,
      key,
      core_ui_paint_rectangle_from_shape(
        @graph.node_x(child_node),
        @graph.node_y(child_node),
        @graph.node_width(child_node),
        @graph.node_height(child_node),
        offset,
        renderer.scale,
      ),
    )
    let child_offset = @core.new_kvector_xy(
      rect.x.to_double(),
      rect.y.to_double(),
    )
    if !rect.painted && core_ui_paint_rectangle_intersects(rect, area) {
      graphics.set_alpha(node_alpha)
      core_ui_graphics_record(
        graphics,
        "draw-node@\{rect.x},\{rect.y},\{rect.width},\{rect.height}",
      )
      rect.painted = true
      core_ui_graph_renderer_set_rect(renderer, key, rect)
      core_ui_graph_renderer_render_node_children(
        renderer, child_node, graphics, area, child_offset, node_alpha,
      )
    }

    match renderer.configurator.get_node_label_font() {
      Some(font) => {
        graphics.set_font(Some(font))
        for label in @graph.node_labels(child_node) {
          core_ui_graph_renderer_render_label(
            renderer, label, graphics, area, child_offset, node_alpha,
          )
        }
      }
      None => ()
    }

    for port in @graph.node_ports(child_node) {
      core_ui_graph_renderer_render_port(
        renderer, port, graphics, area, child_offset, node_alpha,
      )
    }
  }

  for edge in @graph.node_contained_edges(parent) {
    core_ui_graph_renderer_render_edge(
      renderer, edge, graphics, area, offset, node_alpha,
    )
  }
}

///|
fn core_ui_graph_renderer_render_origin_coordinates(
  renderer : GraphRenderer,
  graphics : CoreUiGraphics,
) -> Unit {
  let x = renderer.base_offset.x.round().to_int()
  let y = renderer.base_offset.y.round().to_int()
  core_ui_graphics_record(graphics, "draw-origin:\{x},\{y}")
}

///|
pub fn GraphRenderer::render(
  self : GraphRenderer,
  parent_node : @graph.ElkNode,
  graphics : CoreUiGraphics,
  area : CoreUiPaintRectangle,
) -> Unit {
  match self.most_recently_drawn_graph {
    Some(previous) =>
      if previous != parent_node {
        self.flush_cache()
        self.most_recently_drawn_graph = Some(parent_node)
      }
    None => self.most_recently_drawn_graph = Some(parent_node)
  }

  let max_depth = @cmp.maximum(core_ui_graph_renderer_max_depth(parent_node), 1)
  let node_alpha = 200 / max_depth + 55

  core_ui_graphics_record(
    graphics,
    "fill-out-of-bounds@\{area.x},\{area.y},\{area.width},\{area.height}",
  )
  core_ui_graphics_record(
    graphics,
    "fill-root@\{self.base_offset.x.to_int()},\{self.base_offset.y.to_int()}," +
    core_ui_graph_renderer_scale(self, @graph.node_width(parent_node) + 1.0).to_string() +
    "," +
    core_ui_graph_renderer_scale(self, @graph.node_height(parent_node) + 1.0).to_string(),
  )

  core_ui_graph_renderer_render_node_children(
    self,
    parent_node,
    graphics,
    area,
    self.base_offset,
    node_alpha,
  )

  if @graph.node_width(parent_node) == 0.0 &&
    @graph.node_height(parent_node) == 0.0 &&
    (self.base_offset.x > 0.0 || self.base_offset.y > 0.0) {
    core_ui_graph_renderer_render_origin_coordinates(self, graphics)
  }
}

///|
pub fn GraphRenderer::calculate_base_offset_from_top_level_graph(
  self : GraphRenderer,
  parent : @graph.ElkNode,
) -> Unit {
  let mut min_x = @float.max_value.to_double()
  let mut min_y = @float.max_value.to_double()

  for child_node in @graph.node_children(parent) {
    min_x = @cmp.minimum(min_x, @graph.node_x(child_node))
    min_y = @cmp.minimum(min_y, @graph.node_y(child_node))
    for child_node_label in @graph.node_labels(child_node) {
      min_x = @cmp.minimum(
        min_x,
        @graph.node_x(child_node) + @graph.label_x(child_node_label),
      )
      min_y = @cmp.minimum(
        min_y,
        @graph.node_y(child_node) + @graph.label_y(child_node_label),
      )
    }
  }

  for edge in @graph.node_contained_edges(parent) {
    let edge_rect = core_ui_paint_rectangle_from_edge(
      edge,
      @core.new_kvector(),
      self.scale,
    )
    min_x = @cmp.minimum(min_x, edge_rect.x.to_double())
    min_y = @cmp.minimum(min_y, edge_rect.y.to_double())
    for edge_label in @graph.edge_labels(edge) {
      min_x = @cmp.minimum(min_x, @graph.label_x(edge_label))
      min_y = @cmp.minimum(min_y, @graph.label_y(edge_label))
    }
  }

  if min_x == @float.max_value.to_double() {
    min_x = 0.0
    min_y = 0.0
  }
  self.base_offset.x = -@cmp.minimum(0.0, min_x)
  self.base_offset.y = -@cmp.minimum(0.0, min_y)
}
