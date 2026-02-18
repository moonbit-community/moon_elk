///|
let fixed_layout_provider_position_option_id : String = "org.eclipse.elk.position"

///|
let fixed_layout_provider_bend_points_option_id : String = "org.eclipse.elk.bendPoints"

///|
pub struct FixedLayoutProvider {
  initialized : Bool
}

///|
priv enum FixedLayoutProviderEdgeRouting {
  FixedLayoutProviderOrthogonalRouting
  FixedLayoutProviderOtherRouting
}

///|
fn fixed_layout_provider_max(a : Double, b : Double) -> Double {
  if a >= b {
    a
  } else {
    b
  }
}

///|
fn fixed_layout_provider_parse_edge_routing(
  layout_node : ElkNode,
) -> FixedLayoutProviderEdgeRouting {
  if node_get_string_property(layout_node, edge_routing).to_upper() ==
    "ORTHOGONAL" {
    FixedLayoutProviderOrthogonalRouting
  } else {
    FixedLayoutProviderOtherRouting
  }
}

///|
fn fixed_layout_provider_parse_padding(layout_node : ElkNode) -> ElkPadding {
  let parsed = new_elk_padding()
  parsed.parse(node_get_string_property(layout_node, padding))
  parsed
}

///|
fn fixed_layout_provider_parse_position(text : String?) -> KVector? {
  if text is Some(value) {
    let parsed = new_kvector()
    parsed.parse(value)
    Some(parsed)
  } else {
    None
  }
}

///|
fn fixed_layout_provider_parse_bend_points(text : String?) -> KVectorChain? {
  if text is Some(value) {
    let parsed = new_kvector_chain()
    parsed.parse(value)
    Some(parsed)
  } else {
    None
  }
}

///|
fn fixed_layout_provider_contains_constraint(
  constraints : Array[String],
  expected : String,
) -> Bool {
  for constraint in constraints {
    if constraint == expected {
      return true
    }
  }
  false
}

///|
fn fixed_layout_provider_apply_minimum_size(node : ElkNode) -> Unit {
  if !fixed_layout_provider_contains_constraint(
      node_get_string_set_property(node, node_size_constraints),
      "MINIMUM_SIZE",
    ) {
    return
  }
  let parsed_minimum = new_kvector()
  parsed_minimum.parse(node_get_string_property(node, node_size_minimum))
  if parsed_minimum.x > 0.0 && parsed_minimum.y > 0.0 {
    node_set_dimensions(node, parsed_minimum.x, parsed_minimum.y)
  }
}

///|
fn fixed_layout_provider_update_max(
  maxx : Ref[Double],
  maxy : Ref[Double],
  x : Double,
  y : Double,
) -> Unit {
  maxx.val = fixed_layout_provider_max(maxx.val, x)
  maxy.val = fixed_layout_provider_max(maxy.val, y)
}

///|
fn fixed_layout_provider_source_parent(edge : ElkEdge) -> ElkNode? {
  let sources = edge_sources(edge)
  if sources.is_empty() {
    None
  } else {
    node_parent(connectable_shape_to_node(Some(sources[0])))
  }
}

///|
fn fixed_layout_provider_process_edge(
  edge : ElkEdge,
  edge_routing_kind : FixedLayoutProviderEdgeRouting,
) -> KVector {
  ignore(edge_routing_kind)
  let maxv = new_kvector()
  let sources = edge_sources(edge)
  let targets = edge_targets(edge)
  if sources.is_empty() || targets.is_empty() {
    return maxv
  }

  let source_parent = node_parent(connectable_shape_to_node(Some(sources[0])))
  let target_parent = node_parent(connectable_shape_to_node(Some(targets[0])))
  let same_hierarchy = source_parent == target_parent

  if fixed_layout_provider_parse_bend_points(
      edge_layout_option_string_value(
        edge, fixed_layout_provider_bend_points_option_id,
      ),
    )
    is Some(bend_points) {
    if bend_points.size() >= 2 {
      let sections = edge_sections(edge)
      if sections.is_empty() {
        ignore(create_edge_section(edge))
      } else if sections.length() > 1 {
        let kept_section = sections[0]
        sections.clear()
        sections.push(kept_section)
      }
      let section = edge_sections(edge)[0]
      let start = bend_points.get(0)
      let end = bend_points.get(bend_points.size() - 1)
      edge_section_set_start(section, start.x, start.y)
      edge_section_set_end(section, end.x, end.y)
    }
  }

  if same_hierarchy {
    for edge_section in edge_sections(edge) {
      maxv.x = fixed_layout_provider_max(
        maxv.x,
        edge_section_start_x(edge_section),
      )
      maxv.y = fixed_layout_provider_max(
        maxv.y,
        edge_section_start_y(edge_section),
      )
      maxv.x = fixed_layout_provider_max(
        maxv.x,
        edge_section_end_x(edge_section),
      )
      maxv.y = fixed_layout_provider_max(
        maxv.y,
        edge_section_end_y(edge_section),
      )
    }
  }

  for label in edge_labels(edge) {
    if fixed_layout_provider_parse_position(
        label_layout_option_string_value(
          label, fixed_layout_provider_position_option_id,
        ),
      )
      is Some(position) {
      label_set_location(label, position.x, position.y)
    }
    if same_hierarchy {
      maxv.x = fixed_layout_provider_max(
        maxv.x,
        label_x(label) + label_width(label),
      )
      maxv.y = fixed_layout_provider_max(
        maxv.y,
        label_y(label) + label_height(label),
      )
    }
  }

  maxv
}

