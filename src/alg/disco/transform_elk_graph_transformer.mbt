///|
pub struct ElkGraphTransformer {
  mut parent : @graph.ElkNode?
  node_mapping : Map[@graph.ElkNode, DCElement]
  label_mapping : Map[@graph.ElkLabel, DCElement]
  port_mapping : Map[@graph.ElkPort, DCElement]
  edge_mapping : Map[@graph.ElkEdge, DCElement]
  incoming_extensions_mapping : Map[@graph.ElkEdge, DCExtension]
  outgoing_extensions_mapping : Map[@graph.ElkEdge, DCExtension]
  mut transformed_graph : DCGraph?
  component_spacing : Double
}

///|
pub fn new_elk_graph_transformer(
  component_spacing? : Double = 0.0,
) -> ElkGraphTransformer {
  {
    parent: None,
    node_mapping: {},
    label_mapping: {},
    port_mapping: {},
    edge_mapping: {},
    incoming_extensions_mapping: {},
    outgoing_extensions_mapping: {},
    transformed_graph: None,
    component_spacing,
  }
}

///|
fn disco_transform_parse_double_or_default(
  text : String,
  default_value : Double,
) -> Double {
  let trimmed = text.trim().to_string()
  if trimmed.is_empty() {
    return default_value
  }
  try @string.parse_double(trimmed) catch {
    _ => default_value
  } noraise {
    value => value
  }
}

///|
fn disco_transform_element_offset_or_zero(element : DCElement) -> @core.KVector {
  try element.get_offset() catch {
    DCElementException(message) => {
      @core.layout_runtime_report_unsupported_configuration(
        "org.eclipse.elk.alg.disco.graph.DCElement: " + message,
      )
      @core.new_kvector()
    }
  } noraise {
    offset => offset
  }
}

///|
fn disco_transform_edge_thickness(edge : @graph.ElkEdge) -> Double {
  match
    @graph.edge_layout_option_string_value(edge, disco_edge_thickness.get_id()) {
    Some(value) => disco_transform_parse_double_or_default(value, 1.0)
    None => 1.0
  }
}

///|
fn disco_transform_source_node(edge : @graph.ElkEdge) -> @graph.ElkNode {
  let sources = @graph.edge_sources(edge)
  if sources.is_empty() {
    @core.layout_runtime_report_unsupported_configuration(
      "edge source is missing",
    )
    return @graph.create_node(None)
  }
  try @graph.connectable_shape_to_node(Some(sources[0])) catch {
    _ => {
      @core.layout_runtime_report_unsupported_configuration(
        "edge source shape is not attached to a node",
      )
      @graph.create_node(None)
    }
  } noraise {
    value => value
  }
}

///|
fn disco_transform_target_node(edge : @graph.ElkEdge) -> @graph.ElkNode {
  let targets = @graph.edge_targets(edge)
  if targets.is_empty() {
    @core.layout_runtime_report_unsupported_configuration(
      "edge target is missing",
    )
    return @graph.create_node(None)
  }
  try @graph.connectable_shape_to_node(Some(targets[0])) catch {
    _ => {
      @core.layout_runtime_report_unsupported_configuration(
        "edge target shape is not attached to a node",
      )
      @graph.create_node(None)
    }
  } noraise {
    value => value
  }
}

///|
fn disco_transform_source_port(edge : @graph.ElkEdge) -> @graph.ElkPort? {
  let sources = @graph.edge_sources(edge)
  if sources.is_empty() {
    None
  } else {
    try @graph.connectable_shape_to_port(Some(sources[0])) catch {
      _ => None
    } noraise {
      value => value
    }
  }
}

///|
fn disco_transform_target_port(edge : @graph.ElkEdge) -> @graph.ElkPort? {
  let targets = @graph.edge_targets(edge)
  if targets.is_empty() {
    None
  } else {
    try @graph.connectable_shape_to_port(Some(targets[0])) catch {
      _ => None
    } noraise {
      value => value
    }
  }
}

///|
fn disco_transform_all_incident_edges(
  node : @graph.ElkNode,
) -> Array[@graph.ElkEdge] {
  let edges_map : Map[@graph.ElkEdge, Unit] = {}
  for edge in @graph.node_incoming_edges(node) {
    edges_map[edge] = ()
  }
  for edge in @graph.node_outgoing_edges(node) {
    edges_map[edge] = ()
  }
  for port in @graph.node_ports(node) {
    for edge in @graph.port_incoming_edges(port) {
      edges_map[edge] = ()
    }
    for edge in @graph.port_outgoing_edges(port) {
      edges_map[edge] = ()
    }
  }
  let edges : Array[@graph.ElkEdge] = []
  edges_map.each((edge, _) => edges.push(edge))
  edges
}

