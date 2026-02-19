///|
pub struct ElkGraphTransformer {
  mut parent : ElkNode?
  node_mapping : Map[ElkNode, DCElement]
  label_mapping : Map[ElkLabel, DCElement]
  port_mapping : Map[ElkPort, DCElement]
  edge_mapping : Map[ElkEdge, DCElement]
  incoming_extensions_mapping : Map[ElkEdge, DCExtension]
  outgoing_extensions_mapping : Map[ElkEdge, DCExtension]
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
  try @strconv.parse_double(trimmed) catch {
    _ => default_value
  } noraise {
    value => value
  }
}

///|
fn disco_transform_edge_thickness(edge : ElkEdge) -> Double {
  match edge_layout_option_string_value(edge, disco_edge_thickness.get_id()) {
    Some(value) => disco_transform_parse_double_or_default(value, 1.0)
    None => 1.0
  }
}

///|
fn disco_transform_source_node(edge : ElkEdge) -> ElkNode {
  let sources = edge_sources(edge)
  if sources.is_empty() {
    abort("edge source is missing")
  }
  connectable_shape_to_node(Some(sources[0]))
}

///|
fn disco_transform_target_node(edge : ElkEdge) -> ElkNode {
  let targets = edge_targets(edge)
  if targets.is_empty() {
    abort("edge target is missing")
  }
  connectable_shape_to_node(Some(targets[0]))
}

///|
fn disco_transform_source_port(edge : ElkEdge) -> ElkPort? {
  let sources = edge_sources(edge)
  if sources.is_empty() {
    None
  } else {
    connectable_shape_to_port(Some(sources[0]))
  }
}

///|
fn disco_transform_target_port(edge : ElkEdge) -> ElkPort? {
  let targets = edge_targets(edge)
  if targets.is_empty() {
    None
  } else {
    connectable_shape_to_port(Some(targets[0]))
  }
}

///|
fn disco_transform_all_incident_edges(node : ElkNode) -> Array[ElkEdge] {
  let edges_map : Map[ElkEdge, Unit] = {}
  for edge in node_incoming_edges(node) {
    edges_map[edge] = ()
  }
  for edge in node_outgoing_edges(node) {
    edges_map[edge] = ()
  }
  for port in node_ports(node) {
    for edge in port_incoming_edges(port) {
      edges_map[edge] = ()
    }
    for edge in port_outgoing_edges(port) {
      edges_map[edge] = ()
    }
  }
  let edges : Array[ElkEdge] = []
  edges_map.each((edge, _) => edges.push(edge))
  edges
}

///|
fn disco_transform_first_or_create_edge_section(
  edge : ElkEdge,
) -> ElkEdgeSection {
  let sections = edge_sections(edge)
  let section = if sections.is_empty() {
    create_edge_section(edge)
  } else {
    sections[0]
  }
  if edge_section_incoming_shape(section) is None {
    let sources = edge_sources(edge)
    if sources.length() == 1 {
      edge_section_set_incoming_shape(section, Some(sources[0]))
    }
  }
  if edge_section_outgoing_shape(section) is None {
    let targets = edge_targets(edge)
    if targets.length() == 1 {
      edge_section_set_outgoing_shape(section, Some(targets[0]))
    }
  }
  section
}

