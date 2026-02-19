///|
fn graph_info_count_ports(node_order : Array[Array[LNode]]) -> Int {
  let mut count = 0
  for layer in node_order {
    for node in layer {
      count = count + node.get_ports().length()
    }
  }
  count
}

///|
fn graph_info_to_node_array(graph : LGraph) -> Array[Array[LNode]] {
  let order = []
  for layer in graph.get_layers() {
    order.push(layer.get_nodes())
  }
  order
}

///|
fn _graph_info_contains_node(nodes : Array[LNode], candidate : LNode) -> Bool {
  for node in nodes {
    if lnode_internal_handle(node) == lnode_internal_handle(candidate) {
      return true
    }
  }
  false
}

///|
fn graph_info_add_unique_graph(graphs : Array[LGraph], graph : LGraph) -> Unit {
  graphs.push(graph)
}

///|
fn graph_info_cross_min_type_to_switch_type(
  cross_min_type : CrossMinType,
) -> GreedySwitchType {
  match cross_min_type {
    CrossMinType::TwoSidedGreedySwitch => GreedySwitchType::TwoSided
    _ => GreedySwitchType::OneSided
  }
}

///|
fn graph_info_is_two_sided(cross_min_type : CrossMinType) -> Bool {
  match cross_min_type {
    CrossMinType::TwoSidedGreedySwitch => true
    _ => false
  }
}

///|
fn graph_info_create_port_distributor(
  cross_min_type : CrossMinType,
  node_order : Array[Array[LNode]],
  random : MockRandom,
) -> ISweepPortDistributor {
  if graph_info_is_two_sided(cross_min_type) {
    return new_greedy_port_distributor().as_i_sweep_port_distributor()
  }
  if random.next_boolean() {
    new_node_relative_port_distributor(node_order.length()).as_i_sweep_port_distributor()
  } else {
    new_layer_total_port_distributor(node_order.length()).as_i_sweep_port_distributor()
  }
}

///|
fn graph_info_port_distributor_as_barycenter(
  cross_min_type : CrossMinType,
  node_order : Array[Array[LNode]],
) -> (ISweepPortDistributor, AbstractBarycenterPortDistributor) {
  if graph_info_is_two_sided(cross_min_type) {
    let node_relative = new_node_relative_port_distributor(node_order.length())
    return (
      node_relative.as_i_sweep_port_distributor(),
      node_relative.as_abstract_barycenter_port_distributor(),
    )
  }
  let node_relative = new_node_relative_port_distributor(node_order.length())
  (
    node_relative.as_i_sweep_port_distributor(),
    node_relative.as_abstract_barycenter_port_distributor(),
  )
}

///|
fn graph_info_parent_layer_id(parent : LNode) -> Int {
  match parent.get_layer() {
    Some(layer) => layer.get_id()
    None => abort("parent node is not assigned to a layer")
  }
}

///|
pub enum CrossMinType {
  Barycenter
  OneSidedGreedySwitch
  TwoSidedGreedySwitch
  Median
}

///|
pub fn cross_min_type_constants() -> Array[CrossMinType] {
  [
    CrossMinType::Barycenter,
    CrossMinType::OneSidedGreedySwitch,
    CrossMinType::TwoSidedGreedySwitch,
    CrossMinType::Median,
  ]
}

///|
pub struct GraphInfoHolder {
  mut l_graph_ref : LGraph?
  mut current_node_order_ref : Array[Array[LNode]]
  mut currently_best_node_and_port_order_ref : SweepCopy?
  mut best_node_and_port_order_ref : SweepCopy?
  mut port_positions_ref : Array[Int]
  mut use_bottom_up : Bool
  child_graphs_ref : Array[LGraph]
  mut has_external_ports_ref : Bool
  mut parent_ref : LNode?
  mut parent_graph_data_ref : GraphInfoHolder?
  mut cross_minimizer_ref : ICrossingMinimizationHeuristic?
  mut port_distributor_ref : ISweepPortDistributor?
  mut crossings_counter_ref : AllCrossingsCounter?
  mut random_ref : MockRandom?
  mut n_ports : Int
  mut cross_min_deterministic_ref : Bool
  mut cross_min_always_improves_ref : Bool
}

