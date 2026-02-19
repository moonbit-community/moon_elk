///|
fn mrtree_node_orderer_layout_processor_configuration(
  graph : MrtreeGraph,
) -> @core.LayoutProcessorConfiguration[MrtreeTreeLayoutPhases, MrtreeGraph]? {
  ignore(graph)
  Some(
    @core.layout_processor_configuration_create(mrtree_tree_layout_phase_descriptor)
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
        MrtreeIntermediateProcessorStrategy::LevelProc,
      ),
    ),
  )
}

///|
fn mrtree_node_orderer_property_value(
  node : MrtreeNode,
  weighting : MrtreeOrderWeighting,
) -> Int {
  match weighting {
    MrtreeOrderWeighting::DESCENDANTS => mrtree_node_descendants(node)
    _ => mrtree_node_fan(node)
  }
}

///|
fn mrtree_node_orderer_sort_nodes_desc(
  nodes : Array[MrtreeNode],
  weighting : MrtreeOrderWeighting,
) -> Unit {
  let length = nodes.length()
  for i in 1..<length {
    let current = nodes[i]
    let current_value = mrtree_node_orderer_property_value(current, weighting)
    let mut j = i
    while j > 0 &&
          current_value >
          mrtree_node_orderer_property_value(nodes[j - 1], weighting) {
      nodes[j] = nodes[j - 1]
      j -= 1
    }
    nodes[j] = current
  }
}

///|
fn mrtree_node_orderer_sort_nodes_position_asc(
  nodes : Array[MrtreeNode],
) -> Unit {
  let length = nodes.length()
  for i in 1..<length {
    let current = nodes[i]
    let current_value = mrtree_node_position_in_level(current)
    let mut j = i
    while j > 0 && current_value < mrtree_node_position_in_level(nodes[j - 1]) {
      nodes[j] = nodes[j - 1]
      j -= 1
    }
    nodes[j] = current
  }
}

///|
fn mrtree_node_orderer_sort_nodes_position_desc(
  nodes : Array[MrtreeNode],
) -> Unit {
  let length = nodes.length()
  for i in 1..<length {
    let current = nodes[i]
    let current_value = mrtree_node_position_in_level(current)
    let mut j = i
    while j > 0 && current_value > mrtree_node_position_in_level(nodes[j - 1]) {
      nodes[j] = nodes[j - 1]
      j -= 1
    }
    nodes[j] = current
  }
}

///|
fn mrtree_node_orderer_reorder_children(
  parent : MrtreeNode,
  children : Array[MrtreeNode],
) -> Unit {
  let sorted_edges = []
  for child in children {
    for edge in mrtree_node_outgoing_edges(parent) {
      if mrtree_edge_target(edge) == child {
        sorted_edges.push(edge)
      }
    }
  }
  mrtree_node_set_outgoing_edges(parent, sorted_edges)
}

///|
fn mrtree_node_orderer_order_level_fan_descendants(
  current_level : Array[MrtreeNode],
  weighting : MrtreeOrderWeighting,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Processor arrange level", 1.0))
    None => ()
  }

  let pos_ref : Ref[Int] = Ref::new(0)
  let sorted_level = current_level.copy()
  mrtree_node_orderer_sort_nodes_desc(sorted_level, weighting)

  let mut first_occurrence = sorted_level.length()
  let mut index = sorted_level.length() - 1
  let mut continue_scan = true
  while index >= 0 && continue_scan {
    let node = sorted_level[index]
    if mrtree_node_orderer_property_value(node, weighting) == 0 {
      first_occurrence -= 1
      index -= 1
    } else {
      continue_scan = false
    }
  }

  let inners = []
  let leaves = []
  for i in 0..<sorted_level.length() {
    if i < first_occurrence {
      inners.push(sorted_level[i])
    } else {
      leaves.push(sorted_level[i])
    }
  }

  if inners.is_empty() {
    for node in leaves {
      mrtree_node_set_position_in_level(node, pos_ref.val)
      pos_ref.val += 1
    }
  } else {
    for parent in inners {
      mrtree_node_set_position_in_level(parent, pos_ref.val)
      pos_ref.val += 1

      let children = mrtree_node_children_copy(parent)
      let subtask = match progress_monitor {
        Some(monitor) => monitor.sub_task(1.0)
        None => None
      }
      mrtree_node_orderer_order_level_fan_descendants(
        children, weighting, subtask,
      )
      mrtree_node_orderer_sort_nodes_position_desc(children)
      mrtree_node_orderer_reorder_children(parent, children)

      let mut fill_gap = mrtree_node_outgoing_edges(parent).length()
      let mut leaves_index = leaves.length() - 1
      while fill_gap > 0 && leaves_index >= 0 {
        let leaf = leaves[leaves_index]
        if mrtree_node_orderer_property_value(leaf, weighting) == 0 {
          mrtree_node_set_position_in_level(leaf, pos_ref.val)
          pos_ref.val += 1
          fill_gap -= 1
          ignore(leaves.remove(leaves_index))
        } else {
          fill_gap = 0
        }
        leaves_index -= 1
      }
    }
  }

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
fn mrtree_node_orderer_sort_nodes_constraint_desc(
  nodes : Array[MrtreeNode],
) -> Unit {
  let length = nodes.length()
  for i in 1..<length {
    let current = nodes[i]
    let current_value = mrtree_node_position_constraint(current)
    let mut j = i
    while j > 0 && current_value > mrtree_node_position_constraint(nodes[j - 1]) {
      nodes[j] = nodes[j - 1]
      j -= 1
    }
    nodes[j] = current
  }
}

