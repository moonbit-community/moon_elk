///|
pub struct RadialCompaction {
  base : AbstractRadiusExtensionCompaction
  mut sorter : IRadialSorter?
  mut last_radius : Double
}

///|
pub fn new_radial_compaction() -> RadialCompaction {
  {
    base: new_abstract_radius_extension_compaction(),
    sorter: None,
    last_radius: 0.0,
  }
}

///|
pub fn RadialCompaction::compact(
  self : RadialCompaction,
  graph : ElkNode,
) -> Unit {
  let root = match radial_internal_root(graph) {
    Some(value) => value
    None => abort("radial root node is missing")
  }
  self.base.set_root(root)
  self.sorter = radial_sorting_strategy_create(
    radial_graph_sorting_strategy(graph),
  )
  self.base.set_compaction_step(radial_graph_compaction_step_size(graph))
  self.base.set_spacing(node_get_double_property(graph, spacing_node_node))
  let first_level_nodes = radial_get_successors(root)
  if self.sorter is Some(sorter) {
    sorter.sort(first_level_nodes)
  }
  self.contract(first_level_nodes)
}

///|
fn RadialCompaction::calculate_radius(
  self : RadialCompaction,
  node : ElkNode,
) -> Double {
  let x_pos = node_x(node)
  let y_pos = node_y(node)
  let root = match self.base.root() {
    Some(value) => value
    None => abort("radial root node is missing")
  }
  let root_x = node_x(root)
  let root_y = node_y(root)
  let vector_x = x_pos - root_x
  let vector_y = y_pos - root_y
  (vector_x * vector_x + vector_y * vector_y).sqrt()
}

///|
fn RadialCompaction::overlapping(
  self : RadialCompaction,
  nodes : Array[ElkNode],
) -> Bool {
  if self.base.overlap_layer(nodes) {
    return true
  }
  for node in nodes {
    match radial_get_tree_parent(node) {
      Some(parent) => if self.base.overlap(node, parent) { return true }
      None => ()
    }
    if self.calculate_radius(node) - self.base.spacing() <= self.last_radius {
      return true
    }
  }
  false
}

///|
pub fn RadialCompaction::contract(
  self : RadialCompaction,
  nodes : Array[ElkNode],
) -> Unit {
  if nodes.is_empty() {
    return
  }
  let mut is_overlapping = self.overlapping(nodes)
  let mut was_contracted = false
  while !is_overlapping {
    self.base.contract_layer(nodes, true)
    was_contracted = true
    is_overlapping = self.overlapping(nodes)
  }
  if was_contracted {
    self.base.contract_layer(nodes, false)
  }
  let next_level_nodes = radial_get_next_level_nodes(nodes)
  if self.sorter is Some(sorter) {
    sorter.sort(next_level_nodes)
  }
  self.last_radius = self.calculate_radius(nodes[0])
  self.contract(next_level_nodes)
}
