///|
fn spore_shrink_tree_compaction_phase_configuration(
  graph : SporeGraph,
) -> LayoutProcessorConfiguration[SPOrEPhases, SporeGraph]? {
  ignore(graph)
  Some(layout_processor_configuration_create(spore_phase_descriptor))
}

///|
fn spore_shrink_tree_compaction_draw(tree : Tree[Node], svg : SvgImage) -> Unit {
  svg.add_rect_from_elk(tree.node.rect, "fill=\"none\" stroke=\"black\"")
  for child in tree.children {
    svg.add_line(
      tree.node.vertex.x,
      tree.node.vertex.y,
      child.node.vertex.x,
      child.node.vertex.y,
      attributes="stroke=\"blue\"",
    )
    let cv = tree.node.vertex.clone().sub(child.node.vertex)
    ignore(cv.scale_to_length(tree.node.distance(child.node, cv)))
    svg.add_line(
      child.node.vertex.x,
      child.node.vertex.y,
      child.node.vertex.x + cv.x,
      child.node.vertex.y + cv.y,
      attributes="stroke=\"orange\"",
    )
    spore_shrink_tree_compaction_draw(child, svg)
  }
}

///|
fn spore_shrink_tree_compaction_debug_out(tree : Tree[Node]) -> Unit {
  let svg = new_svg_image(Some("spore_30Tree"))
  svg.clear()
  svg.add_circle(
    tree.node.vertex.x,
    tree.node.vertex.y,
    r=10.0,
    attributes="fill=\"lime\"",
  )
  spore_shrink_tree_compaction_draw(tree, svg)
  svg.save()
}

///|
fn spore_shrink_tree_compaction_phase_process(
  graph : SporeGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(existing) => existing
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Shrinking tree compaction", 1.0))

  let tree = match graph.tree {
    Some(existing) => existing
    None => {
      monitor.done()
      return
    }
  }

  if graph.debug_svg {
    spore_shrink_tree_compaction_debug_out(tree)
    depth_first_compaction_compact(
      tree,
      graph.orthogonal_compaction,
      debug_output_file=Some("spore_60compaction"),
    )
  } else {
    depth_first_compaction_compact(tree, graph.orthogonal_compaction)
  }

  monitor.done()
}

///|
pub fn new_spore_shrink_tree_compaction_layout_phase() -> ILayoutProcessor[
  SPOrEPhases,
  SporeGraph,
] {
  new_layout_phase(
    spore_shrink_tree_compaction_phase_process, spore_shrink_tree_compaction_phase_configuration,
  )
}
