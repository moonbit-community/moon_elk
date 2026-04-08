///|
let compound_graph_postprocessor_internal_properties_cross_hierarchy_map : @graph.IProperty[
  Array[(LEdge, (LEdge, LGraph, PortType))],
] = @graph.new_property("crossHierarchyMap", [])

///|
let compound_graph_postprocessor_internal_properties_original_label_edge : @graph.IProperty[
  LEdge?,
] = @graph.new_property("originalLabelEdge", None)

///|
let compound_graph_postprocessor_internal_properties_target_offset : @graph.IProperty[
  @core.KVector,
] = @graph.new_property("targetOffset", @core.new_kvector())

///|
priv suberror CompoundGraphPostprocessorException {
  UnsupportedGraphException(String)
} derive(Debug, ToJson)

///|
fn[T] compound_graph_postprocessor_raise_unsupported_graph(
  message : String,
) -> T raise CompoundGraphPostprocessorException {
  raise CompoundGraphPostprocessorException::UnsupportedGraphException(message)
}

///|
fn compound_graph_postprocessor_require_source_port(
  edge : LEdge,
) -> LPort raise CompoundGraphPostprocessorException {
  match edge.get_source() {
    Some(port) => port
    None =>
      compound_graph_postprocessor_raise_unsupported_graph(
        "edge has no source port",
      )
  }
}

///|
fn compound_graph_postprocessor_require_target_port(
  edge : LEdge,
) -> LPort raise CompoundGraphPostprocessorException {
  match edge.get_target() {
    Some(port) => port
    None =>
      compound_graph_postprocessor_raise_unsupported_graph(
        "edge has no target port",
      )
  }
}

///|
fn compound_graph_postprocessor_require_port_node(
  port : LPort,
) -> LNode raise CompoundGraphPostprocessorException {
  match port.get_node() {
    Some(node) => node
    None =>
      compound_graph_postprocessor_raise_unsupported_graph(
        "port has no owner node",
      )
  }
}

///|
fn compound_graph_postprocessor_require_nested_graph(
  node : LNode,
) -> LGraph raise CompoundGraphPostprocessorException {
  match node.get_nested_graph() {
    Some(graph) => graph
    None =>
      compound_graph_postprocessor_raise_unsupported_graph(
        "node has no nested graph",
      )
  }
}

///|
fn compound_graph_postprocessor_contains_edge(
  edges : Array[LEdge],
  candidate : LEdge,
) -> Bool {
  for edge in edges {
    if edge.get_handle() == candidate.get_handle() {
      return true
    }
  }
  false
}

///|
fn compound_graph_postprocessor_cross_hierarchy_key_set(
  cross_hierarchy_map : Array[(LEdge, (LEdge, LGraph, PortType))],
) -> Array[LEdge] {
  let keys : Array[LEdge] = []
  for entry in cross_hierarchy_map {
    let (orig_edge, _) = entry
    if !compound_graph_postprocessor_contains_edge(keys, orig_edge) {
      keys.push(orig_edge)
    }
  }
  keys
}

///|
fn compound_graph_postprocessor_get_cross_hierarchy_edges(
  cross_hierarchy_map : Array[(LEdge, (LEdge, LGraph, PortType))],
  orig_edge : LEdge,
) -> Array[CrossHierarchyEdge] {
  let result : Array[CrossHierarchyEdge] = []
  for entry in cross_hierarchy_map {
    let (candidate_orig_edge, (segment_edge, segment_graph, segment_type)) = entry
    if candidate_orig_edge.get_handle() == orig_edge.get_handle() {
      result.push(
        new_cross_hierarchy_edge(segment_edge, segment_graph, segment_type),
      )
    }
  }
  result
}

