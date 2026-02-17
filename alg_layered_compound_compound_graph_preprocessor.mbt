///|
let compound_graph_preprocessor_internal_properties_cross_hierarchy_map : IProperty[
  Array[(LEdge, (LEdge, LGraph, PortType))],
] = new_property("crossHierarchyMap", [])

///|
let compound_graph_preprocessor_internal_properties_original_label_edge : IProperty[
  LEdge?,
] = new_property("originalLabelEdge", None)

///|
let compound_graph_preprocessor_layered_options_merge_hierarchy_edges : IProperty[
  Bool,
] = new_property("org.eclipse.elk.layered.mergeHierarchyEdges", true)

///|
let compound_graph_preprocessor_layered_options_inside_self_loops_yo : IProperty[
  Bool,
] = new_property("org.eclipse.elk.insideSelfLoops.yo", false)

///|
struct CompoundGraphPreprocessorExternalPort {
  orig_edges : Array[LEdge]
  new_edge : LEdge
  dummy_node : LNode
  dummy_port : LPort
  port_type : PortType
  exported : Bool
}

///|
fn compound_graph_preprocessor_new_external_port(
  orig_edge : LEdge,
  new_edge : LEdge,
  dummy_node : LNode,
  dummy_port : LPort,
  port_type : PortType,
  exported : Bool,
) -> CompoundGraphPreprocessorExternalPort {
  {
    orig_edges: [orig_edge],
    new_edge,
    dummy_node,
    dummy_port,
    port_type,
    exported,
  }
}

///|
fn compound_graph_preprocessor_require_source_port(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(port) => port
    None => abort("edge has no source port")
  }
}

///|
fn compound_graph_preprocessor_require_target_port(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(port) => port
    None => abort("edge has no target port")
  }
}

///|
fn compound_graph_preprocessor_require_port_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(node) => node
    None => abort("port has no owner node")
  }
}

///|
fn compound_graph_preprocessor_require_parent_node(graph : LGraph) -> LNode {
  match graph.get_parent_node() {
    Some(node) => node
    None => abort("graph has no parent node")
  }
}

///|
fn compound_graph_preprocessor_port_type_is_input(port_type : PortType) -> Bool {
  match port_type {
    Input => true
    _ => false
  }
}

///|
fn compound_graph_preprocessor_port_type_is_output(
  port_type : PortType,
) -> Bool {
  match port_type {
    Output => true
    _ => false
  }
}

///|
fn compound_graph_preprocessor_port_side_is_east_or_west(
  side : PortSide,
) -> Bool {
  match side {
    PortSide::East => true
    PortSide::West => true
    _ => false
  }
}

///|
fn compound_graph_preprocessor_port_constraints_from_string(
  value : String,
) -> PortConstraints {
  for constraints in port_constraints_values() {
    if port_constraints_to_string(constraints) == value {
      return constraints
    }
  }
  PortConstraints::Undefined
}

///|
fn compound_graph_preprocessor_parse_port_label_placement(
  values : Array[String],
) -> Array[PortLabelPlacement] {
  let parsed : Array[PortLabelPlacement] = []
  for value in values {
    for placement in port_label_placement_values() {
      if port_label_placement_to_string(placement) == value {
        parsed.push(placement)
      }
    }
  }
  parsed
}

///|
fn compound_graph_preprocessor_contains_port_label_placement(
  values : Array[PortLabelPlacement],
  expected : PortLabelPlacement,
) -> Bool {
  let expected_name = port_label_placement_to_string(expected)
  for value in values {
    if port_label_placement_to_string(value) == expected_name {
      return true
    }
  }
  false
}

///|
fn compound_graph_preprocessor_compute_inside_part(
  label_position : KVector,
  label_size : KVector,
  port_size : KVector,
  port_border_offset : Double,
  port_side : PortSide,
) -> Double {
  match port_side {
    PortSide::North =>
      @cmp.maximum(
        0.0,
        label_size.y + label_position.y - (port_size.y + port_border_offset),
      )
    PortSide::South => @cmp.maximum(0.0, -label_position.y - port_border_offset)
    PortSide::East => @cmp.maximum(0.0, -label_position.x - port_border_offset)
    PortSide::West =>
      @cmp.maximum(
        0.0,
        label_size.x + label_position.x - (port_size.x + port_border_offset),
      )
    PortSide::SideUndefined => 0.0
  }
}

///|
fn compound_graph_preprocessor_graph_properties_contains(
  properties : Array[GraphProperties],
  property : GraphProperties,
) -> Bool {
  let property_name = graph_properties_to_string(property)
  for current in properties {
    if graph_properties_to_string(current) == property_name {
      return true
    }
  }
  false
}

///|
fn compound_graph_preprocessor_graph_has_property(
  graph : LGraph,
  property : GraphProperties,
) -> Bool {
  compound_graph_preprocessor_graph_properties_contains(
    graph.get_property_graph_properties_array(
      internal_properties_graph_properties,
    ),
    property,
  )
}

