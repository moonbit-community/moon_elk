///|
pub struct ICrossingMinimizationHeuristic {
  initializable : IInitializable
  always_improves_fn : () -> Bool
  set_first_layer_order_fn : (Array[Array[@runtime.LNode]], Bool) -> Bool raise
  minimize_crossings_fn : (Array[Array[@runtime.LNode]], Int, Bool, Bool) -> Bool raise
  is_deterministic_fn : () -> Bool
}

///|
pub fn new_i_crossing_minimization_heuristic(
  always_improves : () -> Bool,
  set_first_layer_order : (Array[Array[@runtime.LNode]], Bool) -> Bool raise,
  minimize_crossings : (Array[Array[@runtime.LNode]], Int, Bool, Bool) -> Bool raise,
  is_deterministic : () -> Bool,
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
) -> ICrossingMinimizationHeuristic {
  {
    initializable: new_i_initializable(
      init_at_layer_level~,
      init_at_node_level~,
      init_at_port_level~,
      init_at_edge_level~,
      init_after_traversal~,
    ),
    always_improves_fn: always_improves,
    set_first_layer_order_fn: set_first_layer_order,
    minimize_crossings_fn: minimize_crossings,
    is_deterministic_fn: is_deterministic,
  }
}

///|
pub fn i_crossing_minimization_heuristic_init(
  heuristics : Array[ICrossingMinimizationHeuristic],
  order : Array[Array[@runtime.LNode]],
) -> Unit {
  let initializables = []
  for heuristic in heuristics {
    initializables.push(heuristic.as_initializable())
  }
  i_initializable_init(initializables, order)
}

///|
pub fn ICrossingMinimizationHeuristic::always_improves(
  self : ICrossingMinimizationHeuristic,
) -> Bool {
  (self.always_improves_fn)()
}

///|
pub fn ICrossingMinimizationHeuristic::set_first_layer_order(
  self : ICrossingMinimizationHeuristic,
  order : Array[Array[@runtime.LNode]],
  forward_sweep : Bool,
) -> Bool raise {
  (self.set_first_layer_order_fn)(order, forward_sweep)
}

///|
pub fn ICrossingMinimizationHeuristic::minimize_crossings(
  self : ICrossingMinimizationHeuristic,
  order : Array[Array[@runtime.LNode]],
  free_layer_index : Int,
  forward_sweep : Bool,
  is_first_sweep : Bool,
) -> Bool raise {
  (self.minimize_crossings_fn)(
    order, free_layer_index, forward_sweep, is_first_sweep,
  )
}

///|
pub fn ICrossingMinimizationHeuristic::is_deterministic(
  self : ICrossingMinimizationHeuristic,
) -> Bool {
  (self.is_deterministic_fn)()
}

///|
pub fn ICrossingMinimizationHeuristic::as_initializable(
  self : ICrossingMinimizationHeuristic,
) -> IInitializable {
  self.initializable
}

///|
pub fn ICrossingMinimizationHeuristic::init_at_layer_level(
  self : ICrossingMinimizationHeuristic,
  l : Int,
  node_order : Array[Array[@runtime.LNode]],
) -> Unit {
  self.initializable.init_at_layer_level(l, node_order)
}

///|
pub fn ICrossingMinimizationHeuristic::init_at_node_level(
  self : ICrossingMinimizationHeuristic,
  l : Int,
  n : Int,
  node_order : Array[Array[@runtime.LNode]],
) -> Unit {
  self.initializable.init_at_node_level(l, n, node_order)
}

///|
pub fn ICrossingMinimizationHeuristic::init_at_port_level(
  self : ICrossingMinimizationHeuristic,
  l : Int,
  n : Int,
  p : Int,
  node_order : Array[Array[@runtime.LNode]],
) -> Unit {
  self.initializable.init_at_port_level(l, n, p, node_order)
}

///|
pub fn ICrossingMinimizationHeuristic::init_at_edge_level(
  self : ICrossingMinimizationHeuristic,
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
pub fn ICrossingMinimizationHeuristic::init_after_traversal(
  self : ICrossingMinimizationHeuristic,
) -> Unit {
  self.initializable.init_after_traversal()
}