///|
pub fn new_graph_info_holder(
  current_node_order : Array[Array[LNode]],
  parent? : LNode? = None,
  parent_graph_data? : GraphInfoHolder? = None,
  dont_sweep_into? : Bool = false,
  port_positions? : Array[Int] = [],
  l_graph? : LGraph? = None,
  cross_min_deterministic? : Bool = false,
) -> GraphInfoHolder {
  let actual_port_positions = if port_positions.length() == 0 {
    Array::make(graph_info_count_ports(current_node_order), 0)
  } else {
    port_positions
  }
  {
    l_graph_ref: l_graph,
    current_node_order_ref: current_node_order,
    currently_best_node_and_port_order_ref: None,
    best_node_and_port_order_ref: None,
    port_positions_ref: actual_port_positions,
    use_bottom_up: dont_sweep_into,
    child_graphs_ref: [],
    has_external_ports_ref: false,
    parent_ref: parent,
    parent_graph_data_ref: parent_graph_data,
    cross_minimizer_ref: None,
    port_distributor_ref: None,
    crossings_counter_ref: None,
    random_ref: None,
    n_ports: 0,
    cross_min_deterministic_ref: cross_min_deterministic,
    cross_min_always_improves_ref: false,
  }
}

///|
pub fn new_graph_info_holder_from_graph(
  graph : LGraph,
  cross_min_type : CrossMinType,
  graphs : Array[GraphInfoHolder],
) -> GraphInfoHolder {
  let current_node_order = graph_info_to_node_array(graph)
  let parent = graph.get_parent_node()
  let parent_graph_data = match parent {
    Some(parent_node) => {
      let parent_graph = parent_node.get_graph()
      let parent_id = parent_graph.get_id()
      if parent_id >= 0 && parent_id < graphs.length() {
        Some(graphs[parent_id])
      } else {
        None
      }
    }
    None => None
  }

  let holder = new_graph_info_holder(
    current_node_order,
    parent~,
    parent_graph_data~,
    l_graph=Some(graph),
  )
  holder.n_ports = 0
  holder.child_graphs_ref.clear()
  holder.has_external_ports_ref = false

  let all_crossings_counter = new_all_crossings_counter(current_node_order)
  holder.crossings_counter_ref = Some(all_crossings_counter)

  let random = new_mock_random()
  holder.random_ref = Some(random)

  let (port_distributor, barycenter_port_distributor) = graph_info_port_distributor_as_barycenter(
    cross_min_type, current_node_order,
  )
  holder.port_distributor_ref = Some(
    if graph_info_is_two_sided(cross_min_type) {
      graph_info_create_port_distributor(
        cross_min_type, current_node_order, random,
      )
    } else {
      port_distributor
    },
  )

  let layer_sweep_type_decider = new_layer_sweep_type_decider(holder)
  let initializables = [
    holder.as_initializable(),
    all_crossings_counter.as_initializable(),
    layer_sweep_type_decider.as_initializable(),
    holder.port_distributor().as_initializable(),
  ]

  let cross_minimizer = match cross_min_type {
    CrossMinType::Barycenter => {
      let constraint_resolver = new_forster_constraint_resolver(
        current_node_order,
      )
      initializables.push(constraint_resolver.as_initializable())
      if graph.get_property_bool(
          layered_options_crossing_minimization_force_node_model_order,
        ) {
        new_model_order_barycenter_heuristic(
          constraint_resolver, random, barycenter_port_distributor, current_node_order,
        ).as_i_crossing_minimization_heuristic()
      } else {
        new_barycenter_heuristic(
          constraint_resolver, random, barycenter_port_distributor, current_node_order,
        ).as_i_crossing_minimization_heuristic()
      }
    }
    CrossMinType::Median =>
      new_median_heuristic(@random.Rand::new()).as_i_crossing_minimization_heuristic()
    CrossMinType::OneSidedGreedySwitch =>
      new_greedy_switch_heuristic(
        graph_info_cross_min_type_to_switch_type(cross_min_type),
        holder,
      ).as_i_crossing_minimization_heuristic()
    CrossMinType::TwoSidedGreedySwitch =>
      new_greedy_switch_heuristic(
        graph_info_cross_min_type_to_switch_type(cross_min_type),
        holder,
      ).as_i_crossing_minimization_heuristic()
  }
  holder.cross_minimizer_ref = Some(cross_minimizer)
  initializables.push(cross_minimizer.as_initializable())

  i_initializable_init(initializables, current_node_order)
  holder.use_bottom_up = layer_sweep_type_decider.use_bottom_up()
  holder.cross_min_deterministic_ref = cross_minimizer.is_deterministic()
  holder.cross_min_always_improves_ref = cross_minimizer.always_improves()
  holder
}

