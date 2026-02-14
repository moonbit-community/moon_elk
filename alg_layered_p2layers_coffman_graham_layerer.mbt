///|
let layered_options_layering_coffman_graham_layer_bound : IProperty[Int] = new_property(
  "org.eclipse.elk.layered.layering.coffmanGraham.layerBound", @int.max_value,
)

///|
fn coffman_graham_layerer_layer_constraint_preprocessor_factory() -> ILayoutProcessorFactory[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor_factory(23027, 27, () => {
    new_layer_constraint_preprocessor_layout_processor()
  })
}

///|
fn coffman_graham_layerer_layer_constraint_postprocessor_factory() -> ILayoutProcessorFactory[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor_factory(23028, 28, () => {
    new_layer_constraint_postprocessor_layout_processor()
  })
}

///|
let coffman_graham_layerer_baseline_processing_configuration : LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] = layout_processor_configuration_create(layered_phase_descriptor)
  .add_before(
    LayeredPhases::P1CycleBreaking,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::EdgeAndLayerConstraintEdgeReverser,
    ),
  )
  .add_before(
    LayeredPhases::P2Layering,
    coffman_graham_layerer_layer_constraint_preprocessor_factory(),
  )
  .add_before(
    LayeredPhases::P3NodeOrdering,
    coffman_graham_layerer_layer_constraint_postprocessor_factory(),
  )

///|
fn coffman_graham_layerer_require_edge_source_node(edge : LEdge) -> LNode {
  let source = match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source port")
  }
  match source.get_node() {
    Some(value) => value
    None => abort("source port has no owner node")
  }
}

