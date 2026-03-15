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
  node_id_map : Map[Int, @graph.ElkNode]
  node_inverse_map : Map[@graph.ElkNode, Int]
  port_id_map : Map[Int, @graph.ElkPort]
  port_inverse_map : Map[@graph.ElkPort, Int]
  edge_id_map : Map[Int, @graph.ElkEdge]
  edge_inverse_map : Map[@graph.ElkEdge, Int]
  mut node_id_counter : Int
  mut port_id_counter : Int
  mut edge_id_counter : Int
  lines : Array[String]
}

///|
pub suberror LibavoidCommunicatorException {
  LibavoidCommunicatorException(String)
} derive(Show, ToJson)

///|
fn[T] libavoid_communicator_raise(
  message : String,
) -> T raise LibavoidCommunicatorException {
  raise LibavoidCommunicatorException(message)
}

///|
fn libavoid_communicator_exception_message(
  err : LibavoidCommunicatorException,
) -> String {
  match err {
    LibavoidCommunicatorException(message) => message
  }
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
  monitor : @core.IElkProgressMonitor,
  work : Double,
) -> @core.IElkProgressMonitor {
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
fn libavoid_communicator_shape_to_node(
  shape : @graph.ElkConnectableShape,
) -> @graph.ElkNode? {
  try @graph.connectable_shape_to_node(Some(shape)) catch {
    _ => None
  } noraise {
    value => Some(value)
  }
}

///|
fn libavoid_communicator_shape_to_port(
  shape : @graph.ElkConnectableShape,
) -> @graph.ElkPort? {
  try @graph.connectable_shape_to_port(Some(shape)) catch {
    _ => None
  } noraise {
    value => value
  }
}

///|
fn libavoid_communicator_process_timeout_of(
  layout_node : @graph.ElkNode,
) -> Int {
  let timeout_text = match
    @graph.node_layout_option_string_value(
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
  layout_node : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
  lv_server : LibavoidServer,
) -> Unit {
  try self.request_layout_impl(layout_node, progress_monitor, lv_server) catch {
    err => {
      @core.layout_runtime_report_unsupported_configuration(
        libavoid_communicator_exception_message(err),
      )
      if lv_server.is_running() {
        lv_server.cleanup(libavoid_server_cleanup_error())
      }
      if progress_monitor.is_running() {
        progress_monitor.done()
      }
      self.reset()
    }
  } noraise {
    _ => ()
  }
}

///|
fn LibavoidServerCommunicator::request_layout_impl(
  self : LibavoidServerCommunicator,
  layout_node : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
  lv_server : LibavoidServer,
) -> Unit raise LibavoidCommunicatorException {
  self.reset()
  ignore(
    progress_monitor.begin("Libavoid Layout", libavoid_communicator_layout_work),
  )
  if @graph.node_children(layout_node).is_empty() {
    progress_monitor.done()
    return
  }

  lv_server.initialize()
  lv_server.set_process_timeout(
    libavoid_communicator_process_timeout_of(layout_node),
  )
  let output_stream = try lv_server.input() catch {
    err =>
      libavoid_communicator_raise(libavoid_server_state_exception_message(err))
  } noraise {
    stream => stream
  }
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
  edge : @graph.ElkEdge,
) -> @graph.ElkEdgeSection {
  let sections = @graph.edge_sections(edge)
  let section = if sections.is_empty() {
    @graph.create_edge_section(edge)
  } else {
    sections[0]
  }
  if @graph.edge_section_incoming_shape(section) is None {
    let sources = @graph.edge_sources(edge)
    if sources.length() == 1 {
      @graph.edge_section_set_incoming_shape(section, Some(sources[0]))
    }
  }
  if @graph.edge_section_outgoing_shape(section) is None {
    let targets = @graph.edge_targets(edge)
    if targets.length() == 1 {
      @graph.edge_section_set_outgoing_shape(section, Some(targets[0]))
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
fn libavoid_communicator_parse_point_list(value : String) -> @core.KVectorChain {
  let tokens : Array[String] = []
  for token in value.split(" ") {
    let normalized = token.trim().to_string()
    if !normalized.is_empty() {
      tokens.push(normalized)
    }
  }
  let points = @core.new_kvector_chain()
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
fn libavoid_communicator_padding_of(node : @graph.ElkNode) -> @core.ElkPadding {
  let parsed = @core.new_elk_padding()
  parsed.parse(@graph.node_get_string_property(node, @core.padding))
  parsed
}

///|
fn LibavoidServerCommunicator::apply_layout(
  self : LibavoidServerCommunicator,
  parent_node : @graph.ElkNode,
  layout_information : Map[String, @core.KVectorChain],
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit raise LibavoidCommunicatorException {
  ignore(
    progress_monitor.begin("Apply layout", libavoid_communicator_subtask_work),
  )
  let mut max_x = 0.0
  let mut max_y = 0.0

  layout_information.each((key, points) => {
    if points.size() < 2 {
      libavoid_communicator_raise(
        "An edge retrieved from Libavoid has less than 2 points.",
      )
    }

    let edge_id = match libavoid_communicator_edge_id_from_key(key) {
      Some(value) => value
      None =>
        libavoid_communicator_raise(
          "Failed to determine edge id from Libavoid output.",
        )
    }
    let edge = match self.edge_id_map.get(edge_id) {
      Some(value) => value
      None =>
        libavoid_communicator_raise(
          "A problem within the edge mapping occured. Could not determine edge for id \{edge_id}.",
        )
    }
    let section = libavoid_communicator_first_or_create_edge_section(edge)
    let first_point = points.get(0)
    let last_point = points.get(points.size() - 1)
    @graph.edge_section_set_start(section, first_point.x, first_point.y)
    @graph.edge_section_set_end(section, last_point.x, last_point.y)

    for point in points.to_array() {
      max_x = @cmp.maximum(max_x, point.x)
      max_y = @cmp.maximum(max_y, point.y)
    }
  })

  for node in @graph.node_children(parent_node) {
    max_x = @cmp.maximum(max_x, @graph.node_x(node) + @graph.node_width(node))
    max_y = @cmp.maximum(max_y, @graph.node_y(node) + @graph.node_height(node))
  }

  let node_padding = libavoid_communicator_padding_of(parent_node)
  if @graph.node_width(parent_node) < max_x {
    @graph.node_set_dimensions(
      parent_node,
      max_x + node_padding.get_right(),
      @graph.node_height(parent_node),
    )
  }
  if @graph.node_height(parent_node) < max_y {
    @graph.node_set_dimensions(
      parent_node,
      @graph.node_width(parent_node),
      max_y + node_padding.get_bottom(),
    )
  }

  progress_monitor.done()
}

///|
fn LibavoidServerCommunicator::calculate_junction_points(
  self : LibavoidServerCommunicator,
  graph : @graph.ElkNode,
) -> Unit {
  ignore(self)
  let visited : Map[@graph.ElkEdge, Unit] = {}
  for node in @graph.node_children(graph) {
    for edge in @graph.node_outgoing_edges(node) {
      if !visited.contains(edge) {
        @graph.edge_set_layout_option_string_by_id(
          edge, libavoid_option_junction_points_id, "()",
        )
        visited[edge] = ()
      }
    }
    for port in @graph.node_ports(node) {
      for edge in @graph.port_outgoing_edges(port) {
        if !visited.contains(edge) {
          @graph.edge_set_layout_option_string_by_id(
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
  progress_monitor : @core.IElkProgressMonitor,
) -> Map[String, @core.KVectorChain] raise LibavoidCommunicatorException {
  ignore(self)
  ignore(progress_monitor.begin("Read output from Libavoid", 1.0))
  let output_data = try libavoid_server.read_output_data() catch {
    err =>
      libavoid_communicator_raise(libavoid_server_state_exception_message(err))
  } noraise {
    output => output
  }
  let layout_information : Map[String, @core.KVectorChain] = {}
  match output_data {
    Some(data) =>
      data.each((key, value) => {
        layout_information[key] = libavoid_communicator_parse_point_list(value)
      })
    None => {
      libavoid_server.cleanup(libavoid_server_cleanup_error())
      libavoid_communicator_raise(
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
  root : @graph.ElkNode,
  stream : @layouter.GraphvizOutputStream,
) -> Unit {
  self.transform_options(root)
  if @graph.node_get_bool_property(root, libavoid_option_debug_mode) {
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
  if id.has_prefix("org.eclipse.elk.alg.libavoid.") {
    id["org.eclipse.elk.alg.libavoid.".length():].to_string()
  } else if id.has_prefix("org.eclipse.elk.") {
    id["org.eclipse.elk.".length():].to_string()
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
  node : @graph.ElkNode,
) -> Unit {
  let edge_routing = @graph.node_get_string_property(
    node, libavoid_option_edge_routing,
  )
  if edge_routing != "UNDEFINED" {
    self.add_option_line(
      libavoid_option_edge_routing.get_id(),
      Some(edge_routing),
    )
  }

  let node_direction = @graph.node_get_string_property(
    node, libavoid_option_direction,
  )
  if node_direction != "UNDEFINED" {
    self.add_option_line(
      libavoid_option_direction.get_id(),
      Some(node_direction),
    )
  }

  self.add_option_line(
    libavoid_option_enable_hyperedges_from_common_source.get_id(),
    Some(
      @graph.node_get_bool_property(
        node, libavoid_option_enable_hyperedges_from_common_source,
      ).to_string(),
    ),
  )

  self.add_penalty_line(
    libavoid_option_segment_penalty.get_id(),
    @graph.node_get_double_property(node, libavoid_option_segment_penalty),
  )
  self.add_penalty_line(
    libavoid_option_angle_penalty.get_id(),
    @graph.node_get_double_property(node, libavoid_option_angle_penalty),
  )
  self.add_penalty_line(
    libavoid_option_crossing_penalty.get_id(),
    @graph.node_get_double_property(node, libavoid_option_crossing_penalty),
  )
  self.add_penalty_line(
    libavoid_option_cluster_crossing_penalty.get_id(),
    @graph.node_get_double_property(
      node, libavoid_option_cluster_crossing_penalty,
    ),
  )
  self.add_penalty_line(
    libavoid_option_fixed_shared_path_penalty.get_id(),
    @graph.node_get_double_property(
      node, libavoid_option_fixed_shared_path_penalty,
    ),
  )
  self.add_penalty_line(
    libavoid_option_port_direction_penalty.get_id(),
    @graph.node_get_double_property(
      node, libavoid_option_port_direction_penalty,
    ),
  )
  self.add_penalty_line(
    libavoid_option_shape_buffer_distance.get_id(),
    @graph.node_get_double_property(node, libavoid_option_shape_buffer_distance),
  )
  self.add_penalty_line(
    libavoid_option_ideal_nudging_distance.get_id(),
    @graph.node_get_double_property(
      node, libavoid_option_ideal_nudging_distance,
    ),
  )
  self.add_penalty_line(
    libavoid_option_reverse_direction_penalty.get_id(),
    @graph.node_get_double_property(
      node, libavoid_option_reverse_direction_penalty,
    ),
  )

  self.add_routing_option_line(
    libavoid_option_nudge_orthogonal_segments_connected_to_shapes.get_id(),
    @graph.node_get_bool_property(
      node, libavoid_option_nudge_orthogonal_segments_connected_to_shapes,
    ),
  )
  self.add_routing_option_line(
    libavoid_option_improve_hyperedge_routes_moving_junctions.get_id(),
    @graph.node_get_bool_property(
      node, libavoid_option_improve_hyperedge_routes_moving_junctions,
    ),
  )
  self.add_routing_option_line(
    libavoid_option_penalise_orthogonal_shared_paths_at_conn_ends.get_id(),
    @graph.node_get_bool_property(
      node, libavoid_option_penalise_orthogonal_shared_paths_at_conn_ends,
    ),
  )
  self.add_routing_option_line(
    libavoid_option_nudge_orthogonal_touching_colinear_segments.get_id(),
    @graph.node_get_bool_property(
      node, libavoid_option_nudge_orthogonal_touching_colinear_segments,
    ),
  )
  self.add_routing_option_line(
    libavoid_option_perform_unifying_nudging_preprocessing_step.get_id(),
    @graph.node_get_bool_property(
      node, libavoid_option_perform_unifying_nudging_preprocessing_step,
    ),
  )
  self.add_routing_option_line(
    libavoid_option_improve_hyperedge_routes_moving_adding_and_deleting_junctions.get_id(),
    @graph.node_get_bool_property(
      node, libavoid_option_improve_hyperedge_routes_moving_adding_and_deleting_junctions,
    ),
  )
  self.add_routing_option_line(
    libavoid_option_nudge_shared_paths_with_common_end_point.get_id(),
    @graph.node_get_bool_property(
      node, libavoid_option_nudge_shared_paths_with_common_end_point,
    ),
  )
}

///|
fn libavoid_communicator_node_parent_is(
  node : @graph.ElkNode,
  parent : @graph.ElkNode,
) -> Bool {
  match @graph.node_parent(node) {
    Some(node_parent_value) => node_parent_value == parent
    None => false
  }
}

///|
fn LibavoidServerCommunicator::transform_graph(
  self : LibavoidServerCommunicator,
  root : @graph.ElkNode,
) -> Unit {
  self.emit_line("GRAPH")

  if @graph.node_parent(root) is Some(_) {
    self.transform_hierarchical_parent(root)
  } else {
    self.transform_hierarchical_parent_dummy(root)
  }

  for node in @graph.node_children(root) {
    self.transform_node(node)
  }

  for node in @graph.node_children(root) {
    for edge in @graph.node_outgoing_edges(node) {
      if !self.is_hierarchical_edge(edge, root) || self.is_cluster_edge(edge) {
        self.transform_edge_if_new(edge)
      }
    }
    for port in @graph.node_ports(node) {
      for edge in @graph.port_outgoing_edges(port) {
        if !self.is_hierarchical_edge(edge, root) || self.is_cluster_edge(edge) {
          self.transform_edge_if_new(edge)
        }
      }
    }
  }

  for port in @graph.node_ports(root) {
    for edge in @graph.port_incoming_edges(port) {
      self.transform_hierarchical_port_edge_if_relevant(root, edge)
    }
    for edge in @graph.port_outgoing_edges(port) {
      self.transform_hierarchical_port_edge_if_relevant(root, edge)
    }
  }

  self.emit_line("GRAPHEND")
}

///|
fn LibavoidServerCommunicator::transform_hierarchical_port_edge_if_relevant(
  self : LibavoidServerCommunicator,
  root : @graph.ElkNode,
  edge : @graph.ElkEdge,
) -> Unit {
  let sources = @graph.edge_sources(edge)
  let targets = @graph.edge_targets(edge)
  if sources.is_empty() || targets.is_empty() {
    return
  }
  let src_node = match libavoid_communicator_shape_to_node(sources[0]) {
    Some(node) => node
    None => return
  }
  let tgt_node = match libavoid_communicator_shape_to_node(targets[0]) {
    Some(node) => node
    None => return
  }
  if libavoid_communicator_node_parent_is(src_node, root) ||
    libavoid_communicator_node_parent_is(tgt_node, root) {
    self.transform_edge_if_new(edge)
  }
}

///|
fn LibavoidServerCommunicator::is_hierarchical_edge(
  self : LibavoidServerCommunicator,
  edge : @graph.ElkEdge,
  root : @graph.ElkNode,
) -> Bool {
  ignore(self)
  let sources = @graph.edge_sources(edge)
  let targets = @graph.edge_targets(edge)
  if sources.is_empty() || targets.is_empty() {
    return false
  }
  let src_node = match libavoid_communicator_shape_to_node(sources[0]) {
    Some(node) => node
    None => return false
  }
  let tgt_node = match libavoid_communicator_shape_to_node(targets[0]) {
    Some(node) => node
    None => return false
  }
  !(libavoid_communicator_node_parent_is(src_node, root) &&
  libavoid_communicator_node_parent_is(tgt_node, root))
}

///|
fn LibavoidServerCommunicator::is_cluster_edge(
  self : LibavoidServerCommunicator,
  edge : @graph.ElkEdge,
) -> Bool {
  ignore(self)
  let sources = @graph.edge_sources(edge)
  let targets = @graph.edge_targets(edge)
  if sources.is_empty() || targets.is_empty() {
    return false
  }
  let src_node = match libavoid_communicator_shape_to_node(sources[0]) {
    Some(node) => node
    None => return false
  }
  let tgt_node = match libavoid_communicator_shape_to_node(targets[0]) {
    Some(node) => node
    None => return false
  }

  let src_parent_is_cluster = match @graph.node_parent(src_node) {
    Some(parent) =>
      @graph.node_has_bool_property(parent, libavoid_option_is_cluster)
    None => false
  }
  let tgt_parent_is_cluster = match @graph.node_parent(tgt_node) {
    Some(parent) =>
      @graph.node_has_bool_property(parent, libavoid_option_is_cluster)
    None => false
  }
  src_parent_is_cluster || tgt_parent_is_cluster
}

///|
fn LibavoidServerCommunicator::transform_hierarchical_parent(
  self : LibavoidServerCommunicator,
  parent : @graph.ElkNode,
) -> Unit {
  let buffer_distance = @graph.node_get_double_property(
    parent, libavoid_option_shape_buffer_distance,
  )
  self.libavoid_node(
    parent,
    libavoid_communicator_node_compound_north,
    0.0,
    0.0 -
    libavoid_communicator_surrounding_rect_size.to_double() -
    buffer_distance,
    @graph.node_width(parent),
    libavoid_communicator_surrounding_rect_size.to_double(),
    0,
    0,
  )
  self.libavoid_node(
    parent,
    libavoid_communicator_node_compound_east,
    @graph.node_width(parent) + buffer_distance,
    0.0,
    libavoid_communicator_surrounding_rect_size.to_double(),
    @graph.node_height(parent),
    0,
    0,
  )
  self.libavoid_node(
    parent,
    libavoid_communicator_node_compound_south,
    0.0,
    @graph.node_height(parent) + buffer_distance,
    @graph.node_width(parent),
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
    @graph.node_height(parent),
    0,
    0,
  )

  for port in @graph.node_ports(parent) {
    let node_id = self.determine_hierarchical_node_id(port)
    self.libavoid_port(port, self.port_id_counter, node_id, Some(parent))
    self.port_id_counter = self.port_id_counter + 1
  }
}

///|
fn LibavoidServerCommunicator::transform_hierarchical_parent_dummy(
  self : LibavoidServerCommunicator,
  root : @graph.ElkNode,
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
  node : @graph.ElkNode,
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
  node : @graph.ElkNode,
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
fn libavoid_communicator_port_side_or_undefined(
  port : @graph.ElkPort,
) -> String {
  match @graph.port_layout_option_string_value(port, @core.port_side.get_id()) {
    Some(value) => value
    None => "UNDEFINED"
  }
}

///|
fn LibavoidServerCommunicator::libavoid_port(
  self : LibavoidServerCommunicator,
  port : @graph.ElkPort,
  port_id : Int,
  node_id : Int,
  compound_node : @graph.ElkNode?,
) -> Unit {
  self.port_id_map[port_id] = port
  self.port_inverse_map[port] = port_id

  let mut side = libavoid_communicator_port_side_or_undefined(port)
  if compound_node is Some(_) {
    side = libavoid_communicator_opposed_side(side)
  }

  let center_x = @graph.port_x(port) + @graph.port_width(port) / 2.0
  let center_y = @graph.port_y(port) + @graph.port_height(port) / 2.0
  self.emit_line("PORT \{port_id} \{node_id} \{side} \{center_x} \{center_y}")
}

///|
fn LibavoidServerCommunicator::transform_node(
  self : LibavoidServerCommunicator,
  node : @graph.ElkNode,
) -> Unit {
  if self.is_cluster(node) {
    self.transform_cluster(node)
  } else {
    self.transform_node_at(node, @graph.node_x(node), @graph.node_y(node))
  }
}

///|
fn LibavoidServerCommunicator::is_cluster(
  self : LibavoidServerCommunicator,
  node : @graph.ElkNode,
) -> Bool {
  ignore(self)
  let cluster_marked = @graph.node_get_bool_property(
    node, libavoid_option_is_cluster,
  )
  if !cluster_marked {
    return false
  }
  let parent_not_cluster = match @graph.node_parent(node) {
    Some(parent) =>
      !@graph.node_get_bool_property(parent, libavoid_option_is_cluster)
    None => false
  }
  parent_not_cluster &&
  @graph.node_outgoing_edges(node).is_empty() &&
  @graph.node_incoming_edges(node).is_empty() &&
  @graph.node_ports(node).is_empty()
}

///|
fn LibavoidServerCommunicator::transform_node_at(
  self : LibavoidServerCommunicator,
  node : @graph.ElkNode,
  x : Double,
  y : Double,
) -> Unit {
  let port_less_incoming_edges = @graph.node_incoming_edges(node).length()
  let port_less_outgoing_edges = @graph.node_outgoing_edges(node).length()
  self.libavoid_node(
    node,
    self.node_id_counter,
    x,
    y,
    @graph.node_width(node),
    @graph.node_height(node),
    port_less_incoming_edges,
    port_less_outgoing_edges,
  )
  for port in @graph.node_ports(node) {
    self.libavoid_port(port, self.port_id_counter, self.node_id_counter, None)
    self.port_id_counter = self.port_id_counter + 1
  }
  self.node_id_counter = self.node_id_counter + 1
}

///|
fn LibavoidServerCommunicator::transform_cluster(
  self : LibavoidServerCommunicator,
  node : @graph.ElkNode,
) -> Unit {
  self.libavoid_cluster(
    node,
    self.node_id_counter,
    @graph.node_x(node),
    @graph.node_y(node),
    @graph.node_width(node),
    @graph.node_height(node),
  )
  self.node_id_counter = self.node_id_counter + 1

  let x = @graph.node_x(node)
  let y = @graph.node_y(node)
  for child in @graph.node_children(node) {
    self.transform_node_at(
      child,
      @graph.node_x(child) + x,
      @graph.node_x(child) + y,
    )
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
  edge : @graph.ElkEdge,
) -> Unit {
  if self.edge_inverse_map.contains(edge) {
    return
  }
  self.transform_edge(edge)
}

///|
fn LibavoidServerCommunicator::transform_edge(
  self : LibavoidServerCommunicator,
  edge : @graph.ElkEdge,
) -> Unit {
  let sources = @graph.edge_sources(edge)
  let targets = @graph.edge_targets(edge)
  if sources.is_empty() || targets.is_empty() {
    return
  }

  self.edge_id_map[self.edge_id_counter] = edge
  self.edge_inverse_map[edge] = self.edge_id_counter

  let source_shape = sources[0]
  let target_shape = targets[0]
  let src_node = match libavoid_communicator_shape_to_node(source_shape) {
    Some(node) => node
    None => return
  }
  let tgt_node = match libavoid_communicator_shape_to_node(target_shape) {
    Some(node) => node
    None => return
  }
  let src_port = libavoid_communicator_shape_to_port(source_shape)
  let tgt_port = libavoid_communicator_shape_to_port(target_shape)

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
  port : @graph.ElkPort,
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