///|
pub fn GraphInfoHolder::dont_sweep_into(self : GraphInfoHolder) -> Bool {
  self.use_bottom_up
}

///|
pub fn GraphInfoHolder::set_dont_sweep_into(
  self : GraphInfoHolder,
  dont_sweep_into : Bool,
) -> Unit {
  self.use_bottom_up = dont_sweep_into
}

///|
pub fn GraphInfoHolder::current_node_order(
  self : GraphInfoHolder,
) -> Array[Array[LNode]] {
  self.current_node_order_ref
}

///|
pub fn GraphInfoHolder::set_current_node_order(
  self : GraphInfoHolder,
  node_order : Array[Array[LNode]],
) -> Unit {
  self.current_node_order_ref = node_order
}

///|
pub fn GraphInfoHolder::currently_best_node_and_port_order(
  self : GraphInfoHolder,
) -> SweepCopy? {
  self.currently_best_node_and_port_order_ref
}

///|
pub fn GraphInfoHolder::set_currently_best_node_and_port_order(
  self : GraphInfoHolder,
  currently_best_node_and_port_order : SweepCopy?,
) -> Unit {
  self.currently_best_node_and_port_order_ref = currently_best_node_and_port_order
}

///|
pub fn GraphInfoHolder::best_node_n_port_order(
  self : GraphInfoHolder,
) -> SweepCopy? {
  self.best_node_and_port_order_ref
}

///|
pub fn GraphInfoHolder::set_best_node_n_port_order(
  self : GraphInfoHolder,
  best_node_n_port_order : SweepCopy?,
) -> Unit {
  self.best_node_and_port_order_ref = best_node_n_port_order
}

///|
pub fn GraphInfoHolder::port_positions(self : GraphInfoHolder) -> Array[Int] {
  self.port_positions_ref
}

///|
pub fn GraphInfoHolder::set_port_positions(
  self : GraphInfoHolder,
  port_positions : Array[Int],
) -> Unit {
  self.port_positions_ref = port_positions
}

///|
pub fn GraphInfoHolder::cross_counter(
  self : GraphInfoHolder,
) -> AllCrossingsCounter {
  match self.crossings_counter_ref {
    Some(counter) => counter
    None => abort("graph info holder crossing counter is not initialized")
  }
}

///|
pub fn GraphInfoHolder::cross_minimizer(
  self : GraphInfoHolder,
) -> ICrossingMinimizationHeuristic {
  match self.cross_minimizer_ref {
    Some(cross_minimizer) => cross_minimizer
    None => abort("graph info holder crossing minimizer is not initialized")
  }
}

///|
pub fn GraphInfoHolder::port_distributor(
  self : GraphInfoHolder,
) -> ISweepPortDistributor {
  match self.port_distributor_ref {
    Some(port_distributor) => port_distributor
    None => abort("graph info holder port distributor is not initialized")
  }
}

///|
pub fn GraphInfoHolder::parent(self : GraphInfoHolder) -> LNode {
  match self.parent_ref {
    Some(parent) => parent
    None => abort("graph info holder has no parent node")
  }
}

///|
pub fn GraphInfoHolder::set_parent(
  self : GraphInfoHolder,
  parent : LNode?,
) -> Unit {
  self.parent_ref = parent
}

