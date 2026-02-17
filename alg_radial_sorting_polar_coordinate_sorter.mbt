///|
let radial_sort_degree_45 : Double = 0.25 * @math.PI

///|
let radial_sort_degree_90 : Double = 0.5 * @math.PI

///|
let radial_sort_degree_135 : Double = 0.75 * @math.PI

///|
let radial_sort_degree_225 : Double = 1.25 * @math.PI

///|
let radial_sort_degree_270 : Double = 1.5 * @math.PI

///|
let radial_sort_degree_315 : Double = 1.75 * @math.PI

///|
pub struct PolarCoordinateSorter {
  comp_right : (ElkNode, ElkNode) -> Int
  comp_left : (ElkNode, ElkNode) -> Int
  comp_top : (ElkNode, ElkNode) -> Int
  comp_bottom : (ElkNode, ElkNode) -> Int
  mut id_sorter : IDSorter?
}

///|
pub fn new_polar_coordinate_sorter() -> PolarCoordinateSorter {
  {
    comp_right: radial_create_polar_comparator(0.0, 0.0),
    comp_left: radial_create_polar_comparator(@math.PI, 0.0),
    comp_top: radial_create_polar_comparator(radial_sort_degree_270, 0.0),
    comp_bottom: radial_create_polar_comparator(radial_sort_degree_90, 0.0),
    id_sorter: None,
  }
}

///|
fn PolarCoordinateSorter::set_id_for_nodes(
  self : PolarCoordinateSorter,
  nodes : Array[ElkNode],
  id_offset : Int,
) -> Int {
  let mut id = id_offset
  for node in nodes {
    radial_internal_set_order_id(node, id)
    id += 1

    let node_successors = radial_get_successors(node)
    let mut arc = @math.atan2(
      node_y(node) + node_height(node) / 2.0,
      node_x(node) + node_width(node) / 2.0,
    )
    if arc < 0.0 {
      arc += 2.0 * @math.PI
    }

    if arc < radial_sort_degree_45 || arc > radial_sort_degree_315 {
      radial_sort_nodes(node_successors, self.comp_left)
    } else if arc <= radial_sort_degree_315 && arc > radial_sort_degree_225 {
      radial_sort_nodes(node_successors, self.comp_top)
    } else if arc <= radial_sort_degree_225 && arc > radial_sort_degree_135 {
      radial_sort_nodes(node_successors, self.comp_right)
    } else if arc <= radial_sort_degree_135 {
      radial_sort_nodes(node_successors, self.comp_bottom)
    }

    id = self.set_id_for_nodes(node_successors, id)
  }

  id
}

///|
pub fn PolarCoordinateSorter::initialize(
  self : PolarCoordinateSorter,
  root : ElkNode,
) -> Unit {
  self.id_sorter = Some(new_id_sorter())
  let successors = radial_get_successors(root)
  radial_sort_nodes(successors, self.comp_right)
  ignore(self.set_id_for_nodes(successors, 0))
}

///|
pub fn PolarCoordinateSorter::sort(
  self : PolarCoordinateSorter,
  nodes : Array[ElkNode],
) -> Unit {
  if nodes.is_empty() {
    return
  }

  if self.id_sorter is None {
    let root = radial_find_root_of_node(nodes[0])
    self.initialize(root)
  }

  if self.id_sorter is Some(id_sorter) {
    id_sorter.sort(nodes)
  }
}
