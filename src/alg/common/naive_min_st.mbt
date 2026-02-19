///|
priv struct WeightedEdge {
  edge : TEdge
  weight : Double
}

///|
priv struct TreeNodeEntry {
  node : @core.KVector
  tree : Tree[@core.KVector]
}

///|
fn contains_tree_node(
  entries : Array[TreeNodeEntry],
  node : @core.KVector,
) -> Bool {
  for entry in entries {
    if entry.node.equals(node) {
      return true
    }
  }
  false
}

///|
fn find_tree_node(
  entries : Array[TreeNodeEntry],
  node : @core.KVector,
) -> Tree[@core.KVector]? {
  for entry in entries {
    if entry.node.equals(node) {
      return Some(entry.tree)
    }
  }
  None
}

///|
fn upsert_tree_node(
  entries : Array[TreeNodeEntry],
  node : @core.KVector,
  tree : Tree[@core.KVector],
) -> Unit {
  for i in 0..<entries.length() {
    if entries[i].node.equals(node) {
      entries[i] = { node, tree }
      return
    }
  }
  entries.push({ node, tree })
}

///|
fn edge_weight(weighted_edges : Array[WeightedEdge], edge : TEdge) -> Double {
  for weighted in weighted_edges {
    if weighted.edge.equals(edge) {
      return weighted.weight
    }
  }
  0.0
}

///|
pub fn naive_minst_create_spanning_tree(
  t_edges : Array[TEdge],
  root : @core.KVector,
  cost_function : ICostFunction,
  debug_output_file? : String? = None,
) -> Tree[@core.KVector] {
  let weighted_edges : Array[WeightedEdge] = []
  for edge in t_edges {
    let weighted = { edge, weight: cost_function(edge) }
    let mut inserted = false
    for i in 0..<weighted_edges.length() {
      if weighted.weight < weighted_edges[i].weight {
        weighted_edges.insert(i, weighted)
        inserted = true
        break
      }
    }
    if !inserted {
      weighted_edges.push(weighted)
    }
  }
  let edges : Array[TEdge] = []
  for weighted in weighted_edges {
    edges.push(weighted.edge)
  }
  let min_st = new_tree(root)
  let tree_nodes : Array[TreeNodeEntry] = [{ node: root, tree: min_st }]
  let svg = new_svg_image(debug_output_file)
  svg.add_groups(["e", "t"])
  for edge in edges {
    svg
    .g("e")
    .add_line(
      edge.u.x,
      edge.u.y,
      edge.v.x,
      edge.v.y,
      attributes="stroke=\"black\" stroke-width=\"1\"",
    )
    svg
    .g("t")
    .add_text(
      (edge.u.x + edge.v.x) / 2.0,
      (edge.u.y + edge.v.y) / 2.0,
      edge_weight(weighted_edges, edge).to_string(),
      "fill=\"blue\" font-size=\"20px\"",
    )
  }
  svg.isave()
  while !edges.is_empty() {
    let mut next_index = -1
    let mut next_node : @core.KVector? = None
    let mut node_in_tree : @core.KVector? = None
    for i in 0..<edges.length() {
      let edge = edges[i]
      let u_in_tree = contains_tree_node(tree_nodes, edge.u)
      let v_in_tree = contains_tree_node(tree_nodes, edge.v)
      if u_in_tree && !v_in_tree {
        next_index = i
        next_node = Some(edge.v)
        node_in_tree = Some(edge.u)
        break
      }
      if v_in_tree && !u_in_tree {
        next_index = i
        next_node = Some(edge.u)
        node_in_tree = Some(edge.v)
        break
      }
    }
    if next_index < 0 {
      break
    }
    let next_edge = edges[next_index]
    let new_node = match next_node {
      Some(value) => value
      None => break
    }
    let parent_node = match node_in_tree {
      Some(value) => value
      None => break
    }
    let subtree = new_tree(new_node)
    match find_tree_node(tree_nodes, parent_node) {
      Some(parent_tree) => {
        parent_tree.children.push(subtree)
        upsert_tree_node(tree_nodes, new_node, subtree)
      }
      None => ()
    }
    ignore(edges.remove(next_index))
    svg
    .g("e")
    .add_line(
      next_edge.u.x,
      next_edge.u.y,
      next_edge.v.x,
      next_edge.v.y,
      attributes="stroke=\"red\" stroke-width=\"3\"",
    )
    svg.isave()
  }
  min_st
}
