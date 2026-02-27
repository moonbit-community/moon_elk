///|
pub struct AnnulusWedgeCompaction {
  base : AbstractRadiusExtensionCompaction
  left_contour : Map[@graph.ElkNode, Array[@graph.ElkNode]]
  right_contour : Map[@graph.ElkNode, Array[@graph.ElkNode]]
  mut sorter : IRadialSorter?
  mut root : @graph.ElkNode?
}

///|
pub fn new_annulus_wedge_compaction() -> AnnulusWedgeCompaction {
  {
    base: new_abstract_radius_extension_compaction(),
    left_contour: {},
    right_contour: {},
    sorter: None,
    root: None,
  }
}

///|
fn annulus_wedge_contour_put(
  contour : Map[@graph.ElkNode, Array[@graph.ElkNode]],
  key : @graph.ElkNode,
  value : @graph.ElkNode,
) -> Unit {
  let list = match contour.get(key) {
    Some(values) => values
    None => []
  }
  list.push(value)
  contour[key] = list
}

///|
fn annulus_wedge_contour_get(
  contour : Map[@graph.ElkNode, Array[@graph.ElkNode]],
  key : @graph.ElkNode,
) -> Array[@graph.ElkNode] {
  match contour.get(key) {
    Some(values) => values.copy()
    None => []
  }
}

///|
pub fn AnnulusWedgeCompaction::compact(
  self : AnnulusWedgeCompaction,
  graph : @graph.ElkNode,
) -> Unit {
  let root = radial_internal_root(graph).unwrap()
  self.root = Some(root)
  self.base.set_root(root)
  self.sorter = radial_sorting_strategy_create(
    radial_graph_sorting_strategy(graph),
  )
  self.base.set_compaction_step(radial_graph_compaction_step_size(graph))
  self.base.set_spacing(
    @graph.node_get_double_property(graph, @core.spacing_node_node),
  )
  self.left_contour.clear()
  self.right_contour.clear()
  let successors = radial_get_successors(root)
  if self.sorter is Some(sorter) {
    sorter.sort(successors)
  }
  self.construct_contour(successors)

  let root_list = [root]
  let mut k = 0
  while k < 2 {
    let mut i = 0
    while i < successors.length() {
      let node_as_list = [successors[i]]
      let right_parent = if i < successors.length() - 1 {
        successors[i + 1]
      } else {
        successors[0]
      }
      let left_parent = if i == 0 {
        successors[successors.length() - 1]
      } else {
        successors[i - 1]
      }
      self.contract_wedge(
        successors[i],
        root_list,
        left_parent,
        right_parent,
        node_as_list,
      )
      i += 1
    }
    k += 1
  }
}

///|
fn AnnulusWedgeCompaction::contract_wedge(
  self : AnnulusWedgeCompaction,
  wedge_parent : @graph.ElkNode,
  predecessors : Array[@graph.ElkNode],
  radial_predecessor : @graph.ElkNode,
  radial_successor : @graph.ElkNode,
  current_radius_nodes : Array[@graph.ElkNode],
) -> Unit {
  ignore(wedge_parent)
  let mut is_overlapping = self.overlapping(
    predecessors, radial_predecessor, radial_successor, current_radius_nodes,
  )
  let mut was_contracted = false
  while !is_overlapping {
    self.base.contract_layer(current_radius_nodes, true)
    was_contracted = true
    is_overlapping = self.overlapping(
      predecessors, radial_predecessor, radial_successor, current_radius_nodes,
    )
  }
  if was_contracted {
    self.base.contract_layer(current_radius_nodes, false)
  }
  let next_level_nodes = radial_get_next_level_nodes(current_radius_nodes)
  if !next_level_nodes.is_empty() {
    if self.sorter is Some(sorter) {
      sorter.sort(next_level_nodes)
    }
    self.contract_wedge(
      wedge_parent, current_radius_nodes, radial_predecessor, radial_successor, next_level_nodes,
    )
  }
}

///|
fn AnnulusWedgeCompaction::contour_overlap(
  self : AnnulusWedgeCompaction,
  neighbour_wedge_parent : @graph.ElkNode,
  node : @graph.ElkNode,
  left : Bool,
) -> Bool {
  let contour = if left {
    annulus_wedge_contour_get(self.left_contour, neighbour_wedge_parent)
  } else {
    annulus_wedge_contour_get(self.right_contour, neighbour_wedge_parent)
  }
  for contour_node in contour {
    if self.base.overlap(node, contour_node) {
      return true
    }
  }
  false
}

///|
fn AnnulusWedgeCompaction::overlapping(
  self : AnnulusWedgeCompaction,
  predecessors : Array[@graph.ElkNode],
  left_parent : @graph.ElkNode,
  right_parent : @graph.ElkNode,
  layer_nodes : Array[@graph.ElkNode],
) -> Bool {
  if self.sorter is Some(sorter) {
    sorter.sort(layer_nodes)
  }
  let first_node = layer_nodes[0]
  if self.contour_overlap(left_parent, first_node, false) {
    return true
  }
  let last_node = layer_nodes[layer_nodes.length() - 1]
  if self.contour_overlap(right_parent, last_node, true) {
    return true
  }
  if self.base.overlap_layer(layer_nodes) {
    return true
  }
  for sorted_node in layer_nodes {
    for predecessor in predecessors {
      if self.base.overlap(sorted_node, predecessor) {
        return true
      }
    }
  }
  false
}

///|
fn AnnulusWedgeCompaction::construct_contour(
  self : AnnulusWedgeCompaction,
  nodes : Array[@graph.ElkNode],
) -> Unit {
  for node in nodes {
    annulus_wedge_contour_put(self.left_contour, node, node)
    annulus_wedge_contour_put(self.right_contour, node, node)
    let mut successors = radial_get_successors(node)
    if successors.is_empty() {
      continue
    }
    if self.sorter is Some(sorter) {
      sorter.sort(successors)
    }
    annulus_wedge_contour_put(self.left_contour, node, successors[0])
    annulus_wedge_contour_put(
      self.right_contour,
      node,
      successors[successors.length() - 1],
    )
    while !radial_get_next_level_nodes(successors).is_empty() {
      successors = radial_get_next_level_nodes(successors)
      if self.sorter is Some(sorter) {
        sorter.sort(successors)
      }
      annulus_wedge_contour_put(self.left_contour, node, successors[0])
      annulus_wedge_contour_put(
        self.right_contour,
        node,
        successors[successors.length() - 1],
      )
    }
  }
}
