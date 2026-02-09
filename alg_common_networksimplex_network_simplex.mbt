///|
let ns_remove_subtrees_thresh = 40

///|
let ns_fuzzy_st_zero = -1.0e-10

///|
let ns_int_max_value = 2147483647

///|
let ns_int_min_value = -2147483648

///|
fn ns_int_min(left : Int, right : Int) -> Int {
  if left < right {
    left
  } else {
    right
  }
}

///|
fn ns_int_max(left : Int, right : Int) -> Int {
  if left > right {
    left
  } else {
    right
  }
}

///|
fn ns_bool_array(size : Int, init : Bool) -> Array[Bool] {
  let array : Array[Bool] = []
  for _ in 0..<size {
    array.push(init)
  }
  array
}

///|
fn ns_int_array(size : Int, init : Int) -> Array[Int] {
  let array : Array[Int] = []
  for _ in 0..<size {
    array.push(init)
  }
  array
}

///|
fn ns_double_array(size : Int, init : Double) -> Array[Double] {
  let array : Array[Double] = []
  for _ in 0..<size {
    array.push(init)
  }
  array
}

///|
fn ns_reset_edge_visited(network_simplex : NetworkSimplex) -> Unit {
  for i in 0..<network_simplex.edge_visited.length() {
    network_simplex.edge_visited[i] = false
  }
}

///|
fn ns_add_tree_edge_unique(
  network_simplex : NetworkSimplex,
  edge : NEdge,
) -> Unit {
  for existing in network_simplex.tree_edges {
    if existing == edge {
      return
    }
  }
  network_simplex.tree_edges.push(edge)
}

///|
fn ns_remove_tree_edge(network_simplex : NetworkSimplex, edge : NEdge) -> Unit {
  for i in 0..<network_simplex.tree_edges.length() {
    if network_simplex.tree_edges[i] == edge {
      ignore(network_simplex.tree_edges.remove(i))
      return
    }
  }
}

///|
fn ns_remove_graph_node(graph : NGraph, node : NNode) -> Unit {
  for i in 0..<graph.nodes.length() {
    if graph.nodes[i] == node {
      ignore(graph.nodes.remove(i))
      return
    }
  }
}

///|
pub struct NetworkSimplex {
  graph : NGraph
  mut previous_layering_node_counts : Array[Int]?
  mut balance : Bool
  mut iteration_limit : Int
  mut edges : Array[NEdge]
  tree_edges : Array[NEdge]
  sources : Array[NNode]
  mut edge_visited : Array[Bool]
  mut post_order : Int
  mut po_id : Array[Int]
  mut lowest_po_id : Array[Int]
  mut cutvalue : Array[Double]
  subtree_nodes_stack : Array[(NNode, NEdge)]
}

///|
pub fn network_simplex_for_graph(graph : NGraph) -> NetworkSimplex {
  {
    graph,
    previous_layering_node_counts: None,
    balance: false,
    iteration_limit: ns_int_max_value,
    edges: [],
    tree_edges: [],
    sources: [],
    edge_visited: [],
    post_order: 1,
    po_id: [],
    lowest_po_id: [],
    cutvalue: [],
    subtree_nodes_stack: [],
  }
}

///|
pub fn NetworkSimplex::with_balancing(
  self : NetworkSimplex,
  do_balance : Bool,
) -> NetworkSimplex {
  self.balance = do_balance
  self
}

///|
pub fn NetworkSimplex::with_previous_layering(
  self : NetworkSimplex,
  consider_previous_layering : Array[Int],
) -> NetworkSimplex {
  self.previous_layering_node_counts = Some(consider_previous_layering.copy())
  self
}

///|
pub fn NetworkSimplex::with_iteration_limit(
  self : NetworkSimplex,
  limit : Int,
) -> NetworkSimplex {
  self.iteration_limit = limit
  self
}

