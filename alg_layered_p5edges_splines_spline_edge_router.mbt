///|
let spline_edge_router_max_vertical_diff_for_straight : Double = 0.2

///|
pub let spline_edge_router_spline_dimension : Int = 3

///|
pub enum SplineSideToProcess {
  Left
  Right
}

///|
pub fn spline_side_to_process_values() -> Array[SplineSideToProcess] {
  [Left, Right]
}

///|
pub fn spline_side_to_process_to_string(side : SplineSideToProcess) -> String {
  match side {
    Left => "LEFT"
    Right => "RIGHT"
  }
}

///|
pub struct SplineDependency {
  mut source : SplineSegment?
  mut target : SplineSegment?
  weight : Int
}

///|
pub fn new_spline_dependency(
  source : SplineSegment,
  target : SplineSegment,
  weight : Int,
) -> SplineDependency {
  let dependency = { source: Some(source), target: Some(target), weight }
  source.outgoing.push(dependency)
  target.incoming.push(dependency)
  dependency
}

///|
pub fn SplineDependency::to_string(self : SplineDependency) -> String {
  let source_mark = match self.source {
    Some(segment) => segment.mark.to_string()
    None => "null"
  }
  let target_mark = match self.target {
    Some(segment) => segment.mark.to_string()
    None => "null"
  }
  source_mark + " ->(" + self.weight.to_string() + ") " + target_mark
}

///|
pub fn spline_edge_router_is_straight(
  first_y : Double,
  second_y : Double,
) -> Bool {
  (first_y - second_y).abs() < spline_edge_router_max_vertical_diff_for_straight
}

///|
pub fn spline_edge_router_is_normal_node(node : LNode) -> Bool {
  match node.get_type() {
    NodeType::Normal => true
    NodeType::BreakingPoint => true
    _ => false
  }
}

///|
pub fn spline_edge_router_is_qualified_as_starting_node(node : LNode) -> Bool {
  match node.get_type() {
    NodeType::Normal => true
    NodeType::NorthSouthPort => true
    NodeType::ExternalPort => true
    NodeType::BreakingPoint => true
    _ => false
  }
}

///|
fn spline_edge_router_graph_property_equals(
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
fn spline_edge_router_graph_properties_contain(
  properties : Array[GraphProperties],
  property : GraphProperties,
) -> Bool {
  for candidate in properties {
    if spline_edge_router_graph_property_equals(candidate, property) {
      return true
    }
  }
  false
}

///|
fn spline_edge_router_edge_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(source) => source
    None => abort("edge source is not connected")
  }
}

///|
fn spline_edge_router_edge_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(target) => target
    None => abort("edge target is not connected")
  }
}

///|
fn spline_edge_router_port_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(node) => node
    None => abort("port is not attached to a node")
  }
}

///|
fn spline_edge_router_segment_identity(segment : SplineSegment) -> Int {
  if segment.edges.is_empty() {
    abort("segment must contain at least one edge")
  }
  ledge_internal_handle(segment.edges[0])
}

///|
fn spline_edge_router_dependency_source(dependency : SplineDependency) -> SplineSegment {
  match dependency.source {
    Some(source) => source
    None => abort("dependency source is missing")
  }
}

///|
fn spline_edge_router_dependency_target(dependency : SplineDependency) -> SplineSegment {
  match dependency.target {
    Some(target) => target
    None => abort("dependency target is missing")
  }
}

///|
fn spline_edge_router_segment_set_contains(
  segments : Array[SplineSegment],
  candidate : SplineSegment,
) -> Bool {
  let wanted = spline_edge_router_segment_identity(candidate)
  for segment in segments {
    if spline_edge_router_segment_identity(segment) == wanted {
      return true
    }
  }
  false
}

///|
fn spline_edge_router_segment_set_add(
  segments : Array[SplineSegment],
  candidate : SplineSegment,
) -> Unit {
  if !spline_edge_router_segment_set_contains(segments, candidate) {
    segments.push(candidate)
  }
}

///|
fn spline_edge_router_segment_set_remove(
  segments : Array[SplineSegment],
  candidate : SplineSegment,
) -> Bool {
  let wanted = spline_edge_router_segment_identity(candidate)
  for i in 0..<segments.length() {
    if spline_edge_router_segment_identity(segments[i]) == wanted {
      ignore(segments.remove(i))
      return true
    }
  }
  false
}

///|
fn spline_edge_router_dependency_equals(
  left : SplineDependency,
  right : SplineDependency,
) -> Bool {
  left.weight == right.weight &&
  spline_edge_router_segment_identity(
    spline_edge_router_dependency_source(left),
  ) == spline_edge_router_segment_identity(
    spline_edge_router_dependency_source(right),
  ) &&
  spline_edge_router_segment_identity(
    spline_edge_router_dependency_target(left),
  ) == spline_edge_router_segment_identity(
    spline_edge_router_dependency_target(right),
  )
}

