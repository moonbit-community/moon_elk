///|
let depth_first_compaction_root : Ref[Tree[Node]?] = Ref::new(None)

///|
let depth_first_compaction_orthogonal_compaction : Ref[Bool] = Ref::new(false)

///|
let depth_first_compaction_svg : Ref[SvgImage?] = Ref::new(None)

///|
fn depth_first_compaction_node_identity_eq(left : Node, right : Node) -> Bool {
  left.original_vertex.x == right.original_vertex.x &&
  left.original_vertex.y == right.original_vertex.y
}

///|
fn depth_first_compaction_tree_identity_eq(
  left : Tree[Node],
  right : Tree[Node],
) -> Bool {
  left.uid == right.uid
}

///|
fn depth_first_compaction_fuzzy_compare(left : Double, right : Double) -> Int {
  if (left - right).abs() <= spore_fuzziness {
    0
  } else if left < right {
    -1
  } else {
    1
  }
}

///|
fn depth_first_compaction_svg_get() -> SvgImage {
  match depth_first_compaction_svg.val {
    Some(svg) => svg
    None => abort("DepthFirstCompaction is not initialized")
  }
}

///|
fn depth_first_compaction_root_get() -> Tree[Node] {
  match depth_first_compaction_root.val {
    Some(root) => root
    None => abort("DepthFirstCompaction root is not initialized")
  }
}

///|
pub fn depth_first_compaction_compact(
  tree : Tree[Node],
  orthogonal : Bool,
  debug_output_file? : String? = None,
) -> Unit {
  depth_first_compaction_svg.val = Some(new_svg_image(debug_output_file))
  depth_first_compaction_orthogonal_compaction.val = orthogonal
  depth_first_compaction_root.val = Some(tree)
  depth_first_compaction_debug_out(tree, None)
  depth_first_compaction_compact_tree(tree)
}

///|
fn depth_first_compaction_compact_tree(tree : Tree[Node]) -> Unit {
  for child in tree.children {
    depth_first_compaction_compact_tree(child)
  }

  for child in tree.children {
    let compaction_vector = tree.node.vertex.clone().sub(child.node.vertex)

    if depth_first_compaction_orthogonal_compaction.val {
      let root_rect = tree.node.rect
      let child_rect = child.node.rect
      if compaction_vector.x.abs() >= compaction_vector.y.abs() {
        compaction_vector.y = 0.0
        if child_rect.y + child_rect.height > root_rect.y &&
          child_rect.y < root_rect.y + root_rect.height {
          ignore(
            compaction_vector.scale_to_length(
              @cmp.maximum(
                root_rect.x - (child_rect.x + child_rect.width),
                child_rect.x - (root_rect.x + root_rect.width),
              ),
            ),
          )
        }
      } else {
        compaction_vector.x = 0.0
        if child_rect.x + child_rect.width > root_rect.x &&
          child_rect.x < root_rect.x + root_rect.width {
          ignore(
            compaction_vector.scale_to_length(
              @cmp.maximum(
                root_rect.y - (child_rect.y + child_rect.height),
                child_rect.y - (root_rect.y + root_rect.height),
              ),
            ),
          )
        }
      }
    } else {
      ignore(compaction_vector.scale_to_length(tree.node.underlap(child.node)))
    }

    let min_underlap = depth_first_compaction_get_min_underlap(
      depth_first_compaction_root_get(),
      child,
      compaction_vector.length(),
      compaction_vector,
    )

    ignore(compaction_vector.scale_to_length(min_underlap))
    depth_first_compaction_translate_subtree(child, compaction_vector)
    depth_first_compaction_debug_out(tree, Some(child))
  }
}

///|
fn depth_first_compaction_get_min_underlap(
  tree : Tree[Node],
  child : Tree[Node],
  current_min_underlap : Double,
  compaction_vector : @core.KVector,
) -> Double {
  let mut min_underlap = @cmp.minimum(
    current_min_underlap,
    depth_first_compaction_min_underlap_with_subtree(
      tree.node,
      child,
      current_min_underlap,
      compaction_vector,
    ),
  )

  for sub_tree in tree.children {
    if !depth_first_compaction_tree_identity_eq(sub_tree, child) {
      min_underlap = @cmp.minimum(
        min_underlap,
        depth_first_compaction_get_min_underlap(
          sub_tree, child, min_underlap, compaction_vector,
        ),
      )
    }
  }

  min_underlap
}

