///|
fn mrtree_order_balance_layout_processor_configuration(
  graph : MrtreeGraph,
) -> LayoutProcessorConfiguration[MrtreeTreeLayoutPhases, MrtreeGraph]? {
  ignore(graph)
  Some(
    layout_processor_configuration_create(mrtree_tree_layout_phase_descriptor)
    .before(MrtreeTreeLayoutPhases::P2NodeOrdering)
    .add(
      mrtree_intermediate_processor_factory(
        MrtreeIntermediateProcessorStrategy::RootProc,
      ),
    )
    .add(
      mrtree_intermediate_processor_factory(
        MrtreeIntermediateProcessorStrategy::FanProc,
      ),
    )
    .add(
      mrtree_intermediate_processor_factory(
        MrtreeIntermediateProcessorStrategy::NeighborsProc,
      ),
    ),
  )
}

///|
fn mrtree_order_balance_target_value(
  edge : MrtreeEdge,
  weighting : MrtreeOrderWeighting,
) -> Int {
  let target = mrtree_edge_target(edge)
  match weighting {
    MrtreeOrderWeighting::FAN => mrtree_node_fan(target)
    _ => mrtree_node_descendants(target)
  }
}

///|
fn mrtree_order_balance_sort_outgoing(
  edges : Array[MrtreeEdge],
  weighting : MrtreeOrderWeighting,
) -> Unit {
  let length = edges.length()
  for i in 1..<length {
    let current = edges[i]
    let current_value = mrtree_order_balance_target_value(current, weighting)
    let mut j = i
    while j > 0 &&
          current_value >
          mrtree_order_balance_target_value(edges[j - 1], weighting) {
      edges[j] = edges[j - 1]
      j -= 1
    }
    edges[j] = current
  }
}

///|
fn mrtree_order_balance_order_level(
  left_most : MrtreeNode?,
  odd : Bool,
  weighting : MrtreeOrderWeighting,
) -> Unit {
  match left_most {
    None => ()
    Some(start_node) => {
      let mut current_node = Some(start_node)
      while current_node != None {
        let node = match current_node {
          Some(value) => value
          None => abort("unreachable")
        }

        let outgoing = mrtree_node_outgoing_edges(node).copy()
        mrtree_order_balance_sort_outgoing(outgoing, weighting)

        let balanced = []
        let mut inner_odd = odd
        while !outgoing.is_empty() {
          let mut gaps = mrtree_node_fan(mrtree_edge_target(outgoing[0]))
          let index = if inner_odd {
            let idx = balanced.length()
            balanced.push(outgoing[0])
            idx
          } else {
            ignore(balanced.insert(0, outgoing[0]))
            0
          }
          ignore(outgoing.remove(0))
          inner_odd = !inner_odd

          let mut index_end = outgoing.length()
          let mut leaves_odd = odd
          while 0 < gaps && 0 < index_end {
            index_end -= 1
            let candidate = outgoing[index_end]
            if mrtree_node_is_leaf(mrtree_edge_target(candidate)) {
              gaps -= 1
              if leaves_odd {
                balanced.push(candidate)
              } else {
                ignore(balanced.insert(index, candidate))
              }
              ignore(outgoing.remove(index_end))
              leaves_odd = !leaves_odd
            } else {
              gaps = 0
            }
          }
        }

        mrtree_node_set_outgoing_edges(node, balanced)
        current_node = mrtree_node_right_neighbor(node)
      }

      mrtree_order_balance_order_level(
        mrtree_node_parent(start_node),
        !odd,
        weighting,
      )
    }
  }
}

///|
pub fn mrtree_order_balance_process(
  graph : MrtreeGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_basic_progress_monitor()
  }
  ignore(monitor.begin("Processor arrange node", 1.0))

  let weighting = match mrtree_graph_weighting(graph) {
    MrtreeOrderWeighting::FAN => MrtreeOrderWeighting::FAN
    _ => MrtreeOrderWeighting::DESCENDANTS
  }

  let mut root = None
  for node in mrtree_graph_nodes(graph) {
    if root == None && mrtree_node_root(node) {
      root = Some(node)
    }
  }

  match root {
    None => ()
    Some(root_node) => {
      let left_most = mrtree_tree_util_get_left_most(
        mrtree_node_children_copy(root_node),
      )
      match left_most {
        None => ()
        Some(lowest_node) =>
          match mrtree_node_parent(lowest_node) {
            None => ()
            Some(parent_node) =>
              if parent_node != root_node {
                match mrtree_node_parent(parent_node) {
                  None => ()
                  Some(parent_of_parent) => {
                    let mut left_start = parent_of_parent
                    let mut scan = mrtree_node_left_neighbor(left_start)
                    while scan != None {
                      left_start = match scan {
                        Some(value) => value
                        None => abort("unreachable")
                      }
                      scan = mrtree_node_left_neighbor(left_start)
                    }
                    mrtree_order_balance_order_level(
                      Some(left_start),
                      false,
                      weighting,
                    )
                    for node in mrtree_graph_nodes(graph) {
                      mrtree_node_set_right_neighbor(node, None)
                      mrtree_node_set_left_neighbor(node, None)
                      mrtree_node_set_right_sibling(node, None)
                      mrtree_node_set_left_sibling(node, None)
                    }
                  }
                }
              }
          }
      }
    }
  }
  monitor.done()
}

///|
pub fn new_mrtree_order_balance_layout_phase() -> ILayoutProcessor[
  MrtreeTreeLayoutPhases,
  MrtreeGraph,
] {
  new_layout_phase(
    mrtree_order_balance_process, mrtree_order_balance_layout_processor_configuration,
  )
}