///|
fn compound_graph_postprocessor_sort_cross_hierarchy_edges(
  edges : Array[CrossHierarchyEdge],
  comparator : CrossHierarchyEdgeComparator,
) -> Unit raise CrossHierarchyEdgeComparatorException {
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
fn compound_graph_postprocessor_has_junction_points(
  ch_edge : CrossHierarchyEdge,
) -> Bool {
  let edge = ch_edge.get_edge()
  if !edge.has_property_kvector_chain(layered_options_junction_points) {
    return false
  }
  let jps = edge.get_property_kvector_chain(layered_options_junction_points)
  !jps.is_empty()
}

///|
fn compound_graph_postprocessor_clear_junction_points(
  orig_edge : LEdge,
  cross_hierarchy_edges : Array[CrossHierarchyEdge],
) -> @core.KVectorChain? {
  let mut has_junction_points = false
  for ch_edge in cross_hierarchy_edges {
    if compound_graph_postprocessor_has_junction_points(ch_edge) {
      has_junction_points = true
      break
    }
  }

  if has_junction_points {
    if orig_edge.has_property_kvector_chain(layered_options_junction_points) {
      let junction_points = orig_edge.get_property_kvector_chain(
        layered_options_junction_points,
      )
      junction_points.clear()
      return Some(junction_points)
    }

    let junction_points = @core.new_kvector_chain()
    orig_edge.set_property_kvector_chain(
      layered_options_junction_points, junction_points,
    )
    return Some(junction_points)
  }

  if orig_edge.has_property_kvector_chain(layered_options_junction_points) {
    orig_edge.clear_property_kvector_chain(layered_options_junction_points)
  }
  None
}

///|
fn compound_graph_postprocessor_copy_junction_points(
  source : LEdge,
  target : @core.KVectorChain?,
  offset : @core.KVector,
) -> Unit {
  if !source.has_property_kvector_chain(layered_options_junction_points) {
    return
  }

  match target {
    Some(target_chain) => {
      let ledge_jps = source.get_property_kvector_chain(
        layered_options_junction_points,
      )
      let jp_copies = @core.new_kvector_chain()
      jp_copies.add_all_as_copies(0, ledge_jps)
      ignore(jp_copies.offset(offset))
      target_chain.add_all(jp_copies.to_array())
    }
    None => ()
  }
}

///|
fn compound_graph_postprocessor_copy_labels_back(
  hierarchy_segment : LEdge,
  orig_edge : LEdge,
  reference_graph : LGraph,
) -> Unit raise CompoundGraphPostprocessorException {
  let source_graph = compound_graph_postprocessor_require_port_node(
    compound_graph_postprocessor_require_source_port(hierarchy_segment),
  ).get_graph()
  let segment_labels = hierarchy_segment.get_labels()

  let mut index = 0
  while index < segment_labels.length() {
    let curr_label = segment_labels[index]
    let mut moved = false
    match
      curr_label.get_property_l_edge(
        compound_graph_postprocessor_internal_properties_original_label_edge,
      ) {
      Some(label_orig_edge) =>
        if label_orig_edge.get_handle() == orig_edge.get_handle() {
          change_coord_system(
            curr_label.get_position(),
            source_graph,
            reference_graph,
          )
          ignore(segment_labels.remove(index))
          orig_edge.get_labels().push(curr_label)
          moved = true
        }
      None => ()
    }
    if !moved {
      index += 1
    }
  }
}

///|
fn compound_graph_postprocessor_process(
  graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Compound graph postprocessor", 1.0))

  let add_unnecessary_bendpoints = graph.get_property_bool(
    layered_options_unnecessary_bendpoints,
  )
  let cross_hierarchy_map = graph.get_property_cross_hierarchy_map_entry_array(
    compound_graph_postprocessor_internal_properties_cross_hierarchy_map,
  )
  let dummy_edges : Array[LEdge] = []

  try {
    for
      orig_edge in compound_graph_postprocessor_cross_hierarchy_key_set(
        cross_hierarchy_map,
      ) {
      let cross_hierarchy_edges = compound_graph_postprocessor_get_cross_hierarchy_edges(
        cross_hierarchy_map, orig_edge,
      )
      if cross_hierarchy_edges.is_empty() {
        continue
      }

      try
        compound_graph_postprocessor_sort_cross_hierarchy_edges(
          cross_hierarchy_edges,
          new_cross_hierarchy_edge_comparator(graph),
        )
      catch {
        err => {
          @core.layout_runtime_report_unsupported_configuration(
            cross_hierarchy_edge_comparator_exception_message(err),
          )
          monitor.done()
          return
        }
      } noraise {
        _ => ()
      }

      let source_port = cross_hierarchy_edges[0].get_actual_source()
      let target_port = cross_hierarchy_edges[cross_hierarchy_edges.length() - 1].get_actual_target()

      let reference_node = compound_graph_postprocessor_require_port_node(
        source_port,
      )
      let reference_graph = if is_descendant_l_node(
          compound_graph_postprocessor_require_port_node(target_port),
          reference_node,
        ) {
        compound_graph_postprocessor_require_nested_graph(reference_node)
      } else {
        reference_node.get_graph()
      }

      let junction_points = compound_graph_postprocessor_clear_junction_points(
        orig_edge, cross_hierarchy_edges,
      )
      orig_edge.get_bend_points().clear()

      let mut last_point : @core.KVector? = None
      for ch_edge in cross_hierarchy_edges {
        let offset = @core.new_kvector()
        change_coord_system(offset, ch_edge.get_graph(), reference_graph)

        let ledge = ch_edge.get_edge()
        let bend_points = @core.new_kvector_chain()
        bend_points.add_all_as_copies(0, ledge.get_bend_points())
        ignore(bend_points.offset(offset))

        let source_point = @core.new_kvector_copy(
          compound_graph_postprocessor_require_source_port(ledge).get_absolute_anchor(),
        )
        let target_point = @core.new_kvector_copy(
          compound_graph_postprocessor_require_target_port(ledge).get_absolute_anchor(),
        )
        ignore(source_point.add(offset))
        ignore(target_point.add(offset))

        match last_point {
          Some(last) => {
            let next_point = if bend_points.is_empty() {
              target_point
            } else {
              bend_points.get(0)
            }
            let x_diff_enough = (last.x - next_point.x).abs() >
              orthogonal_routing_generator_tolerance
            let y_diff_enough = (last.y - next_point.y).abs() >
              orthogonal_routing_generator_tolerance

            if (!add_unnecessary_bendpoints && x_diff_enough && y_diff_enough) ||
              (add_unnecessary_bendpoints && (x_diff_enough || y_diff_enough)) {
              orig_edge.get_bend_points().add_vector(source_point)
            }
          }
          None => ()
        }

        orig_edge.get_bend_points().add_all(bend_points.to_array())

        if bend_points.is_empty() {
          last_point = Some(source_point)
        } else {
          last_point = Some(bend_points.get(bend_points.size() - 1))
        }

        compound_graph_postprocessor_copy_junction_points(
          ledge, junction_points, offset,
        )

        if ch_edge.get_actual_target().get_handle() == target_port.get_handle() {
          let target_offset = @core.new_kvector_copy(offset)
          if compound_graph_postprocessor_require_port_node(target_port)
            .get_graph()
            .get_handle() !=
            ch_edge.get_graph().get_handle() {
            ignore(target_offset.reset())
            change_coord_system(
              target_offset,
              compound_graph_postprocessor_require_port_node(target_port).get_graph(),
              reference_graph,
            )
          }
          orig_edge.set_property_kvector(
            compound_graph_postprocessor_internal_properties_target_offset, target_offset,
          )
        }

        compound_graph_postprocessor_copy_labels_back(
          ledge, orig_edge, reference_graph,
        )
        dummy_edges.push(ledge)
      }

      orig_edge.set_source(Some(source_port))
      orig_edge.set_target(Some(target_port))
    }
  } catch {
    CompoundGraphPostprocessorException::UnsupportedGraphException(message) => {
      @core.layout_runtime_report_unsupported_configuration(message)
      monitor.done()
      return
    }
  } noraise {
    _ => ()
  }

  for dummy_edge in dummy_edges {
    dummy_edge.set_source(None)
    dummy_edge.set_target(None)
  }

  monitor.done()
}

///|
pub fn new_compound_graph_postprocessor_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(compound_graph_postprocessor_process)
}
