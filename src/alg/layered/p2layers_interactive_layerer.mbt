///|
struct InteractiveLayererLayerSpan {
  mut start : Double
  mut end : Double
  nodes : Array[LNode]
}

///|
fn interactive_layerer_layer_constraint_preprocessor_factory() -> @core.ILayoutProcessorFactory[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor_factory(23007, 7, () => {
    new_layer_constraint_preprocessor_layout_processor()
  })
}

///|
fn interactive_layerer_layer_constraint_postprocessor_factory() -> @core.ILayoutProcessorFactory[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor_factory(23011, 11, () => {
    new_layer_constraint_postprocessor_layout_processor()
  })
}

///|
fn interactive_layerer_require_edge_target_node(edge : LEdge) -> LNode {
  let target = match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target port")
  }
  match target.get_node() {
    Some(value) => value
    None => abort("target port has no owner node")
  }
}

///|
fn interactive_layerer_require_node_layer(node : LNode) -> Layer {
  match node.get_layer() {
    Some(value) => value
    None => abort("node has no layer")
  }
}

///|
fn interactive_layerer_push_unique_nodes(
  target : Array[LNode],
  nodes : Array[LNode],
) -> Unit {
  for node in nodes {
    let mut exists = false
    for existing in target {
      if lnode_internal_handle(existing) == lnode_internal_handle(node) {
        exists = true
        break
      }
    }
    if !exists {
      target.push(node)
    }
  }
}

///|
fn interactive_layerer_insert_node_into_spans(
  current_spans : Array[InteractiveLayererLayerSpan],
  node : LNode,
) -> Unit {
  let minx = node.get_position().x
  let mut maxx = minx + node.get_size().x
  if maxx < minx + 1.0 {
    maxx = minx + 1.0
  }

  let mut insert_index = current_spans.length()
  let mut found_span_index = -1
  let mut i = 0
  while i < current_spans.length() {
    let span = current_spans[i]
    if span.start >= maxx {
      insert_index = i
      break
    } else if span.end > minx {
      if found_span_index < 0 {
        span.nodes.push(node)
        if minx < span.start {
          span.start = minx
        }
        if maxx > span.end {
          span.end = maxx
        }
        found_span_index = i
      } else {
        let found_span = current_spans[found_span_index]
        for existing in span.nodes {
          found_span.nodes.push(existing)
        }
        if span.end > found_span.end {
          found_span.end = span.end
        }
        ignore(current_spans.remove(i))
        continue
      }
    }
    i += 1
  }

  if found_span_index < 0 {
    let span : InteractiveLayererLayerSpan = {
      start: minx,
      end: maxx,
      nodes: [node],
    }
    ignore(current_spans.insert(insert_index, span))
  }
}

///|
fn interactive_layerer_check_node(
  node1 : LNode,
  graph : LGraph,
) -> Array[LNode] {
  node1.set_id(1)
  let layer1 = interactive_layerer_require_node_layer(node1)
  let shift_nodes = []
  for port in node1.get_ports_by_type(PortType::Output) {
    for edge in port.get_outgoing_edges() {
      let node2 = interactive_layerer_require_edge_target_node(edge)
      if lnode_internal_handle(node1) != lnode_internal_handle(node2) {
        let layer2 = interactive_layerer_require_node_layer(node2)
        if layer2.get_id() <= layer1.get_id() {
          let new_index = layer1.get_id() + 1
          if new_index == graph.get_layers().length() {
            let new_layer = new_layer(graph)
            new_layer.set_id(new_index)
            graph.get_layers().push(new_layer)
            node2.set_layer(Some(new_layer))
          } else {
            let new_layer = graph.get_layers()[new_index]
            node2.set_layer(Some(new_layer))
          }

          let mut exists = false
          for shifted in shift_nodes {
            if lnode_internal_handle(shifted) == lnode_internal_handle(node2) {
              exists = true
              break
            }
          }
          if !exists {
            shift_nodes.push(node2)
          }
        }
      }
    }
  }
  shift_nodes
}

///|
fn interactive_layerer_configuration(
  graph : LGraph,
) -> @core.LayoutProcessorConfiguration[LayeredPhases, LGraph]? {
  ignore(graph)
  Some(
    @core.layout_processor_configuration_create(layered_phase_descriptor)
    .add_before(
      LayeredPhases::P1CycleBreaking,
      layered_intermediate_processor_factory(
        IntermediateProcessorStrategy::InteractiveExternalPortPositioner,
      ),
    )
    .add_before(
      LayeredPhases::P2Layering,
      interactive_layerer_layer_constraint_preprocessor_factory(),
    )
    .add_before(
      LayeredPhases::P3NodeOrdering,
      interactive_layerer_layer_constraint_postprocessor_factory(),
    ),
  )
}

///|
fn interactive_layerer_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Interactive node layering", 1.0))

  let current_spans = []
  for node in layered_graph.get_layerless_nodes() {
    interactive_layerer_insert_node_into_spans(current_spans, node)
  }

  let layers = layered_graph.get_layers()
  let mut next_index = 0
  for span in current_spans {
    let layer = new_layer(layered_graph)
    layer.set_id(next_index)
    next_index += 1
    layers.push(layer)
    for node in span.nodes {
      node.set_layer(Some(layer))
      node.set_id(0)
    }
  }

  for node in layered_graph.get_layerless_nodes() {
    if node.get_id() == 0 {
      let shifted_nodes = interactive_layerer_check_node(node, layered_graph)
      while !shifted_nodes.is_empty() {
        let node_to_check = shifted_nodes[0]
        ignore(shifted_nodes.remove(0))
        interactive_layerer_push_unique_nodes(
          shifted_nodes,
          interactive_layerer_check_node(node_to_check, layered_graph),
        )
      }
    }
  }

  let mut i = 0
  while i < layers.length() {
    if layers[i].get_nodes().is_empty() {
      ignore(layers.remove(i))
    } else {
      i += 1
    }
  }

  layered_graph.get_layerless_nodes().clear()
  monitor.done()
}

///|
pub fn new_interactive_layerer_layout_phase() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_phase(
    interactive_layerer_process, interactive_layerer_configuration,
  )
}
