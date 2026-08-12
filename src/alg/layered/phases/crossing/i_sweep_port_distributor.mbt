///|
pub struct ISweepPortDistributor {
  initializable : IInitializable
  distribute_ports_while_sweeping_fn : (Array[Array[@runtime.LNode]], Int, Bool) -> Bool raise
}

///|
pub fn new_i_sweep_port_distributor(
  distribute_ports_while_sweeping : (Array[Array[@runtime.LNode]], Int, Bool) -> Bool raise,
  init_at_layer_level? : (Int, Array[Array[@runtime.LNode]]) -> Unit = (_, _) => {
    ()
  },
  init_at_node_level? : (Int, Int, Array[Array[@runtime.LNode]]) -> Unit = (
    _,
    _,
    _,
  ) => (),
  init_at_port_level? : (Int, Int, Int, Array[Array[@runtime.LNode]]) -> Unit = (
    _,
    _,
    _,
    _,
  ) => (),
  init_at_edge_level? : (
    Int,
    Int,
    Int,
    Int,
    @runtime.LEdge,
    Array[Array[@runtime.LNode]],
  ) -> Unit = (_, _, _, _, _, _) => (),
  init_after_traversal? : () -> Unit = () => (),
) -> ISweepPortDistributor {
  {
    initializable: new_i_initializable(
      init_at_layer_level~,
      init_at_node_level~,
      init_at_port_level~,
      init_at_edge_level~,
      init_after_traversal~,
    ),
    distribute_ports_while_sweeping_fn: distribute_ports_while_sweeping,
  }
}

///|
pub fn i_sweep_port_distributor_init(
  distributors : Array[ISweepPortDistributor],
  order : Array[Array[@runtime.LNode]],
) -> Unit {
  let initializables = []
  for distributor in distributors {
    initializables.push(distributor.as_initializable())
  }
  i_initializable_init(initializables, order)
}

///|
pub fn ISweepPortDistributor::distribute_ports_while_sweeping(
  self : ISweepPortDistributor,
  order : Array[Array[@runtime.LNode]],
  free_layer_index : Int,
  is_forward_sweep : Bool,
) -> Bool raise {
  (self.distribute_ports_while_sweeping_fn)(
    order, free_layer_index, is_forward_sweep,
  )
}

///|
pub fn ISweepPortDistributor::as_initializable(
  self : ISweepPortDistributor,
) -> IInitializable {
  self.initializable
}

///|
pub fn ISweepPortDistributor::init_at_layer_level(
  self : ISweepPortDistributor,
  l : Int,
  node_order : Array[Array[@runtime.LNode]],
) -> Unit {
  self.initializable.init_at_layer_level(l, node_order)
}

///|
pub fn ISweepPortDistributor::init_at_node_level(
  self : ISweepPortDistributor,
  l : Int,
  n : Int,
  node_order : Array[Array[@runtime.LNode]],
) -> Unit {
  self.initializable.init_at_node_level(l, n, node_order)
}

///|
pub fn ISweepPortDistributor::init_at_port_level(
  self : ISweepPortDistributor,
  l : Int,
  n : Int,
  p : Int,
  node_order : Array[Array[@runtime.LNode]],
) -> Unit {
  self.initializable.init_at_port_level(l, n, p, node_order)
}

///|
pub fn ISweepPortDistributor::init_at_edge_level(
  self : ISweepPortDistributor,
  l : Int,
  n : Int,
  p : Int,
  e : Int,
  edge : @runtime.LEdge,
  node_order : Array[Array[@runtime.LNode]],
) -> Unit {
  self.initializable.init_at_edge_level(l, n, p, e, edge, node_order)
}

///|
pub fn ISweepPortDistributor::init_after_traversal(
  self : ISweepPortDistributor,
) -> Unit {
  self.initializable.init_after_traversal()
}