///|
fn coffman_graham_layerer_require_edge_target_node(edge : LEdge) -> LNode {
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
fn coffman_graham_layerer_compare_nodes_in_topo(
  in_topo : Array[Array[Int]],
  u : LNode,
  v : LNode,
) -> Int {
  let in_list_u = in_topo[u.get_id()]
  let in_list_v = in_topo[v.get_id()]
  let mut index_u = in_list_u.length()
  let mut index_v = in_list_v.length()

  while index_u > 0 && index_v > 0 {
    index_u -= 1
    index_v -= 1
    let iu = in_list_u[index_u]
    let iv = in_list_v[index_v]
    if iu != iv {
      return if iu < iv { -1 } else { 1 }
    }
  }

  if index_u >= in_list_u.length() && index_v >= in_list_v.length() {
    if u.get_id() < v.get_id() {
      -1
    } else if u.get_id() > v.get_id() {
      1
    } else {
      0
    }
  } else if index_u >= in_list_u.length() {
    -1
  } else {
    1
  }
}

///|
fn coffman_graham_layerer_insert_source(
  sources : Array[LNode],
  in_topo : Array[Array[Int]],
  node : LNode,
) -> Unit {
  let mut insert_index = 0
  while insert_index < sources.length() &&
        coffman_graham_layerer_compare_nodes_in_topo(
          in_topo,
          sources[insert_index],
          node,
        ) <=
        0 {
    insert_index += 1
  }
  ignore(sources.insert(insert_index, node))
}

///|
fn coffman_graham_layerer_insert_sink(
  sinks : Array[LNode],
  topo_ord : Array[Int],
  node : LNode,
) -> Unit {
  let node_topo = topo_ord[node.get_id()]
  let mut insert_index = 0
  while insert_index < sinks.length() &&
        topo_ord[sinks[insert_index].get_id()] >= node_topo {
    insert_index += 1
  }
  ignore(sinks.insert(insert_index, node))
}

///|
fn coffman_graham_layerer_layer_equals(left : Layer?, right : Layer) -> Bool {
  match left {
    Some(value) => layer_internal_handle(value) == layer_internal_handle(right)
    None => false
  }
}

///|
fn coffman_graham_layerer_can_add(node : LNode, layer : Layer) -> Bool {
  for edge in node.get_outgoing_edges() {
    let target = coffman_graham_layerer_require_edge_target_node(edge)
    if coffman_graham_layerer_layer_equals(target.get_layer(), layer) {
      return false
    }
  }
  true
}

///|
fn coffman_graham_layerer_create_layer(
  graph : LGraph,
  layers : Array[Layer],
) -> Layer {
  let a_layer = new_layer(graph)
  layers.push(a_layer)
  a_layer
}

///|
fn coffman_graham_layerer_dfs(
  start : LNode,
  node : LNode,
  node_mark : Array[Bool],
  edge_mark : Array[Bool],
) -> Unit {
  if node_mark[node.get_id()] {
    return
  }

  for out in node.get_outgoing_edges() {
    let w = coffman_graham_layerer_require_edge_target_node(out)
    for transitive in w.get_incoming_edges() {
      let source = coffman_graham_layerer_require_edge_source_node(transitive)
      if lnode_internal_handle(source) == lnode_internal_handle(start) {
        edge_mark[transitive.get_id()] = true
      }
    }
    coffman_graham_layerer_dfs(start, w, node_mark, edge_mark)
  }

  node_mark[node.get_id()] = true
}

///|
fn coffman_graham_layerer_transitive_reduction(
  graph : LGraph,
  node_mark : Array[Bool],
  edge_mark : Array[Bool],
) -> Unit {
  for start in graph.get_layerless_nodes() {
    let mut i = 0
    while i < node_mark.length() {
      node_mark[i] = false
      i += 1
    }
    for out in start.get_outgoing_edges() {
      let target = coffman_graham_layerer_require_edge_target_node(out)
      coffman_graham_layerer_dfs(start, target, node_mark, edge_mark)
    }
  }
}

///|
fn coffman_graham_layerer_configuration(
  graph : LGraph,
) -> LayoutProcessorConfiguration[LayeredPhases, LGraph]? {
  ignore(graph)
  Some(coffman_graham_layerer_baseline_processing_configuration)
}

///|
fn coffman_graham_layerer_process(
  layered_graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Coffman-Graham Layering", 1.0))

  if layered_graph.get_layerless_nodes().is_empty() {
    monitor.done()
    return
  }

  let layer_bound = layered_graph.get_property_int(
    layered_options_layering_coffman_graham_layer_bound,
  )

  let mut index = 0
  let mut edge_index = 0
  for node in layered_graph.get_layerless_nodes() {
    node.set_id(index)
    index += 1
    for edge in node.get_outgoing_edges() {
      edge.set_id(edge_index)
      edge_index += 1
    }
  }

  let node_mark = Array::make(index, false)
  let edge_mark = Array::make(edge_index, false)
  let in_deg = Array::make(index, 0)
  let out_deg = Array::make(index, 0)
  let topo_ord = Array::make(index, 0)
  let in_topo = []
  for _ in 0..<index {
    in_topo.push([])
  }

  coffman_graham_layerer_transitive_reduction(
    layered_graph, node_mark, edge_mark,
  )

  let sources = []
  for v in layered_graph.get_layerless_nodes() {
    for edge in v.get_incoming_edges() {
      if !edge_mark[edge.get_id()] {
        in_deg[v.get_id()] += 1
      }
    }
    if in_deg[v.get_id()] == 0 {
      coffman_graham_layerer_insert_source(sources, in_topo, v)
    }
  }

  let mut topo_index = 0
  while !sources.is_empty() {
    let v = sources[0]
    ignore(sources.remove(0))
    topo_ord[v.get_id()] = topo_index
    topo_index += 1

    for edge in v.get_outgoing_edges() {
      if edge_mark[edge.get_id()] {
        continue
      }
      let tgt = coffman_graham_layerer_require_edge_target_node(edge)
      in_deg[tgt.get_id()] -= 1
      in_topo[tgt.get_id()].push(topo_ord[v.get_id()])
      if in_deg[tgt.get_id()] == 0 {
        coffman_graham_layerer_insert_source(sources, in_topo, tgt)
      }
    }
  }

  let sinks = []
  for v in layered_graph.get_layerless_nodes() {
    for edge in v.get_outgoing_edges() {
      if !edge_mark[edge.get_id()] {
        out_deg[v.get_id()] += 1
      }
    }
    if out_deg[v.get_id()] == 0 {
      coffman_graham_layerer_insert_sink(sinks, topo_ord, v)
    }
  }

  let layers = []
  let mut current_layer = coffman_graham_layerer_create_layer(
    layered_graph, layers,
  )
  while !sinks.is_empty() {
    let u = sinks[0]
    ignore(sinks.remove(0))

    if current_layer.get_nodes().length() >= layer_bound ||
      !coffman_graham_layerer_can_add(u, current_layer) {
      current_layer = coffman_graham_layerer_create_layer(layered_graph, layers)
    }

    u.set_layer(Some(current_layer))

    for edge in u.get_incoming_edges() {
      if edge_mark[edge.get_id()] {
        continue
      }
      let src = coffman_graham_layerer_require_edge_source_node(edge)
      out_deg[src.get_id()] -= 1
      if out_deg[src.get_id()] == 0 {
        coffman_graham_layerer_insert_sink(sinks, topo_ord, src)
      }
    }
  }

  let mut i = layers.length()
  while i > 0 {
    i -= 1
    layered_graph.get_layers().push(layers[i])
  }

  layered_graph.get_layerless_nodes().clear()
  monitor.done()
}

///|
pub fn new_coffman_graham_layerer_layout_phase() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_phase(
    coffman_graham_layerer_process, coffman_graham_layerer_configuration,
  )
}
