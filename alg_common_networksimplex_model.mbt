///|
pub struct NNode {
  handle : Int
} derive(Eq)

///|
pub struct NEdge {
  handle : Int
} derive(Eq)

///|
priv struct NNodeData {
  id : Int
  mut internal_id : Int
  origin : String?
  node_type : String
  mut layer : Int
  outgoing_edges : Array[NEdge]
  incoming_edges : Array[NEdge]
  mut tree_node : Bool
  unknown_cutvalues : Array[NEdge]
}

///|
priv struct NEdgeData {
  id : Int
  mut internal_id : Int
  origin : String?
  mut source : NNode?
  mut target : NNode?
  mut weight : Double
  mut delta : Int
  mut tree_edge : Bool
}

///|
pub struct NGraph {
  nodes : Array[NNode]
}

///|
pub struct NNodeBuilder {
  mut id : Int
  mut origin : String?
  mut node_type : String
}

///|
pub struct NEdgeBuilder {
  mut id : Int
  mut origin : String?
  mut weight : Double
  mut delta : Int
  mut source : NNode?
  mut target : NNode?
}

///|
let nnode_store : Ref[Array[NNodeData]] = Ref::new([])

///|
let nedge_store : Ref[Array[NEdgeData]] = Ref::new([])

///|
fn checked_nnode(node : NNode) -> Unit {
  if node.handle < 0 || node.handle >= nnode_store.val.length() {
    abort("invalid network simplex node id")
  }
}

///|
fn checked_nedge(edge : NEdge) -> Unit {
  if edge.handle < 0 || edge.handle >= nedge_store.val.length() {
    abort("invalid network simplex edge id")
  }
}

///|
fn[T : Eq] remove_first(array : Array[T], value : T) -> Bool {
  for i in 0..<array.length() {
    if array[i] == value {
      ignore(array.remove(i))
      return true
    }
  }
  false
}

///|
fn int_max(left : Int, right : Int) -> Int {
  if left > right {
    left
  } else {
    right
  }
}

///|
pub fn reset_network_simplex_model_for_test() -> Unit {
  nnode_store.val.clear()
  nedge_store.val.clear()
}

///|
pub fn new_ngraph() -> NGraph {
  { nodes: [] }
}

///|
pub fn NGraph::write_debug_graph(self : NGraph, file_path : String) -> Unit {
  ignore(self)
  ignore(file_path)
}

///|
pub fn nnode_of() -> NNodeBuilder {
  { id: 0, origin: None, node_type: "" }
}

///|
pub fn NNodeBuilder::id(self : NNodeBuilder, id : Int) -> NNodeBuilder {
  self.id = id
  self
}

///|
pub fn NNodeBuilder::origin(
  self : NNodeBuilder,
  origin : String,
) -> NNodeBuilder {
  self.origin = Some(origin)
  self
}

///|
pub fn NNodeBuilder::node_type(
  self : NNodeBuilder,
  node_type : String,
) -> NNodeBuilder {
  self.node_type = node_type
  self
}

///|
pub fn NNodeBuilder::create(self : NNodeBuilder, graph : NGraph) -> NNode {
  let node : NNode = { handle: nnode_store.val.length() }
  nnode_store.val.push({
    id: self.id,
    internal_id: 0,
    origin: self.origin,
    node_type: self.node_type,
    layer: 0,
    outgoing_edges: [],
    incoming_edges: [],
    tree_node: false,
    unknown_cutvalues: [],
  })
  graph.nodes.push(node)
  node
}

///|
pub fn nedge_of() -> NEdgeBuilder {
  { id: 0, origin: None, weight: 0.0, delta: 1, source: None, target: None }
}

///|
pub fn NEdgeBuilder::id(self : NEdgeBuilder, id : Int) -> NEdgeBuilder {
  self.id = id
  self
}

///|
pub fn NEdgeBuilder::origin(
  self : NEdgeBuilder,
  origin : String,
) -> NEdgeBuilder {
  self.origin = Some(origin)
  self
}

///|
pub fn NEdgeBuilder::weight(
  self : NEdgeBuilder,
  weight : Double,
) -> NEdgeBuilder {
  self.weight = weight
  self
}

///|
pub fn NEdgeBuilder::delta(self : NEdgeBuilder, delta : Int) -> NEdgeBuilder {
  self.delta = delta
  self
}

///|
pub fn NEdgeBuilder::source(
  self : NEdgeBuilder,
  source : NNode,
) -> NEdgeBuilder {
  checked_nnode(source)
  self.source = Some(source)
  self
}

///|
pub fn NEdgeBuilder::target(
  self : NEdgeBuilder,
  target : NNode,
) -> NEdgeBuilder {
  checked_nnode(target)
  self.target = Some(target)
  self
}