///|
fn compound_graph_preprocessor_graph_add_property(
  graph : LGraph,
  property : GraphProperties,
) -> Unit {
  let properties = graph.get_property_graph_properties_array(
    internal_properties_graph_properties,
  )
  if compound_graph_preprocessor_graph_properties_contains(properties, property) {
    return
  }

  properties.push(property)
  graph.set_property_graph_properties_array(
    internal_properties_graph_properties, properties,
  )
}

///|
fn compound_graph_preprocessor_graph_contains_node(
  graph : LGraph,
  node : LNode,
) -> Bool {
  for current in graph.get_layerless_nodes() {
    if current.get_handle() == node.get_handle() {
      return true
    }
  }
  false
}

///|
fn compound_graph_preprocessor_dummy_node_map_index(
  dummy_node_entries : Array[(LPort, LNode)],
  port : LPort,
) -> Int {
  let port_handle = port.get_handle()
  let mut index = 0
  while index < dummy_node_entries.length() {
    if dummy_node_entries[index].0.get_handle() == port_handle {
      return index
    }
    index += 1
  }
  -1
}

///|
fn compound_graph_preprocessor_dummy_node_map_get(
  dummy_node_entries : Array[(LPort, LNode)],
  port : LPort,
) -> LNode? {
  let index = compound_graph_preprocessor_dummy_node_map_index(
    dummy_node_entries, port,
  )
  if index < 0 {
    None
  } else {
    Some(dummy_node_entries[index].1)
  }
}

///|
fn compound_graph_preprocessor_dummy_node_map_put(
  dummy_node_entries : Array[(LPort, LNode)],
  port : LPort,
  node : LNode,
) -> Unit {
  let index = compound_graph_preprocessor_dummy_node_map_index(
    dummy_node_entries, port,
  )
  if index < 0 {
    dummy_node_entries.push((port, node))
  } else {
    dummy_node_entries[index] = (port, node)
  }
}

///|
fn compound_graph_preprocessor_cross_hierarchy_map_put(
  cross_hierarchy_map : Array[(LEdge, (LEdge, LGraph, PortType))],
  orig_edge : LEdge,
  new_edge : LEdge,
  graph : LGraph,
  port_type : PortType,
) -> Unit {
  cross_hierarchy_map.push((orig_edge, (new_edge, graph, port_type)))
}

///|
fn compound_graph_preprocessor_cross_hierarchy_key_set(
  cross_hierarchy_map : Array[(LEdge, (LEdge, LGraph, PortType))],
) -> Array[LEdge] {
  let keys : Array[LEdge] = []

  for entry in cross_hierarchy_map {
    let (orig_edge, _) = entry
    let mut known = false
    for key in keys {
      if key.get_handle() == orig_edge.get_handle() {
        known = true
        break
      }
    }

    if !known {
      keys.push(orig_edge)
    }
  }

  keys
}

///|
fn compound_graph_preprocessor_cross_hierarchy_values(
  cross_hierarchy_map : Array[(LEdge, (LEdge, LGraph, PortType))],
  orig_edge : LEdge,
) -> Array[CrossHierarchyEdge] {
  let values : Array[CrossHierarchyEdge] = []

  for entry in cross_hierarchy_map {
    let (candidate_orig_edge, (segment_edge, segment_graph, segment_type)) = entry
    if candidate_orig_edge.get_handle() == orig_edge.get_handle() {
      values.push(
        new_cross_hierarchy_edge(segment_edge, segment_graph, segment_type),
      )
    }
  }

  values
}

///|
fn compound_graph_preprocessor_sort_cross_hierarchy_edges(
  edges : Array[CrossHierarchyEdge],
  comparator : CrossHierarchyEdgeComparator,
) -> Unit {
  if edges.length() <= 1 {
    return
  }

  for i in 1..<edges.length() {
    let key = edges[i]
    let mut j = i
    while j > 0 && comparator.compare(edges[j - 1], key) > 0 {
      edges[j] = edges[j - 1]
      j -= 1
    }
    edges[j] = key
  }
}

///|
fn compound_graph_preprocessor_external_port_contains_edge(
  external_port : CompoundGraphPreprocessorExternalPort,
  orig_edge : LEdge,
) -> Bool {
  for current in external_port.orig_edges {
    if current.get_handle() == orig_edge.get_handle() {
      return true
    }
  }
  false
}

///|
fn compound_graph_preprocessor_external_port_equals(
  left : CompoundGraphPreprocessorExternalPort,
  right : CompoundGraphPreprocessorExternalPort,
) -> Bool {
  left.new_edge.get_handle() == right.new_edge.get_handle()
}

///|
fn compound_graph_preprocessor_external_port_is_same_as_current(
  current : CompoundGraphPreprocessorExternalPort?,
  next : CompoundGraphPreprocessorExternalPort,
) -> Bool {
  match current {
    Some(value) => compound_graph_preprocessor_external_port_equals(value, next)
    None => false
  }
}