///|
fn disco_transform_first_or_create_edge_section(
  edge : @graph.ElkEdge,
) -> @graph.ElkEdgeSection {
  let sections = @graph.edge_sections(edge)
  if sections.is_empty() {
    @graph.create_edge_section(edge)
  } else {
    sections[0]
  }
}

///|
fn disco_transform_edge_points(
  section : @graph.ElkEdgeSection,
) -> @core.KVectorChain {
  let points = @core.new_kvector_chain()
  let visited : Map[@graph.ElkEdgeSection, Unit] = {}
  let mut current = section
  points.add_xy(
    @graph.edge_section_start_x(current),
    @graph.edge_section_start_y(current),
  )
  while true {
    points.add_xy(
      @graph.edge_section_end_x(current),
      @graph.edge_section_end_y(current),
    )
    visited[current] = ()
    let outgoing = @graph.edge_section_outgoing_sections(current)
    if outgoing.is_empty() {
      break
    }
    let next = outgoing[0]
    if visited.contains(next) {
      break
    }
    current = next
  }
  points
}

///|
fn disco_transform_apply_points_to_section(
  section : @graph.ElkEdgeSection,
  points : @core.KVectorChain,
) -> Unit {
  if points.size() < 2 {
    return
  }
  let first = points.get(0)
  let last = points.get(points.size() - 1)
  @graph.edge_section_set_start(section, first.x, first.y)
  @graph.edge_section_set_end(section, last.x, last.y)
}

///|
fn disco_transform_new_point(x : Double, y : Double) -> @core.KVector {
  @core.new_kvector_xy(x, y)
}

///|
fn disco_transform_get_orthogonal_points(
  cur_x : Double,
  cur_y : Double,
  nxt_x : Double,
  nxt_y : Double,
  radius : Double,
) -> Array[@core.KVector] {
  let dif_x = nxt_x - cur_x
  let dif_y = nxt_y - cur_y
  let angle_radians = @math.atan2(dif_x, dif_y)
  let orth_angle_ccw = angle_radians + @math.PI / 2.0
  let orth_angle_cw = angle_radians - @math.PI / 2.0
  let x_ccw = radius * @math.sin(orth_angle_ccw) + cur_x
  let y_ccw = radius * @math.cos(orth_angle_ccw) + cur_y
  let x_cw = radius * @math.sin(orth_angle_cw) + cur_x
  let y_cw = radius * @math.cos(orth_angle_cw) + cur_y
  [
    disco_transform_new_point(x_ccw, y_ccw),
    disco_transform_new_point(x_cw, y_cw),
  ]
}

///|
fn disco_transform_compute_intersection(
  p1 : @core.KVector,
  p2 : @core.KVector,
  p3 : @core.KVector,
  p4 : @core.KVector,
) -> @core.KVector {
  let x1 = p1.x
  let y1 = p1.y
  let x2 = p2.x
  let y2 = p2.y
  let x3 = p3.x
  let y3 = p3.y
  let x4 = p4.x
  let y4 = p4.y

  let factor1 = x1 * y2 - y1 * x2
  let factor2 = x3 * y4 - y3 * x4
  let denominator = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)

  let x = (factor1 * (x3 - x4) - factor2 * (x1 - x2)) / denominator
  let y = (factor1 * (y3 - y4) - factor2 * (y1 - y2)) / denominator
  disco_transform_new_point(x, y)
}

///|
fn disco_transform_is_finite(value : Double) -> Bool {
  !value.is_nan() && !value.is_inf()
}