///|
fn depth_first_compaction_min_underlap_with_subtree(
  root_node : Node,
  tree : Tree[Node],
  current_min_underlap : Double,
  compaction_vector : @core.KVector,
) -> Double {
  let mut min_underlap = current_min_underlap
  for child in tree.children {
    let child_node = child.node
    if root_node.touches(child_node) {
      if (
          depth_first_compaction_fuzzy_compare(
            child_node.rect.x,
            root_node.rect.x + root_node.rect.width,
          ) ==
          0 &&
          compaction_vector.x < 0.0
        ) ||
        (
          depth_first_compaction_fuzzy_compare(
            child_node.rect.x + child_node.rect.width,
            root_node.rect.x,
          ) ==
          0 &&
          compaction_vector.x > 0.0
        ) ||
        (
          depth_first_compaction_fuzzy_compare(
            child_node.rect.y,
            root_node.rect.y + root_node.rect.height,
          ) ==
          0 &&
          compaction_vector.y < 0.0
        ) ||
        (
          depth_first_compaction_fuzzy_compare(
            child_node.rect.y + child_node.rect.height,
            root_node.rect.y,
          ) ==
          0 &&
          compaction_vector.y > 0.0
        ) {
        min_underlap = 0.0
        break
      }
    } else {
      min_underlap = @cmp.minimum(
        min_underlap,
        root_node.distance(child_node, compaction_vector),
      )
    }

    min_underlap = @cmp.minimum(
      min_underlap,
      depth_first_compaction_min_underlap_with_subtree(
        root_node, child, min_underlap, compaction_vector,
      ),
    )
  }

  min_underlap
}

///|
fn depth_first_compaction_translate_subtree(
  tree : Tree[Node],
  compaction_vector : @core.KVector,
) -> Unit {
  tree.node.translate(compaction_vector)
  for child in tree.children {
    depth_first_compaction_translate_subtree(child, compaction_vector)
  }
}

///|
fn depth_first_compaction_draw_tree(
  tree : Tree[Node],
  svg_image : SvgImage,
  mark_node : Node?,
) -> Unit {
  svg_image
  .g("rects")
  .add_rect_from_elk(tree.node.rect, "fill=\"none\" stroke=\"black\"")
  svg_image
  .g("centers")
  .add_circle(
    tree.node.vertex.x,
    tree.node.vertex.y,
    r=6.0,
    attributes="fill=\"black\"",
  )

  for child in tree.children {
    let mut marked = false
    match mark_node {
      Some(node) =>
        marked = depth_first_compaction_node_identity_eq(child.node, node)
      None => ()
    }

    if marked {
      svg_image
      .g("edges")
      .add_line(
        tree.node.vertex.x,
        tree.node.vertex.y,
        child.node.vertex.x,
        child.node.vertex.y,
        attributes="stroke=\"red\" stroke-width=\"5\" stroke-dasharray=\"8,8\"",
      )
    } else {
      svg_image
      .g("edges")
      .add_line(
        tree.node.vertex.x,
        tree.node.vertex.y,
        child.node.vertex.x,
        child.node.vertex.y,
        attributes="stroke=\"blue\" stroke-width=\"2\"",
      )
    }
    depth_first_compaction_draw_tree(child, svg_image, mark_node)
  }
}

///|
fn depth_first_compaction_debug_out(
  tree : Tree[Node],
  mark : Tree[Node]?,
) -> Unit {
  ignore(tree)
  let svg = depth_first_compaction_svg_get()
  let root = depth_first_compaction_root_get()
  svg.clear()
  svg.add_groups(["rects", "root", "edges", "centers", "marks"])
  svg
  .g("root")
  .add_rect_from_elk(root.node.rect, "fill=\"#C4E3F3\" stroke=\"black\"")

  let mark_node = match mark {
    Some(mark_tree) => Some(mark_tree.node)
    None => None
  }
  depth_first_compaction_draw_tree(root, svg, mark_node)
  svg.isave()
}