///|
fn compound_graph_preprocessor_set_sides_of_ports_to_sides_of_dummy_nodes(
  dummy_node_entries : Array[(LPort, LNode)],
) -> Unit {
  for entry in dummy_node_entries {
    let (external_port, dummy_node) = entry

    dummy_node.set_property_l_port(
      internal_properties_origin_l_port,
      Some(external_port),
    )
    external_port.set_property_l_node(
      internal_properties_port_dummy,
      Some(dummy_node),
    )
    external_port.set_property_bool(
      internal_properties_inside_connections, true,
    )
    external_port.set_side(
      dummy_node.get_property_port_side(internal_properties_ext_port_side),
    )

    let external_port_node = compound_graph_preprocessor_require_port_node(
      external_port,
    )
    external_port_node.set_property_string(
      port_constraints,
      port_constraints_to_string(PortConstraints::FixedSide),
    )
    compound_graph_preprocessor_graph_add_property(
      external_port_node.get_graph(),
      GraphProperties::NonFreePorts,
    )
  }
}

///|
fn compound_graph_preprocessor_get_shallowest_edge_segment(
  edge_segments : Array[CrossHierarchyEdge],
) -> Int {
  let mut result = -1
  let mut index = 0

  for edge_segment in edge_segments {
    if compound_graph_preprocessor_port_type_is_input(edge_segment.get_type()) {
      result = if index == 0 { 0 } else { index - 1 }
      break
    } else if index == edge_segments.length() - 1 {
      result = index
    }

    index += 1
  }

  result
}

///|
fn compound_graph_preprocessor_move_labels_and_remove_original_edges(
  graph : LGraph,
  cross_hierarchy_map : Array[(LEdge, (LEdge, LGraph, PortType))],
) -> Unit {
  for
    orig_edge in compound_graph_preprocessor_cross_hierarchy_key_set(
      cross_hierarchy_map,
    ) {
    if !orig_edge.get_labels().is_empty() {
      let edge_segments = compound_graph_preprocessor_cross_hierarchy_values(
        cross_hierarchy_map, orig_edge,
      )
      compound_graph_preprocessor_sort_cross_hierarchy_edges(
        edge_segments,
        new_cross_hierarchy_edge_comparator(graph),
      )

      let labels = orig_edge.get_labels()
      let mut index = 0
      while index < labels.length() {
        let curr_label = labels[index]
        let mut target_dummy_edge_index = -1

        let placement = curr_label.get_property_string(edge_labels_placement)
        if placement == edge_label_placement_to_string(EdgeLabelPlacement::Head) {
          target_dummy_edge_index = edge_segments.length() - 1
        } else if placement ==
          edge_label_placement_to_string(EdgeLabelPlacement::Centered) {
          target_dummy_edge_index = compound_graph_preprocessor_get_shallowest_edge_segment(
            edge_segments,
          )
        } else if placement ==
          edge_label_placement_to_string(EdgeLabelPlacement::Tail) {
          target_dummy_edge_index = 0
        }

        if target_dummy_edge_index != -1 {
          let target_segment = edge_segments[target_dummy_edge_index]
          target_segment.get_edge().get_labels().push(curr_label)

          let target_graph = compound_graph_preprocessor_require_port_node(
            compound_graph_preprocessor_require_source_port(
              target_segment.get_edge(),
            ),
          ).get_graph()
          compound_graph_preprocessor_graph_add_property(
            target_graph,
            GraphProperties::EndLabels,
          )
          compound_graph_preprocessor_graph_add_property(
            target_graph,
            GraphProperties::CenterLabels,
          )

          ignore(labels.remove(index))
          curr_label.set_property_l_edge(
            compound_graph_preprocessor_internal_properties_original_label_edge,
            Some(orig_edge),
          )
        } else {
          index += 1
        }
      }
    }

    orig_edge.set_source(None)
    orig_edge.set_target(None)
  }
}

///|
fn compound_graph_preprocessor_connect_child(
  graph : LGraph,
  external_port : CompoundGraphPreprocessorExternalPort,
  orig_edge : LEdge,
  source_port : LPort,
  target_port : LPort,
  cross_hierarchy_map : Array[(LEdge, (LEdge, LGraph, PortType))],
) -> Unit {
  let dummy_edge = compound_graph_preprocessor_create_dummy_edge(
    graph, orig_edge,
  )
  dummy_edge.set_source(Some(source_port))
  dummy_edge.set_target(Some(target_port))

  compound_graph_preprocessor_cross_hierarchy_map_put(
    cross_hierarchy_map,
    orig_edge,
    dummy_edge,
    graph,
    external_port.port_type,
  )
}

///|
fn compound_graph_preprocessor_connect_siblings(
  graph : LGraph,
  external_output_port : CompoundGraphPreprocessorExternalPort,
  contained_external_ports : Array[CompoundGraphPreprocessorExternalPort],
  orig_edge : LEdge,
  cross_hierarchy_map : Array[(LEdge, (LEdge, LGraph, PortType))],
) -> Unit {
  let mut target_external_port : CompoundGraphPreprocessorExternalPort? = None

  for external_port in contained_external_ports {
    if !compound_graph_preprocessor_external_port_equals(
        external_port, external_output_port,
      ) &&
      compound_graph_preprocessor_external_port_contains_edge(
        external_port, orig_edge,
      ) {
      target_external_port = Some(external_port)
      break
    }
  }

  let resolved_target_external_port = match target_external_port {
    Some(value) => value
    None => abort("target external port not found")
  }

  let dummy_edge = compound_graph_preprocessor_create_dummy_edge(
    graph, orig_edge,
  )
  dummy_edge.set_source(Some(external_output_port.dummy_port))
  dummy_edge.set_target(Some(resolved_target_external_port.dummy_port))

  compound_graph_preprocessor_cross_hierarchy_map_put(
    cross_hierarchy_map,
    orig_edge,
    dummy_edge,
    graph,
    external_output_port.port_type,
  )
}

