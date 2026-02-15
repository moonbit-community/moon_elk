///|
let hierarchical_node_resizing_processor_default_min_width = 20.0

///|
let hierarchical_node_resizing_processor_default_min_height = 20.0

///|
fn hierarchical_node_resizing_processor_graph_property_equals(
  left : GraphProperties,
  right : GraphProperties,
) -> Bool {
  match (left, right) {
    (Comments, Comments) => true
    (ExternalPorts, ExternalPorts) => true
    (Hyperedges, Hyperedges) => true
    (Hypernodes, Hypernodes) => true
    (NonFreePorts, NonFreePorts) => true
    (NorthSouthPorts, NorthSouthPorts) => true
    (SelfLoops, SelfLoops) => true
    (CenterLabels, CenterLabels) => true
    (EndLabels, EndLabels) => true
    (Partitions, Partitions) => true
    _ => false
  }
}

///|
fn hierarchical_node_resizing_processor_graph_properties_contain(
  properties : Array[GraphProperties],
  property : GraphProperties,
) -> Bool {
  for candidate in properties {
    if hierarchical_node_resizing_processor_graph_property_equals(
        candidate, property,
      ) {
      return true
    }
  }
  false
}

///|
fn hierarchical_node_resizing_processor_string_set_contains(
  values : Array[String],
  value : String,
) -> Bool {
  for item in values {
    if item == value {
      return true
    }
  }
  false
}

///|
fn hierarchical_node_resizing_processor_resize_node(
  node : LNode,
  new_size : KVector,
  move_ports : Bool,
  move_labels : Bool,
) -> Unit {
  let old_size = new_kvector_copy(node.get_size())
  let width_ratio = new_size.x / old_size.x
  let height_ratio = new_size.y / old_size.y
  let width_diff = new_size.x - old_size.x
  let height_diff = new_size.y - old_size.y

  if move_ports {
    let fixed_ports = node.get_property_string(port_constraints) == "FIXED_POS"
    for port in node.get_ports() {
      match port.get_side() {
        North =>
          if !fixed_ports {
            port.get_position().x = port.get_position().x * width_ratio
          }
        East => {
          port.get_position().x = port.get_position().x + width_diff
          if !fixed_ports {
            port.get_position().y = port.get_position().y * height_ratio
          }
        }
        South => {
          if !fixed_ports {
            port.get_position().x = port.get_position().x * width_ratio
          }
          port.get_position().y = port.get_position().y + height_diff
        }
        West =>
          if !fixed_ports {
            port.get_position().y = port.get_position().y * height_ratio
          }
        SideUndefined => ()
      }
    }
  }

  if move_labels {
    for label in node.get_labels() {
      let midx = label.get_position().x + label.get_size().x / 2.0
      let midy = label.get_position().y + label.get_size().y / 2.0
      let width_percent = midx / old_size.x
      let height_percent = midy / old_size.y

      if width_percent + height_percent >= 1.0 {
        if width_percent - height_percent > 0.0 && midy >= 0.0 {
          label.get_position().x = label.get_position().x + width_diff
          label.get_position().y = label.get_position().y +
            height_diff * height_percent
        } else if width_percent - height_percent < 0.0 && midx >= 0.0 {
          label.get_position().x = label.get_position().x +
            width_diff * width_percent
          label.get_position().y = label.get_position().y + height_diff
        }
      }
    }
  }

  node.get_size().x = new_size.x
  node.get_size().y = new_size.y
  node.set_property_string_array(node_size_constraints, ["FIXED"])
}

