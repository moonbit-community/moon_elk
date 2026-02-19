///|
pub struct RadiusExtensionOverlapRemoval {
  base : AbstractRadiusExtensionCompaction
  mut sorter : IRadialSorter?
}

///|
pub fn new_radius_extension_overlap_removal() -> RadiusExtensionOverlapRemoval {
  { base: new_abstract_radius_extension_compaction(), sorter: None }
}

///|
pub fn RadiusExtensionOverlapRemoval::as_i_overlap_removal(
  self : RadiusExtensionOverlapRemoval,
) -> IOverlapRemoval {
  new_i_overlap_removal((graph, progress_monitor) => {
    self.remove_overlaps(graph, progress_monitor)
  })
}

///|
pub fn RadiusExtensionOverlapRemoval::remove_overlaps(
  self : RadiusExtensionOverlapRemoval,
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let root = match radial_internal_root(graph) {
    Some(value) => value
    None => abort("radial root node is missing")
  }
  self.base.set_root(root)
  self.sorter = radial_sorting_strategy_create(
    radial_graph_sorting_strategy(graph),
  )
  self.base.set_spacing(@graph.node_get_double_property(graph, @core.spacing_node_node))
  let successors = radial_get_successors(root)
  self.extend(graph, successors, progress_monitor)
}

///|
pub fn RadiusExtensionOverlapRemoval::extend(
  self : RadiusExtensionOverlapRemoval,
  graph : @graph.ElkNode,
  nodes : Array[@graph.ElkNode],
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  if nodes.is_empty() {
    return
  }
  let old_positions = []
  for node in nodes {
    old_positions.push(@core.new_kvector_xy(@graph.node_x(node), @graph.node_y(node)))
  }
  match progress_monitor {
    Some(monitor) => monitor.log_graph("Before removing overlaps")
    None => ()
  }
  while self.base.overlap_layer(nodes) {
    self.base.contract_layer(nodes, false)
  }
  match progress_monitor {
    Some(monitor) => monitor.log_graph("After removing overlaps")
    None => ()
  }

  let mut moved_x = 0.0
  let mut moved_y = 0.0
  if !nodes.is_empty() {
    moved_x = @graph.node_x(nodes[0]) - old_positions[0].x
    moved_y = @graph.node_y(nodes[0]) - old_positions[0].y
  }
  let moved_distance = (moved_x * moved_x + moved_y * moved_y).sqrt()
  let next_level_nodes = radial_get_next_level_node_set(nodes)
  if !next_level_nodes.is_empty() {
    for next_level_node in next_level_nodes {
      self.base.move_node(next_level_node, moved_distance)
    }
    match progress_monitor {
      Some(monitor) => monitor.log_graph("Child movement 1")
      None => ()
    }
  }
  if self.sorter is Some(sorter) {
    let sorted_next_level_nodes = next_level_nodes.copy()
    sorter.sort(sorted_next_level_nodes)
  }
  self.extend(graph, next_level_nodes.copy(), progress_monitor)
}

///|
pub fn new_radius_extension_overlap_removal_layout_processor() -> @core.ILayoutProcessor[
  RadialLayoutPhases,
  @graph.ElkNode,
] {
  @core.new_layout_processor((graph, progress_monitor) => {
    let removal = new_radius_extension_overlap_removal()
    match progress_monitor {
      Some(monitor) => {
        ignore(monitor.begin("Remove overlaps", 1.0))
        monitor.log_graph("Before")
      }
      None => ()
    }
    removal.remove_overlaps(graph, progress_monitor)
    match progress_monitor {
      Some(monitor) => monitor.log_graph("After")
      None => ()
    }
  })
}