///|
fn compound_graph_preprocessor_process_inner_hierarchical_edge_segments(
  graph : LGraph,
  parent_node : LNode?,
  contained_external_ports : Array[CompoundGraphPreprocessorExternalPort],
  exported_external_ports : Array[CompoundGraphPreprocessorExternalPort],
  cross_hierarchy_map : Array[(LEdge, (LEdge, LGraph, PortType))],
  dummy_node_entries : Array[(LPort, LNode)],
) -> Unit {
  let created_external_ports : Array[CompoundGraphPreprocessorExternalPort] = []

  for external_port in contained_external_ports {
    let mut current_external_port : CompoundGraphPreprocessorExternalPort? = None

    if compound_graph_preprocessor_port_type_is_output(external_port.port_type) {
      for out_edge in external_port.orig_edges {
        let target_node = compound_graph_preprocessor_require_port_node(
          compound_graph_preprocessor_require_target_port(out_edge),
        )

        if compound_graph_preprocessor_graph_contains_node(graph, target_node) {
          compound_graph_preprocessor_connect_child(
            graph,
            external_port,
            out_edge,
            external_port.dummy_port,
            compound_graph_preprocessor_require_target_port(out_edge),
            cross_hierarchy_map,
          )
        } else if parent_node is Some(parent) {
          if is_descendant_l_node(target_node, parent) {
            compound_graph_preprocessor_connect_siblings(
              graph, external_port, contained_external_ports, out_edge, cross_hierarchy_map,
            )
          } else {
            let new_external_port = compound_graph_preprocessor_introduce_hierarchical_edge_segment(
              graph,
              parent,
              out_edge,
              external_port.dummy_port,
              PortType::Output,
              current_external_port,
              cross_hierarchy_map,
              dummy_node_entries,
            )

            if !compound_graph_preprocessor_external_port_is_same_as_current(
                current_external_port, new_external_port,
              ) {
              created_external_ports.push(new_external_port)
            }

            if new_external_port.exported {
              current_external_port = Some(new_external_port)
            }
          }
        } else {
          compound_graph_preprocessor_connect_siblings(
            graph, external_port, contained_external_ports, out_edge, cross_hierarchy_map,
          )
        }
      }
    } else {
      for in_edge in external_port.orig_edges {
        let source_node = compound_graph_preprocessor_require_port_node(
          compound_graph_preprocessor_require_source_port(in_edge),
        )

        if compound_graph_preprocessor_graph_contains_node(graph, source_node) {
          compound_graph_preprocessor_connect_child(
            graph,
            external_port,
            in_edge,
            compound_graph_preprocessor_require_source_port(in_edge),
            external_port.dummy_port,
            cross_hierarchy_map,
          )
        } else if parent_node is Some(parent) {
          if is_descendant_l_node(source_node, parent) {
            continue
          } else {
            let new_external_port = compound_graph_preprocessor_introduce_hierarchical_edge_segment(
              graph,
              parent,
              in_edge,
              external_port.dummy_port,
              PortType::Input,
              current_external_port,
              cross_hierarchy_map,
              dummy_node_entries,
            )

            if !compound_graph_preprocessor_external_port_is_same_as_current(
                current_external_port, new_external_port,
              ) {
              created_external_ports.push(new_external_port)
            }

            if new_external_port.exported {
              current_external_port = Some(new_external_port)
            }
          }
        } else {
          continue
        }
      }
    }
  }

  for external_port in created_external_ports {
    if !compound_graph_preprocessor_graph_contains_node(
        graph,
        external_port.dummy_node,
      ) {
      graph.get_layerless_nodes().push(external_port.dummy_node)
    }

    if external_port.exported {
      exported_external_ports.push(external_port)
    }
  }
}