///|
fn hierarchical_node_resizing_processor_get_external_port_position(
  graph : LGraph,
  port_dummy : LNode,
  port_width : Double,
  port_height : Double,
) -> KVector {
  let port_position = new_kvector_copy(port_dummy.get_position())
  port_position.x = port_position.x + port_dummy.get_size().x / 2.0
  port_position.y = port_position.y + port_dummy.get_size().y / 2.0
  let port_offset = port_dummy.get_property_double(
    layered_options_port_border_offset,
  )

  let graph_size = graph.get_size()
  let padding = graph.get_padding()
  let graph_offset = graph.get_offset()

  match port_dummy.get_property_port_side(internal_properties_ext_port_side) {
    North => {
      port_position.x = port_position.x +
        padding.left +
        graph_offset.x -
        port_width / 2.0
      port_position.y = -port_height - port_offset
      port_dummy.get_position().y = -(padding.top + port_offset + graph_offset.y)
    }
    East => {
      port_position.x = graph_size.x +
        padding.left +
        padding.right +
        port_offset
      port_position.y = port_position.y +
        padding.top +
        graph_offset.y -
        port_height / 2.0
      port_dummy.get_position().x = graph_size.x +
        padding.right +
        port_offset -
        graph_offset.x
    }
    South => {
      port_position.x = port_position.x +
        padding.left +
        graph_offset.x -
        port_width / 2.0
      port_position.y = graph_size.y +
        padding.top +
        padding.bottom +
        port_offset
      port_dummy.get_position().y = graph_size.y +
        padding.bottom +
        port_offset -
        graph_offset.y
    }
    West => {
      port_position.x = -port_width - port_offset
      port_position.y = port_position.y +
        padding.top +
        graph_offset.y -
        port_height / 2.0
      port_dummy.get_position().x = -(padding.left +
        port_offset +
        graph_offset.x)
    }
    SideUndefined => ()
  }

  port_position
}

///|
fn hierarchical_node_resizing_processor_graph_layout_to_node(
  node : LNode,
  lgraph : LGraph,
) -> Unit {
  for child_node in lgraph.get_layerless_nodes() {
    if child_node.has_property_l_port(internal_properties_origin_l_port) {
      match child_node.get_property_l_port(internal_properties_origin_l_port) {
        Some(port) => {
          let port_position = hierarchical_node_resizing_processor_get_external_port_position(
            lgraph,
            child_node,
            port.get_size().x,
            port.get_size().y,
          )
          port.get_position().x = port_position.x
          port.get_position().y = port_position.y
          port.set_side(
            child_node.get_property_port_side(internal_properties_ext_port_side),
          )
        }
        None => ()
      }
    }
  }

  let actual_graph_size = lgraph.get_actual_size()
  let graph_properties = lgraph.get_property_graph_properties_array(
    internal_properties_graph_properties,
  )
  if hierarchical_node_resizing_processor_graph_properties_contain(
      graph_properties,
      ExternalPorts,
    ) {
    node.set_property_string(port_constraints, "FIXED_POS")

    let parent_graph_properties = node
      .get_graph()
      .get_property_graph_properties_array(internal_properties_graph_properties)
    if !hierarchical_node_resizing_processor_graph_properties_contain(
        parent_graph_properties,
        NonFreePorts,
      ) {
      parent_graph_properties.push(NonFreePorts)
      node
      .get_graph()
      .set_property_graph_properties_array(
        internal_properties_graph_properties, parent_graph_properties,
      )
    }

    hierarchical_node_resizing_processor_resize_node(
      node, actual_graph_size, false, true,
    )
  } else {
    hierarchical_node_resizing_processor_resize_node(
      node, actual_graph_size, true, true,
    )
  }
}

