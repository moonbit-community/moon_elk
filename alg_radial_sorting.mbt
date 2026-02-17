///|
pub fn radial_sort_initialize(
  strategy : RadialSortingStrategy,
  root : ElkNode,
) -> Unit {
  match strategy {
    RadialSortingStrategy::NONE => ()
    RadialSortingStrategy::ID => ()
    RadialSortingStrategy::POLAR_COORDINATE => {
      let sorter = new_polar_coordinate_sorter()
      sorter.initialize(root)
    }
  }
}

///|
pub fn radial_sort(
  strategy : RadialSortingStrategy,
  nodes : Array[ElkNode],
) -> Unit {
  if nodes.is_empty() {
    return
  }
  match strategy {
    RadialSortingStrategy::NONE => ()
    RadialSortingStrategy::ID => new_id_sorter().sort(nodes)
    RadialSortingStrategy::POLAR_COORDINATE => {
      if !radial_internal_has_order_id(nodes[0]) {
        radial_sort_initialize(strategy, radial_find_root_of_node(nodes[0]))
      }
      new_id_sorter().sort(nodes)
    }
  }
}