///|
fn disco_transform_get_contour(
  edge_points : Array[@core.KVector],
  thickness : Double,
) -> @core.KVectorChain {
  let ccw_points : Array[@core.KVector] = []
  let cw_points : Array[@core.KVector] = []
  let radius = thickness / 2.0

  let number_of_points = edge_points.length()
  let mut current = edge_points[0]
  let mut successor = edge_points[1]
  let mut orth_points = disco_transform_get_orthogonal_points(
    current.x,
    current.y,
    successor.x,
    successor.y,
    radius,
  )
  ccw_points.push(orth_points[0])
  cw_points.push(orth_points[1])

  for i = 2; i < number_of_points; i = i + 1 {
    let predecessor = current
    current = successor
    successor = edge_points[i]
    orth_points = disco_transform_get_orthogonal_points(
      current.x,
      current.y,
      predecessor.x,
      predecessor.y,
      radius,
    )
    ccw_points.push(orth_points[1])
    cw_points.push(orth_points[0])

    orth_points = disco_transform_get_orthogonal_points(
      current.x,
      current.y,
      successor.x,
      successor.y,
      radius,
    )
    ccw_points.push(orth_points[0])
    cw_points.push(orth_points[1])
  }

  orth_points = disco_transform_get_orthogonal_points(
    successor.x,
    successor.y,
    current.x,
    current.y,
    radius,
  )
  ccw_points.push(orth_points[1])
  cw_points.push(orth_points[0])

  let ccw_merged = @core.new_kvector_chain()
  let cw_merged : Array[@core.KVector] = []

  ccw_merged.add_vector(ccw_points[0])
  for i = 1; i < ccw_points.length() - 2; i = i + 2 {
    let current_point = ccw_points[i]
    let intersection_point = disco_transform_compute_intersection(
      ccw_points[i - 1],
      current_point,
      ccw_points[i + 1],
      ccw_points[i + 2],
    )
    if !disco_transform_is_finite(intersection_point.x) ||
      !disco_transform_is_finite(intersection_point.y) {
      ccw_merged.add_vector(current_point)
    } else {
      ccw_merged.add_vector(intersection_point)
    }
  }
  ccw_merged.add_vector(ccw_points[ccw_points.length() - 1])

  cw_merged.push(cw_points[0])
  for i = 1; i < cw_points.length() - 2; i = i + 2 {
    let current_point = cw_points[i]
    let intersection_point = disco_transform_compute_intersection(
      cw_points[i - 1],
      current_point,
      cw_points[i + 1],
      cw_points[i + 2],
    )
    if !disco_transform_is_finite(intersection_point.x) ||
      !disco_transform_is_finite(intersection_point.y) {
      cw_merged.push(current_point)
    } else {
      cw_merged.push(intersection_point)
    }
  }
  cw_merged.push(cw_points[cw_points.length() - 1])

  for i = cw_merged.length() - 1; i >= 0; i = i - 1 {
    ccw_merged.add_vector(cw_merged[i])
  }

  ccw_merged
}

///|
fn disco_transform_import_node_shape(
  transformer : ElkGraphTransformer,
  node : @graph.ElkNode,
  consider_offset : Bool,
  offset_x : Double,
  offset_y : Double,
) -> DCElement {
  let half_spacing = transformer.component_spacing / 2.0
  let x0 = @graph.node_x(node) + offset_x - half_spacing
  let y0 = @graph.node_y(node) + offset_y - half_spacing
  let x1 = x0 + @graph.node_width(node) + transformer.component_spacing
  let y1 = y0 + @graph.node_height(node) + transformer.component_spacing
  let coords = @core.new_kvector_chain()
  coords.add_xy(x0, y0)
  coords.add_xy(x0, y1)
  coords.add_xy(x1, y1)
  coords.add_xy(x1, y0)
  let shape = new_dc_element(coords)
  if consider_offset {
    transformer.node_mapping[node] = shape
  }
  shape
}

///|
fn disco_transform_import_label_shape(
  transformer : ElkGraphTransformer,
  label : @graph.ElkLabel,
  consider_offset : Bool,
  offset_x : Double,
  offset_y : Double,
) -> DCElement {
  let half_spacing = transformer.component_spacing / 2.0
  let x0 = @graph.label_x(label) + offset_x - half_spacing
  let y0 = @graph.label_y(label) + offset_y - half_spacing
  let x1 = x0 + @graph.label_width(label) + transformer.component_spacing
  let y1 = y0 + @graph.label_height(label) + transformer.component_spacing
  let coords = @core.new_kvector_chain()
  coords.add_xy(x0, y0)
  coords.add_xy(x0, y1)
  coords.add_xy(x1, y1)
  coords.add_xy(x1, y0)
  let shape = new_dc_element(coords)
  if consider_offset {
    transformer.label_mapping[label] = shape
  }
  shape
}