///|
fn compound_graph_preprocessor_process_outer_hierarchical_edge_segments(
  graph : LGraph,
  parent_node : LNode,
  exported_external_ports : Array[CompoundGraphPreprocessorExternalPort],
  cross_hierarchy_map : Array[(LEdge, (LEdge, LGraph, PortType))],
  dummy_node_entries : Array[(LPort, LNode)],
) -> Unit {
  let created_external_ports : Array[CompoundGraphPreprocessorExternalPort] = []

  for child_node in graph.get_layerless_nodes() {
    for child_port in child_node.get_ports() {
      let mut current_external_output_port : CompoundGraphPreprocessorExternalPort? = None
      for out_edge in to_edge_array(child_port.get_outgoing_edges()) {
        let out_target_node = compound_graph_preprocessor_require_port_node(
          compound_graph_preprocessor_require_target_port(out_edge),
        )
        if !is_descendant_l_node(out_target_node, parent_node) {
          let new_external_port = compound_graph_preprocessor_introduce_hierarchical_edge_segment(
            graph,
            parent_node,
            out_edge,
            compound_graph_preprocessor_require_source_port(out_edge),
            PortType::Output,
            current_external_output_port,
            cross_hierarchy_map,
            dummy_node_entries,
          )

          if !compound_graph_preprocessor_external_port_is_same_as_current(
              current_external_output_port, new_external_port,
            ) {
            created_external_ports.push(new_external_port)
          }

          if new_external_port.exported {
            current_external_output_port = Some(new_external_port)
          }
        }
      }

      let mut current_external_input_port : CompoundGraphPreprocessorExternalPort? = None
      for in_edge in to_edge_array(child_port.get_incoming_edges()) {
        let in_source_node = compound_graph_preprocessor_require_port_node(
          compound_graph_preprocessor_require_source_port(in_edge),
        )
        if !is_descendant_l_node(in_source_node, parent_node) {
          let new_external_port = compound_graph_preprocessor_introduce_hierarchical_edge_segment(
            graph,
            parent_node,
            in_edge,
            compound_graph_preprocessor_require_target_port(in_edge),
            PortType::Input,
            current_external_input_port,
            cross_hierarchy_map,
            dummy_node_entries,
          )

          if !compound_graph_preprocessor_external_port_is_same_as_current(
              current_external_input_port, new_external_port,
            ) {
            created_external_ports.push(new_external_port)
          }

          if new_external_port.exported {
            current_external_input_port = Some(new_external_port)
          }
        }
      }
    }
  }

  for external_port in created_external_ports {
    if !compound_graph_preprocessor_graph_contains_node(
        graph,
        external_port.dummy_node,
      ) {
      graph.get_layerless_nodes().push(external_port.dummy_node)
    }

    if external_port.exported {
      exported_external_ports.push(external_port)
    }
  }
}

///|
fn compound_graph_preprocessor_process_inside_self_loops(
  nested_graph : LGraph,
  node : LNode,
  cross_hierarchy_map : Array[(LEdge, (LEdge, LGraph, PortType))],
  dummy_node_entries : Array[(LPort, LNode)],
) -> Unit {
  if !node.get_property_bool(inside_self_loops_activate) {
    return
  }

  for lport in node.get_ports() {
    let out_edges = to_edge_array(lport.get_outgoing_edges())
    for out_edge in out_edges {
      let out_target_node = compound_graph_preprocessor_require_port_node(
        compound_graph_preprocessor_require_target_port(out_edge),
      )
      let is_self_loop = out_target_node.get_handle() == node.get_handle()
      let is_inside_self_loop = is_self_loop &&
        out_edge.get_property_bool(
          compound_graph_preprocessor_layered_options_inside_self_loops_yo,
        )

      if is_inside_self_loop {
        let source_port = compound_graph_preprocessor_require_source_port(
          out_edge,
        )
        let source_ext_port_dummy = match
          compound_graph_preprocessor_dummy_node_map_get(
            dummy_node_entries, source_port,
          ) {
          Some(dummy) => dummy
          None => {
            let dummy = create_external_port_dummy(
              source_port,
              PortConstraints::Free,
              source_port.get_side(),
              -1,
              None,
              None,
              source_port.get_size(),
              get_direction(nested_graph),
              nested_graph,
            )
            dummy.set_property_l_port(
              internal_properties_origin_l_port,
              Some(source_port),
            )
            compound_graph_preprocessor_dummy_node_map_put(
              dummy_node_entries, source_port, dummy,
            )
            if !compound_graph_preprocessor_graph_contains_node(
                nested_graph, dummy,
              ) {
              nested_graph.get_layerless_nodes().push(dummy)
            }
            dummy
          }
        }

        let target_port = compound_graph_preprocessor_require_target_port(
          out_edge,
        )
        let target_ext_port_dummy = match
          compound_graph_preprocessor_dummy_node_map_get(
            dummy_node_entries, target_port,
          ) {
          Some(dummy) => dummy
          None => {
            let dummy = create_external_port_dummy(
              target_port,
              PortConstraints::Free,
              target_port.get_side(),
              1,
              None,
              None,
              target_port.get_size(),
              get_direction(nested_graph),
              nested_graph,
            )
            dummy.set_property_l_port(
              internal_properties_origin_l_port,
              Some(target_port),
            )
            compound_graph_preprocessor_dummy_node_map_put(
              dummy_node_entries, target_port, dummy,
            )
            if !compound_graph_preprocessor_graph_contains_node(
                nested_graph, dummy,
              ) {
              nested_graph.get_layerless_nodes().push(dummy)
            }
            dummy
          }
        }

        let dummy_edge = compound_graph_preprocessor_create_dummy_edge(
          nested_graph, out_edge,
        )
        dummy_edge.set_source(Some(source_ext_port_dummy.get_ports()[0]))
        dummy_edge.set_target(Some(target_ext_port_dummy.get_ports()[0]))

        compound_graph_preprocessor_cross_hierarchy_map_put(
          cross_hierarchy_map,
          out_edge,
          dummy_edge,
          nested_graph,
          PortType::Output,
        )
        compound_graph_preprocessor_graph_add_property(
          nested_graph,
          GraphProperties::ExternalPorts,
        )
      }
    }
  }
}

