///|
pub enum MrtreeTreeLayoutPhases {
  P1Treeification
  P2NodeOrdering
  P3NodePlacement
  P4EdgeRouting
}

///|
fn mrtree_tree_layout_phase_ordinal(phase : MrtreeTreeLayoutPhases) -> Int {
  match phase {
    P1Treeification => 0
    P2NodeOrdering => 1
    P3NodePlacement => 2
    P4EdgeRouting => 3
  }
}

///|
pub let mrtree_tree_layout_phase_descriptor : PhaseDescriptor[
  MrtreeTreeLayoutPhases,
] = new_phase_descriptor(
  [
    MrtreeTreeLayoutPhases::P1Treeification,
    MrtreeTreeLayoutPhases::P2NodeOrdering,
    MrtreeTreeLayoutPhases::P3NodePlacement,
    MrtreeTreeLayoutPhases::P4EdgeRouting,
  ],
  mrtree_tree_layout_phase_ordinal,
)

///|
fn mrtree_node_placer_process(
  graph : MrtreeGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Node placement phase", 1.0))
    None => ()
  }
  mrtree_layout_levels(graph)
  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_mrtree_node_placer_layout_phase() -> ILayoutProcessor[
  MrtreeTreeLayoutPhases,
  MrtreeGraph,
] {
  new_layout_phase(mrtree_node_placer_process, _ => None)
}

///|
fn mrtree_edge_router_noop_process(
  graph : MrtreeGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  ignore(graph)
  ignore(progress_monitor)
}

///|
pub fn new_mrtree_edge_router_layout_phase() -> ILayoutProcessor[
  MrtreeTreeLayoutPhases,
  MrtreeGraph,
] {
  new_layout_phase(mrtree_edge_router_noop_process, _ => None)
}

///|
pub fn mrtree_tree_layout_phase_factory(
  phase : MrtreeTreeLayoutPhases,
) -> ILayoutPhaseFactory[MrtreeTreeLayoutPhases, MrtreeGraph] {
  match phase {
    P1Treeification =>
      new_layout_processor_factory(21100, 0, () => {
        new_mrtree_dfs_treeifyer_layout_phase()
      })
    P2NodeOrdering =>
      new_layout_processor_factory(21101, 1, () => {
        new_mrtree_node_orderer_layout_phase()
      })
    P3NodePlacement =>
      new_layout_processor_factory(21102, 2, () => {
        new_mrtree_node_placer_layout_phase()
      })
    P4EdgeRouting =>
      new_layout_processor_factory(21103, 3, () => {
        new_mrtree_edge_router_layout_phase()
      })
  }
}