///|
fn mrtree_node_orderer_order_level_constraint(
  current_level : Array[MrtreeNode],
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Processor arrange level", 1.0))
    None => ()
  }

  let undefined_nodes = []
  let in_bound_nodes = []
  let out_of_bound_nodes = []
  for node in current_level {
    let constraint = mrtree_node_position_constraint(node)
    if constraint < 0 {
      undefined_nodes.push(node)
    } else if constraint < current_level.length() {
      in_bound_nodes.push(node)
    } else {
      out_of_bound_nodes.push(node)
    }
  }

  let sorted_nodes : Array[MrtreeNode?] = []
  for _ in 0..<current_level.length() {
    sorted_nodes.push(None)
  }

  let mut i = 0
  while i < in_bound_nodes.length() {
    let node = in_bound_nodes[i]
    let target_pos = mrtree_node_position_constraint(node)
    if target_pos >= 0 &&
      target_pos < in_bound_nodes.length() &&
      sorted_nodes[target_pos] == None {
      sorted_nodes[target_pos] = Some(node)
      ignore(in_bound_nodes.remove(i))
    } else {
      i += 1
    }
  }

  i = 0
  while i < in_bound_nodes.length() {
    let node = in_bound_nodes[i]
    let target_pos = mrtree_node_position_constraint(node)
    let mut j = 0
    while true {
      let new_target_pos = target_pos + j
      if new_target_pos < sorted_nodes.length() &&
        new_target_pos >= 0 &&
        sorted_nodes[new_target_pos] == None {
        sorted_nodes[new_target_pos] = Some(node)
        ignore(in_bound_nodes.remove(i))
        break
      }
      let reverse_target_pos = target_pos - j
      if reverse_target_pos < sorted_nodes.length() &&
        reverse_target_pos >= 0 &&
        sorted_nodes[reverse_target_pos] == None {
        sorted_nodes[reverse_target_pos] = Some(node)
        ignore(in_bound_nodes.remove(i))
        break
      }
      j += 1
    }
  }

  mrtree_node_orderer_sort_nodes_constraint_desc(out_of_bound_nodes)
  let mut index = sorted_nodes.length() - 1
  while index >= 0 {
    if sorted_nodes[index] == None && !out_of_bound_nodes.is_empty() {
      sorted_nodes[index] = Some(out_of_bound_nodes[0])
      ignore(out_of_bound_nodes.remove(0))
    }
    index -= 1
  }

  for index in 0..<sorted_nodes.length() {
    if sorted_nodes[index] == None && !undefined_nodes.is_empty() {
      sorted_nodes[index] = Some(undefined_nodes[0])
      ignore(undefined_nodes.remove(0))
    }
  }

  for index in 0..<sorted_nodes.length() {
    match sorted_nodes[index] {
      Some(node) => mrtree_node_set_position_in_level(node, index)
      None => ()
    }
  }

  let inners = []
  for node in current_level {
    if mrtree_node_fan(node) != 0 {
      inners.push(node)
    }
  }
  for parent in inners {
    let children = mrtree_node_children_copy(parent)
    let subtask = match progress_monitor {
      Some(monitor) => monitor.sub_task(1.0)
      None => None
    }
    mrtree_node_orderer_order_level_constraint(children, subtask)
    mrtree_node_orderer_sort_nodes_position_asc(children)
    mrtree_node_orderer_reorder_children(parent, children)
  }

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
fn mrtree_node_orderer_process(
  graph : MrtreeGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Processor arrange node", 1.0))
    None => ()
  }

  let mut root : MrtreeNode? = None
  for node in mrtree_graph_nodes(graph) {
    if mrtree_node_root(node) {
      root = Some(node)
      break
    }
  }

  let weighting = mrtree_graph_weighting(graph)
  match root {
    Some(root_node) =>
      match weighting {
        MrtreeOrderWeighting::FAN =>
          mrtree_node_orderer_order_level_fan_descendants(
            [root_node],
            weighting,
            match progress_monitor {
              Some(monitor) => monitor.sub_task(1.0)
              None => None
            },
          )
        MrtreeOrderWeighting::DESCENDANTS =>
          mrtree_node_orderer_order_level_fan_descendants(
            [root_node],
            weighting,
            match progress_monitor {
              Some(monitor) => monitor.sub_task(1.0)
              None => None
            },
          )
        MrtreeOrderWeighting::CONSTRAINT =>
          mrtree_node_orderer_order_level_constraint(
            [root_node],
            match progress_monitor {
              Some(monitor) => monitor.sub_task(1.0)
              None => None
            },
          )
        MrtreeOrderWeighting::MODEL_ORDER => ()
      }
    None => ()
  }

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_mrtree_node_orderer_layout_phase() -> @core.ILayoutProcessor[
  MrtreeTreeLayoutPhases,
  MrtreeGraph,
] {
  @core.new_layout_phase(
    mrtree_node_orderer_process, mrtree_node_orderer_layout_processor_configuration,
  )
}
