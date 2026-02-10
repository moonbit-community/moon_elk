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
fn radial_sort_by_order_id(nodes : Array[ElkNode]) -> Unit {
  radial_sort_nodes(nodes, (node1, node2) => {
    radial_internal_order_id(node1) - radial_internal_order_id(node2)
  })
}

///|
fn radial_set_id_for_nodes(nodes : Array[ElkNode], id_offset : Int) -> Int {
  let mut id = id_offset
  let mut next_layer_id = 0
  let comp_right = radial_create_polar_comparator(0.0, 0.0)
  let comp_left = radial_create_polar_comparator(@math.PI, 0.0)
  let comp_top = radial_create_polar_comparator(radial_sort_degree_270, 0.0)
  let comp_bottom = radial_create_polar_comparator(radial_sort_degree_90, 0.0)
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
      radial_sort_nodes(node_successors, comp_left)
    } else if arc <= radial_sort_degree_315 && arc > radial_sort_degree_225 {
      radial_sort_nodes(node_successors, comp_top)
    } else if arc <= radial_sort_degree_225 && arc > radial_sort_degree_135 {
      radial_sort_nodes(node_successors, comp_right)
    } else if arc <= radial_sort_degree_135 {
      radial_sort_nodes(node_successors, comp_bottom)
    }
    next_layer_id = radial_set_id_for_nodes(node_successors, next_layer_id)
  }
  id
}

///|
pub fn radial_sort_initialize(
  strategy : RadialSortingStrategy,
  root : ElkNode,
) -> Unit {
  match strategy {
    RadialSortingStrategy::NONE => ()
    RadialSortingStrategy::ID => ()
    RadialSortingStrategy::POLAR_COORDINATE => {
      let successors = radial_get_successors(root)
      radial_sort_nodes(successors, radial_create_polar_comparator(0.0, 0.0))
      ignore(radial_set_id_for_nodes(successors, 0))
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
    RadialSortingStrategy::ID => radial_sort_by_order_id(nodes)
    RadialSortingStrategy::POLAR_COORDINATE => {
      if !radial_internal_has_order_id(nodes[0]) {
        radial_sort_initialize(strategy, radial_find_root_of_node(nodes[0]))
      }
      radial_sort_by_order_id(nodes)
    }
  }
}