///|
fn disco_transform_edge_points(section : ElkEdgeSection) -> KVectorChain {
  let points = new_kvector_chain()
  let visited : Map[ElkEdgeSection, Unit] = {}
  let mut current = section
  points.add_xy(edge_section_start_x(current), edge_section_start_y(current))
  while true {
    points.add_xy(edge_section_end_x(current), edge_section_end_y(current))
    visited[current] = ()
    let outgoing = edge_section_outgoing_sections(current)
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
  section : ElkEdgeSection,
  points : KVectorChain,
) -> Unit {
  if points.size() < 2 {
    return
  }
  let first = points.get(0)
  let last = points.get(points.size() - 1)
  edge_section_set_start(section, first.x, first.y)
  edge_section_set_end(section, last.x, last.y)
}

///|
fn disco_transform_new_point(x : Double, y : Double) -> KVector {
  new_kvector_xy(x, y)
}

///|
fn disco_transform_get_orthogonal_points(
  cur_x : Double,
  cur_y : Double,
  nxt_x : Double,
  nxt_y : Double,
  radius : Double,
) -> Array[KVector] {
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
  p1 : KVector,
  p2 : KVector,
  p3 : KVector,
  p4 : KVector,
) -> KVector {
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
  edge_points : Array[KVector],
  thickness : Double,
) -> KVectorChain {
  let ccw_points : Array[KVector] = []
  let cw_points : Array[KVector] = []
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

  let ccw_merged = new_kvector_chain()
  let cw_merged : Array[KVector] = []

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
  node : ElkNode,
  consider_offset : Bool,
  offset_x : Double,
  offset_y : Double,
) -> DCElement {
  let half_spacing = transformer.component_spacing / 2.0
  let x0 = node_x(node) + offset_x - half_spacing
  let y0 = node_y(node) + offset_y - half_spacing
  let x1 = x0 + node_width(node) + transformer.component_spacing
  let y1 = y0 + node_height(node) + transformer.component_spacing
  let coords = new_kvector_chain()
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
  label : ElkLabel,
  consider_offset : Bool,
  offset_x : Double,
  offset_y : Double,
) -> DCElement {
  let half_spacing = transformer.component_spacing / 2.0
  let x0 = label_x(label) + offset_x - half_spacing
  let y0 = label_y(label) + offset_y - half_spacing
  let x1 = x0 + label_width(label) + transformer.component_spacing
  let y1 = y0 + label_height(label) + transformer.component_spacing
  let coords = new_kvector_chain()
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
  port : ElkPort,
  consider_offset : Bool,
  offset_x : Double,
  offset_y : Double,
) -> DCElement {
  let half_spacing = transformer.component_spacing / 2.0
  let x0 = offset_x - half_spacing
  let y0 = offset_y - half_spacing
  let x1 = x0 + transformer.component_spacing
  let y1 = y0 + transformer.component_spacing
  let coords = new_kvector_chain()
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
  edge : ElkEdge,
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
  for label in edge_labels(edge) {
    new_component.push(
      disco_transform_import_label_shape(transformer, label, true, 0.0, 0.0),
    )
  }
  shape
}

///|
fn disco_transform_nearest_side(point : KVector, node : ElkNode) -> DCDirection {
  let mut shortest_distance = point.y.abs()
  let mut result = DCNorth

  let south_distance = (node_height(node) - point.y).abs()
  if south_distance < shortest_distance {
    shortest_distance = south_distance
    result = DCSouth
  }

  let west_distance = point.x.abs()
  if west_distance < shortest_distance {
    shortest_distance = west_distance
    result = DCWest
  }

  let east_distance = (node_width(node) - point.x).abs()
  if east_distance < shortest_distance {
    ignore(shortest_distance)
    result = DCEast
  }

  result
}

///|
fn disco_transform_import_extension(
  transformer : ElkGraphTransformer,
  edge : ElkEdge,
  new_component : Array[DCElement],
  outgoing_extension : Bool,
) -> Unit {
  let edge_section = disco_transform_first_or_create_edge_section(edge)
  let points = if outgoing_extension {
    kvector_chain_reverse(disco_transform_edge_points(edge_section))
  } else {
    disco_transform_edge_points(edge_section)
  }
  let points_array = points.to_array()
  if points_array.length() < 2 {
    return
  }

  let thickness = disco_transform_edge_thickness(edge)
  let shape = if points_array.length() > 2 {
    let fixed_edge_points : Array[KVector] = []
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
    new_kvector_xy(inner_point.x, (inner_point.y + outer_point.y) / 2.0)
  } else {
    extension_width += (outer_point.x - inner_point.x).abs()
    new_kvector_xy((inner_point.x + outer_point.x) / 2.0, inner_point.y)
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

  for label in edge_labels(edge) {
    new_component.push(
      disco_transform_import_label_shape(transformer, label, true, 0.0, 0.0),
    )
  }
}

///|
fn disco_transform_import_elk_edges(
  transformer : ElkGraphTransformer,
  edges : Array[ElkEdge],
  new_component : Array[DCElement],
) -> Unit {
  for edge in edges {
    if transformer.edge_mapping.contains(edge) {
      continue
    }
    let source_node = disco_transform_source_node(edge)
    let target_node = disco_transform_target_node(edge)
    if node_parent(source_node) == node_parent(target_node) {
      ignore(disco_transform_import_elk_edge(transformer, edge, new_component))
    } else if node_parent(target_node) == Some(source_node) {
      if !transformer.incoming_extensions_mapping.contains(edge) &&
        transformer.node_mapping.contains(target_node) {
        disco_transform_import_extension(
          transformer, edge, new_component, false,
        )
      }
    } else if node_parent(source_node) == Some(target_node) {
      if !transformer.outgoing_extensions_mapping.contains(edge) &&
        transformer.node_mapping.contains(source_node) {
        disco_transform_import_extension(transformer, edge, new_component, true)
      }
    }
  }
}

///|
fn disco_transform_padding_from_node(node : ElkNode) -> ElkPadding {
  let value = node_get_string_property(node, disco_padding)
  let parsed = new_elk_padding()
  parsed.parse(value)
  parsed
}

///|
pub fn ElkGraphTransformer::import_graph(
  self : ElkGraphTransformer,
  graph : ElkNode,
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
    let edge_set : Map[ElkEdge, Unit] = {}
    for node in component {
      let component_node = disco_transform_import_node_shape(
        self, node, true, 0.0, 0.0,
      )
      sub_result.push(component_node)

      let node_x_value = node_x(node)
      let node_y_value = node_y(node)
      component_node.set_parent_coords(
        new_kvector_xy(node_x_value, node_y_value),
      )

      for label in node_labels(node) {
        sub_result.push(
          disco_transform_import_label_shape(
            self, label, false, node_x_value, node_y_value,
          ),
        )
      }

      for port in node_ports(node) {
        sub_result.push(
          disco_transform_import_port_shape(
            self, port, false, node_x_value, node_y_value,
          ),
        )
        for label in port_labels(port) {
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
    let edges : Array[ElkEdge] = []
    edge_set.each((edge, _) => edges.push(edge))
    disco_transform_import_elk_edges(self, edges, sub_result)
  }

  let transformed = new_dc_graph(result, inset=self.component_spacing / 2.0)
  transformed.set_polyomino_fill(
    node_get_bool_property(graph, disco_polyomino_fill),
  )
  if node_has_double_property(graph, disco_aspect_ratio) {
    transformed.set_aspect_ratio(
      Some(node_get_double_property(graph, disco_aspect_ratio)),
    )
  } else {
    transformed.set_aspect_ratio(None)
  }
  transformed.set_padding(disco_transform_padding_from_node(graph))
  self.transformed_graph = Some(transformed)
  transformed
}

///|
fn disco_transform_offset_edge(edge : ElkEdge, offset : KVector) -> Unit {
  for section in edge_sections(edge) {
    edge_section_set_start(
      section,
      edge_section_start_x(section) + offset.x,
      edge_section_start_y(section) + offset.y,
    )
    edge_section_set_end(
      section,
      edge_section_end_x(section) + offset.x,
      edge_section_end_y(section) + offset.y,
    )
  }
}

///|
fn disco_transform_adjust_related_port(
  port : ElkPort,
  edge_point : KVector,
  direction : DCDirection,
) -> Unit {
  ignore(port)
  ignore(edge_point)
  ignore(direction)
}

///|
fn disco_transform_adjust_first_segment(
  source : ElkNode,
  chain : KVectorChain,
  direction : DCDirection,
) -> KVectorChain {
  if chain.is_empty() {
    return chain
  }
  let first_point = chain.get(0)
  match direction {
    DCNorth => first_point.y = 0.0
    DCSouth => first_point.y = node_height(source)
    DCWest => first_point.x = 0.0
    DCEast => first_point.x = node_width(source)
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
  let old_width = node_width(parent)
  let old_height = node_height(parent)

  node_set_dimensions(parent, new_width, new_height)

  let x_factor = if old_width == 0.0 { 1.0 } else { new_width / old_width }
  let y_factor = if old_height == 0.0 { 1.0 } else { new_height / old_height }

  for label in node_labels(parent) {
    label_set_location(
      label,
      label_x(label) * x_factor,
      label_y(label) * y_factor,
    )
  }

  self.node_mapping.each((node, poly) => {
    let offset = poly.get_offset()
    node_set_location(node, node_x(node) + offset.x, node_y(node) + offset.y)
  })
  self.label_mapping.each((label, poly) => {
    let offset = poly.get_offset()
    label_set_location(
      label,
      label_x(label) + offset.x,
      label_y(label) + offset.y,
    )
  })
  self.edge_mapping.each((edge, poly) => {
    disco_transform_offset_edge(edge, poly.get_offset())
  })

  let adjusted_ports : Map[ElkPort, Unit] = {}
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
    let reversed = kvector_chain_reverse(disco_transform_edge_points(section))
    let new_points_reversed = disco_transform_adjust_first_segment(
      disco_transform_target_node(edge),
      reversed,
      extension.get_direction(),
    )
    let new_points = kvector_chain_reverse(new_points_reversed)
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
) -> IGraphTransformer[ElkNode] {
  new_igraph_transformer(graph => transformer.import_graph(graph), () => {
    transformer.apply_layout()
  })
}
