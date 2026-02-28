///|
pub struct LibavoidLayoutProvider {
  parent_node_to_server : Map[@graph.ElkNode, LibavoidServer]
  comm : LibavoidServerCommunicator
}

///|
pub fn new_libavoid_layout_provider() -> LibavoidLayoutProvider {
  { parent_node_to_server: {}, comm: new_libavoid_server_communicator() }
}

///|
fn libavoid_layout_provider_port_side_for_direction(
  direction : String,
) -> String {
  if direction == "RIGHT" {
    "EAST"
  } else if direction == "LEFT" {
    "WEST"
  } else if direction == "DOWN" {
    "SOUTH"
  } else if direction == "UP" {
    "NORTH"
  } else {
    "WEST"
  }
}

///|
fn libavoid_layout_provider_detect_port_side(
  node : @graph.ElkNode,
  port : @graph.ElkPort,
  direction : String,
) -> String {
  let node_w = @graph.node_width(node)
  let node_h = @graph.node_height(node)
  if node_w <= 0.0 || node_h <= 0.0 {
    return libavoid_layout_provider_port_side_for_direction(direction)
  }

  let center_x = @graph.port_x(port) + @graph.port_width(port) / 2.0
  let center_y = @graph.port_y(port) + @graph.port_height(port) / 2.0
  let left_distance = center_x.abs()
  let right_distance = (node_w - center_x).abs()
  let top_distance = center_y.abs()
  let bottom_distance = (node_h - center_y).abs()

  let mut best_distance = left_distance
  let mut best_side = "WEST"
  if right_distance < best_distance {
    best_distance = right_distance
    best_side = "EAST"
  }
  if top_distance < best_distance {
    best_distance = top_distance
    best_side = "NORTH"
  }
  if bottom_distance < best_distance {
    best_side = "SOUTH"
  }
  best_side
}

///|
pub fn LibavoidLayoutProvider::prepare_graph(
  self : LibavoidLayoutProvider,
  parent_node : @graph.ElkNode,
) -> Unit {
  ignore(self)
  let direction = @graph.node_get_string_property(
    parent_node, libavoid_option_direction,
  )
  for node in @graph.node_children(parent_node) {
    for port in @graph.node_ports(node) {
      let side = match
        @graph.port_layout_option_string_value(port, @core.port_side.get_id()) {
        Some(value) => value
        None => "UNDEFINED"
      }
      if side == "UNDEFINED" {
        let computed = libavoid_layout_provider_detect_port_side(
          node, port, direction,
        )
        @graph.port_set_layout_option_string_by_id(
          port,
          @core.port_side.get_id(),
          computed,
        )
      }
    }
  }
}

///|
pub fn LibavoidLayoutProvider::layout(
  self : LibavoidLayoutProvider,
  parent_node : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit {
  ignore(progress_monitor)
  self.prepare_graph(parent_node)
  let server_pool = libavoid_server_pool_instance()
  let lv_server = server_pool.fetch()
  self.parent_node_to_server[parent_node] = lv_server
  self.comm.request_layout(parent_node, progress_monitor, lv_server)
  ignore(self.parent_node_to_server.remove(parent_node))
  server_pool.release(lv_server)
}

///|
pub fn LibavoidLayoutProvider::cancel_layouting(
  self : LibavoidLayoutProvider,
  parent_node : @graph.ElkNode,
) -> Bool {
  match self.parent_node_to_server.get(parent_node) {
    Some(server) => {
      ignore(self.parent_node_to_server.remove(parent_node))
      server.cancel_process()
      true
    }
    None => false
  }
}

///|
pub fn LibavoidLayoutProvider::register_server_for_test(
  self : LibavoidLayoutProvider,
  parent_node : @graph.ElkNode,
  server : LibavoidServer,
) -> Unit {
  self.parent_node_to_server[parent_node] = server
}

///|
pub fn libavoid_layout_provider_as_layout_provider(
  provider : LibavoidLayoutProvider,
) -> @core.AbstractLayoutProvider {
  @core.new_abstract_layout_provider((graph, monitor) => {
    provider.layout(graph, monitor)
  })
}