///|
fn hierarchical_node_resizing_processor_resize_graph(lgraph : LGraph) -> Unit {
  let size_constraint = lgraph.get_property_string_array(node_size_constraints)
  let size_options = lgraph.get_property_string_array(node_size_options)

  let calculated_size = lgraph.get_actual_size()
  let adjusted_size = new_kvector_copy(calculated_size)

  if hierarchical_node_resizing_processor_string_set_contains(
      size_constraint, "MINIMUM_SIZE",
    ) {
    let min_size = new_kvector()
    min_size.parse(lgraph.get_property_string(node_size_minimum))

    if hierarchical_node_resizing_processor_string_set_contains(
        size_options, "DEFAULT_MINIMUM_SIZE",
      ) {
      if min_size.x <= 0.0 {
        min_size.x = hierarchical_node_resizing_processor_default_min_width
      }
      if min_size.y <= 0.0 {
        min_size.y = hierarchical_node_resizing_processor_default_min_height
      }
    }

    adjusted_size.x = if calculated_size.x > min_size.x {
      calculated_size.x
    } else {
      min_size.x
    }
    adjusted_size.y = if calculated_size.y > min_size.y {
      calculated_size.y
    } else {
      min_size.y
    }
  }

  hierarchical_node_resizing_processor_resize_graph_no_really_i_mean_it(
    lgraph, calculated_size, adjusted_size,
  )
}

///|
fn hierarchical_node_resizing_processor_resize_graph_no_really_i_mean_it(
  lgraph : LGraph,
  old_size : KVector,
  new_size : KVector,
) -> Unit {
  let content_alignment_values = lgraph.get_property_string_array(
    content_alignment,
  )

  if new_size.x > old_size.x {
    if hierarchical_node_resizing_processor_string_set_contains(
        content_alignment_values, "H_CENTER",
      ) {
      lgraph.get_offset().x = lgraph.get_offset().x +
        (new_size.x - old_size.x) / 2.0
    } else if hierarchical_node_resizing_processor_string_set_contains(
        content_alignment_values, "H_RIGHT",
      ) {
      lgraph.get_offset().x = lgraph.get_offset().x + (new_size.x - old_size.x)
    }
  }

  if new_size.y > old_size.y {
    if hierarchical_node_resizing_processor_string_set_contains(
        content_alignment_values, "V_CENTER",
      ) {
      lgraph.get_offset().y = lgraph.get_offset().y +
        (new_size.y - old_size.y) / 2.0
    } else if hierarchical_node_resizing_processor_string_set_contains(
        content_alignment_values, "V_BOTTOM",
      ) {
      lgraph.get_offset().y = lgraph.get_offset().y + (new_size.y - old_size.y)
    }
  }

  let graph_properties = lgraph.get_property_graph_properties_array(
    internal_properties_graph_properties,
  )
  if hierarchical_node_resizing_processor_graph_properties_contain(
      graph_properties,
      ExternalPorts,
    ) &&
    (new_size.x > old_size.x || new_size.y > old_size.y) {
    for node in lgraph.get_layerless_nodes() {
      match node.get_type() {
        ExternalPort =>
          match node.get_property_port_side(internal_properties_ext_port_side) {
            East =>
              node.get_position().x = node.get_position().x +
                (new_size.x - old_size.x)
            South =>
              node.get_position().y = node.get_position().y +
                (new_size.y - old_size.y)
            _ => ()
          }
        _ => ()
      }
    }
  }

  let padding = lgraph.get_padding()
  lgraph.get_size().x = new_size.x - padding.left - padding.right
  lgraph.get_size().y = new_size.y - padding.top - padding.bottom
}

///|
fn hierarchical_node_resizing_processor_process(
  graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Resize child graph to fit parent.", 1.0))

  for layer in graph.get_layers() {
    let nodes = layer.get_nodes().copy()
    for node in nodes {
      graph.get_layerless_nodes().push(node)
    }
    layer.get_nodes().clear()
  }

  for node in graph.get_layerless_nodes() {
    node.set_layer(None)
  }
  graph.get_layers().clear()

  hierarchical_node_resizing_processor_resize_graph(graph)

  match graph.get_parent_node() {
    Some(parent_node) =>
      hierarchical_node_resizing_processor_graph_layout_to_node(
        parent_node, graph,
      )
    None => ()
  }

  monitor.done()
}

///|
pub fn new_hierarchical_node_resizing_processor_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(hierarchical_node_resizing_processor_process)
}