///|
fn ns_initialize(network_simplex : NetworkSimplex) -> Unit {
  let num_nodes = network_simplex.graph.nodes.length()
  for node in network_simplex.graph.nodes {
    node.set_tree_node(false)
  }
  network_simplex.po_id = ns_int_array(num_nodes, 0)
  network_simplex.lowest_po_id = ns_int_array(num_nodes, 0)
  network_simplex.sources.clear()
  let mut index = 0
  let the_edges : Array[NEdge] = []
  for node in network_simplex.graph.nodes {
    node.set_internal_id(index)
    index = index + 1
    if node.get_incoming_edges().length() == 0 {
      network_simplex.sources.push(node)
    }
    for edge in node.get_outgoing_edges() {
      the_edges.push(edge)
    }
  }
  let mut counter = 0
  for edge in the_edges {
    edge.set_internal_id(counter)
    counter = counter + 1
    edge.set_tree_edge(false)
  }
  let num_edges = the_edges.length()
  network_simplex.cutvalue = ns_double_array(num_edges, 0.0)
  network_simplex.edge_visited = ns_bool_array(num_edges, false)
  network_simplex.edges = the_edges
  network_simplex.tree_edges.clear()
  network_simplex.post_order = 1
}

///|
fn ns_dispose(network_simplex : NetworkSimplex) -> Unit {
  network_simplex.cutvalue.clear()
  network_simplex.edges.clear()
  network_simplex.tree_edges.clear()
  network_simplex.edge_visited.clear()
  network_simplex.lowest_po_id.clear()
  network_simplex.po_id.clear()
  network_simplex.sources.clear()
  network_simplex.subtree_nodes_stack.clear()
}

///|
fn ns_layering_topological_numbering(
  network_simplex : NetworkSimplex,
  initial_root_nodes : Array[NNode],
) -> Unit {
  let incident = ns_int_array(network_simplex.graph.nodes.length(), 0)
  for node in network_simplex.graph.nodes {
    incident[node.get_internal_id()] = incident[node.get_internal_id()] +
      node.get_incoming_edges().length()
  }
  let roots = initial_root_nodes.copy()
  while !roots.is_empty() {
    let node = roots[0]
    ignore(roots.remove(0))
    for edge in node.get_outgoing_edges() {
      let target = edge.get_target()
      target.set_layer(
        ns_int_max(target.get_layer(), node.get_layer() + edge.get_delta()),
      )
      let target_id = target.get_internal_id()
      incident[target_id] = incident[target_id] - 1
      if incident[target_id] == 0 {
        roots.push(target)
      }
    }
  }
}

///|
fn ns_tight_tree_dfs(network_simplex : NetworkSimplex, node : NNode) -> Int {
  let mut node_count = 1
  node.set_tree_node(true)
  for edge in node.get_connected_edges() {
    let edge_internal_id = edge.get_internal_id()
    if !network_simplex.edge_visited[edge_internal_id] {
      network_simplex.edge_visited[edge_internal_id] = true
      let opposite = edge.get_other(node)
      if edge.is_tree_edge() {
        node_count = node_count + ns_tight_tree_dfs(network_simplex, opposite)
      } else if !opposite.is_tree_node() &&
        edge.get_delta() ==
        edge.get_target().get_layer() - edge.get_source().get_layer() {
        edge.set_tree_edge(true)
        ns_add_tree_edge_unique(network_simplex, edge)
        node_count = node_count + ns_tight_tree_dfs(network_simplex, opposite)
      }
    }
  }
  node_count
}

///|
fn ns_minimal_slack(network_simplex : NetworkSimplex) -> NEdge? {
  let mut min_slack = ns_int_max_value
  let mut min_slack_edge : NEdge? = None
  for edge in network_simplex.edges {
    if edge.get_source().is_tree_node() != edge.get_target().is_tree_node() {
      let current_slack = edge.get_target().get_layer() -
        edge.get_source().get_layer() -
        edge.get_delta()
      if current_slack < min_slack {
        min_slack = current_slack
        min_slack_edge = Some(edge)
      }
    }
  }
  min_slack_edge
}

///|
fn ns_postorder_traversal(
  network_simplex : NetworkSimplex,
  node : NNode,
) -> Int {
  let mut lowest = ns_int_max_value
  for edge in node.get_connected_edges() {
    let edge_internal_id = edge.get_internal_id()
    if edge.is_tree_edge() && !network_simplex.edge_visited[edge_internal_id] {
      network_simplex.edge_visited[edge_internal_id] = true
      lowest = ns_int_min(
        lowest,
        ns_postorder_traversal(network_simplex, edge.get_other(node)),
      )
    }
  }
  let node_internal_id = node.get_internal_id()
  network_simplex.po_id[node_internal_id] = network_simplex.post_order
  network_simplex.lowest_po_id[node_internal_id] = ns_int_min(
    lowest,
    network_simplex.post_order,
  )
  network_simplex.post_order = network_simplex.post_order + 1
  network_simplex.lowest_po_id[node_internal_id]
}