///|
pub fn NEdgeBuilder::create(self : NEdgeBuilder) -> NEdge {
  let source = match self.source {
    Some(node) => node
    None => abort("NEdge must have a source and target NNode specified.")
  }
  let target = match self.target {
    Some(node) => node
    None => abort("NEdge must have a source and target NNode specified.")
  }
  if source == target {
    abort("Network simplex does not support self-loops")
  }
  let edge : NEdge = { handle: nedge_store.val.length() }
  nedge_store.val.push({
    id: self.id,
    internal_id: 0,
    origin: self.origin,
    source: Some(source),
    target: Some(target),
    weight: self.weight,
    delta: self.delta,
    tree_edge: false,
  })
  nnode_store.val[source.handle].outgoing_edges.push(edge)
  nnode_store.val[target.handle].incoming_edges.push(edge)
  edge
}

///|
pub fn NNode::get_id(self : NNode) -> Int {
  checked_nnode(self)
  nnode_store.val[self.handle].id
}

///|
pub fn NNode::set_internal_id(self : NNode, internal_id : Int) -> Unit {
  checked_nnode(self)
  nnode_store.val[self.handle].internal_id = internal_id
}

///|
pub fn NNode::get_internal_id(self : NNode) -> Int {
  checked_nnode(self)
  nnode_store.val[self.handle].internal_id
}

///|
pub fn NNode::set_layer(self : NNode, layer : Int) -> Unit {
  checked_nnode(self)
  nnode_store.val[self.handle].layer = layer
}

///|
pub fn NNode::get_layer(self : NNode) -> Int {
  checked_nnode(self)
  nnode_store.val[self.handle].layer
}

///|
pub fn NNode::set_tree_node(self : NNode, tree_node : Bool) -> Unit {
  checked_nnode(self)
  nnode_store.val[self.handle].tree_node = tree_node
}

///|
pub fn NNode::is_tree_node(self : NNode) -> Bool {
  checked_nnode(self)
  nnode_store.val[self.handle].tree_node
}

///|
pub fn NNode::get_outgoing_edges(self : NNode) -> Array[NEdge] {
  checked_nnode(self)
  nnode_store.val[self.handle].outgoing_edges
}

///|
pub fn NNode::get_incoming_edges(self : NNode) -> Array[NEdge] {
  checked_nnode(self)
  nnode_store.val[self.handle].incoming_edges
}

///|
pub fn NNode::get_connected_edges(self : NNode) -> Array[NEdge] {
  checked_nnode(self)
  let edges : Array[NEdge] = []
  for edge in nnode_store.val[self.handle].incoming_edges {
    edges.push(edge)
  }
  for edge in nnode_store.val[self.handle].outgoing_edges {
    edges.push(edge)
  }
  edges
}

///|
pub fn NNode::clear_unknown_cutvalues(self : NNode) -> Unit {
  checked_nnode(self)
  nnode_store.val[self.handle].unknown_cutvalues.clear()
}

///|
pub fn NNode::add_unknown_cutvalue(self : NNode, edge : NEdge) -> Unit {
  checked_nnode(self)
  checked_nedge(edge)
  nnode_store.val[self.handle].unknown_cutvalues.push(edge)
}

///|
pub fn NNode::remove_unknown_cutvalue(self : NNode, edge : NEdge) -> Unit {
  checked_nnode(self)
  checked_nedge(edge)
  ignore(remove_first(nnode_store.val[self.handle].unknown_cutvalues, edge))
}

///|
pub fn NNode::unknown_cutvalues(self : NNode) -> Array[NEdge] {
  checked_nnode(self)
  nnode_store.val[self.handle].unknown_cutvalues
}

///|
pub fn NEdge::get_id(self : NEdge) -> Int {
  checked_nedge(self)
  nedge_store.val[self.handle].id
}

///|
pub fn NEdge::set_internal_id(self : NEdge, internal_id : Int) -> Unit {
  checked_nedge(self)
  nedge_store.val[self.handle].internal_id = internal_id
}

///|
pub fn NEdge::get_internal_id(self : NEdge) -> Int {
  checked_nedge(self)
  nedge_store.val[self.handle].internal_id
}

///|
pub fn NEdge::set_tree_edge(self : NEdge, tree_edge : Bool) -> Unit {
  checked_nedge(self)
  nedge_store.val[self.handle].tree_edge = tree_edge
}

///|
pub fn NEdge::is_tree_edge(self : NEdge) -> Bool {
  checked_nedge(self)
  nedge_store.val[self.handle].tree_edge
}

///|
pub fn NEdge::get_source(self : NEdge) -> NNode {
  checked_nedge(self)
  match nedge_store.val[self.handle].source {
    Some(node) => node
    None => abort("edge source is missing")
  }
}

///|
pub fn NEdge::get_target(self : NEdge) -> NNode {
  checked_nedge(self)
  match nedge_store.val[self.handle].target {
    Some(node) => node
    None => abort("edge target is missing")
  }
}