///|
fn spline_edge_router_dependency_remove(
  dependencies : Array[SplineDependency],
  dependency : SplineDependency,
) -> Bool {
  for i in 0..<dependencies.length() {
    if spline_edge_router_dependency_equals(dependencies[i], dependency) {
      ignore(dependencies.remove(i))
      return true
    }
  }
  false
}

///|
fn spline_edge_router_compute_sloppy_spacing(
  right_layer : Layer,
  edge_edge_spacing : Double,
  node_node_spacing : Double,
  sloppy_layer_spacing_factor : Double,
) -> Double {
  let mut max_vert_diff = 0.0
  for node in right_layer.get_nodes() {
    let mut max_curr_input_y_diff = 0.0
    for incoming_edge in node.get_incoming_edges() {
      let source_pos =
        spline_edge_router_edge_source(incoming_edge).get_absolute_anchor().y
      let target_pos =
        spline_edge_router_edge_target(incoming_edge).get_absolute_anchor().y
      let diff = (target_pos - source_pos).abs()
      if diff > max_curr_input_y_diff {
        max_curr_input_y_diff = diff
      }
    }
    if max_curr_input_y_diff > max_vert_diff {
      max_vert_diff = max_curr_input_y_diff
    }
  }

  let spacing_ratio = @cmp.minimum(1.0, edge_edge_spacing / node_node_spacing)
  sloppy_layer_spacing_factor * spacing_ratio * max_vert_diff
}

///|
fn spline_edge_router_create_dependency(
  edge0 : SplineSegment,
  edge1 : SplineSegment,
) -> Unit {
  if edge0.hyper_edge_top_y_pos > edge1.hyper_edge_bottom_y_pos ||
    edge1.hyper_edge_top_y_pos > edge0.hyper_edge_bottom_y_pos {
    return
  }

  let mut edge0_counter = 0
  let mut edge1_counter = 0

  for port in edge0.right_ports {
    if splines_math_is_between_double(
      port.get_absolute_anchor().y,
      edge1.hyper_edge_top_y_pos,
      edge1.hyper_edge_bottom_y_pos,
    ) {
      edge0_counter += 1
    }
  }
  for port in edge0.left_ports {
    if splines_math_is_between_double(
      port.get_absolute_anchor().y,
      edge1.hyper_edge_top_y_pos,
      edge1.hyper_edge_bottom_y_pos,
    ) {
      edge0_counter -= 1
    }
  }
  for port in edge1.right_ports {
    if splines_math_is_between_double(
      port.get_absolute_anchor().y,
      edge0.hyper_edge_top_y_pos,
      edge0.hyper_edge_bottom_y_pos,
    ) {
      edge1_counter += 1
    }
  }
  for port in edge1.left_ports {
    if splines_math_is_between_double(
      port.get_absolute_anchor().y,
      edge0.hyper_edge_top_y_pos,
      edge0.hyper_edge_bottom_y_pos,
    ) {
      edge1_counter -= 1
    }
  }

  if edge0_counter < edge1_counter {
    ignore(new_spline_dependency(edge0, edge1, edge1_counter - edge0_counter))
  } else if edge1_counter < edge0_counter {
    ignore(new_spline_dependency(edge1, edge0, edge0_counter - edge1_counter))
  } else {
    ignore(new_spline_dependency(edge1, edge0, 0))
    ignore(new_spline_dependency(edge0, edge1, 0))
  }
}

///|
fn spline_edge_router_update_neighbors(
  edge : SplineSegment,
  sources : Array[SplineSegment],
  sinks : Array[SplineSegment],
) -> Unit {
  for dependency in edge.outgoing {
    let target = spline_edge_router_dependency_target(dependency)
    if target.mark < 0 && dependency.weight > 0 {
      target.inweight -= dependency.weight
      if target.inweight <= 0 && target.outweight > 0 {
        spline_edge_router_segment_set_add(sources, target)
      }
    }
  }

  for dependency in edge.incoming {
    let source = spline_edge_router_dependency_source(dependency)
    if source.mark < 0 && dependency.weight > 0 {
      source.outweight -= dependency.weight
      if source.outweight <= 0 && source.inweight > 0 {
        spline_edge_router_segment_set_add(sinks, source)
      }
    }
  }
}