///|
pub fn GraphInfoHolder::has_parent(self : GraphInfoHolder) -> Bool {
  match self.parent_ref {
    Some(_) => true
    None => false
  }
}

///|
pub fn GraphInfoHolder::child_graphs(self : GraphInfoHolder) -> Array[LGraph] {
  self.child_graphs_ref
}

///|
pub fn GraphInfoHolder::has_external_ports(self : GraphInfoHolder) -> Bool {
  self.has_external_ports_ref
}

///|
pub fn GraphInfoHolder::parent_graph_data(
  self : GraphInfoHolder,
) -> GraphInfoHolder {
  match self.parent_graph_data_ref {
    Some(parent_graph_data) => parent_graph_data
    None => abort("graph info holder has no parent graph data")
  }
}

///|
pub fn GraphInfoHolder::set_parent_graph_data(
  self : GraphInfoHolder,
  parent_graph_data : GraphInfoHolder?,
) -> Unit {
  self.parent_graph_data_ref = parent_graph_data
}

///|
pub fn GraphInfoHolder::l_graph(self : GraphInfoHolder) -> LGraph {
  match self.l_graph_ref {
    Some(graph) => graph
    None => abort("graph info holder has no graph")
  }
}

///|
pub fn GraphInfoHolder::set_l_graph(
  self : GraphInfoHolder,
  graph : LGraph?,
) -> Unit {
  self.l_graph_ref = graph
}

///|
pub fn GraphInfoHolder::cross_min_deterministic(self : GraphInfoHolder) -> Bool {
  match self.cross_minimizer_ref {
    Some(cross_minimizer) => cross_minimizer.is_deterministic()
    None => self.cross_min_deterministic_ref
  }
}

///|
pub fn GraphInfoHolder::set_cross_min_deterministic(
  self : GraphInfoHolder,
  deterministic : Bool,
) -> Unit {
  self.cross_min_deterministic_ref = deterministic
}

///|
pub fn GraphInfoHolder::cross_min_always_improves(
  self : GraphInfoHolder,
) -> Bool {
  match self.cross_minimizer_ref {
    Some(cross_minimizer) => cross_minimizer.always_improves()
    None => self.cross_min_always_improves_ref
  }
}

///|
pub fn GraphInfoHolder::get_best_sweep(self : GraphInfoHolder) -> SweepCopy? {
  if self.cross_min_deterministic() {
    self.currently_best_node_and_port_order_ref
  } else {
    self.best_node_and_port_order_ref
  }
}

///|
pub fn GraphInfoHolder::parent_layer_id(self : GraphInfoHolder) -> Int {
  graph_info_parent_layer_id(self.parent())
}

///|
pub fn GraphInfoHolder::init_at_node_level(
  self : GraphInfoHolder,
  l : Int,
  n : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  ignore(l)
  let node = node_order[l][n]
  let is_external_port = match node.get_type() {
    NodeType::ExternalPort => true
    _ => false
  }
  if is_external_port {
    self.has_external_ports_ref = true
  }
  match node.get_nested_graph() {
    Some(nested) => graph_info_add_unique_graph(self.child_graphs_ref, nested)
    None => ()
  }
}

///|
pub fn GraphInfoHolder::init_at_port_level(
  self : GraphInfoHolder,
  l : Int,
  n : Int,
  p : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  ignore(l)
  ignore(n)
  ignore(p)
  ignore(node_order)
  self.n_ports = self.n_ports + 1
}

///|
pub fn GraphInfoHolder::init_after_traversal(self : GraphInfoHolder) -> Unit {
  self.port_positions_ref = Array::make(self.n_ports, 0)
}

///|
pub fn GraphInfoHolder::as_initializable(
  self : GraphInfoHolder,
) -> IInitializable {
  new_i_initializable(
    init_at_node_level=(l, n, node_order) => {
      self.init_at_node_level(l, n, node_order)
    },
    init_at_port_level=(l, n, p, node_order) => {
      self.init_at_port_level(l, n, p, node_order)
    },
    init_after_traversal=() => self.init_after_traversal(),
  )
}
