///|
pub struct IInitializable {
  init_at_layer_level_fn : (Int, Array[Array[LNode]]) -> Unit
  init_at_node_level_fn : (Int, Int, Array[Array[LNode]]) -> Unit
  init_at_port_level_fn : (Int, Int, Int, Array[Array[LNode]]) -> Unit
  init_at_edge_level_fn : (Int, Int, Int, Int, LEdge, Array[Array[LNode]]) -> Unit
  init_after_traversal_fn : () -> Unit
}

///|
pub fn new_i_initializable(
  init_at_layer_level? : (Int, Array[Array[LNode]]) -> Unit = (_, _) => (),
  init_at_node_level? : (Int, Int, Array[Array[LNode]]) -> Unit = (_, _, _) => {
    ()
  },
  init_at_port_level? : (Int, Int, Int, Array[Array[LNode]]) -> Unit = (
    _,
    _,
    _,
    _,
  ) => (),
  init_at_edge_level? : (Int, Int, Int, Int, LEdge, Array[Array[LNode]]) -> Unit = (
    _,
    _,
    _,
    _,
    _,
    _,
  ) => (),
  init_after_traversal? : () -> Unit = () => (),
) -> IInitializable {
  {
    init_at_layer_level_fn: init_at_layer_level,
    init_at_node_level_fn: init_at_node_level,
    init_at_port_level_fn: init_at_port_level,
    init_at_edge_level_fn: init_at_edge_level,
    init_after_traversal_fn: init_after_traversal,
  }
}

///|
pub fn i_initializable_init(
  initializables : Array[IInitializable],
  order : Array[Array[LNode]],
) -> Unit {
  for l in 0..<order.length() {
    for initializable in initializables {
      initializable.init_at_layer_level(l, order)
    }

    for n in 0..<order[l].length() {
      for initializable in initializables {
        initializable.init_at_node_level(l, n, order)
      }

      let ports = order[l][n].get_ports()
      for p in 0..<ports.length() {
        for initializable in initializables {
          initializable.init_at_port_level(l, n, p, order)
        }

        let port = ports[p]
        let mut e = 0
        for edge in port.get_connected_edges() {
          for initializable in initializables {
            initializable.init_at_edge_level(l, n, p, e, edge, order)
          }
          e = e + 1
        }
      }
    }
  }

  for initializable in initializables {
    initializable.init_after_traversal()
  }
}

///|
pub fn IInitializable::init_at_layer_level(
  self : IInitializable,
  l : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  (self.init_at_layer_level_fn)(l, node_order)
}

///|
pub fn IInitializable::init_at_node_level(
  self : IInitializable,
  l : Int,
  n : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  (self.init_at_node_level_fn)(l, n, node_order)
}

///|
pub fn IInitializable::init_at_port_level(
  self : IInitializable,
  l : Int,
  n : Int,
  p : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  (self.init_at_port_level_fn)(l, n, p, node_order)
}

///|
pub fn IInitializable::init_at_edge_level(
  self : IInitializable,
  l : Int,
  n : Int,
  p : Int,
  e : Int,
  edge : LEdge,
  node_order : Array[Array[LNode]],
) -> Unit {
  (self.init_at_edge_level_fn)(l, n, p, e, edge, node_order)
}

///|
pub fn IInitializable::init_after_traversal(self : IInitializable) -> Unit {
  (self.init_after_traversal_fn)()
}
