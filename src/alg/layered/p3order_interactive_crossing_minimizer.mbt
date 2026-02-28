///|
fn interactive_crossing_minimizer_to_node_array(
  graph : LGraph,
) -> Array[Array[LNode]] {
  let order = []
  for layer in graph.get_layers() {
    order.push(layer.get_nodes())
  }
  order
}

///|
fn interactive_crossing_minimizer_contains_node(
  nodes : Array[LNode],
  candidate : LNode,
) -> Bool {
  for node in nodes {
    if lnode_internal_handle(node) == lnode_internal_handle(candidate) {
      return true
    }
  }
  false
}

///|
fn interactive_crossing_minimizer_compare_doubles(
  left : Double,
  right : Double,
) -> Int {
  if left < right {
    -1
  } else if left > right {
    1
  } else {
    0
  }
}

///|
fn interactive_crossing_minimizer_get_pos(
  node : LNode,
  horiz_pos : Double,
) -> Double {
  ignore(horiz_pos)
  match node.get_type() {
    NodeType::NorthSouthPort => {
      let ports = node.get_ports()
      if ports.is_empty() {
        return node.get_position().y
      }
      let origin_port = match
        ports[0].get_property_l_port(internal_properties_origin_l_port) {
        Some(port) => port
        None => return node.get_position().y
      }
      let origin_node = match origin_port.get_node() {
        Some(value) => value
        None => return node.get_position().y
      }
      match origin_port.get_side() {
        @core.PortSide::North => origin_node.get_position().y
        @core.PortSide::South =>
          origin_node.get_position().y + origin_node.get_size().y
        _ => node.get_position().y
      }
    }
    _ => node.get_position().y
  }
}

///|
fn interactive_crossing_minimizer_sort_nodes(
  nodes : Array[LNode],
  node_pos : Array[Double],
) -> Unit {
  let mut i = 1
  while i < nodes.length() {
    let node = nodes[i]
    let mut j = i
    while j > 0 {
      let left = nodes[j - 1]
      let mut compare = interactive_crossing_minimizer_compare_doubles(
        node_pos[left.get_id()],
        node_pos[node.get_id()],
      )

      if compare == 0 {
        let left_successors = left.get_property_l_node_array(
          internal_properties_in_layer_successor_constraints,
        )
        let right_successors = node.get_property_l_node_array(
          internal_properties_in_layer_successor_constraints,
        )
        if interactive_crossing_minimizer_contains_node(left_successors, node) {
          compare = -1
        } else if interactive_crossing_minimizer_contains_node(
            right_successors, left,
          ) {
          compare = 1
        }
      }

      if compare <= 0 {
        break
      }
      nodes[j] = nodes[j - 1]
      j = j - 1
    }
    nodes[j] = node
    i = i + 1
  }
}

///|
fn interactive_crossing_minimizer_intermediate_configuration() -> @core.LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] {
  @core.layout_processor_configuration_create(layered_phase_descriptor)
  .add_before(
    LayeredPhases::P3NodeOrdering,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::LongEdgeSplitter,
    ),
  )
  .add_before(
    LayeredPhases::P4NodePlacement,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::InLayerConstraintProcessor,
    ),
  )
  .after(LayeredPhases::P5EdgeRouting)
  .add(
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::LongEdgeJoiner,
    ),
  )
}

///|
let interactive_crossing_minimizer_default_configuration : @core.LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] = interactive_crossing_minimizer_intermediate_configuration()

///|
fn interactive_crossing_minimizer_configuration(
  graph : LGraph,
) -> @core.LayoutProcessorConfiguration[LayeredPhases, LGraph]? {
  ignore(graph)
  let configuration = @core.layout_processor_configuration_create_from(
    interactive_crossing_minimizer_default_configuration,
  )
  ignore(
    configuration.add_before(
      LayeredPhases::P3NodeOrdering,
      layered_intermediate_processor_factory(
        IntermediateProcessorStrategy::PortListSorter,
      ),
    ),
  )
  Some(configuration)
}

///|
fn interactive_crossing_minimizer_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Interactive crossing minimization", 1.0))

  let mut layer_index = 0
  for layer in layered_graph.get_layers() {
    layer.set_id(layer_index)
    layer_index = layer_index + 1
  }

  let node_order = interactive_crossing_minimizer_to_node_array(layered_graph)
  let port_distributor = new_node_relative_port_distributor(node_order.length())
  i_initializable_init([port_distributor.as_initializable()], node_order)

  let mut port_count = 0
  layer_index = 0
  for layer in layered_graph.get_layers() {
    let mut horiz_pos = 0.0
    let mut node_count = 0
    for node in layer.get_nodes() {
      if node.get_position().x > 0.0 {
        horiz_pos = horiz_pos + node.get_position().x + node.get_size().x / 2.0
        node_count = node_count + 1
      }
      for port in node.get_ports() {
        port.set_id(port_count)
        port_count = port_count + 1
      }
    }
    if node_count > 0 {
      horiz_pos = horiz_pos / node_count.to_double()
    }

    let nodes = layer.get_nodes()
    let node_pos = Array::make(nodes.length(), 0.0)
    for i in 0..<nodes.length() {
      let node = nodes[i]
      node.set_id(i)
      let position = interactive_crossing_minimizer_get_pos(node, horiz_pos)
      node_pos[node.get_id()] = position
      match node.get_type() {
        NodeType::LongEdge =>
          node.set_property_double(
            internal_properties_original_dummy_node_position, position,
          )
        _ => ()
      }
    }

    interactive_crossing_minimizer_sort_nodes(nodes, node_pos)
    ignore(
      port_distributor.distribute_ports_while_sweeping(
        node_order, layer_index, true,
      ),
    )
    layer_index = layer_index + 1
  }

  monitor.done()
}

///|
pub fn new_interactive_crossing_minimizer_layout_phase() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_phase(
    interactive_crossing_minimizer_process, interactive_crossing_minimizer_configuration,
  )
}