///|
fn fixed_layout_provider_generate_junction_points(edge : ElkEdge) -> Unit {
  ignore(edge)
}

///|
pub fn new_fixed_layout_provider() -> FixedLayoutProvider {
  { initialized: true }
}

///|
pub fn FixedLayoutProvider::layout(
  self : FixedLayoutProvider,
  layout_node : ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  ignore(self.initialized)
  ignore(progress_monitor.begin("Fixed Layout", 1.0))

  let edge_routing_kind = fixed_layout_provider_parse_edge_routing(layout_node)
  let maxx : Ref[Double] = Ref::new(0.0)
  let maxy : Ref[Double] = Ref::new(0.0)

  for node in node_children(layout_node) {
    if fixed_layout_provider_parse_position(
        node_layout_option_string_value(
          node, fixed_layout_provider_position_option_id,
        ),
      )
      is Some(position) {
      node_set_location(node, position.x, position.y)
      fixed_layout_provider_apply_minimum_size(node)
    }

    fixed_layout_provider_update_max(
      maxx,
      maxy,
      node_x(node) + node_width(node),
      node_y(node) + node_height(node),
    )

    for label in node_labels(node) {
      if fixed_layout_provider_parse_position(
          label_layout_option_string_value(
            label, fixed_layout_provider_position_option_id,
          ),
        )
        is Some(position) {
        label_set_location(label, position.x, position.y)
      }
      fixed_layout_provider_update_max(
        maxx,
        maxy,
        node_x(node) + label_x(label) + label_width(label),
        node_y(node) + label_y(label) + label_height(label),
      )
    }

    for port in node_ports(node) {
      if fixed_layout_provider_parse_position(
          port_layout_option_string_value(
            port, fixed_layout_provider_position_option_id,
          ),
        )
        is Some(position) {
        port_set_location(port, position.x, position.y)
      }

      let portx = node_x(node) + port_x(port)
      let porty = node_y(node) + port_y(port)
      fixed_layout_provider_update_max(
        maxx,
        maxy,
        portx + port_width(port),
        porty + port_height(port),
      )

      for label in port_labels(port) {
        if fixed_layout_provider_parse_position(
            label_layout_option_string_value(
              label, fixed_layout_provider_position_option_id,
            ),
          )
          is Some(position) {
          label_set_location(label, position.x, position.y)
        }
        fixed_layout_provider_update_max(
          maxx,
          maxy,
          portx + label_x(label) + label_width(label),
          porty + label_y(label) + label_height(label),
        )
      }
    }

    for edge in all_outgoing_edges(node) {
      let maxv = fixed_layout_provider_process_edge(edge, edge_routing_kind)
      fixed_layout_provider_update_max(maxx, maxy, maxv.x, maxv.y)
    }

    for edge in all_incoming_edges(node) {
      if fixed_layout_provider_source_parent(edge) != Some(layout_node) {
        let maxv = fixed_layout_provider_process_edge(edge, edge_routing_kind)
        fixed_layout_provider_update_max(maxx, maxy, maxv.x, maxv.y)
      }
    }
  }

  if edge_routing_kind is FixedLayoutProviderOrthogonalRouting {
    for node in node_children(layout_node) {
      for edge in all_outgoing_edges(node) {
        fixed_layout_provider_generate_junction_points(edge)
      }
    }
  }

  if !node_get_bool_property(layout_node, node_size_fixed_graph_size) {
    let padding_value = fixed_layout_provider_parse_padding(layout_node)
    node_set_dimensions(
      layout_node,
      maxx.val + padding_value.left + padding_value.right,
      maxy.val + padding_value.top + padding_value.bottom,
    )
  }

  progress_monitor.done()
}

///|
pub fn fixed_layout_provider_as_layout_provider(
  provider : FixedLayoutProvider,
) -> AbstractLayoutProvider {
  new_abstract_layout_provider((graph, monitor) => {
    provider.layout(graph, monitor)
  })
}