///|
fn spline_edge_router_break_cycles(
  edges : Array[SplineSegment],
  random : @random.Rand,
) -> Unit {
  let sources : Array[SplineSegment] = []
  let sinks : Array[SplineSegment] = []

  let mut next_mark = -1
  for edge in edges {
    edge.mark = next_mark
    next_mark -= 1

    let mut inweight = 0
    let mut outweight = 0
    for dependency in edge.outgoing {
      outweight += dependency.weight
    }
    for dependency in edge.incoming {
      inweight += dependency.weight
    }
    edge.inweight = inweight
    edge.outweight = outweight

    if outweight == 0 {
      sinks.push(edge)
    } else if inweight == 0 {
      sources.push(edge)
    }
  }

  let unprocessed = edges.copy()
  let mark_base = edges.length()
  let mut next_left = mark_base + 1
  let mut next_right = mark_base - 1
  let max_edges : Array[SplineSegment] = []

  while !unprocessed.is_empty() {
    while !sinks.is_empty() {
      let sink = sinks[0]
      ignore(sinks.remove(0))
      ignore(spline_edge_router_segment_set_remove(unprocessed, sink))
      sink.mark = next_right
      next_right -= 1
      spline_edge_router_update_neighbors(sink, sources, sinks)
    }

    while !sources.is_empty() {
      let source = sources[0]
      ignore(sources.remove(0))
      ignore(spline_edge_router_segment_set_remove(unprocessed, source))
      source.mark = next_left
      next_left += 1
      spline_edge_router_update_neighbors(source, sources, sinks)
    }

    let mut max_outflow = @int.min_value
    for edge in unprocessed {
      let outflow = edge.outweight - edge.inweight
      if outflow >= max_outflow {
        if outflow > max_outflow {
          max_edges.clear()
          max_outflow = outflow
        }
        max_edges.push(edge)
      }
    }

    if !max_edges.is_empty() {
      let index = random.int(limit=max_edges.length())
      let max_edge = max_edges[index]
      ignore(spline_edge_router_segment_set_remove(unprocessed, max_edge))
      max_edge.mark = next_left
      next_left += 1
      spline_edge_router_update_neighbors(max_edge, sources, sinks)
      max_edges.clear()
    }
  }

  let shift_base = edges.length() + 1
  for edge in edges {
    if edge.mark < mark_base {
      edge.mark += shift_base
    }
  }

  for source in edges {
    let mut index = 0
    while index < source.outgoing.length() {
      let dependency = source.outgoing[index]
      let target = spline_edge_router_dependency_target(dependency)
      if source.mark > target.mark {
        ignore(source.outgoing.remove(index))
        ignore(spline_edge_router_dependency_remove(target.incoming, dependency))

        if dependency.weight > 0 {
          dependency.source = Some(target)
          target.outgoing.push(dependency)
          dependency.target = Some(source)
          source.incoming.push(dependency)
        }
      } else {
        index += 1
      }
    }
  }
}

///|
fn spline_edge_router_topological_numbering(edges : Array[SplineSegment]) -> Unit {
  let sources : Array[SplineSegment] = []
  let rightward_targets : Array[SplineSegment] = []

  for edge in edges {
    edge.rank = 0
    edge.inweight = edge.incoming.length()
    edge.outweight = edge.outgoing.length()

    if edge.inweight == 0 {
      sources.push(edge)
    }
    if edge.outweight == 0 && edge.left_ports.is_empty() {
      rightward_targets.push(edge)
    }
  }

  let mut max_rank = -1
  while !sources.is_empty() {
    let edge = sources[0]
    ignore(sources.remove(0))
    for dependency in edge.outgoing {
      let target = spline_edge_router_dependency_target(dependency)
      target.rank = @cmp.maximum(target.rank, edge.rank + 1)
      max_rank = @cmp.maximum(max_rank, target.rank)

      target.inweight -= 1
      if target.inweight == 0 {
        sources.push(target)
      }
    }
  }

  if max_rank > -1 {
    for edge in rightward_targets {
      edge.rank = max_rank
    }

    while !rightward_targets.is_empty() {
      let edge = rightward_targets[0]
      ignore(rightward_targets.remove(0))

      for dependency in edge.incoming {
        let source = spline_edge_router_dependency_source(dependency)
        if !source.left_ports.is_empty() {
          continue
        }

        source.rank = @cmp.minimum(source.rank, edge.rank - 1)
        source.outweight -= 1
        if source.outweight == 0 {
          rightward_targets.push(source)
        }
      }
    }
  }
}

///|
fn spline_edge_router_get_edge_chain(
  start : LEdge,
  successing_edge : Map[Int, LEdge],
) -> Array[LEdge] {
  let edge_chain : Array[LEdge] = []
  let mut current : LEdge? = Some(start)
  while current is Some(edge) {
    edge_chain.push(edge)
    current = successing_edge.get(ledge_internal_handle(edge))
  }
  edge_chain
}

