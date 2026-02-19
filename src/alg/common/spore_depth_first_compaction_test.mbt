///|
fn spore_compact_rect(
  x : Double,
  y : Double,
  w : Double,
  h : Double,
) -> ElkRectangle {
  new_elk_rectangle_xywh(x, y, w, h)
}

///|
fn spore_compact_node(x : Double, y : Double, w : Double, h : Double) -> Node {
  let rect = spore_compact_rect(x, y, w, h)
  new_node(rect.get_center(), rect)
}

///|
fn spore_compact_attach(parent : Tree[Node], child : Tree[Node]) -> Unit {
  parent.children.push(child)
}

///|
fn spore_assert_close(actual : Double, expected : Double) -> Unit raise {
  assert_true((actual - expected).abs() <= 0.0001)
}

///|
test "depth first compaction moves child toward parent" {
  let root_node = spore_compact_node(0.0, 0.0, 20.0, 20.0)
  let child_node = spore_compact_node(40.0, 0.0, 20.0, 20.0)

  let root = new_tree(root_node)
  spore_compact_attach(root, new_tree(child_node))

  depth_first_compaction_compact(root, false)

  spore_assert_close(root.node.rect.x, 0.0)
  spore_assert_close(child_node.rect.x, 20.0)
  spore_assert_close(child_node.rect.y, 0.0)
}

///|
test "depth first compaction translates whole subtree" {
  let root_node = spore_compact_node(0.0, 0.0, 20.0, 20.0)
  let child_node = spore_compact_node(40.0, 0.0, 20.0, 20.0)
  let grandchild_node = spore_compact_node(70.0, 0.0, 20.0, 20.0)

  let root = new_tree(root_node)
  let child = new_tree(child_node)
  spore_compact_attach(child, new_tree(grandchild_node))
  spore_compact_attach(root, child)

  depth_first_compaction_compact(root, false)

  spore_assert_close(child_node.rect.x, 20.0)
  spore_assert_close(grandchild_node.rect.x, 40.0)
}

///|
test "depth first compaction orthogonal keeps axis-aligned motion" {
  let root_node = spore_compact_node(0.0, 0.0, 20.0, 20.0)
  let child_node = spore_compact_node(40.0, 0.0, 20.0, 20.0)

  let root = new_tree(root_node)
  spore_compact_attach(root, new_tree(child_node))

  depth_first_compaction_compact(root, true)

  spore_assert_close(child_node.rect.x, 20.0)
  spore_assert_close(child_node.rect.y, 0.0)
}
