///|
fn spore_overlap_edges_add_unique(edges : Array[TEdge], edge : TEdge) -> Unit {
  for existing in edges {
    if existing.equals(edge) {
      return
    }
  }
  edges.push(edge)
}

///|
pub struct SporeOverlapRemovalLayoutProvider {
  algorithm_assembler : AlgorithmAssembler[SPOrEPhases, SporeGraph]
}

///|
pub fn new_spore_overlap_removal_layout_provider() -> SporeOverlapRemovalLayoutProvider {
  { algorithm_assembler: algorithm_assembler_create(spore_phase_descriptor) }
}

///|
pub fn SporeOverlapRemovalLayoutProvider::layout(
  self : SporeOverlapRemovalLayoutProvider,
  layout_graph : ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  if node_has_string_property(layout_graph, spore_underlying_layout_algorithm) {
    let requested_algorithm = node_get_string_property(
      layout_graph, spore_underlying_layout_algorithm,
    )
    if !requested_algorithm.is_empty() {
      ignore(
        layout_meta_data_service_get_algorithm_data_by_suffix(
          requested_algorithm,
        ),
      )
    }
  }

  node_set_string_property(
    layout_graph, spore_processing_order_root_selection, "CENTER_NODE",
  )
  node_set_string_property(
    layout_graph, spore_processing_order_spanning_tree_cost_function, "INVERTED_OVERLAP",
  )
  node_set_string_property(
    layout_graph, spore_processing_order_tree_construction, "MINIMUM_SPANNING_TREE",
  )
  let max_iterations = node_get_double_property(
    layout_graph, spore_overlap_removal_max_iterations,
  ).to_int()

  ignore(progress_monitor.begin("Overlap removal", 1.0))

  let debug_output_file = if node_get_bool_property(
      layout_graph, spore_debug_mode,
    ) {
    Some("spore_45scanlineOverlaps")
  } else {
    None
  }
  let svg = new_svg_image(debug_output_file)

  let overlap_edges : Array[TEdge] = []
  let overlap_handler : IOverlapHandler = (n1, n2) => {
    spore_overlap_edges_add_unique(
      overlap_edges,
      new_tedge(n1.original_vertex, n2.original_vertex),
    )
  }

  let graph_importer = new_spore_elk_graph_as_igraph_importer()
  let graph = graph_importer.import_graph(layout_graph)

  let mut overlaps_existed = true
  let mut iteration = 0
  while iteration < max_iterations && overlaps_existed {
    if node_get_bool_property(layout_graph, spore_overlap_removal_run_scanline) {
      overlap_edges.clear()
      new_scanline_overlap_check(overlap_handler, svg).sweep(graph.vertices)
      if overlap_edges.is_empty() {
        break
      }
      graph.t_edges = Some(overlap_edges.copy())
    }

    ignore(self.algorithm_assembler.reset())
    ignore(
      self.algorithm_assembler.set_phase(
        SPOrEPhases::P1_STRUCTURE,
        spore_structure_extraction_strategy_phase_factory(
          SporeStructureExtractionStrategy::DELAUNAY_TRIANGULATION,
        ),
      ),
    )
    ignore(
      self.algorithm_assembler.set_phase(
        SPOrEPhases::P2_PROCESSING_ORDER,
        spore_tree_construction_strategy_phase_factory(
          graph.tree_construction_strategy,
        ),
      ),
    )
    ignore(
      self.algorithm_assembler.set_phase(
        SPOrEPhases::P3_EXECUTION,
        spore_overlap_removal_strategy_phase_factory(
          SporeOverlapRemovalStrategy::GROW_TREE,
        ),
      ),
    )
    let algorithm = self.algorithm_assembler.build(graph)
    for processor in algorithm {
      processor.process(graph, progress_monitor.sub_task(1.0))
    }

    graph_importer.update_graph(graph)
    overlaps_existed = graph.overlaps_existed
    iteration += 1
  }

  graph_importer.apply_positions(graph)
  progress_monitor.done()
}

///|
pub fn spore_overlap_removal_layout_provider_as_layout_provider(
  provider : SporeOverlapRemovalLayoutProvider,
) -> AbstractLayoutProvider {
  new_abstract_layout_provider((graph, monitor) => {
    provider.layout(graph, monitor)
  })
}
