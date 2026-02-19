///|
let libavoid_communicator_chunk_keyword : String = "[CHUNK]"

///|
let libavoid_communicator_port_id_start : Int = 5

///|
let libavoid_communicator_node_id_start : Int = 5

///|
let libavoid_communicator_node_compound_north : Int = 1

///|
let libavoid_communicator_node_compound_east : Int = 2

///|
let libavoid_communicator_node_compound_south : Int = 3

///|
let libavoid_communicator_node_compound_west : Int = 4

///|
let libavoid_communicator_surrounding_rect_size : Int = 10

///|
let libavoid_communicator_subtask_work : Double = 1.0

///|
let libavoid_communicator_layout_work : Double = 4.0

///|
pub struct LibavoidServerCommunicator {
  node_id_map : Map[Int, ElkNode]
  node_inverse_map : Map[ElkNode, Int]
  port_id_map : Map[Int, ElkPort]
  port_inverse_map : Map[ElkPort, Int]
  edge_id_map : Map[Int, ElkEdge]
  edge_inverse_map : Map[ElkEdge, Int]
  mut node_id_counter : Int
  mut port_id_counter : Int
  mut edge_id_counter : Int
  lines : Array[String]
}

///|
pub fn new_libavoid_server_communicator() -> LibavoidServerCommunicator {
  {
    node_id_map: {},
    node_inverse_map: {},
    port_id_map: {},
    port_inverse_map: {},
    edge_id_map: {},
    edge_inverse_map: {},
    node_id_counter: libavoid_communicator_node_id_start,
    port_id_counter: libavoid_communicator_port_id_start,
    edge_id_counter: 1,
    lines: [],
  }
}

///|
fn libavoid_communicator_sub_monitor(
  monitor : IElkProgressMonitor,
  work : Double,
) -> IElkProgressMonitor {
  match monitor.sub_task(work) {
    Some(sub_monitor) => sub_monitor
    None => monitor
  }
}

///|
fn LibavoidServerCommunicator::reset(self : LibavoidServerCommunicator) -> Unit {
  self.node_id_counter = libavoid_communicator_node_id_start
  self.node_id_map.clear()
  self.node_inverse_map.clear()
  self.port_id_counter = libavoid_communicator_port_id_start
  self.port_id_map.clear()
  self.port_inverse_map.clear()
  self.edge_id_counter = 1
  self.edge_id_map.clear()
  self.edge_inverse_map.clear()
  self.lines.clear()
}

///|
fn LibavoidServerCommunicator::emit_line(
  self : LibavoidServerCommunicator,
  line : String,
) -> Unit {
  self.lines.push(line)
}

///|
fn LibavoidServerCommunicator::render_text(
  self : LibavoidServerCommunicator,
) -> String {
  if self.lines.is_empty() {
    ""
  } else {
    self.lines.join("\n") + "\n"
  }
}

///|
fn libavoid_communicator_process_timeout_of(layout_node : ElkNode) -> Int {
  let timeout_text = match
    node_layout_option_string_value(
      layout_node,
      libavoid_option_process_timeout.get_id(),
    ) {
    Some(value) => value
    None => libavoid_option_process_timeout.get_default().to_string()
  }
  let parsed : Result[Int, @strconv.StrConvError] = try? @strconv.parse_int(
    timeout_text,
  )
  match parsed {
    Ok(value) => value
    Err(_) => libavoid_option_process_timeout.get_default()
  }
}

///|
pub fn LibavoidServerCommunicator::request_layout(
  self : LibavoidServerCommunicator,
  layout_node : ElkNode,
  progress_monitor : IElkProgressMonitor,
  lv_server : LibavoidServer,
) -> Unit {
  self.reset()
  ignore(
    progress_monitor.begin("Libavoid Layout", libavoid_communicator_layout_work),
  )
  if node_children(layout_node).is_empty() {
    progress_monitor.done()
    return
  }

  lv_server.initialize()
  lv_server.set_process_timeout(
    libavoid_communicator_process_timeout_of(layout_node),
  )
  let output_stream = lv_server.input()
  self.write_text_graph(layout_node, output_stream)
  output_stream.flush()

  let layout_information = self.read_layout_information(
    lv_server,
    libavoid_communicator_sub_monitor(
      progress_monitor, libavoid_communicator_subtask_work,
    ),
  )
  self.apply_layout(
    layout_node,
    layout_information,
    libavoid_communicator_sub_monitor(
      progress_monitor, libavoid_communicator_subtask_work,
    ),
  )
  self.calculate_junction_points(layout_node)
  lv_server.cleanup(libavoid_server_cleanup_normal())
  progress_monitor.done()
  self.reset()
}