///|
fn ns_is_in_head(
  network_simplex : NetworkSimplex,
  node : NNode,
  edge : NEdge,
) -> Bool {
  let source = edge.get_source()
  let target = edge.get_target()
  if network_simplex.lowest_po_id[source.get_internal_id()] <=
    network_simplex.po_id[node.get_internal_id()] &&
    network_simplex.po_id[node.get_internal_id()] <=
    network_simplex.po_id[source.get_internal_id()] &&
    network_simplex.lowest_po_id[target.get_internal_id()] <=
    network_simplex.po_id[node.get_internal_id()] &&
    network_simplex.po_id[node.get_internal_id()] <=
    network_simplex.po_id[target.get_internal_id()] {
    if network_simplex.po_id[source.get_internal_id()] <
      network_simplex.po_id[target.get_internal_id()] {
      return false
    }
    return true
  }
  if network_simplex.po_id[source.get_internal_id()] <
    network_simplex.po_id[target.get_internal_id()] {
    return true
  }
  false
}

///|
fn ns_cutvalues(network_simplex : NetworkSimplex) -> Unit {
  let leafs : Array[NNode] = []
  for node in network_simplex.graph.nodes {
    let mut tree_edge_count = 0
    node.clear_unknown_cutvalues()
    for edge in node.get_connected_edges() {
      if edge.is_tree_edge() {
        node.add_unknown_cutvalue(edge)
        tree_edge_count = tree_edge_count + 1
      }
    }
    if tree_edge_count == 1 {
      leafs.push(node)
    }
  }
  for leaf in leafs {
    let mut node = leaf
    while node.unknown_cutvalues().length() == 1 {
      let to_determine = node.unknown_cutvalues()[0]
      let to_determine_internal_id = to_determine.get_internal_id()
      network_simplex.cutvalue[to_determine_internal_id] = to_determine.get_weight()
      let source = to_determine.get_source()
      let target = to_determine.get_target()
      for edge in node.get_connected_edges() {
        if edge != to_determine {
          let edge_internal_id = edge.get_internal_id()
          if edge.is_tree_edge() {
            if source == edge.get_source() || target == edge.get_target() {
              network_simplex.cutvalue[to_determine_internal_id] = network_simplex.cutvalue[to_determine_internal_id] -
                (network_simplex.cutvalue[edge_internal_id] - edge.get_weight())
            } else {
              network_simplex.cutvalue[to_determine_internal_id] = network_simplex.cutvalue[to_determine_internal_id] +
                (network_simplex.cutvalue[edge_internal_id] - edge.get_weight())
            }
          } else if node == source {
            if edge.get_source() == node {
              network_simplex.cutvalue[to_determine_internal_id] = network_simplex.cutvalue[to_determine_internal_id] +
                edge.get_weight()
            } else {
              network_simplex.cutvalue[to_determine_internal_id] = network_simplex.cutvalue[to_determine_internal_id] -
                edge.get_weight()
            }
          } else if edge.get_source() == node {
            network_simplex.cutvalue[to_determine_internal_id] = network_simplex.cutvalue[to_determine_internal_id] -
              edge.get_weight()
          } else {
            network_simplex.cutvalue[to_determine_internal_id] = network_simplex.cutvalue[to_determine_internal_id] +
              edge.get_weight()
          }
        }
      }
      source.remove_unknown_cutvalue(to_determine)
      target.remove_unknown_cutvalue(to_determine)
      if source == node {
        node = target
      } else {
        node = source
      }
    }
  }
}

///|
fn ns_leave_edge(network_simplex : NetworkSimplex) -> NEdge? {
  for edge in network_simplex.tree_edges {
    if edge.is_tree_edge() &&
      network_simplex.cutvalue[edge.get_internal_id()] < ns_fuzzy_st_zero {
      return Some(edge)
    }
  }
  None
}

