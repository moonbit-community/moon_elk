///|
fn radial_id_sorter_compare(
  node1 : @graph.ElkNode,
  node2 : @graph.ElkNode,
) -> Int {
  radial_internal_order_id(node1) - radial_internal_order_id(node2)
}

///|
pub struct IDSorter {
  sorter : IRadialSorter
}

///|
pub fn new_id_sorter() -> IDSorter {
  {
    sorter: new_i_radial_sorter(fn(nodes : Array[@graph.ElkNode]) {
      radial_sort_nodes(nodes, radial_id_sorter_compare)
    }),
  }
}

///|
pub fn IDSorter::sort(self : IDSorter, nodes : Array[@graph.ElkNode]) -> Unit {
  self.sorter.sort(nodes)
}

///|
pub fn IDSorter::initialize(self : IDSorter, root : @graph.ElkNode) -> Unit {
  self.sorter.initialize(root)
}

///|
pub fn IDSorter::as_i_radial_sorter(self : IDSorter) -> IRadialSorter {
  self.sorter
}