///|
fn disco_transform_import_port_shape(
  transformer : ElkGraphTransformer,
  port : @graph.ElkPort,
  consider_offset : Bool,
  offset_x : Double,
  offset_y : Double,
) -> DCElement {
  let half_spacing = transformer.component_spacing / 2.0
  let x0 = offset_x - half_spacing
  let y0 = offset_y - half_spacing
  let x1 = x0 + transformer.component_spacing
  let y1 = y0 + transformer.component_spacing
  let coords = @core.new_kvector_chain()
  coords.add_xy(x0, y0)
  coords.add_xy(x0, y1)
  coords.add_xy(x1, y1)
  coords.add_xy(x1, y0)
  let shape = new_dc_element(coords)
  if consider_offset {
    transformer.port_mapping[port] = shape
  }
  shape
}

///|
fn disco_transform_import_elk_edge(
  transformer : ElkGraphTransformer,
  edge : @graph.ElkEdge,
  new_component : Array[DCElement],
) -> DCElement {
  let edge_section = disco_transform_first_or_create_edge_section(edge)
  let points = disco_transform_edge_points(edge_section).to_array()
  let thickness = disco_transform_edge_thickness(edge)
  let contour = disco_transform_get_contour(
    points,
    thickness + transformer.component_spacing,
  )
  let shape = new_dc_element(contour)
  transformer.edge_mapping[edge] = shape
  new_component.push(shape)
  for label in @graph.edge_labels(edge) {
    new_component.push(
      disco_transform_import_label_shape(transformer, label, true, 0.0, 0.0),
    )
  }
  shape
}

///|
fn disco_transform_nearest_side(
  point : @core.KVector,
  node : @graph.ElkNode,
) -> DCDirection {
  let mut shortest_distance = point.y.abs()
  let mut result = DCNorth

  let south_distance = (@graph.node_height(node) - point.y).abs()
  if south_distance < shortest_distance {
    shortest_distance = south_distance
    result = DCSouth
  }

  let west_distance = point.x.abs()
  if west_distance < shortest_distance {
    shortest_distance = west_distance
    result = DCWest
  }

  let east_distance = (@graph.node_width(node) - point.x).abs()
  if east_distance < shortest_distance {
    ignore(shortest_distance)
    result = DCEast
  }

  result
}

///|
fn disco_transform_import_extension(
  transformer : ElkGraphTransformer,
  edge : @graph.ElkEdge,
  new_component : Array[DCElement],
  outgoing_extension : Bool,
) -> Unit {
  let edge_section = disco_transform_first_or_create_edge_section(edge)
  let points = if outgoing_extension {
    @core.kvector_chain_reverse(disco_transform_edge_points(edge_section))
  } else {
    disco_transform_edge_points(edge_section)
  }
  let points_array = points.to_array()
  if points_array.length() < 2 {
    return
  }

  let thickness = disco_transform_edge_thickness(edge)
  let shape = if points_array.length() > 2 {
    let fixed_edge_points : Array[@core.KVector] = []
    for i = 1; i < points_array.length(); i = i + 1 {
      fixed_edge_points.push(points_array[i])
    }
    let contour = disco_transform_get_contour(
      fixed_edge_points,
      thickness + transformer.component_spacing,
    )
    let new_shape = new_dc_element(contour)
    new_component.push(new_shape)
    new_shape
  } else if outgoing_extension {
    match transformer.node_mapping.get(disco_transform_source_node(edge)) {
      Some(node_shape) => node_shape
      None => return
    }
  } else {
    match transformer.node_mapping.get(disco_transform_target_node(edge)) {
      Some(node_shape) => node_shape
      None => return
    }
  }

  let outer_point = points_array[0]
  let inner_point = points_array[1]
  let ext_parent = if outgoing_extension {
    disco_transform_target_node(edge)
  } else {
    disco_transform_source_node(edge)
  }
  let direction = disco_transform_nearest_side(outer_point, ext_parent)
  let mut extension_width = thickness + transformer.component_spacing
  let middle_pos = if direction.is_horizontal() {
    extension_width += (outer_point.y - inner_point.y).abs()
    @core.new_kvector_xy(inner_point.x, (inner_point.y + outer_point.y) / 2.0)
  } else {
    extension_width += (outer_point.x - inner_point.x).abs()
    @core.new_kvector_xy((inner_point.x + outer_point.x) / 2.0, inner_point.y)
  }
  let extension = new_dc_extension(
    shape, direction, middle_pos, extension_width,
  )
  if outgoing_extension {
    transformer.outgoing_extensions_mapping[edge] = extension
  } else {
    transformer.incoming_extensions_mapping[edge] = extension
  }
  transformer.edge_mapping[edge] = shape

  for label in @graph.edge_labels(edge) {
    new_component.push(
      disco_transform_import_label_shape(transformer, label, true, 0.0, 0.0),
    )
  }
}