///|
fn ns_enter_edge(network_simplex : NetworkSimplex, leave : NEdge) -> NEdge? {
  if !leave.is_tree_edge() {
    abort("The input edge is not a tree edge.")
  }
  let mut replace : NEdge? = None
  let mut replacement_slack = ns_int_max_value
  for edge in network_simplex.edges {
    let source = edge.get_source()
    let target = edge.get_target()
    if ns_is_in_head(network_simplex, source, leave) &&
      !ns_is_in_head(network_simplex, target, leave) {
      let slack = target.get_layer() - source.get_layer() - edge.get_delta()
      if slack < replacement_slack {
        replacement_slack = slack
        replace = Some(edge)
      }
    }
  }
  replace
}

///|
fn ns_exchange(
  network_simplex : NetworkSimplex,
  leave : NEdge,
  enter : NEdge,
) -> Unit {
  if !leave.is_tree_edge() {
    abort("Given leave edge is no tree edge.")
  }
  if enter.is_tree_edge() {
    abort("Given enter edge is a tree edge already.")
  }
  leave.set_tree_edge(false)
  ns_remove_tree_edge(network_simplex, leave)
  enter.set_tree_edge(true)
  ns_add_tree_edge_unique(network_simplex, enter)
  let mut delta = enter.get_target().get_layer() -
    enter.get_source().get_layer() -
    enter.get_delta()
  if !ns_is_in_head(network_simplex, enter.get_target(), leave) {
    delta = -delta
  }
  for node in network_simplex.graph.nodes {
    if !ns_is_in_head(network_simplex, node, leave) {
      node.set_layer(node.get_layer() + delta)
    }
  }
  network_simplex.post_order = 1
  ns_reset_edge_visited(network_simplex)
  ignore(
    ns_postorder_traversal(network_simplex, network_simplex.graph.nodes[0]),
  )
  ns_cutvalues(network_simplex)
}

///|
fn ns_minimal_span(node : NNode) -> (Int, Int) {
  let mut min_span_out = ns_int_max_value
  let mut min_span_in = ns_int_max_value
  for edge in node.get_connected_edges() {
    let current_span = edge.get_target().get_layer() -
      edge.get_source().get_layer()
    if edge.get_target() == node && current_span < min_span_in {
      min_span_in = current_span
    } else if current_span < min_span_out {
      min_span_out = current_span
    }
  }
  if min_span_in == ns_int_max_value {
    min_span_in = -1
  }
  if min_span_out == ns_int_max_value {
    min_span_out = -1
  }
  (min_span_in, min_span_out)
}

///|
fn ns_normalize(network_simplex : NetworkSimplex) -> Array[Int] {
  let mut highest = ns_int_min_value
  let mut lowest = ns_int_max_value
  for node in network_simplex.graph.nodes {
    lowest = ns_int_min(lowest, node.get_layer())
    highest = ns_int_max(highest, node.get_layer())
  }
  let filling = ns_int_array(highest - lowest + 1, 0)
  for node in network_simplex.graph.nodes {
    node.set_layer(node.get_layer() - lowest)
    filling[node.get_layer()] = filling[node.get_layer()] + 1
  }
  match network_simplex.previous_layering_node_counts {
    Some(node_counts) => {
      let mut layer_id = 0
      for node_count in node_counts {
        filling[layer_id] = filling[layer_id] + node_count
        layer_id = layer_id + 1
        if filling.length() == layer_id {
          break
        }
      }
    }
    None => ()
  }
  filling
}

///|
fn ns_balance(network_simplex : NetworkSimplex, filling : Array[Int]) -> Unit {
  for node in network_simplex.graph.nodes {
    if node.get_incoming_edges().length() == node.get_outgoing_edges().length() {
      let mut new_layer = node.get_layer()
      let (in_span, out_span) = ns_minimal_span(node)
      for i in (node.get_layer() - in_span + 1)..<(node.get_layer() + out_span) {
        if i >= 0 && i < filling.length() {
          if filling[i] < filling[new_layer] {
            new_layer = i
          }
        }
      }
      if filling[new_layer] < filling[node.get_layer()] {
        filling[node.get_layer()] = filling[node.get_layer()] - 1
        filling[new_layer] = filling[new_layer] + 1
        node.set_layer(new_layer)
      }
    }
  }
}