///|
fn compound_graph_preprocessor_transform_hierarchy_edges(
  graph : LGraph,
  parent_node : LNode?,
  cross_hierarchy_map : Array[(LEdge, (LEdge, LGraph, PortType))],
  dummy_node_entries : Array[(LPort, LNode)],
) -> Array[CompoundGraphPreprocessorExternalPort] {
  let contained_external_ports : Array[CompoundGraphPreprocessorExternalPort] = []

  for node in graph.get_layerless_nodes() {
    match node.get_nested_graph() {
      Some(nested_graph) => {
        let child_ports = compound_graph_preprocessor_transform_hierarchy_edges(
          nested_graph,
          Some(node),
          cross_hierarchy_map,
          dummy_node_entries,
        )
        for child_port in child_ports {
          contained_external_ports.push(child_port)
        }

        compound_graph_preprocessor_process_inside_self_loops(
          nested_graph, node, cross_hierarchy_map, dummy_node_entries,
        )

        if compound_graph_preprocessor_graph_has_property(
            nested_graph,
            GraphProperties::ExternalPorts,
          ) {
          let port_constraints_value = compound_graph_preprocessor_port_constraints_from_string(
            node.get_property_string(port_constraints),
          )
          let parsed_port_label_placement = compound_graph_preprocessor_parse_port_label_placement(
            node.get_property_string_array(port_labels_placement),
          )
          let inside_port_labels = compound_graph_preprocessor_contains_port_label_placement(
            parsed_port_label_placement,
            PortLabelPlacement::Inside,
          )

          for port in node.get_ports() {
            let dummy_node = match
              compound_graph_preprocessor_dummy_node_map_get(
                dummy_node_entries, port,
              ) {
              Some(dummy) => dummy
              None => {
                let dummy = create_external_port_dummy(
                  port,
                  port_constraints_value,
                  port.get_side(),
                  -port.get_net_flow(),
                  None,
                  Some(new_kvector()),
                  port.get_size(),
                  get_direction(nested_graph),
                  nested_graph,
                )
                dummy.set_property_l_port(
                  internal_properties_origin_l_port,
                  Some(port),
                )
                compound_graph_preprocessor_dummy_node_map_put(
                  dummy_node_entries, port, dummy,
                )
                nested_graph.get_layerless_nodes().push(dummy)
                dummy
              }
            }

            let dummy_node_port = dummy_node.get_ports()[0]
            for ext_port_label in port.get_labels() {
              let dummy_port_label = new_l_label()
              dummy_port_label.get_size().x = ext_port_label.get_size().x
              dummy_port_label.get_size().y = ext_port_label.get_size().y
              dummy_node_port.get_labels().push(dummy_port_label)

              if !inside_port_labels {
                let side = port.get_side()
                let mut inside_part = 0.0
                if port_label_placement_is_fixed(parsed_port_label_placement) {
                  inside_part = compound_graph_preprocessor_compute_inside_part(
                    ext_port_label.get_position(),
                    ext_port_label.get_size(),
                    port.get_size(),
                    0.0,
                    side,
                  )
                }

                if port_constraints_to_string(port_constraints_value) ==
                  port_constraints_to_string(PortConstraints::Free) ||
                  compound_graph_preprocessor_port_side_is_east_or_west(side) {
                  dummy_port_label.get_size().x = inside_part
                } else {
                  dummy_port_label.get_size().y = inside_part
                }
              }
            }
          }
        }
      }
      None => ()
    }
  }

  let exported_external_ports : Array[CompoundGraphPreprocessorExternalPort] = []
  compound_graph_preprocessor_process_inner_hierarchical_edge_segments(
    graph, parent_node, contained_external_ports, exported_external_ports, cross_hierarchy_map,
    dummy_node_entries,
  )

  match parent_node {
    Some(parent) =>
      compound_graph_preprocessor_process_outer_hierarchical_edge_segments(
        graph, parent, exported_external_ports, cross_hierarchy_map, dummy_node_entries,
      )
    None => ()
  }

  exported_external_ports
}

