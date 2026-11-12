///|
pub struct RadialLayoutProvider {
  algorithm_assembler : @core.AlgorithmAssembler
}

///|
#derive(Debug, ToJson)
priv suberror RadialLayoutProviderException {
  UnsupportedConfiguration(String)
}

///|
fn radial_layout_provider_raise_unsupported_configuration(
  message : String,
) -> Unit raise RadialLayoutProviderException {
  raise UnsupportedConfiguration(message)
}

///|
pub fn new_radial_layout_provider() -> RadialLayoutProvider raise {
  {
    algorithm_assembler: @core.algorithm_assembler_create(
      radial_layout_phase_descriptor,
    ),
  }
}

///|
pub fn register_radial_layout_algorithm(runtime : @core.LayoutRuntime) -> Unit {
  runtime.register_layout_algorithm(radial_algorithm_id, (
    _runtime,
    _session,
    layout_graph,
    progress_monitor,
  ) => new_radial_layout_provider().layout(layout_graph, progress_monitor))
}

///|
fn radial_node_micro_layout_execute(layout_graph : @graph.ElkNode) -> Unit {
  ignore(layout_graph)
}

///|
fn radial_layout_provider_assemble_algorithm(
  provider : RadialLayoutProvider,
  layout_graph : @graph.ElkNode,
) -> @core.LayoutProcessorPlan raise {
  ignore(provider.algorithm_assembler.reset())
  ignore(
    provider.algorithm_assembler.set_phase(
      P1_NODE_PLACEMENT,
      radial_layout_phase_factory(P1_NODE_PLACEMENT, layout_graph),
    ),
  )
  ignore(
    provider.algorithm_assembler.set_phase(
      P2_EDGE_ROUTING,
      radial_layout_phase_factory(P2_EDGE_ROUTING, layout_graph),
    ),
  )

  let configuration = @core.layout_processor_configuration_create()
  ignore(
    configuration.add_before(
      P2_EDGE_ROUTING,
      radial_intermediate_processor_factory(OVERLAP_REMOVAL, layout_graph),
    ),
  )
  let has_compaction = match radial_graph_compaction_strategy(layout_graph) {
    NONE => false
    _ => true
  }
  if has_compaction {
    ignore(
      configuration.add_before(
        P2_EDGE_ROUTING,
        radial_intermediate_processor_factory(COMPACTION, layout_graph),
      ),
    )
  }
  if @graph.node_get_bool_property(layout_graph, radial_rotate) {
    ignore(
      configuration.add_before(
        P2_EDGE_ROUTING,
        radial_intermediate_processor_factory(ROTATION, layout_graph),
      ),
    )
  }
  ignore(
    configuration.add_before(
      P2_EDGE_ROUTING,
      radial_intermediate_processor_factory(
        GRAPH_SIZE_CALCULATION,
        layout_graph,
      ),
    ),
  )
  if @graph.node_get_bool_property(
      layout_graph, radial_rotation_outgoing_edge_angles,
    ) {
    ignore(
      configuration.add_after(
        P2_EDGE_ROUTING,
        radial_intermediate_processor_factory(
          OUTGOING_EDGE_ANGLES,
          layout_graph,
        ),
      ),
    )
  }
  ignore(
    provider.algorithm_assembler.add_processor_configuration(configuration),
  )
  provider.algorithm_assembler.build()
}

///|
pub fn RadialLayoutProvider::layout(
  self : RadialLayoutProvider,
  layout_graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit raise {
  try
    radial_layout_provider_layout_impl(self, layout_graph, progress_monitor)
  catch {
    UnsupportedConfiguration(message) => {
      @core.layout_runtime_raise_unsupported_configuration(message)
      if progress_monitor.is_running() {
        progress_monitor.done()
      }
    }
    err => raise err
  } noraise {
    _ => ()
  }
}

///|
fn radial_layout_provider_layout_impl(
  provider : RadialLayoutProvider,
  layout_graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit raise {
  let plan = radial_layout_provider_assemble_algorithm(provider, layout_graph)
  ignore(progress_monitor.begin("Radial layout", plan.length().to_double()))
  if !@graph.node_get_bool_property(layout_graph, radial_omit_node_micro_layout) {
    radial_node_micro_layout_execute(layout_graph)
  }

  let root = radial_find_root(layout_graph)
  match root {
    Some(root_node) => {
      // ELK walks the tree recursively from the root (e.g. to compute the
      // wedges); on a cycle it recurses until the stack overflows (elkjs
      // fails with "Maximum call stack size exceeded"), which would crash
      // the port's native stack.
      if radial_successors_reach_a_cycle(root_node) {
        radial_layout_provider_raise_unsupported_configuration(
          "java.lang.StackOverflowError",
        )
      }
      let mut layout_radius = @graph.node_get_double_property(
        layout_graph, radial_radius,
      )
      if layout_radius == 0.0 {
        layout_radius = radial_find_largest_node_in_graph(layout_graph)
      }
      @graph.node_set_double_property(
        layout_graph, radial_radius, layout_radius,
      )
      for processor in plan.steps() {
        processor.run(progress_monitor.sub_task(1.0))
      }
      progress_monitor.done()
    }
    None =>
      radial_layout_provider_raise_unsupported_configuration(
        "The given graph is not a tree!",
      )
  }
}

///|
/// Whether following successors from `root` reaches a node twice on one path.
fn radial_successors_reach_a_cycle(root : @graph.ElkNode) -> Bool {
  let on_path : Map[@graph.ElkNode, Bool] = Map([])
  let done : Map[@graph.ElkNode, Bool] = Map([])
  // (node, index of the next successor to visit)
  let stack : Array[(@graph.ElkNode, Array[@graph.ElkNode], Int32)] = [
    (root, radial_get_successors(root), 0),
  ]
  on_path[root] = true
  while stack.length() > 0 {
    let (node, successors, index) = stack[stack.length() - 1]
    if index >= successors.length() {
      ignore(stack.pop())
      on_path.remove(node)
      done[node] = true
      continue
    }
    stack[stack.length() - 1] = (node, successors, index + 1)
    let next = successors[index]
    if on_path.contains(next) {
      return true
    }
    if !done.contains(next) {
      on_path[next] = true
      stack.push((next, radial_get_successors(next), 0))
    }
  }
  false
}