///|
pub fn NEdge::set_source(self : NEdge, source : NNode) -> Unit {
  checked_nedge(self)
  checked_nnode(source)
  nedge_store.val[self.handle].source = Some(source)
}

///|
pub fn NEdge::set_target(self : NEdge, target : NNode) -> Unit {
  checked_nedge(self)
  checked_nnode(target)
  nedge_store.val[self.handle].target = Some(target)
}

///|
pub fn NEdge::get_weight(self : NEdge) -> Double {
  checked_nedge(self)
  nedge_store.val[self.handle].weight
}

///|
pub fn NEdge::set_weight(self : NEdge, weight : Double) -> Unit {
  checked_nedge(self)
  nedge_store.val[self.handle].weight = weight
}

///|
pub fn NEdge::get_delta(self : NEdge) -> Int {
  checked_nedge(self)
  nedge_store.val[self.handle].delta
}

///|
pub fn NEdge::set_delta(self : NEdge, delta : Int) -> Unit {
  checked_nedge(self)
  nedge_store.val[self.handle].delta = delta
}

///|
pub fn NEdge::get_other(self : NEdge, some : NNode) -> NNode {
  checked_nedge(self)
  checked_nnode(some)
  let source = self.get_source()
  let target = self.get_target()
  if some == source {
    target
  } else if some == target {
    source
  } else {
    abort("Node not part of edge")
  }
}

///|
pub fn NEdge::reverse(self : NEdge) -> NEdge {
  checked_nedge(self)
  let source = self.get_source()
  let target = self.get_target()
  self.set_source(target)
  self.set_target(source)
  ignore(remove_first(nnode_store.val[source.handle].outgoing_edges, self))
  nnode_store.val[source.handle].incoming_edges.push(self)
  ignore(remove_first(nnode_store.val[target.handle].incoming_edges, self))
  nnode_store.val[target.handle].outgoing_edges.push(self)
  self
}

///|
fn ngraph_dfs(node : NNode, mark : Array[Bool]) -> Unit {
  let node_internal_id = node.get_internal_id()
  if mark[node_internal_id] {
    return
  }
  mark[node_internal_id] = true
  for edge in node.get_connected_edges() {
    let other = edge.get_other(node)
    ngraph_dfs(other, mark)
  }
}

///|
fn ngraph_find_con_comp_representatives(graph : NGraph) -> Array[NNode] {
  let cc_rep : Array[NNode] = []
  let mark : Array[Bool] = []
  for _ in 0..<graph.nodes.length() {
    mark.push(false)
  }
  for node in graph.nodes {
    if !mark[node.get_internal_id()] {
      cc_rep.push(node)
      ngraph_dfs(node, mark)
    }
  }
  cc_rep
}

///|
fn ngraph_create_artificial_root_and_connect(
  graph : NGraph,
  nodes_to_connect : Array[NNode],
) -> NNode {
  let root = nnode_of().create(graph)
  for src in nodes_to_connect {
    ignore(nedge_of().delta(0).weight(0.0).source(root).target(src).create())
  }
  root
}

///|
pub fn NGraph::make_connected(self : NGraph) -> NNode? {
  let mut id = 0
  for node in self.nodes {
    node.set_internal_id(id)
    id = id + 1
  }
  let cc_rep = ngraph_find_con_comp_representatives(self)
  if cc_rep.length() > 1 {
    Some(ngraph_create_artificial_root_and_connect(self, cc_rep))
  } else {
    None
  }
}

///|
pub fn NGraph::is_acyclic(self : NGraph) -> Bool {
  let mut id = 0
  for node in self.nodes {
    node.set_internal_id(id)
    id = id + 1
  }
  let incident : Array[Int] = []
  let layer : Array[Int] = []
  for _ in 0..<self.nodes.length() {
    incident.push(0)
    layer.push(0)
  }
  for node in self.nodes {
    incident[node.get_internal_id()] = incident[node.get_internal_id()] +
      node.get_incoming_edges().length()
  }
  let roots : Array[NNode] = []
  for node in self.nodes {
    if node.get_incoming_edges().is_empty() {
      roots.push(node)
    }
  }
  if roots.is_empty() && !self.nodes.is_empty() {
    return false
  }
  while !roots.is_empty() {
    let node = roots[0]
    ignore(roots.remove(0))
    for edge in node.get_outgoing_edges() {
      let target = edge.get_target()
      let target_id = target.get_internal_id()
      let node_id = node.get_internal_id()
      layer[target_id] = int_max(layer[target_id], layer[node_id] + 1)
      incident[target_id] = incident[target_id] - 1
      if incident[target_id] == 0 {
        roots.push(target)
      }
    }
  }
  for node in self.nodes {
    for edge in node.get_outgoing_edges() {
      if layer[edge.get_target().get_internal_id()] <=
        layer[edge.get_source().get_internal_id()] {
        return false
      }
    }
  }
  true
}