///|
fn ns_remove_subtrees(network_simplex : NetworkSimplex) -> Unit {
  network_simplex.subtree_nodes_stack.clear()
  let leafs : Array[NNode] = []
  for node in network_simplex.graph.nodes {
    if node.get_connected_edges().length() == 1 {
      leafs.push(node)
    }
  }
  while !leafs.is_empty() {
    let node = leafs[0]
    ignore(leafs.remove(0))
    let connected_edges = node.get_connected_edges()
    if connected_edges.length() == 0 {
      continue
    }
    let edge = connected_edges[0]
    let is_out_edge = node.get_outgoing_edges().length() > 0
    let other = edge.get_other(node)
    if is_out_edge {
      ignore(remove_first(other.get_incoming_edges(), edge))
    } else {
      ignore(remove_first(other.get_outgoing_edges(), edge))
    }
    if other.get_connected_edges().length() == 1 {
      leafs.push(other)
    }
    network_simplex.subtree_nodes_stack.push((node, edge))
    ns_remove_graph_node(network_simplex.graph, node)
  }
}

///|
fn ns_reattach_subtrees(network_simplex : NetworkSimplex) -> Unit {
  while !network_simplex.subtree_nodes_stack.is_empty() {
    let last_index = network_simplex.subtree_nodes_stack.length() - 1
    let (node, edge) = network_simplex.subtree_nodes_stack[last_index]
    ignore(network_simplex.subtree_nodes_stack.remove(last_index))
    let placed = edge.get_other(node)
    if edge.get_target() == node {
      placed.get_outgoing_edges().push(edge)
      node.set_layer(placed.get_layer() + edge.get_delta())
    } else {
      placed.get_incoming_edges().push(edge)
      node.set_layer(placed.get_layer() - edge.get_delta())
    }
    network_simplex.graph.nodes.push(node)
  }
}

///|
fn ns_feasible_tree(network_simplex : NetworkSimplex) -> Unit {
  ns_layering_topological_numbering(network_simplex, network_simplex.sources)
  if network_simplex.edges.length() > 0 {
    ns_reset_edge_visited(network_simplex)
    while ns_tight_tree_dfs(network_simplex, network_simplex.graph.nodes[0]) <
          network_simplex.graph.nodes.length() {
      let edge = match ns_minimal_slack(network_simplex) {
        Some(value) => value
        None => break
      }
      let mut slack = edge.get_target().get_layer() -
        edge.get_source().get_layer() -
        edge.get_delta()
      if edge.get_target().is_tree_node() {
        slack = -slack
      }
      for node in network_simplex.graph.nodes {
        if node.is_tree_node() {
          node.set_layer(node.get_layer() + slack)
        }
      }
      ns_reset_edge_visited(network_simplex)
    }
    ns_reset_edge_visited(network_simplex)
    ignore(
      ns_postorder_traversal(network_simplex, network_simplex.graph.nodes[0]),
    )
    ns_cutvalues(network_simplex)
  }
}

///|
pub fn NetworkSimplex::execute(
  self : NetworkSimplex,
  monitor? : IElkProgressMonitor = new_basic_progress_monitor(),
) -> Unit {
  ignore(monitor.begin("Network simplex", 1.0))
  if self.graph.nodes.length() < 1 {
    monitor.done()
    return
  }
  for node in self.graph.nodes {
    node.set_layer(0)
  }
  let remove_subtrees = self.graph.nodes.length() >= ns_remove_subtrees_thresh
  if remove_subtrees {
    ns_remove_subtrees(self)
  }
  ns_initialize(self)
  ns_feasible_tree(self)
  let mut leave_edge = ns_leave_edge(self)
  let mut iteration = 0
  while leave_edge is Some(leaving) && iteration < self.iteration_limit {
    match ns_enter_edge(self, leaving) {
      Some(entering) => {
        ns_exchange(self, leaving, entering)
        leave_edge = ns_leave_edge(self)
        iteration = iteration + 1
      }
      None => break
    }
  }
  if remove_subtrees {
    ns_reattach_subtrees(self)
  }
  if self.balance {
    ns_balance(self, ns_normalize(self))
  } else {
    ignore(ns_normalize(self))
  }
  ns_dispose(self)
  monitor.done()
}