///|
fn spline_edge_router_get_spline_path(
  start : LEdge,
  successing_edge : Map[Int, LEdge],
  edge_to_segment_map : Map[Int, SplineSegment],
) -> Array[SplineSegment] {
  let segment_chain : Array[SplineSegment] = []
  let mut current : LEdge? = Some(start)

  while current is Some(edge) {
    let segment = match edge_to_segment_map.get(ledge_internal_handle(edge)) {
      Some(value) => value
      None => abort("segment mapping missing for edge")
    }
    segment.source_port = edge.get_source()
    segment.target_port = edge.get_target()
    segment_chain.push(segment)
    current = successing_edge.get(ledge_internal_handle(edge))
  }

  if segment_chain.is_empty() {
    return segment_chain
  }

  let initial_segment = segment_chain[0]
  initial_segment.initial_segment = true
  let initial_edge = initial_segment.edges[0]
  let initial_source = spline_edge_router_edge_source(initial_edge)
  initial_segment.source_node = Some(spline_edge_router_port_node(initial_source))

  let last_segment = segment_chain[segment_chain.length() - 1]
  last_segment.last_segment = true
  let last_edge = last_segment.edges[last_segment.edges.length() - 1]
  let last_target = spline_edge_router_edge_target(last_edge)
  last_segment.target_node = Some(spline_edge_router_port_node(last_target))

  segment_chain
}

///|
fn spline_edge_router_configuration(
  graph : LGraph,
) -> LayoutProcessorConfiguration[LayeredPhases, LGraph]? {
  let configuration = layout_processor_configuration_create(layered_phase_descriptor)
  ignore(
    configuration
    .add_after(
        LayeredPhases::P5EdgeRouting,
        layered_intermediate_processor_factory(
          IntermediateProcessorStrategy::FinalSplineBendpointsCalculator,
        ),
      )
    .add_before(
        LayeredPhases::P3NodeOrdering,
        layered_intermediate_processor_factory(
          IntermediateProcessorStrategy::InvertedPortProcessor,
        ),
      ),
  )

  let graph_properties = graph.get_property_graph_properties_array(
    internal_properties_graph_properties,
  )

  if spline_edge_router_graph_properties_contain(graph_properties, SelfLoops) {
    ignore(
      configuration
      .add_before(
          LayeredPhases::P1CycleBreaking,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::SelfLoopPreprocessor,
          ),
        )
      .add_after(
          LayeredPhases::P5EdgeRouting,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::SelfLoopPostprocessor,
          ),
        )
      .before(LayeredPhases::P4NodePlacement)
      .add(
        layered_intermediate_processor_factory(
          IntermediateProcessorStrategy::SelfLoopPortRestorer,
        ),
      )
      .add(
        layered_intermediate_processor_factory(
          IntermediateProcessorStrategy::SelfLoopRouter,
        ),
      ),
    )
  }

  if spline_edge_router_graph_properties_contain(graph_properties, CenterLabels) {
    ignore(
      configuration
      .add_before(
          LayeredPhases::P2Layering,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::LabelDummyInserter,
          ),
        )
      .add_before(
          LayeredPhases::P4NodePlacement,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::LabelDummySwitcher,
          ),
        )
      .add_before(
          LayeredPhases::P4NodePlacement,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::LabelSideSelector,
          ),
        )
      .add_after(
          LayeredPhases::P5EdgeRouting,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::LabelDummyRemover,
          ),
        ),
    )
  }

  if spline_edge_router_graph_properties_contain(graph_properties, NorthSouthPorts) {
    ignore(
      configuration
      .add_before(
          LayeredPhases::P3NodeOrdering,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::NorthSouthPortPreprocessor,
          ),
        )
      .add_before(
          LayeredPhases::P5EdgeRouting,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::NorthSouthPortPostprocessor,
          ),
        ),
    )
  }

  if spline_edge_router_graph_properties_contain(graph_properties, EndLabels) {
    ignore(
      configuration
      .add_before(
          LayeredPhases::P4NodePlacement,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::LabelSideSelector,
          ),
        )
      .add_before(
          LayeredPhases::P4NodePlacement,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::EndLabelPreprocessor,
          ),
        )
      .add_after(
          LayeredPhases::P5EdgeRouting,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::EndLabelPostprocessor,
          ),
        ),
    )
  }

  Some(configuration)
}

///|
fn spline_edge_router_process(
  layered_graph : LGraph,
  monitor : IElkProgressMonitor?,
) -> Unit {
  ignore(layered_graph)
  let actual_monitor = match monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(actual_monitor.begin("Spline edge routing", 1.0))
  actual_monitor.done()
}

///|
pub fn new_spline_edge_router_layout_phase() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_phase(spline_edge_router_process, spline_edge_router_configuration)
}
