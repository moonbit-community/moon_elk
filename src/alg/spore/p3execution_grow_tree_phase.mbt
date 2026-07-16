///|
fn spore_grow_tree_phase_configuration(
  graph : SporeGraph,
) -> @core.LayoutProcessorConfiguration[SPOrEPhases, SporeGraph]? {
  ignore(graph)
  Some(@core.layout_processor_configuration_create(spore_phase_descriptor))
}

///|
fn spore_grow_tree_draw_tree(
  tree : @common.Tree[@common.Node],
  svg : @common.SvgImage,
) -> Unit {
  svg.g("n").add_rect_from_elk(tree.node.rect, "fill=\"none\" stroke=\"black\"")
  for child in tree.children {
    svg
    .g("e")
    .add_line(
      tree.node.vertex.x,
      tree.node.vertex.y,
      child.node.vertex.x,
      child.node.vertex.y,
      attributes="stroke=\"blue\"",
    )
    spore_grow_tree_draw_tree(child, svg)
  }
}

///|
fn spore_grow_tree_debug_out(
  svg : @common.SvgImage,
  root : @common.Tree[@common.Node],
  child : @common.Tree[@common.Node]?,
) -> Unit {
  svg.clear_group("n")
  svg.clear_group("e")
  svg.clear_group("o")
  spore_grow_tree_draw_tree(root, svg)
  svg
  .g("n")
  .add_rect_from_elk(
    root.node.rect,
    "fill=\"blue\" stroke=\"none\" opacity=\"0.2\"",
  )
  match child {
    Some(marked) =>
      svg
      .g("o")
      .add_rect_from_elk(
        marked.node.rect,
        "fill=\"red\" stroke=\"none\" opacity=\"0.2\"",
      )
    None => ()
  }
  svg.isave()
}

///|
fn spore_grow_tree_grow_at(
  tree : @common.Tree[@common.Node],
  root : @common.Tree[@common.Node],
  svg : @common.SvgImage,
  overlaps_existed : Ref[Bool],
) -> Unit {
  for child in tree.children {
    child.node.translate(
      tree.node.vertex.clone().sub(tree.node.original_vertex),
    )

    let factor = @common.overlap(tree.node.rect, child.node.rect)
    if factor > 1.0 {
      overlaps_existed.val = true
    }

    child.node.set_center_position(
      tree.node.vertex
      .clone()
      .add(
        child.node.original_vertex
        .clone()
        .sub(tree.node.original_vertex)
        .scale(factor),
      ),
    )

    spore_grow_tree_debug_out(svg, root, Some(child))
    spore_grow_tree_grow_at(child, root, svg, overlaps_existed)
  }
}

///|
fn spore_grow_tree_phase_process(
  graph : SporeGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(existing) => existing
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Grow @common.Tree", 1.0))

  let root = match graph.tree {
    Some(tree) => tree
    None => {
      graph.overlaps_existed = false
      monitor.done()
      return
    }
  }

  let svg = if graph.debug_svg {
    let image = @common.new_svg_image(Some("spore_40or"))
    image.add_groups(["n", "e", "o"])
    spore_grow_tree_debug_out(image, root, None)
    image
  } else {
    @common.new_svg_image(None)
  }

  let overlaps_existed : Ref[Bool] = Ref(false)
  spore_grow_tree_grow_at(root, root, svg, overlaps_existed)
  graph.overlaps_existed = overlaps_existed.val
  monitor.done()
}

///|
pub fn new_spore_grow_tree_layout_phase() -> @core.ILayoutProcessor[
  SPOrEPhases,
  SporeGraph,
] {
  @core.new_layout_phase(
    spore_grow_tree_phase_process, spore_grow_tree_phase_configuration,
  )
}
