///|
pub type MrtreeTreeLayoutPhases = @core.PhaseId

///|
pub const P1Treeification : MrtreeTreeLayoutPhases = 0

///|
pub const P2NodeOrdering : MrtreeTreeLayoutPhases = 1

///|
pub const P3NodePlacement : MrtreeTreeLayoutPhases = 2

///|
pub const P4EdgeRouting : MrtreeTreeLayoutPhases = 3

///|
pub let mrtree_tree_layout_phase_descriptor : @core.PhaseDescriptor = @core.new_phase_descriptor([
    P1Treeification,
    P2NodeOrdering,
    P3NodePlacement,
    P4EdgeRouting,
  ],
)

///|
pub fn mrtree_tree_layout_phase_factory(
  phase : MrtreeTreeLayoutPhases,
  graph : MrtreeGraph,
) -> @core.LayoutProcessorFactory {
  if phase == P1Treeification {
    @core.new_layout_processor_factory(21100, 0, graph, () => {
      new_mrtree_dfs_treeifyer_layout_phase()
    })
  } else if phase == P2NodeOrdering {
    @core.new_layout_processor_factory(21101, 1, graph, () => {
      new_mrtree_node_orderer_layout_phase()
    })
  } else if phase == P3NodePlacement {
    @core.new_layout_processor_factory(21102, 2, graph, () => {
      new_mrtree_node_placer_layout_phase()
    })
  } else {
    @core.new_layout_processor_factory(21103, 3, graph, () => {
      new_mrtree_edge_router_layout_phase()
    })
  }
}