///|
fn libavoid_communicator_first_or_create_edge_section(
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
fn libavoid_communicator_edge_id_from_key(key : String) -> Int? {
  let tokens : Array[String] = []
  for token in key.split(" ") {
    let value = token.trim().to_string()
    if !value.is_empty() {
      tokens.push(value)
    }
  }
  if tokens.length() < 2 {
    return None
  }
  let parsed : Result[Int, @strconv.StrConvError] = try? @strconv.parse_int(
    tokens[1],
  )
  match parsed {
    Ok(value) => Some(value)
    Err(_) => None
  }
}

///|
fn libavoid_communicator_parse_double_or_zero(value : String) -> Double {
  let parsed : Result[Double, @strconv.StrConvError] = try? @strconv.parse_double(
    value,
  )
  match parsed {
    Ok(number) => number
    Err(_) => 0.0
  }
}

///|
fn libavoid_communicator_parse_point_list(value : String) -> KVectorChain {
  let tokens : Array[String] = []
  for token in value.split(" ") {
    let normalized = token.trim().to_string()
    if !normalized.is_empty() {
      tokens.push(normalized)
    }
  }
  let points = new_kvector_chain()
  let mut i = 0
  while i + 1 < tokens.length() {
    let x = libavoid_communicator_parse_double_or_zero(tokens[i])
    let y = libavoid_communicator_parse_double_or_zero(tokens[i + 1])
    points.add_xy(x, y)
    i = i + 2
  }
  points
}

///|
fn libavoid_communicator_padding_of(node : ElkNode) -> ElkPadding {
  let parsed = new_elk_padding()
  parsed.parse(node_get_string_property(node, padding))
  parsed
}

///|
fn LibavoidServerCommunicator::apply_layout(
  self : LibavoidServerCommunicator,
  parent_node : ElkNode,
  layout_information : Map[String, KVectorChain],
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  ignore(
    progress_monitor.begin("Apply layout", libavoid_communicator_subtask_work),
  )
  let mut max_x = 0.0
  let mut max_y = 0.0

  layout_information.each((key, points) => {
    if points.size() < 2 {
      abort("An edge retrieved from Libavoid has less than 2 points.")
    }

    let edge_id = match libavoid_communicator_edge_id_from_key(key) {
      Some(value) => value
      None => abort("Failed to determine edge id from Libavoid output.")
    }
    let edge = match self.edge_id_map.get(edge_id) {
      Some(value) => value
      None =>
        abort(
          "A problem within the edge mapping occured. Could not determine edge for id \{edge_id}.",
        )
    }
    let section = libavoid_communicator_first_or_create_edge_section(edge)
    let first_point = points.get(0)
    let last_point = points.get(points.size() - 1)
    edge_section_set_start(section, first_point.x, first_point.y)
    edge_section_set_end(section, last_point.x, last_point.y)

    for point in points.to_array() {
      max_x = @cmp.maximum(max_x, point.x)
      max_y = @cmp.maximum(max_y, point.y)
    }
  })

  for node in node_children(parent_node) {
    max_x = @cmp.maximum(max_x, node_x(node) + node_width(node))
    max_y = @cmp.maximum(max_y, node_y(node) + node_height(node))
  }

  let node_padding = libavoid_communicator_padding_of(parent_node)
  if node_width(parent_node) < max_x {
    node_set_dimensions(
      parent_node,
      max_x + node_padding.get_right(),
      node_height(parent_node),
    )
  }
  if node_height(parent_node) < max_y {
    node_set_dimensions(
      parent_node,
      node_width(parent_node),
      max_y + node_padding.get_bottom(),
    )
  }

  progress_monitor.done()
}

///|
fn LibavoidServerCommunicator::calculate_junction_points(
  self : LibavoidServerCommunicator,
  graph : ElkNode,
) -> Unit {
  ignore(self)
  let visited : Map[ElkEdge, Unit] = {}
  for node in node_children(graph) {
    for edge in node_outgoing_edges(node) {
      if !visited.contains(edge) {
        edge_set_layout_option_string_by_id(
          edge, libavoid_option_junction_points_id, "()",
        )
        visited[edge] = ()
      }
    }
    for port in node_ports(node) {
      for edge in port_outgoing_edges(port) {
        if !visited.contains(edge) {
          edge_set_layout_option_string_by_id(
            edge, libavoid_option_junction_points_id, "()",
          )
          visited[edge] = ()
        }
      }
    }
  }
}

///|
fn LibavoidServerCommunicator::read_layout_information(
  self : LibavoidServerCommunicator,
  libavoid_server : LibavoidServer,
  progress_monitor : IElkProgressMonitor,
) -> Map[String, KVectorChain] {
  ignore(self)
  ignore(progress_monitor.begin("Read output from Libavoid", 1.0))
  let output_data = libavoid_server.read_output_data()
  let layout_information : Map[String, KVectorChain] = {}
  match output_data {
    Some(data) =>
      data.each((key, value) => {
        layout_information[key] = libavoid_communicator_parse_point_list(value)
      })
    None => {
      libavoid_server.cleanup(libavoid_server_cleanup_error())
      abort(
        "No output from the Libavoid process. Try increasing the timeout value in the preferences (KIELER / Layout / Libavoid).",
      )
    }
  }
  progress_monitor.done()
  layout_information
}

///|
fn LibavoidServerCommunicator::write_text_graph(
  self : LibavoidServerCommunicator,
  root : ElkNode,
  stream : GraphvizOutputStream,
) -> Unit {
  self.transform_options(root)
  if node_get_bool_property(root, libavoid_option_debug_mode) {
    self.emit_line("DEBUG")
  }
  self.transform_graph(root)
  self.emit_line(libavoid_communicator_chunk_keyword)

  let text = self.render_text()
  for ch in text {
    stream.write(ch.to_int())
  }
}

///|
fn libavoid_communicator_option_id(id : String) -> String {
  if id.starts_with("org.eclipse.elk.alg.libavoid.") {
    id.substring(start="org.eclipse.elk.alg.libavoid.".length())
  } else if id.starts_with("org.eclipse.elk.") {
    id.substring(start="org.eclipse.elk.".length())
  } else {
    id
  }
}

///|
fn LibavoidServerCommunicator::add_option_line(
  self : LibavoidServerCommunicator,
  key_id : String,
  value : String?,
) -> Unit {
  match value {
    Some(option_value) =>
      self.emit_line(
        "OPTION \{libavoid_communicator_option_id(key_id)} \{option_value}",
      )
    None => ()
  }
}

///|
fn LibavoidServerCommunicator::add_routing_option_line(
  self : LibavoidServerCommunicator,
  key_id : String,
  value : Bool,
) -> Unit {
  self.emit_line(
    "ROUTINGOPTION \{libavoid_communicator_option_id(key_id)} \{value}",
  )
}

///|
fn LibavoidServerCommunicator::add_penalty_line(
  self : LibavoidServerCommunicator,
  key_id : String,
  value : Double,
) -> Unit {
  if !value.is_nan() {
    self.emit_line(
      "PENALTY \{libavoid_communicator_option_id(key_id)} \{value}",
    )
  }
}

///|
fn LibavoidServerCommunicator::transform_options(
  self : LibavoidServerCommunicator,
  node : ElkNode,
) -> Unit {
  let edge_routing = node_get_string_property(
    node, libavoid_option_edge_routing,
  )
  if edge_routing != "UNDEFINED" {
    self.add_option_line(
      libavoid_option_edge_routing.get_id(),
      Some(edge_routing),
    )
  }

  let node_direction = node_get_string_property(node, libavoid_option_direction)
  if node_direction != "UNDEFINED" {
    self.add_option_line(
      libavoid_option_direction.get_id(),
      Some(node_direction),
    )
  }

  self.add_option_line(
    libavoid_option_enable_hyperedges_from_common_source.get_id(),
    Some(
      node_get_bool_property(
        node, libavoid_option_enable_hyperedges_from_common_source,
      ).to_string(),
    ),
  )

  self.add_penalty_line(
    libavoid_option_segment_penalty.get_id(),
    node_get_double_property(node, libavoid_option_segment_penalty),
  )
  self.add_penalty_line(
    libavoid_option_angle_penalty.get_id(),
    node_get_double_property(node, libavoid_option_angle_penalty),
  )
  self.add_penalty_line(
    libavoid_option_crossing_penalty.get_id(),
    node_get_double_property(node, libavoid_option_crossing_penalty),
  )
  self.add_penalty_line(
    libavoid_option_cluster_crossing_penalty.get_id(),
    node_get_double_property(node, libavoid_option_cluster_crossing_penalty),
  )
  self.add_penalty_line(
    libavoid_option_fixed_shared_path_penalty.get_id(),
    node_get_double_property(node, libavoid_option_fixed_shared_path_penalty),
  )
  self.add_penalty_line(
    libavoid_option_port_direction_penalty.get_id(),
    node_get_double_property(node, libavoid_option_port_direction_penalty),
  )
  self.add_penalty_line(
    libavoid_option_shape_buffer_distance.get_id(),
    node_get_double_property(node, libavoid_option_shape_buffer_distance),
  )
  self.add_penalty_line(
    libavoid_option_ideal_nudging_distance.get_id(),
    node_get_double_property(node, libavoid_option_ideal_nudging_distance),
  )
  self.add_penalty_line(
    libavoid_option_reverse_direction_penalty.get_id(),
    node_get_double_property(node, libavoid_option_reverse_direction_penalty),
  )

  self.add_routing_option_line(
    libavoid_option_nudge_orthogonal_segments_connected_to_shapes.get_id(),
    node_get_bool_property(
      node, libavoid_option_nudge_orthogonal_segments_connected_to_shapes,
    ),
  )
  self.add_routing_option_line(
    libavoid_option_improve_hyperedge_routes_moving_junctions.get_id(),
    node_get_bool_property(
      node, libavoid_option_improve_hyperedge_routes_moving_junctions,
    ),
  )
  self.add_routing_option_line(
    libavoid_option_penalise_orthogonal_shared_paths_at_conn_ends.get_id(),
    node_get_bool_property(
      node, libavoid_option_penalise_orthogonal_shared_paths_at_conn_ends,
    ),
  )
  self.add_routing_option_line(
    libavoid_option_nudge_orthogonal_touching_colinear_segments.get_id(),
    node_get_bool_property(
      node, libavoid_option_nudge_orthogonal_touching_colinear_segments,
    ),
  )
  self.add_routing_option_line(
    libavoid_option_perform_unifying_nudging_preprocessing_step.get_id(),
    node_get_bool_property(
      node, libavoid_option_perform_unifying_nudging_preprocessing_step,
    ),
  )
  self.add_routing_option_line(
    libavoid_option_improve_hyperedge_routes_moving_adding_and_deleting_junctions.get_id(),
    node_get_bool_property(
      node, libavoid_option_improve_hyperedge_routes_moving_adding_and_deleting_junctions,
    ),
  )
  self.add_routing_option_line(
    libavoid_option_nudge_shared_paths_with_common_end_point.get_id(),
    node_get_bool_property(
      node, libavoid_option_nudge_shared_paths_with_common_end_point,
    ),
  )
}

///|
fn libavoid_communicator_node_parent_is(
  node : ElkNode,
  parent : ElkNode,
) -> Bool {
  match node_parent(node) {
    Some(node_parent_value) => node_parent_value == parent
    None => false
  }
}

///|
fn LibavoidServerCommunicator::transform_graph(
  self : LibavoidServerCommunicator,
  root : ElkNode,
) -> Unit {
  self.emit_line("GRAPH")

  if node_parent(root) is Some(_) {
    self.transform_hierarchical_parent(root)
  } else {
    self.transform_hierarchical_parent_dummy(root)
  }

  for node in node_children(root) {
    self.transform_node(node)
  }

  for node in node_children(root) {
    for edge in node_outgoing_edges(node) {
      if !self.is_hierarchical_edge(edge, root) || self.is_cluster_edge(edge) {
        self.transform_edge_if_new(edge)
      }
    }
    for port in node_ports(node) {
      for edge in port_outgoing_edges(port) {
        if !self.is_hierarchical_edge(edge, root) || self.is_cluster_edge(edge) {
          self.transform_edge_if_new(edge)
        }
      }
    }
  }

  for port in node_ports(root) {
    for edge in port_incoming_edges(port) {
      self.transform_hierarchical_port_edge_if_relevant(root, edge)
    }
    for edge in port_outgoing_edges(port) {
      self.transform_hierarchical_port_edge_if_relevant(root, edge)
    }
  }

  self.emit_line("GRAPHEND")
}

///|
fn LibavoidServerCommunicator::transform_hierarchical_port_edge_if_relevant(
  self : LibavoidServerCommunicator,
  root : ElkNode,
  edge : ElkEdge,
) -> Unit {
  let sources = edge_sources(edge)
  let targets = edge_targets(edge)
  if sources.is_empty() || targets.is_empty() {
    return
  }
  let src_node = connectable_shape_to_node(Some(sources[0]))
  let tgt_node = connectable_shape_to_node(Some(targets[0]))
  if libavoid_communicator_node_parent_is(src_node, root) ||
    libavoid_communicator_node_parent_is(tgt_node, root) {
    self.transform_edge_if_new(edge)
  }
}

///|
fn LibavoidServerCommunicator::is_hierarchical_edge(
  self : LibavoidServerCommunicator,
  edge : ElkEdge,
  root : ElkNode,
) -> Bool {
  ignore(self)
  let sources = edge_sources(edge)
  let targets = edge_targets(edge)
  if sources.is_empty() || targets.is_empty() {
    return false
  }
  let src_node = connectable_shape_to_node(Some(sources[0]))
  let tgt_node = connectable_shape_to_node(Some(targets[0]))
  !(libavoid_communicator_node_parent_is(src_node, root) &&
  libavoid_communicator_node_parent_is(tgt_node, root))
}

///|
fn LibavoidServerCommunicator::is_cluster_edge(
  self : LibavoidServerCommunicator,
  edge : ElkEdge,
) -> Bool {
  ignore(self)
  let sources = edge_sources(edge)
  let targets = edge_targets(edge)
  if sources.is_empty() || targets.is_empty() {
    return false
  }
  let src_node = connectable_shape_to_node(Some(sources[0]))
  let tgt_node = connectable_shape_to_node(Some(targets[0]))

  let src_parent_is_cluster = match node_parent(src_node) {
    Some(parent) => node_has_bool_property(parent, libavoid_option_is_cluster)
    None => false
  }
  let tgt_parent_is_cluster = match node_parent(tgt_node) {
    Some(parent) => node_has_bool_property(parent, libavoid_option_is_cluster)
    None => false
  }
  src_parent_is_cluster || tgt_parent_is_cluster
}

///|
fn LibavoidServerCommunicator::transform_hierarchical_parent(
  self : LibavoidServerCommunicator,
  parent : ElkNode,
) -> Unit {
  let buffer_distance = node_get_double_property(
    parent, libavoid_option_shape_buffer_distance,
  )
  self.libavoid_node(
    parent,
    libavoid_communicator_node_compound_north,
    0.0,
    0.0 -
    libavoid_communicator_surrounding_rect_size.to_double() -
    buffer_distance,
    node_width(parent),
    libavoid_communicator_surrounding_rect_size.to_double(),
    0,
    0,
  )
  self.libavoid_node(
    parent,
    libavoid_communicator_node_compound_east,
    node_width(parent) + buffer_distance,
    0.0,
    libavoid_communicator_surrounding_rect_size.to_double(),
    node_height(parent),
    0,
    0,
  )
  self.libavoid_node(
    parent,
    libavoid_communicator_node_compound_south,
    0.0,
    node_height(parent) + buffer_distance,
    node_width(parent),
    libavoid_communicator_surrounding_rect_size.to_double(),
    0,
    0,
  )
  self.libavoid_node(
    parent,
    libavoid_communicator_node_compound_west,
    0.0 -
    buffer_distance -
    libavoid_communicator_surrounding_rect_size.to_double(),
    0.0,
    libavoid_communicator_surrounding_rect_size.to_double(),
    node_height(parent),
    0,
    0,
  )

  for port in node_ports(parent) {
    let node_id = self.determine_hierarchical_node_id(port)
    self.libavoid_port(port, self.port_id_counter, node_id, Some(parent))
    self.port_id_counter = self.port_id_counter + 1
  }
}

///|
fn LibavoidServerCommunicator::transform_hierarchical_parent_dummy(
  self : LibavoidServerCommunicator,
  root : ElkNode,
) -> Unit {
  self.libavoid_node(
    root, libavoid_communicator_node_compound_north, 0.0, 0.0, 0.0, 0.0, 0, 0,
  )
  self.libavoid_node(
    root, libavoid_communicator_node_compound_east, 0.0, 0.0, 0.0, 0.0, 0, 0,
  )
  self.libavoid_node(
    root, libavoid_communicator_node_compound_south, 0.0, 0.0, 0.0, 0.0, 0, 0,
  )
  self.libavoid_node(
    root, libavoid_communicator_node_compound_west, 0.0, 0.0, 0.0, 0.0, 0, 0,
  )
}

///|
fn LibavoidServerCommunicator::libavoid_node(
  self : LibavoidServerCommunicator,
  node : ElkNode,
  id : Int,
  x_pos : Double,
  y_pos : Double,
  width : Double,
  height : Double,
  port_less_incoming_edges : Int,
  port_less_outgoing_edges : Int,
) -> Unit {
  if id >= libavoid_communicator_node_id_start {
    self.node_id_map[id] = node
    self.node_inverse_map[node] = id
  }
  self.emit_line(
    "NODE \{id} \{x_pos} \{y_pos} \{x_pos + width} \{y_pos + height} \{port_less_incoming_edges} \{port_less_outgoing_edges}",
  )
}

///|
fn LibavoidServerCommunicator::libavoid_cluster(
  self : LibavoidServerCommunicator,
  node : ElkNode,
  id : Int,
  x_pos : Double,
  y_pos : Double,
  width : Double,
  height : Double,
) -> Unit {
  ignore(node)
  self.emit_line(
    "CLUSTER \{id} \{x_pos} \{y_pos} \{x_pos + width} \{y_pos + height}",
  )
}

///|
fn libavoid_communicator_opposed_side(side : String) -> String {
  if side == "NORTH" {
    "SOUTH"
  } else if side == "SOUTH" {
    "NORTH"
  } else if side == "EAST" {
    "WEST"
  } else if side == "WEST" {
    "EAST"
  } else {
    side
  }
}

///|
fn libavoid_communicator_port_side_or_undefined(port : ElkPort) -> String {
  match port_layout_option_string_value(port, port_side.get_id()) {
    Some(value) => value
    None => "UNDEFINED"
  }
}

///|
fn LibavoidServerCommunicator::libavoid_port(
  self : LibavoidServerCommunicator,
  port : ElkPort,
  port_id : Int,
  node_id : Int,
  compound_node : ElkNode?,
) -> Unit {
  self.port_id_map[port_id] = port
  self.port_inverse_map[port] = port_id

  let mut side = libavoid_communicator_port_side_or_undefined(port)
  if compound_node is Some(_) {
    side = libavoid_communicator_opposed_side(side)
  }

  let center_x = port_x(port) + port_width(port) / 2.0
  let center_y = port_y(port) + port_height(port) / 2.0
  self.emit_line("PORT \{port_id} \{node_id} \{side} \{center_x} \{center_y}")
}

///|
fn LibavoidServerCommunicator::transform_node(
  self : LibavoidServerCommunicator,
  node : ElkNode,
) -> Unit {
  if self.is_cluster(node) {
    self.transform_cluster(node)
  } else {
    self.transform_node_at(node, node_x(node), node_y(node))
  }
}

///|
fn LibavoidServerCommunicator::is_cluster(
  self : LibavoidServerCommunicator,
  node : ElkNode,
) -> Bool {
  ignore(self)
  let cluster_marked = node_get_bool_property(node, libavoid_option_is_cluster)
  if !cluster_marked {
    return false
  }
  let parent_not_cluster = match node_parent(node) {
    Some(parent) => !node_get_bool_property(parent, libavoid_option_is_cluster)
    None => false
  }
  parent_not_cluster &&
  node_outgoing_edges(node).is_empty() &&
  node_incoming_edges(node).is_empty() &&
  node_ports(node).is_empty()
}

///|
fn LibavoidServerCommunicator::transform_node_at(
  self : LibavoidServerCommunicator,
  node : ElkNode,
  x : Double,
  y : Double,
) -> Unit {
  let port_less_incoming_edges = node_incoming_edges(node).length()
  let port_less_outgoing_edges = node_outgoing_edges(node).length()
  self.libavoid_node(
    node,
    self.node_id_counter,
    x,
    y,
    node_width(node),
    node_height(node),
    port_less_incoming_edges,
    port_less_outgoing_edges,
  )
  for port in node_ports(node) {
    self.libavoid_port(port, self.port_id_counter, self.node_id_counter, None)
    self.port_id_counter = self.port_id_counter + 1
  }
  self.node_id_counter = self.node_id_counter + 1
}

///|
fn LibavoidServerCommunicator::transform_cluster(
  self : LibavoidServerCommunicator,
  node : ElkNode,
) -> Unit {
  self.libavoid_cluster(
    node,
    self.node_id_counter,
    node_x(node),
    node_y(node),
    node_width(node),
    node_height(node),
  )
  self.node_id_counter = self.node_id_counter + 1

  let x = node_x(node)
  let y = node_y(node)
  for child in node_children(node) {
    self.transform_node_at(child, node_x(child) + x, node_x(child) + y)
  }
}

///|
fn libavoid_communicator_id_or_null(id : Int?) -> String {
  match id {
    Some(value) => value.to_string()
    None => "null"
  }
}

///|
fn LibavoidServerCommunicator::transform_edge_if_new(
  self : LibavoidServerCommunicator,
  edge : ElkEdge,
) -> Unit {
  if self.edge_inverse_map.contains(edge) {
    return
  }
  self.transform_edge(edge)
}

///|
fn LibavoidServerCommunicator::transform_edge(
  self : LibavoidServerCommunicator,
  edge : ElkEdge,
) -> Unit {
  let sources = edge_sources(edge)
  let targets = edge_targets(edge)
  if sources.is_empty() || targets.is_empty() {
    return
  }

  self.edge_id_map[self.edge_id_counter] = edge
  self.edge_inverse_map[edge] = self.edge_id_counter

  let source_shape = sources[0]
  let target_shape = targets[0]
  let src_node = connectable_shape_to_node(Some(source_shape))
  let tgt_node = connectable_shape_to_node(Some(target_shape))
  let src_port = connectable_shape_to_port(Some(source_shape))
  let tgt_port = connectable_shape_to_port(Some(target_shape))

  let mut src_id = self.node_inverse_map.get(src_node)
  let mut tgt_id = self.node_inverse_map.get(tgt_node)
  let src_port_id = match src_port {
    Some(port) => self.port_inverse_map.get(port)
    None => None
  }
  let tgt_port_id = match tgt_port {
    Some(port) => self.port_inverse_map.get(port)
    None => None
  }

  if src_port_id is Some(_) && src_id is None {
    src_id = match src_port {
      Some(port) => Some(self.determine_hierarchical_node_id(port))
      None => None
    }
  }
  if tgt_port_id is Some(_) && tgt_id is None {
    tgt_id = match tgt_port {
      Some(port) => Some(self.determine_hierarchical_node_id(port))
      None => None
    }
  }

  let mut edge_type = "EDGE"
  if src_port_id is Some(_) && tgt_port_id is Some(_) {
    edge_type = "PEDGEP"
  } else if src_port_id is Some(_) {
    edge_type = "PEDGE"
  } else if tgt_port_id is Some(_) {
    edge_type = "EDGEP"
  }

  self.emit_line(
    "\{edge_type} \{self.edge_id_counter} \{libavoid_communicator_id_or_null(src_id)} \{libavoid_communicator_id_or_null(tgt_id)} \{libavoid_communicator_id_or_null(src_port_id)} \{libavoid_communicator_id_or_null(tgt_port_id)}",
  )
  self.edge_id_counter = self.edge_id_counter + 1
}

///|
fn LibavoidServerCommunicator::determine_hierarchical_node_id(
  self : LibavoidServerCommunicator,
  port : ElkPort,
) -> Int {
  ignore(self)
  let side = libavoid_communicator_port_side_or_undefined(port)
  if side == "NORTH" {
    libavoid_communicator_node_compound_north
  } else if side == "EAST" {
    libavoid_communicator_node_compound_east
  } else if side == "SOUTH" {
    libavoid_communicator_node_compound_south
  } else {
    libavoid_communicator_node_compound_west
  }
}
