///|
fn contains_edge(edges : Array[TEdge], target : TEdge) -> Bool {
  for edge in edges {
    if edge.equals(target) {
      return true
    }
  }
  false
}

///|
fn tree_node_count(tree : Tree[KVector]) -> Int {
  let mut count = 1
  for child in tree.children {
    count = count + tree_node_count(child)
  }
  count
}

///|
fn tree_edges(tree : Tree[KVector]) -> Array[TEdge] {
  let edges : Array[TEdge] = []
  for child in tree.children {
    edges.push(new_tedge(tree.node, child.node))
    for edge in tree_edges(child) {
      edges.push(edge)
    }
  }
  edges
}

///|
test "TEdge undirected equality and hash code" {
  let a = new_kvector_xy(1.0, 2.0)
  let b = new_kvector_xy(3.0, 4.0)
  let e1 = new_tedge(a, b)
  let e2 = new_tedge(b, a)
  assert_true(e1.equals(e2))
  assert_true(e2.equals(e1))
  assert_eq(e1.hash_code(), e2.hash_code())
}

///|
test "TTriangle circumcenter and containment" {
  let a = new_kvector_xy(0.0, 0.0)
  let b = new_kvector_xy(2.0, 0.0)
  let c = new_kvector_xy(0.0, 2.0)
  let triangle = new_ttriangle(a, b, c)
  let center = triangle.get_circumcenter()
  assert_double_eq(center.x, 1.0, 0.0000001)
  assert_double_eq(center.y, 1.0, 0.0000001)
  assert_true(triangle.contains_edge(new_tedge(a, b)))
  assert_true(triangle.contains_vertex(c))
  assert_true(triangle.in_circumcircle(new_kvector_xy(1.0, 1.0)))
  assert_false(triangle.in_circumcircle(new_kvector_xy(4.0, 4.0)))
}

///|
test "Bowyer-Watson triangulation on square" {
  let a = new_kvector_xy(0.0, 0.0)
  let b = new_kvector_xy(1.0, 0.0)
  let c = new_kvector_xy(1.0, 1.0)
  let d = new_kvector_xy(0.0, 1.0)
  let edges = bowyer_watson_triangulate([a, b, c, d])
  assert_eq(edges.length(), 5)
  assert_true(contains_edge(edges, new_tedge(a, b)))
  assert_true(contains_edge(edges, new_tedge(b, c)))
  assert_true(contains_edge(edges, new_tedge(c, d)))
  assert_true(contains_edge(edges, new_tedge(d, a)))
  assert_true(
    contains_edge(edges, new_tedge(a, c)) ||
    contains_edge(edges, new_tedge(b, d)),
  )
}

///|
test "NaiveMinST creates a minimum spanning tree" {
  let a = new_kvector_xy(0.0, 0.0)
  let b = new_kvector_xy(1.0, 0.0)
  let c = new_kvector_xy(2.0, 0.0)
  let d = new_kvector_xy(3.0, 0.0)
  let edges = [
    new_tedge(a, b),
    new_tedge(b, c),
    new_tedge(c, d),
    new_tedge(a, c),
    new_tedge(b, d),
  ]
  let cost_function : ICostFunction = (edge : TEdge) => edge.u.distance(edge.v)
  let tree = naive_minst_create_spanning_tree(edges, a, cost_function)
  let mst_edges = tree_edges(tree)
  assert_true(tree.node.equals(a))
  assert_eq(tree_node_count(tree), 4)
  assert_eq(mst_edges.length(), 3)
  assert_true(contains_edge(mst_edges, new_tedge(a, b)))
  assert_true(contains_edge(mst_edges, new_tedge(b, c)))
  assert_true(contains_edge(mst_edges, new_tedge(c, d)))
}