///|
fn compound_graph_preprocessor_introduce_hierarchical_edge_segment(
  graph : LGraph,
  parent_node : LNode,
  orig_edge : LEdge,
  opposite_port : LPort,
  port_type : PortType,
  default_external_port : CompoundGraphPreprocessorExternalPort?,
  cross_hierarchy_map : Array[(LEdge, (LEdge, LGraph, PortType))],
  dummy_node_entries : Array[(LPort, LNode)],
) -> CompoundGraphPreprocessorExternalPort {
  let merge_external_ports = graph.get_property_bool(
    compound_graph_preprocessor_layered_options_merge_hierarchy_edges,
  )

  let mut parent_end_port : LPort? = None
  if compound_graph_preprocessor_port_type_is_input(port_type) {
    if compound_graph_preprocessor_require_port_node(
        compound_graph_preprocessor_require_source_port(orig_edge),
      ).get_handle() ==
      parent_node.get_handle() {
      parent_end_port = Some(
        compound_graph_preprocessor_require_source_port(orig_edge),
      )
    }
  } else if compound_graph_preprocessor_port_type_is_output(port_type) {
    if compound_graph_preprocessor_require_port_node(
        compound_graph_preprocessor_require_target_port(orig_edge),
      ).get_handle() ==
      parent_node.get_handle() {
      parent_end_port = Some(
        compound_graph_preprocessor_require_target_port(orig_edge),
      )
    }
  }

  let mut external_port = default_external_port
  if external_port is None ||
    !merge_external_ports ||
    parent_end_port is Some(_) {
    let mut external_port_side = PortSide::SideUndefined
    match parent_end_port {
      Some(parent_end) => external_port_side = parent_end.get_side()
      None =>
        if compound_graph_preprocessor_port_constraints_from_string(
            parent_node.get_property_string(port_constraints),
          ).is_side_fixed() {
          external_port_side = if compound_graph_preprocessor_port_type_is_input(
              port_type,
            ) {
            PortSide::West
          } else {
            PortSide::East
          }
        }
    }

    let dummy_node = compound_graph_preprocessor_create_external_port_dummy(
      graph, parent_node, port_type, external_port_side, orig_edge, dummy_node_entries,
    )

    let dummy_edge = compound_graph_preprocessor_create_dummy_edge(
      parent_node.get_graph(),
      orig_edge,
    )
    if compound_graph_preprocessor_port_type_is_input(port_type) {
      dummy_edge.set_source(Some(dummy_node.get_ports()[0]))
      dummy_edge.set_target(Some(opposite_port))
    } else {
      dummy_edge.set_source(Some(opposite_port))
      dummy_edge.set_target(Some(dummy_node.get_ports()[0]))
    }

    external_port = Some(
      compound_graph_preprocessor_new_external_port(
        orig_edge,
        dummy_edge,
        dummy_node,
        match
          dummy_node.get_property_l_port(internal_properties_origin_l_port) {
          Some(dummy_port) => dummy_port
          None => abort("external port dummy has no origin port")
        },
        port_type,
        parent_end_port is None,
      ),
    )
  } else {
    match external_port {
      Some(existing_external_port) => {
        existing_external_port.orig_edges.push(orig_edge)
        let thickness = @cmp.maximum(
          existing_external_port.new_edge.get_property_double(edge_thickness),
          orig_edge.get_property_double(edge_thickness),
        )
        existing_external_port.new_edge.set_property_double(
          edge_thickness, thickness,
        )
      }
      None => ()
    }
  }

  let result = match external_port {
    Some(value) => value
    None => abort("failed to create or reuse external port")
  }

  compound_graph_preprocessor_cross_hierarchy_map_put(
    cross_hierarchy_map,
    orig_edge,
    result.new_edge,
    graph,
    port_type,
  )

  result
}

///|
fn compound_graph_preprocessor_create_dummy_edge(
  graph : LGraph,
  orig_edge : LEdge,
) -> LEdge {
  ignore(graph)
  let dummy_edge = new_l_edge()
  dummy_edge.copy_properties(orig_edge)
  if dummy_edge.has_property_kvector_chain(layered_options_junction_points) {
    dummy_edge.clear_property_kvector_chain(layered_options_junction_points)
  }
  dummy_edge
}

///|
fn compound_graph_preprocessor_calculate_net_flow(port : LPort) -> Int {
  let node = compound_graph_preprocessor_require_port_node(port)
  let inside_self_loops_enabled = node.get_property_bool(
    inside_self_loops_activate,
  )

  let mut output_port_vote = 0
  let mut input_port_vote = 0

  for outgoing_edge in port.get_outgoing_edges() {
    let is_self_loop = outgoing_edge.is_self_loop()
    let is_inside_self_loop = is_self_loop &&
      inside_self_loops_enabled &&
      outgoing_edge.get_property_bool(
        compound_graph_preprocessor_layered_options_inside_self_loops_yo,
      )
    let target_node = compound_graph_preprocessor_require_port_node(
      compound_graph_preprocessor_require_target_port(outgoing_edge),
    )

    if is_self_loop && is_inside_self_loop {
      input_port_vote += 1
    } else if is_self_loop && !is_inside_self_loop {
      output_port_vote += 1
    } else if target_node.get_graph().get_parent_node() is Some(parent) {
      if parent.get_handle() == node.get_handle() {
        input_port_vote += 1
      } else {
        output_port_vote += 1
      }
    } else {
      output_port_vote += 1
    }
  }

  for incoming_edge in port.get_incoming_edges() {
    let is_self_loop = incoming_edge.is_self_loop()
    let is_inside_self_loop = is_self_loop &&
      inside_self_loops_enabled &&
      incoming_edge.get_property_bool(
        compound_graph_preprocessor_layered_options_inside_self_loops_yo,
      )
    let source_node = compound_graph_preprocessor_require_port_node(
      compound_graph_preprocessor_require_source_port(incoming_edge),
    )

    if is_self_loop && is_inside_self_loop {
      output_port_vote += 1
    } else if is_self_loop && !is_inside_self_loop {
      input_port_vote += 1
    } else if source_node.get_graph().get_parent_node() is Some(parent) {
      if parent.get_handle() == node.get_handle() {
        output_port_vote += 1
      } else {
        input_port_vote += 1
      }
    } else {
      input_port_vote += 1
    }
  }

  output_port_vote - input_port_vote
}

