///|
let dis_co_graph_renderer_arrow_length : Double = 8.0

///|
let dis_co_graph_renderer_arrow_width : Double = 7.0

///|
pub struct DisCoPaintRectangle {
  x : Int
  y : Int
  width : Int
  height : Int
  mut painted : Bool
}

///|
pub fn new_dis_co_paint_rectangle(
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> DisCoPaintRectangle {
  { x, y, width, height, painted: false }
}

///|
fn dis_co_paint_rectangle_from_shape(
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  offset : @core.KVector,
  scale : Double,
) -> DisCoPaintRectangle {
  {
    x: (x * scale + offset.x).round().to_int(),
    y: (y * scale + offset.y).round().to_int(),
    width: @cmp.maximum((width * scale).round().to_int(), 1),
    height: @cmp.maximum((height * scale).round().to_int(), 1),
    painted: false,
  }
}

///|
fn dis_co_paint_rectangle_intersects(
  rectangle : DisCoPaintRectangle,
  other : DisCoPaintRectangle,
) -> Bool {
  other.x < rectangle.x + rectangle.width &&
  other.y < rectangle.y + rectangle.height &&
  other.x + other.width > rectangle.x &&
  other.y + other.height > rectangle.y
}

///|
fn dis_co_graph_renderer_element_offset_or_zero(
  element : @disco.DCElement,
) -> @core.KVector {
  try element.get_offset() catch {
    err => {
      @core.layout_runtime_report_unsupported_configuration(
        @disco.dc_element_exception_message(err),
      )
      @core.new_kvector()
    }
  } noraise {
    offset => offset
  }
}

///|
fn dis_co_paint_rectangle_contains_point(
  rectangle : DisCoPaintRectangle,
  x : Int,
  y : Int,
) -> Bool {
  x >= rectangle.x &&
  y >= rectangle.y &&
  x <= rectangle.x + rectangle.width &&
  y <= rectangle.y + rectangle.height
}

///|
fn dis_co_geometry_orientation(
  ax : Int,
  ay : Int,
  bx : Int,
  by : Int,
  cx : Int,
  cy : Int,
) -> Double {
  (bx - ax).to_double() * (cy - ay).to_double() -
  (by - ay).to_double() * (cx - ax).to_double()
}

///|
fn dis_co_geometry_on_segment(
  ax : Int,
  ay : Int,
  bx : Int,
  by : Int,
  cx : Int,
  cy : Int,
) -> Bool {
  cx >= @cmp.minimum(ax, bx) &&
  cx <= @cmp.maximum(ax, bx) &&
  cy >= @cmp.minimum(ay, by) &&
  cy <= @cmp.maximum(ay, by)
}

///|
fn dis_co_geometry_segments_intersect(
  ax : Int,
  ay : Int,
  bx : Int,
  by : Int,
  cx : Int,
  cy : Int,
  dx : Int,
  dy : Int,
) -> Bool {
  let o1 = dis_co_geometry_orientation(ax, ay, bx, by, cx, cy)
  let o2 = dis_co_geometry_orientation(ax, ay, bx, by, dx, dy)
  let o3 = dis_co_geometry_orientation(cx, cy, dx, dy, ax, ay)
  let o4 = dis_co_geometry_orientation(cx, cy, dx, dy, bx, by)

  let epsilon = 0.000000001
  let cross = (
      (o1 > epsilon && o2 < -epsilon) || (o1 < -epsilon && o2 > epsilon)
    ) &&
    ((o3 > epsilon && o4 < -epsilon) || (o3 < -epsilon && o4 > epsilon))
  if cross {
    return true
  }

  if o1.abs() <= epsilon && dis_co_geometry_on_segment(ax, ay, bx, by, cx, cy) {
    return true
  }
  if o2.abs() <= epsilon && dis_co_geometry_on_segment(ax, ay, bx, by, dx, dy) {
    return true
  }
  if o3.abs() <= epsilon && dis_co_geometry_on_segment(cx, cy, dx, dy, ax, ay) {
    return true
  }
  if o4.abs() <= epsilon && dis_co_geometry_on_segment(cx, cy, dx, dy, bx, by) {
    return true
  }
  false
}

///|
fn dis_co_geometry_point_in_polygon(
  coords : Array[Int],
  px : Int,
  py : Int,
) -> Bool {
  let len = coords.length()
  if len < 6 {
    return false
  }

  let mut inside = false
  let mut prev_x = coords[len - 2]
  let mut prev_y = coords[len - 1]
  let mut index = 0
  while index < len {
    let cur_x = coords[index]
    let cur_y = coords[index + 1]
    if (cur_y > py) != (prev_y > py) {
      let t = (py - cur_y).to_double() / (prev_y - cur_y).to_double()
      let x_cross = cur_x.to_double() + t * (prev_x - cur_x).to_double()
      if px.to_double() < x_cross {
        inside = !inside
      }
    }
    prev_x = cur_x
    prev_y = cur_y
    index = index + 2
  }
  inside
}

///|
fn dis_co_dc_direction_to_string(direction : @disco.DCDirection) -> String {
  match direction {
    DCNorth => "NORTH"
    DCEast => "EAST"
    DCSouth => "SOUTH"
    DCWest => "WEST"
  }
}

///|
fn dis_co_poly_direction_to_string(
  direction : @common.PolyominoDirection,
) -> String {
  match direction {
    North => "NORTH"
    East => "EAST"
    South => "SOUTH"
    West => "WEST"
  }
}

///|
fn dis_co_paint_rectangle_from_extension(
  extension : @disco.DCExtension,
  element_bounding : @core.ElkRectangle,
  boundaries : @core.KVector,
  offset : @core.KVector,
  scale : Double,
) -> DisCoPaintRectangle {
  let direction = extension.get_direction()
  let extension_offset = extension.get_offset()
  let extension_width = extension.get_width()

  let mut x = 0.0
  let mut y = 0.0
  let mut width = 0.0
  let mut height = 0.0

  match direction {
    DCNorth => {
      x = element_bounding.x + extension_offset.x
      y = 0.0
      width = extension_width
      height = element_bounding.y + extension_offset.y
    }
    DCSouth => {
      x = element_bounding.x + extension_offset.x
      y = element_bounding.y + extension_offset.y
      width = extension_width
      height = boundaries.y - y
    }
    DCWest => {
      x = 0.0
      y = element_bounding.y + extension_offset.y
      width = element_bounding.x + extension_offset.x - x
      height = extension_width
    }
    DCEast => {
      x = element_bounding.x + extension_offset.x
      y = element_bounding.y + extension_offset.y
      width = boundaries.x - x
      height = extension_width
    }
  }

  dis_co_paint_rectangle_from_shape(x, y, width, height, offset, scale)
}

///|
fn dis_co_graph_renderer_first_edge_section(
  edge : @graph.ElkEdge,
) -> @graph.ElkEdgeSection? {
  let sections = @graph.edge_sections(edge)
  if sections.is_empty() {
    None
  } else {
    Some(sections[0])
  }
}

///|
fn dis_co_paint_rectangle_from_edge(
  edge : @graph.ElkEdge,
  offset : @core.KVector,
  scale : Double,
) -> DisCoPaintRectangle {
  let sources = @graph.edge_sources(edge)
  let targets = @graph.edge_targets(edge)

  if sources.is_empty() || targets.is_empty() {
    return dis_co_paint_rectangle_from_shape(0.0, 0.0, 1.0, 1.0, offset, scale)
  }

  let source_node = try
    @graph.connectable_shape_to_node(Some(sources[0]))
  catch {
    _ =>
      return dis_co_paint_rectangle_from_shape(
        0.0, 0.0, 1.0, 1.0, offset, scale,
      )
  } noraise {
    value => value
  }
  let target_node = try
    @graph.connectable_shape_to_node(Some(targets[0]))
  catch {
    _ =>
      return dis_co_paint_rectangle_from_shape(
        0.0, 0.0, 1.0, 1.0, offset, scale,
      )
  } noraise {
    value => value
  }

  let mut min_x = @graph.node_x(source_node)
  let mut min_y = @graph.node_y(source_node)
  let mut max_x = min_x
  let mut max_y = min_y

  match dis_co_graph_renderer_first_edge_section(edge) {
    Some(section) => {
      let sx = @graph.edge_section_start_x(section)
      let sy = @graph.edge_section_start_y(section)
      let ex = @graph.edge_section_end_x(section)
      let ey = @graph.edge_section_end_y(section)
      min_x = @cmp.minimum(min_x, sx)
      min_y = @cmp.minimum(min_y, sy)
      max_x = @cmp.maximum(max_x, sx)
      max_y = @cmp.maximum(max_y, sy)
      min_x = @cmp.minimum(min_x, ex)
      min_y = @cmp.minimum(min_y, ey)
      max_x = @cmp.maximum(max_x, ex)
      max_y = @cmp.maximum(max_y, ey)
    }
    None => ()
  }

  min_x = @cmp.minimum(min_x, @graph.node_x(target_node))
  min_y = @cmp.minimum(min_y, @graph.node_y(target_node))
  max_x = @cmp.maximum(max_x, @graph.node_x(target_node))
  max_y = @cmp.maximum(max_y, @graph.node_y(target_node))

  {
    x: (min_x * scale + offset.x).round().to_int(),
    y: (min_y * scale + offset.y).round().to_int(),
    width: (max_x - min_x).round().to_int(),
    height: (max_y - min_y).round().to_int(),
    painted: false,
  }
}

///|
pub struct DisCoPaintPolygon {
  coords_scaled_and_rounded : Array[Int]
  min_x : Int
  min_y : Int
  max_x : Int
  max_y : Int
  mut painted : Bool
}

///|
fn new_dis_co_paint_polygon(
  element : @disco.DCElement,
  offset : @core.KVector,
  scale : Double,
) -> DisCoPaintPolygon {
  let coords = element.get_coords()
  let component_offset = dis_co_graph_renderer_element_offset_or_zero(element)

  let mut min_x = @int.max_value
  let mut min_y = @int.max_value
  let mut max_x = -@int.max_value
  let mut max_y = -@int.max_value

  let len = coords.length()
  let rounded : Array[Int] = []
  let mut index = 0
  while index < len {
    let x = ((coords[index] + component_offset.x) * scale + offset.x)
      .round()
      .to_int()
    let y = ((coords[index + 1] + component_offset.y) * scale + offset.y)
      .round()
      .to_int()

    rounded.push(x)
    rounded.push(y)

    min_x = @cmp.minimum(min_x, x)
    min_y = @cmp.minimum(min_y, y)
    max_x = @cmp.maximum(max_x, x)
    max_y = @cmp.maximum(max_y, y)

    index = index + 2
  }

  {
    coords_scaled_and_rounded: rounded,
    min_x,
    min_y,
    max_x,
    max_y,
    painted: false,
  }
}

///|
fn dis_co_paint_polygon_intersects(
  polygon : DisCoPaintPolygon,
  area : DisCoPaintRectangle,
) -> Bool {
  let polygon_bounds = new_dis_co_paint_rectangle(
    polygon.min_x,
    polygon.min_y,
    @cmp.maximum(polygon.max_x - polygon.min_x, 1),
    @cmp.maximum(polygon.max_y - polygon.min_y, 1),
  )
  if !dis_co_paint_rectangle_intersects(polygon_bounds, area) {
    return false
  }

  let coords = polygon.coords_scaled_and_rounded
  let len = coords.length()
  if len < 6 {
    return false
  }

  let mut index = 0
  while index < len {
    if dis_co_paint_rectangle_contains_point(
        area,
        coords[index],
        coords[index + 1],
      ) {
      return true
    }
    index = index + 2
  }

  let x0 = area.x
  let y0 = area.y
  let x1 = area.x + area.width
  let y1 = area.y + area.height
  if dis_co_geometry_point_in_polygon(coords, x0, y0) ||
    dis_co_geometry_point_in_polygon(coords, x1, y0) ||
    dis_co_geometry_point_in_polygon(coords, x1, y1) ||
    dis_co_geometry_point_in_polygon(coords, x0, y1) {
    return true
  }

  let mut prev_x = coords[len - 2]
  let mut prev_y = coords[len - 1]
  index = 0
  while index < len {
    let cur_x = coords[index]
    let cur_y = coords[index + 1]
    if dis_co_geometry_segments_intersect(
        prev_x, prev_y, cur_x, cur_y, x0, y0, x1, y0,
      ) ||
      dis_co_geometry_segments_intersect(
        prev_x, prev_y, cur_x, cur_y, x1, y0, x1, y1,
      ) ||
      dis_co_geometry_segments_intersect(
        prev_x, prev_y, cur_x, cur_y, x1, y1, x0, y1,
      ) ||
      dis_co_geometry_segments_intersect(
        prev_x, prev_y, cur_x, cur_y, x0, y1, x0, y0,
      ) {
      return true
    }
    prev_x = cur_x
    prev_y = cur_y
    index = index + 2
  }
  false
}

///|
let dis_co_debug_node_component_graph_store : Ref[
  Map[@graph.ElkNode, @disco.DCGraph],
] = Ref::new({})

///|
let dis_co_debug_node_polyomino_store : Ref[
  Map[@graph.ElkNode, Array[@disco.DCPolyomino]],
] = Ref::new({})

///|
pub fn dis_co_graph_renderer_bind_component_graph(
  node : @graph.ElkNode,
  graph : @disco.DCGraph,
) -> Unit {
  dis_co_debug_node_component_graph_store.val[node] = graph
}

///|
pub fn dis_co_graph_renderer_bind_polyominoes(
  node : @graph.ElkNode,
  polys : Array[@disco.DCPolyomino],
) -> Unit {
  dis_co_debug_node_polyomino_store.val[node] = polys
}

///|
pub fn dis_co_graph_renderer_clear_bindings_for_test() -> Unit {
  dis_co_debug_node_component_graph_store.val.clear()
  dis_co_debug_node_polyomino_store.val.clear()
}

///|
fn dis_co_graph_renderer_component_graph_of(
  node : @graph.ElkNode,
) -> @disco.DCGraph? {
  dis_co_debug_node_component_graph_store.val.get(node)
}

///|
fn dis_co_graph_renderer_polys_of(
  node : @graph.ElkNode,
) -> Array[@disco.DCPolyomino]? {
  dis_co_debug_node_polyomino_store.val.get(node)
}

///|
fn dis_co_graph_renderer_polygon_key(element : @disco.DCElement) -> String {
  let bounds = element.get_bounds()
  "poly:elem:" +
  bounds.x.to_string() +
  ":" +
  bounds.y.to_string() +
  ":" +
  bounds.width.to_string() +
  ":" +
  bounds.height.to_string()
}

///|
fn dis_co_graph_renderer_extension_key(
  extension : @disco.DCExtension,
) -> String {
  let offset = extension.get_offset()
  "ext:" +
  dis_co_dc_direction_to_string(extension.get_direction()) +
  ":" +
  offset.x.to_string() +
  ":" +
  offset.y.to_string() +
  ":" +
  extension.get_width().to_string()
}

///|
fn dis_co_graph_renderer_poly_cell_key(
  poly : @disco.DCPolyomino,
  x : Int,
  y : Int,
) -> String {
  "cell:" +
  poly.get_id().to_string() +
  ":" +
  x.to_string() +
  ":" +
  y.to_string()
}

///|
fn dis_co_graph_renderer_poly_center_key(poly : @disco.DCPolyomino) -> String {
  "center:" + poly.get_id().to_string()
}

///|
fn dis_co_graph_renderer_poly_extension_key(
  poly : @disco.DCPolyomino,
  direction : @common.PolyominoDirection,
  start : Int,
  end_ : Int,
) -> String {
  "polyext:" +
  poly.get_id().to_string() +
  ":" +
  dis_co_poly_direction_to_string(direction) +
  ":" +
  start.to_string() +
  ":" +
  end_.to_string()
}

///|
fn[K : Hash + Eq] dis_co_graph_renderer_mark_rectangles_dirty(
  map : Map[K, DisCoPaintRectangle],
  area : DisCoPaintRectangle,
) -> Unit {
  let keys : Array[K] = []
  map.each((key, _value) => keys.push(key))
  for key in keys {
    match map.get(key) {
      Some(rectangle) =>
        if dis_co_paint_rectangle_intersects(rectangle, area) {
          rectangle.painted = false
          map[key] = rectangle
        }
      None => ()
    }
  }
}

///|
fn dis_co_graph_renderer_mark_polygons_dirty(
  map : Map[String, DisCoPaintPolygon],
  area : DisCoPaintRectangle,
) -> Unit {
  let keys : Array[String] = []
  map.each((key, _value) => keys.push(key))
  for key in keys {
    match map.get(key) {
      Some(polygon) =>
        if dis_co_paint_polygon_intersects(polygon, area) {
          polygon.painted = false
          map[key] = polygon
        }
      None => ()
    }
  }
}

///|
pub struct DisCoGraphRenderer {
  configurator : DisCoGraphRenderingConfigurator
  scale : Double
  mut base_offset : @core.KVector
  state : ConfigState
  patterns : DisCoGraphRenderingFillPatterns
  bounds_map : Map[String, DisCoPaintRectangle]
  polygon_map : Map[String, DisCoPaintPolygon]
  dc_extension_map : Map[String, DisCoPaintRectangle]
  polyomino_map : Map[String, DisCoPaintRectangle]
  polyomino_center_map : Map[String, DisCoPaintRectangle]
  polyomino_extension_map : Map[String, DisCoPaintRectangle]
  mut most_recently_drawn_graph : @graph.ElkNode?
  mut paint_elk_graph : Bool
  mut paint_dc_graph : Bool
  mut paint_polys : Bool
  mut save_paint_dc_graph : Bool?
  mut save_paint_polys : Bool?
}

///|
pub fn new_dis_co_graph_renderer(
  configurator : DisCoGraphRenderingConfigurator,
  scale? : Double = config_state_get_scale(new_config_state()),
) -> DisCoGraphRenderer {
  dis_co_graph_rendering_configurator_initialize(configurator, scale)
  let state = new_config_state()
  {
    configurator,
    scale,
    base_offset: @core.new_kvector(),
    state,
    patterns: new_dis_co_graph_rendering_fill_patterns(
      configurator,
      scale * config_state_get_pattern_scale(state).to_double(),
    ),
    bounds_map: {},
    polygon_map: {},
    dc_extension_map: {},
    polyomino_map: {},
    polyomino_center_map: {},
    polyomino_extension_map: {},
    most_recently_drawn_graph: None,
    paint_elk_graph: true,
    paint_dc_graph: true,
    paint_polys: true,
    save_paint_dc_graph: None,
    save_paint_polys: None,
  }
}

///|
fn dis_co_graph_renderer_flush_cache(renderer : DisCoGraphRenderer) -> Unit {
  renderer.bounds_map.clear()
  renderer.polygon_map.clear()
  renderer.polyomino_map.clear()
  renderer.dc_extension_map.clear()
  renderer.polyomino_extension_map.clear()
}

///|
pub fn dis_co_graph_renderer_dispose(renderer : DisCoGraphRenderer) -> Unit {
  dis_co_graph_renderer_flush_cache(renderer)
  renderer.most_recently_drawn_graph = None
  dis_co_graph_rendering_configurator_dispose(renderer.configurator)
}

///|
pub fn dis_co_graph_renderer_get_base_offset(
  renderer : DisCoGraphRenderer,
) -> @core.KVector {
  renderer.base_offset
}

///|
pub fn dis_co_graph_renderer_set_base_offset(
  renderer : DisCoGraphRenderer,
  base_offset : @core.KVector,
) -> Unit {
  renderer.base_offset = base_offset
}

///|
pub fn dis_co_graph_renderer_mark_dirty(
  renderer : DisCoGraphRenderer,
  area : DisCoPaintRectangle,
) -> Unit {
  dis_co_graph_renderer_mark_rectangles_dirty(renderer.bounds_map, area)
  dis_co_graph_renderer_mark_polygons_dirty(renderer.polygon_map, area)
  dis_co_graph_renderer_mark_rectangles_dirty(renderer.polyomino_map, area)
  dis_co_graph_renderer_mark_rectangles_dirty(renderer.dc_extension_map, area)
  dis_co_graph_renderer_mark_rectangles_dirty(
    renderer.polyomino_extension_map,
    area,
  )
}

///|
fn dis_co_graph_renderer_max_depth(node : @graph.ElkNode) -> Int {
  let mut depth = 0
  for child in @graph.node_children(node) {
    let child_depth = dis_co_graph_renderer_max_depth(child) + 1
    if child_depth > depth {
      depth = child_depth
    }
  }
  depth
}

///|
fn dis_co_graph_renderer_render_label(
  renderer : DisCoGraphRenderer,
  label : @graph.ElkLabel,
  area : DisCoPaintRectangle,
  offset : @core.KVector,
  font : DisCoDebugFont?,
) -> Unit {
  match font {
    Some(value) => if value.size < dis_co_min_font_height { return }
    None => return
  }

  let key = "l:" + label.to_string()
  let rect = match renderer.bounds_map.get(key) {
    Some(existing) => existing
    None =>
      dis_co_paint_rectangle_from_shape(
        @graph.label_x(label),
        @graph.label_y(label),
        @graph.label_width(label),
        @graph.label_height(label),
        offset,
        renderer.scale,
      )
  }

  if !rect.painted && dis_co_paint_rectangle_intersects(rect, area) {
    rect.painted = true
  }

  renderer.bounds_map[key] = rect
}

///|
fn dis_co_graph_renderer_render_port(
  renderer : DisCoGraphRenderer,
  port : @graph.ElkPort,
  area : DisCoPaintRectangle,
  offset : @core.KVector,
) -> Unit {
  let key = "p:" + port.to_string()
  let rect = match renderer.bounds_map.get(key) {
    Some(existing) => existing
    None =>
      // ElkPort coordinates are not exported in the current model API.
      // Keep a stable 1x1 placeholder at the current offset.
      new_dis_co_paint_rectangle(
        offset.x.round().to_int(),
        offset.y.round().to_int(),
        1,
        1,
      )
  }

  if !rect.painted && dis_co_paint_rectangle_intersects(rect, area) {
    rect.painted = true
  }

  renderer.bounds_map[key] = rect

  for label in @graph.port_labels(port) {
    dis_co_graph_renderer_render_label(
      renderer,
      label,
      area,
      @core.new_kvector_xy(rect.x.to_double(), rect.y.to_double()),
      dis_co_graph_rendering_configurator_get_port_label_font(
        renderer.configurator,
      ),
    )
  }
}

///|
fn dis_co_graph_renderer_make_arrow(
  renderer : DisCoGraphRenderer,
  point1 : @core.KVector,
  point2 : @core.KVector,
) -> Array[Int]? {
  if point1.x == point2.x || point1.y == point2.y {
    if point1.x == point2.x && point1.y == point2.y {
      return None
    }
  }
  if dis_co_graph_renderer_arrow_width * renderer.scale < 2.0 {
    return None
  }

  let arrow : Array[Int] = [0, 0, 0, 0, 0, 0]
  arrow[0] = point2.x.round().to_int()
  arrow[1] = point2.y.round().to_int()

  let vector_x = point1.x - point2.x
  let vector_y = point1.y - point2.y
  let length = @math.hypot(vector_x, vector_y)
  let norm_x = vector_x / length
  let norm_y = vector_y / length
  let neck_x = point2.x +
    dis_co_graph_renderer_arrow_length * norm_x * renderer.scale
  let neck_y = point2.y +
    dis_co_graph_renderer_arrow_length * norm_y * renderer.scale
  let orth_x = norm_y * dis_co_graph_renderer_arrow_width / 2.0 * renderer.scale
  let orth_y = -norm_x *
    dis_co_graph_renderer_arrow_width /
    2.0 *
    renderer.scale

  arrow[2] = (neck_x + orth_x).round().to_int()
  arrow[3] = (neck_y + orth_y).round().to_int()
  arrow[4] = (neck_x - orth_x).round().to_int()
  arrow[5] = (neck_y - orth_y).round().to_int()
  Some(arrow)
}

///|
fn dis_co_graph_renderer_render_edge(
  renderer : DisCoGraphRenderer,
  graph : @graph.ElkNode,
  edge : @graph.ElkEdge,
  area : DisCoPaintRectangle,
  edge_base_offset : @core.KVector,
) -> Unit {
  if dis_co_graph_rendering_configurator_get_edge_color(renderer.configurator)
    is None {
    return
  }

  let sources = @graph.edge_sources(edge)
  let targets = @graph.edge_targets(edge)
  if sources.is_empty() || targets.is_empty() {
    return
  }

  let source_node = try
    @graph.connectable_shape_to_node(Some(sources[0]))
  catch {
    _ => return
  } noraise {
    value => value
  }
  let target_node = try
    @graph.connectable_shape_to_node(Some(targets[0]))
  catch {
    _ => return
  } noraise {
    value => value
  }

  if !@graph.is_descendant(source_node, graph) ||
    !@graph.is_descendant(target_node, graph) {
    return
  }

  let mut parent = source_node
  if !@graph.is_descendant(target_node, parent) {
    match @graph.node_parent(parent) {
      Some(value) => parent = value
      None => ()
    }
  }

  let mut node = parent
  let offset = @core.new_kvector_copy(edge_base_offset)
  while node != graph {
    ignore(
      offset.add_xy(
        @graph.node_x(node) * renderer.scale,
        @graph.node_y(node) * renderer.scale,
      ),
    )
    match @graph.node_parent(node) {
      Some(value) => node = value
      None => break
    }
  }

  let key = "e:" + edge.to_string()
  let rect = match renderer.bounds_map.get(key) {
    Some(existing) => existing
    None => dis_co_paint_rectangle_from_edge(edge, offset, renderer.scale)
  }

  if !rect.painted && dis_co_paint_rectangle_intersects(rect, area) {
    match dis_co_graph_renderer_first_edge_section(edge) {
      Some(section) => {
        let start_point = @core.new_kvector_xy(
          @graph.edge_section_start_x(section) * renderer.scale + offset.x,
          @graph.edge_section_start_y(section) * renderer.scale + offset.y,
        )
        let end_point = @core.new_kvector_xy(
          @graph.edge_section_end_x(section) * renderer.scale + offset.x,
          @graph.edge_section_end_y(section) * renderer.scale + offset.y,
        )
        ignore(
          dis_co_graph_renderer_make_arrow(renderer, start_point, end_point),
        )
      }
      None => ()
    }
    rect.painted = true
  }

  renderer.bounds_map[key] = rect

  for label in @graph.edge_labels(edge) {
    dis_co_graph_renderer_render_label(
      renderer,
      label,
      area,
      offset,
      dis_co_graph_rendering_configurator_get_edge_label_font(
        renderer.configurator,
      ),
    )
  }
}

///|
fn dis_co_graph_renderer_render_node_children(
  renderer : DisCoGraphRenderer,
  parent : @graph.ElkNode,
  area : DisCoPaintRectangle,
  offset : @core.KVector,
  edge_set : Map[@graph.ElkEdge, Bool],
) -> Unit {
  for child in @graph.node_children(parent) {
    let key = "n:" + child.to_string()
    let rect = match renderer.bounds_map.get(key) {
      Some(existing) => existing
      None =>
        dis_co_paint_rectangle_from_shape(
          @graph.node_x(child),
          @graph.node_y(child),
          @graph.node_width(child),
          @graph.node_height(child),
          offset,
          renderer.scale,
        )
    }

    if !rect.painted && dis_co_paint_rectangle_intersects(rect, area) {
      rect.painted = true
    }

    renderer.bounds_map[key] = rect

    let child_offset = @core.new_kvector_xy(
      rect.x.to_double(),
      rect.y.to_double(),
    )

    for label in @graph.node_labels(child) {
      dis_co_graph_renderer_render_label(
        renderer,
        label,
        area,
        child_offset,
        dis_co_graph_rendering_configurator_get_node_label_font(
          renderer.configurator,
        ),
      )
    }

    for port in @graph.node_ports(child) {
      dis_co_graph_renderer_render_port(renderer, port, area, child_offset)
    }

    for edge in @graph.node_incoming_edges(child) {
      edge_set[edge] = true
    }
    for edge in @graph.node_outgoing_edges(child) {
      edge_set[edge] = true
    }
  }
}

///|
fn dis_co_graph_renderer_render_component_graph(
  renderer : DisCoGraphRenderer,
  parent : @graph.ElkNode,
  component_graph : @disco.DCGraph,
  area : DisCoPaintRectangle,
  offset : @core.KVector,
  level_number : Int,
) -> Unit {
  ignore(level_number)
  let boundaries = @core.new_kvector_xy(
    @graph.node_width(parent),
    @graph.node_height(parent),
  )

  for component in component_graph.get_components() {
    for element in component.get_elements() {
      let polygon_key = dis_co_graph_renderer_polygon_key(element)
      let polygon = match renderer.polygon_map.get(polygon_key) {
        Some(existing) => existing
        None => new_dis_co_paint_polygon(element, offset, renderer.scale)
      }

      if !polygon.painted && dis_co_paint_polygon_intersects(polygon, area) {
        polygon.painted = true
      }
      renderer.polygon_map[polygon_key] = polygon

      let bounds = element.get_bounds()
      let element_offset = dis_co_graph_renderer_element_offset_or_zero(element)
      let element_bounding = @core.new_elk_rectangle()
      element_bounding.set_rect(
        bounds.x + element_offset.x,
        bounds.y + element_offset.y,
        bounds.width,
        bounds.height,
      )

      for extension in element.get_extensions() {
        let extension_key = dis_co_graph_renderer_extension_key(extension) +
          ":" +
          component.get_id().to_string()
        let rect = match renderer.dc_extension_map.get(extension_key) {
          Some(existing) => existing
          None =>
            dis_co_paint_rectangle_from_extension(
              extension,
              element_bounding,
              boundaries,
              offset,
              renderer.scale,
            )
        }

        if !rect.painted && dis_co_paint_rectangle_intersects(rect, area) {
          rect.painted = true
        }

        renderer.dc_extension_map[extension_key] = rect
      }
    }
  }
}

///|
fn dis_co_graph_renderer_render_polyominoes(
  renderer : DisCoGraphRenderer,
  parent : @graph.ElkNode,
  polys : Array[@disco.DCPolyomino],
  area : DisCoPaintRectangle,
  offset : @core.KVector,
  level_number : Int,
) -> Unit {
  ignore(level_number)

  for poly in polys {
    let poly_corner = poly.get_min_corner_on_canvas()
    let top_left_corner_x = poly_corner.x
    let top_left_corner_y = poly_corner.y
    let cell_size_x = poly.get_cell_size_x()
    let cell_size_y = poly.get_cell_size_y()
    let bottom_right_corner_x = top_left_corner_x +
      cell_size_x * poly.width().to_double()
    let bottom_right_corner_y = top_left_corner_y +
      cell_size_y * poly.height().to_double()

    for x = 0; x < poly.width(); x = x + 1 {
      for y = 0; y < poly.height(); y = y + 1 {
        let key = dis_co_graph_renderer_poly_cell_key(poly, x, y)
        let rect = match renderer.polyomino_map.get(key) {
          Some(existing) => existing
          None =>
            dis_co_paint_rectangle_from_shape(
              top_left_corner_x + x.to_double() * cell_size_x,
              top_left_corner_y + y.to_double() * cell_size_y,
              cell_size_x,
              cell_size_y,
              offset,
              renderer.scale,
            )
        }

        if !rect.painted && dis_co_paint_rectangle_intersects(rect, area) {
          rect.painted = true
        }
        renderer.polyomino_map[key] = rect
      }
    }

    if config_state_mark_the_center(renderer.state) {
      let key = dis_co_graph_renderer_poly_center_key(poly)
      let rect = match renderer.polyomino_center_map.get(key) {
        Some(existing) => existing
        None =>
          dis_co_paint_rectangle_from_shape(
            top_left_corner_x + poly.get_center_x().to_double() * cell_size_x,
            top_left_corner_y + poly.get_center_y().to_double() * cell_size_y,
            cell_size_x,
            cell_size_y,
            offset,
            renderer.scale,
          )
      }
      rect.painted = true
      renderer.polyomino_center_map[key] = rect
    }

    for extension in poly.get_polyomino_extensions() {
      let direction = extension.get_first()
      let ext_start = extension.get_second()
      let ext_end = extension.get_third()
      let key = dis_co_graph_renderer_poly_extension_key(
        poly, direction, ext_start, ext_end,
      )
      let rect = match renderer.polyomino_extension_map.get(key) {
        Some(existing) => existing
        None =>
          match direction {
            North =>
              dis_co_paint_rectangle_from_shape(
                top_left_corner_x + ext_start.to_double() * cell_size_x,
                0.0,
                (ext_end - ext_start + 1).to_double() * cell_size_x,
                top_left_corner_y,
                offset,
                renderer.scale,
              )
            South =>
              dis_co_paint_rectangle_from_shape(
                top_left_corner_x + ext_start.to_double() * cell_size_x,
                bottom_right_corner_y,
                (ext_end - ext_start + 1).to_double() * cell_size_x,
                @graph.node_height(parent) - bottom_right_corner_y,
                offset,
                renderer.scale,
              )
            West =>
              dis_co_paint_rectangle_from_shape(
                0.0,
                top_left_corner_y + ext_start.to_double() * cell_size_y,
                top_left_corner_x,
                (ext_end - ext_start + 1).to_double() * cell_size_y,
                offset,
                renderer.scale,
              )
            East =>
              dis_co_paint_rectangle_from_shape(
                bottom_right_corner_x,
                top_left_corner_y + ext_start.to_double() * cell_size_y,
                @graph.node_width(parent) - bottom_right_corner_x,
                (ext_end - ext_start + 1).to_double() * cell_size_y,
                offset,
                renderer.scale,
              )
          }
      }

      rect.painted = true
      renderer.polyomino_extension_map[key] = rect
    }
  }
}

///|
fn dis_co_graph_renderer_render_recursively(
  renderer : DisCoGraphRenderer,
  parent : @graph.ElkNode,
  area : DisCoPaintRectangle,
  offset : @core.KVector,
  level_number : Int,
) -> Unit {
  let component_graph = dis_co_graph_renderer_component_graph_of(parent)

  let lower_lvl = config_state_get_lower_lvl(renderer.state)
  let upper_lvl = config_state_get_upper_lvl(renderer.state)

  if (
      renderer.paint_elk_graph &&
      level_number >= lower_lvl &&
      level_number <= upper_lvl
    ) ||
    (config_state_draw_ghost_parent(renderer.state) && level_number == 0) {
    let edge_set : Map[@graph.ElkEdge, Bool] = {}
    dis_co_graph_renderer_render_node_children(
      renderer, parent, area, offset, edge_set,
    )

    let edges : Array[@graph.ElkEdge] = []
    edge_set.each((edge, _value) => edges.push(edge))
    for edge in edges {
      dis_co_graph_renderer_render_edge(renderer, parent, edge, area, offset)
    }
  }

  match component_graph {
    Some(graph) =>
      if renderer.paint_dc_graph &&
        level_number >= lower_lvl &&
        level_number <= upper_lvl {
        dis_co_graph_renderer_render_component_graph(
          renderer, parent, graph, area, offset, level_number,
        )
      }
    None => ()
  }

  if renderer.paint_polys &&
    level_number >= lower_lvl &&
    level_number <= upper_lvl {
    match dis_co_graph_renderer_polys_of(parent) {
      Some(polys) =>
        dis_co_graph_renderer_render_polyominoes(
          renderer, parent, polys, area, offset, level_number,
        )
      None => ()
    }
  }

  for child in @graph.node_children(parent) {
    let content_offset = @core.new_kvector_xy(
      @graph.node_x(child) * renderer.scale,
      @graph.node_y(child) * renderer.scale,
    )
    ignore(content_offset.add(offset))

    dis_co_graph_renderer_render_recursively(
      renderer,
      child,
      area,
      content_offset,
      level_number + 1,
    )
  }
}

///|
pub fn dis_co_graph_renderer_render(
  renderer : DisCoGraphRenderer,
  parent_node : @graph.ElkNode,
  area : DisCoPaintRectangle,
) -> Unit {
  let component_graph = dis_co_graph_renderer_component_graph_of(parent_node)

  if renderer.most_recently_drawn_graph != Some(parent_node) {
    dis_co_graph_renderer_flush_cache(renderer)
    renderer.most_recently_drawn_graph = Some(parent_node)
  }

  let max_depth = @cmp.maximum(dis_co_graph_renderer_max_depth(parent_node), 1)
  config_state_set_depth(renderer.state, max_depth)

  if config_state_make_solid(renderer.state) {
    ignore(
      dis_co_graph_rendering_fill_patterns_get_dc_extension_pattern(
        renderer.patterns,
        255,
      ),
    )
  }

  match component_graph {
    None => {
      if renderer.save_paint_dc_graph is None {
        renderer.save_paint_dc_graph = Some(renderer.paint_dc_graph)
      }
      renderer.paint_dc_graph = false

      if renderer.save_paint_polys is None {
        renderer.save_paint_polys = Some(renderer.paint_polys)
      }
      renderer.paint_polys = false
    }
    Some(_graph) => {
      match renderer.save_paint_dc_graph {
        Some(saved) => {
          renderer.paint_dc_graph = saved
          renderer.save_paint_dc_graph = None
        }
        None => ()
      }
      match renderer.save_paint_polys {
        Some(saved) => {
          renderer.paint_polys = saved
          renderer.save_paint_polys = None
        }
        None => ()
      }
    }
  }

  dis_co_graph_renderer_render_recursively(
    renderer,
    parent_node,
    area,
    renderer.base_offset,
    0,
  )
}

///|
pub fn dis_co_graph_renderer_set_visible(
  renderer : DisCoGraphRenderer,
  command : String,
  visible : Bool,
) -> Unit {
  match command {
    "elkgraph" => renderer.paint_elk_graph = visible
    "dcgraph" => renderer.paint_dc_graph = visible
    "polyominoes" => renderer.paint_polys = visible
    _ => ()
  }
}

///|
pub fn dis_co_graph_renderer_is_visible(
  renderer : DisCoGraphRenderer,
  command : String,
) -> Bool {
  match command {
    "elkgraph" => renderer.paint_elk_graph
    "dcgraph" => renderer.paint_dc_graph
    "polyominoes" => renderer.paint_polys
    _ => true
  }
}

///|
pub fn dis_co_graph_renderer_get_scale(renderer : DisCoGraphRenderer) -> Double {
  renderer.scale
}

///|
pub fn dis_co_graph_renderer_get_state(
  renderer : DisCoGraphRenderer,
) -> ConfigState {
  renderer.state
}

///|
pub fn dis_co_graph_renderer_debug_bounds_cache_size(
  renderer : DisCoGraphRenderer,
) -> Int {
  renderer.bounds_map.length()
}

///|
pub fn dis_co_graph_renderer_debug_polygon_cache_size(
  renderer : DisCoGraphRenderer,
) -> Int {
  renderer.polygon_map.length()
}

///|
pub fn dis_co_graph_renderer_debug_poly_cell_cache_size(
  renderer : DisCoGraphRenderer,
) -> Int {
  renderer.polyomino_map.length()
}

///|
pub fn dis_co_graph_renderer_debug_painted_bounds_count(
  renderer : DisCoGraphRenderer,
) -> Int {
  let mut count = 0
  renderer.bounds_map.each((_key, value) => {
    if value.painted {
      count = count + 1
    }
  })
  count
}

///|
pub fn dis_co_graph_renderer_debug_painted_polygon_count(
  renderer : DisCoGraphRenderer,
) -> Int {
  let mut count = 0
  renderer.polygon_map.each((_key, value) => {
    if value.painted {
      count = count + 1
    }
  })
  count
}

///|
pub fn dis_co_graph_renderer_debug_painted_poly_cell_count(
  renderer : DisCoGraphRenderer,
) -> Int {
  let mut count = 0
  renderer.polyomino_map.each((_key, value) => {
    if value.painted {
      count = count + 1
    }
  })
  count
}

///|
pub fn dis_co_graph_renderer_debug_make_arrow(
  renderer : DisCoGraphRenderer,
  point1 : @core.KVector,
  point2 : @core.KVector,
) -> Array[Int]? {
  dis_co_graph_renderer_make_arrow(renderer, point1, point2)
}