///|
fn disco_transform_import_elk_edges(
  transformer : ElkGraphTransformer,
  edges : Array[@graph.ElkEdge],
  new_component : Array[DCElement],
) -> Unit {
  for edge in edges {
    if transformer.edge_mapping.contains(edge) {
      continue
    }
    let source_node = disco_transform_source_node(edge)
    let target_node = disco_transform_target_node(edge)
    if @graph.node_parent(source_node) == @graph.node_parent(target_node) {
      ignore(disco_transform_import_elk_edge(transformer, edge, new_component))
    } else if @graph.node_parent(target_node) == Some(source_node) {
      if !transformer.incoming_extensions_mapping.contains(edge) &&
        transformer.node_mapping.contains(target_node) {
        disco_transform_import_extension(
          transformer, edge, new_component, false,
        )
      }
    } else if @graph.node_parent(source_node) == Some(target_node) {
      if !transformer.outgoing_extensions_mapping.contains(edge) &&
        transformer.node_mapping.contains(source_node) {
        disco_transform_import_extension(transformer, edge, new_component, true)
      }
    }
  }
}

///|
fn disco_transform_padding_from_node(node : @graph.ElkNode) -> @core.ElkPadding {
  let value = @graph.node_get_string_property(node, disco_padding)
  let parsed = @core.new_elk_padding()
  parsed.parse(value)
  parsed
}

///|
pub fn ElkGraphTransformer::import_graph(
  self : ElkGraphTransformer,
  graph : @graph.ElkNode,
) -> DCGraph {
  self.parent = Some(graph)
  self.node_mapping.clear()
  self.label_mapping.clear()
  self.port_mapping.clear()
  self.edge_mapping.clear()
  self.incoming_extensions_mapping.clear()
  self.outgoing_extensions_mapping.clear()

  let components = elk_graph_components_processor_split(graph)
  let result : Array[Array[DCElement]] = []

  for component in components {
    let sub_result : Array[DCElement] = []
    result.push(sub_result)
    let edge_set : Map[@graph.ElkEdge, Unit] = {}
    for node in component {
      let component_node = disco_transform_import_node_shape(
        self, node, true, 0.0, 0.0,
      )
      sub_result.push(component_node)

      let node_x_value = @graph.node_x(node)
      let node_y_value = @graph.node_y(node)
      component_node.set_parent_coords(
        @core.new_kvector_xy(node_x_value, node_y_value),
      )

      for label in @graph.node_labels(node) {
        sub_result.push(
          disco_transform_import_label_shape(
            self, label, false, node_x_value, node_y_value,
          ),
        )
      }

      for port in @graph.node_ports(node) {
        sub_result.push(
          disco_transform_import_port_shape(
            self, port, false, node_x_value, node_y_value,
          ),
        )
        for label in @graph.port_labels(port) {
          sub_result.push(
            disco_transform_import_label_shape(
              self, label, false, node_x_value, node_y_value,
            ),
          )
        }
      }

      for edge in disco_transform_all_incident_edges(node) {
        edge_set[edge] = ()
      }
    }
    let edges : Array[@graph.ElkEdge] = []
    edge_set.each((edge, _) => edges.push(edge))
    disco_transform_import_elk_edges(self, edges, sub_result)
  }

  let transformed = new_dc_graph(result, inset=self.component_spacing / 2.0)
  transformed.set_polyomino_fill(
    @graph.node_get_bool_property(graph, disco_polyomino_fill),
  )
  if @graph.node_has_double_property(graph, disco_aspect_ratio) {
    transformed.set_aspect_ratio(
      Some(@graph.node_get_double_property(graph, disco_aspect_ratio)),
    )
  } else {
    transformed.set_aspect_ratio(None)
  }
  transformed.set_padding(disco_transform_padding_from_node(graph))
  self.transformed_graph = Some(transformed)
  transformed
}

///|
fn disco_transform_offset_edge(
  edge : @graph.ElkEdge,
  offset : @core.KVector,
) -> Unit {
  for section in @graph.edge_sections(edge) {
    @graph.edge_section_set_start(
      section,
      @graph.edge_section_start_x(section) + offset.x,
      @graph.edge_section_start_y(section) + offset.y,
    )
    @graph.edge_section_set_end(
      section,
      @graph.edge_section_end_x(section) + offset.x,
      @graph.edge_section_end_y(section) + offset.y,
    )
  }
}