///|
fn compound_graph_preprocessor_create_external_port_dummy(
  graph : LGraph,
  parent_node : LNode,
  port_type : PortType,
  port_side : PortSide,
  edge : LEdge,
  dummy_node_entries : Array[(LPort, LNode)],
) -> LNode {
  let outside_port = if compound_graph_preprocessor_port_type_is_input(
      port_type,
    ) {
    compound_graph_preprocessor_require_source_port(edge)
  } else {
    compound_graph_preprocessor_require_target_port(edge)
  }
  let layout_direction = get_direction(graph)

  let mut dummy_node : LNode? = None
  if compound_graph_preprocessor_require_port_node(outside_port).get_handle() ==
    parent_node.get_handle() {
    dummy_node = compound_graph_preprocessor_dummy_node_map_get(
      dummy_node_entries, outside_port,
    )
    if dummy_node is None {
      let created_dummy = create_external_port_dummy(
        outside_port,
        compound_graph_preprocessor_port_constraints_from_string(
          parent_node.get_property_string(port_constraints),
        ),
        port_side,
        compound_graph_preprocessor_calculate_net_flow(outside_port),
        None,
        Some(outside_port.get_position()),
        outside_port.get_size(),
        layout_direction,
        graph,
      )
      created_dummy.set_property_l_port(
        internal_properties_origin_l_port,
        Some(outside_port),
      )
      compound_graph_preprocessor_dummy_node_map_put(
        dummy_node_entries, outside_port, created_dummy,
      )
      dummy_node = Some(created_dummy)
    }
  } else {
    let created_dummy = create_external_port_dummy(
      compound_graph_preprocessor_create_external_port_properties(graph),
      compound_graph_preprocessor_port_constraints_from_string(
        parent_node.get_property_string(port_constraints),
      ),
      port_side,
      if compound_graph_preprocessor_port_type_is_input(port_type) {
        -1
      } else {
        1
      },
      None,
      Some(new_kvector()),
      new_kvector_xy(0.0, 0.0),
      layout_direction,
      graph,
    )
    let dummy_port = compound_graph_preprocessor_create_port_for_dummy(
      created_dummy, parent_node, port_type,
    )
    created_dummy.set_property_l_port(
      internal_properties_origin_l_port,
      Some(dummy_port),
    )
    compound_graph_preprocessor_dummy_node_map_put(
      dummy_node_entries, dummy_port, created_dummy,
    )
    dummy_node = Some(created_dummy)
  }

  compound_graph_preprocessor_graph_add_property(
    graph,
    GraphProperties::ExternalPorts,
  )
  if compound_graph_preprocessor_port_constraints_from_string(
      graph.get_property_string(port_constraints),
    ).is_side_fixed() {
    graph.set_property_string(
      port_constraints,
      port_constraints_to_string(PortConstraints::FixedSide),
    )
  } else {
    graph.set_property_string(
      port_constraints,
      port_constraints_to_string(PortConstraints::Free),
    )
  }

  match dummy_node {
    Some(node) => node
    None => abort("failed to create external port dummy")
  }
}

///|
fn compound_graph_preprocessor_create_external_port_properties(
  graph : LGraph,
) -> LPort {
  let property_holder = new_l_port()
  property_holder.set_property_double(
    layered_options_port_border_offset,
    graph.get_property_double(spacing_edge_edge) / 2.0,
  )
  property_holder
}

///|
fn compound_graph_preprocessor_create_port_for_dummy(
  dummy_node : LNode,
  parent_node : LNode,
  port_type : PortType,
) -> LPort {
  let graph = parent_node.get_graph()
  let layout_direction = get_direction(graph)

  let port = new_l_port()
  port.set_node(Some(parent_node))
  if compound_graph_preprocessor_port_type_is_input(port_type) {
    port.set_side(port_side_from_direction(layout_direction).opposed())
  } else if compound_graph_preprocessor_port_type_is_output(port_type) {
    port.set_side(port_side_from_direction(layout_direction))
  }

  port.set_property_double(
    layered_options_port_border_offset,
    dummy_node.get_property_double(layered_options_port_border_offset),
  )
  port
}

///|
fn compound_graph_preprocessor_process(
  graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Compound graph preprocessor", 1.0))

  let cross_hierarchy_map : Array[(LEdge, (LEdge, LGraph, PortType))] = []
  let dummy_node_entries : Array[(LPort, LNode)] = []

  ignore(
    compound_graph_preprocessor_transform_hierarchy_edges(
      graph,
      None,
      cross_hierarchy_map,
      dummy_node_entries,
    ),
  )
  compound_graph_preprocessor_move_labels_and_remove_original_edges(
    graph, cross_hierarchy_map,
  )
  compound_graph_preprocessor_set_sides_of_ports_to_sides_of_dummy_nodes(
    dummy_node_entries,
  )

  graph.set_property_cross_hierarchy_map_entry_array(
    compound_graph_preprocessor_internal_properties_cross_hierarchy_map, cross_hierarchy_map,
  )
  monitor.done()
}

///|
pub fn new_compound_graph_preprocessor_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(compound_graph_preprocessor_process)
}