///|
fn disco_transform_adjust_related_port(
  port : @graph.ElkPort,
  edge_point : @core.KVector,
  direction : DCDirection,
) -> Unit {
  ignore(port)
  ignore(edge_point)
  ignore(direction)
}

///|
fn disco_transform_adjust_first_segment(
  source : @graph.ElkNode,
  chain : @core.KVectorChain,
  direction : DCDirection,
) -> @core.KVectorChain {
  if chain.is_empty() {
    return chain
  }
  let first_point = chain.get(0)
  match direction {
    DCNorth => first_point.y = 0.0
    DCSouth => first_point.y = @graph.node_height(source)
    DCWest => first_point.x = 0.0
    DCEast => first_point.x = @graph.node_width(source)
  }
  chain
}

///|
pub fn ElkGraphTransformer::apply_layout(self : ElkGraphTransformer) -> Unit {
  let graph = match self.transformed_graph {
    Some(graph) => graph
    None => return
  }
  let parent = match self.parent {
    Some(parent) => parent
    None => return
  }
  let graph_dimensions = graph.get_dimensions()
  let new_width = graph_dimensions.x
  let new_height = graph_dimensions.y
  let old_width = @graph.node_width(parent)
  let old_height = @graph.node_height(parent)

  @graph.node_set_dimensions(parent, new_width, new_height)

  let x_factor = if old_width == 0.0 { 1.0 } else { new_width / old_width }
  let y_factor = if old_height == 0.0 { 1.0 } else { new_height / old_height }

  for label in @graph.node_labels(parent) {
    @graph.label_set_location(
      label,
      @graph.label_x(label) * x_factor,
      @graph.label_y(label) * y_factor,
    )
  }

  self.node_mapping.each((node, poly) => {
    let offset = disco_transform_element_offset_or_zero(poly)
    @graph.node_set_location(
      node,
      @graph.node_x(node) + offset.x,
      @graph.node_y(node) + offset.y,
    )
  })
  self.label_mapping.each((label, poly) => {
    let offset = disco_transform_element_offset_or_zero(poly)
    @graph.label_set_location(
      label,
      @graph.label_x(label) + offset.x,
      @graph.label_y(label) + offset.y,
    )
  })
  self.edge_mapping.each((edge, poly) => {
    disco_transform_offset_edge(
      edge,
      disco_transform_element_offset_or_zero(poly),
    )
  })

  let adjusted_ports : Map[@graph.ElkPort, Unit] = {}
  self.incoming_extensions_mapping.each((edge, extension) => {
    let section = disco_transform_first_or_create_edge_section(edge)
    let new_points = disco_transform_adjust_first_segment(
      disco_transform_source_node(edge),
      disco_transform_edge_points(section),
      extension.get_direction(),
    )
    disco_transform_apply_points_to_section(section, new_points)
    match disco_transform_source_port(edge) {
      Some(port) =>
        if !adjusted_ports.contains(port) {
          adjusted_ports[port] = ()
          disco_transform_adjust_related_port(
            port,
            new_points.get(0),
            extension.get_direction(),
          )
        }
      None => ()
    }
  })
  self.outgoing_extensions_mapping.each((edge, extension) => {
    let section = disco_transform_first_or_create_edge_section(edge)
    let reversed = @core.kvector_chain_reverse(
      disco_transform_edge_points(section),
    )
    let new_points_reversed = disco_transform_adjust_first_segment(
      disco_transform_target_node(edge),
      reversed,
      extension.get_direction(),
    )
    let new_points = @core.kvector_chain_reverse(new_points_reversed)
    disco_transform_apply_points_to_section(section, new_points)
    match disco_transform_target_port(edge) {
      Some(port) =>
        if !adjusted_ports.contains(port) {
          adjusted_ports[port] = ()
          disco_transform_adjust_related_port(
            port,
            new_points.get(new_points.size() - 1),
            extension.get_direction(),
          )
        }
      None => ()
    }
  })
}

///|
pub fn elk_graph_transformer_as_igraph_transformer(
  transformer : ElkGraphTransformer,
) -> IGraphTransformer[@graph.ElkNode] {
  new_igraph_transformer(graph => transformer.import_graph(graph), () => {
    transformer.apply_layout()
  })
}
