///|
pub enum TopdownSizeApproximator {
  CountChildren
  LookaheadLayout
  FixedIntegerRatioBoxes
  LayoutNextLevel
}

///|
pub fn topdown_size_approximator_to_string(
  approximator : TopdownSizeApproximator,
) -> String {
  match approximator {
    CountChildren => "COUNT_CHILDREN"
    LookaheadLayout => "LOOKAHEAD_LAYOUT"
    FixedIntegerRatioBoxes => "FIXED_INTEGER_RATIO_BOXES"
    LayoutNextLevel => "LAYOUT_NEXT_LEVEL"
  }
}

///|
pub fn topdown_size_approximator_from_string(
  value : String,
) -> TopdownSizeApproximator? {
  if value == "COUNT_CHILDREN" {
    Some(CountChildren)
  } else if value == "LOOKAHEAD_LAYOUT" {
    Some(LookaheadLayout)
  } else if value == "FIXED_INTEGER_RATIO_BOXES" {
    Some(FixedIntegerRatioBoxes)
  } else if value == "LAYOUT_NEXT_LEVEL" {
    Some(LayoutNextLevel)
  } else {
    None
  }
}

///|
pub fn topdown_size_approximator_as_interface(
  approximator : TopdownSizeApproximator,
) -> ITopdownSizeApproximator {
  new_topdown_size_approximator(node => approximator.get_size(node))
}

///|
fn topdown_size_approximator_parse_padding(value : String) -> ElkPadding {
  let padding_value = new_elk_padding()
  padding_value.parse(value)
  padding_value
}

///|
fn topdown_size_approximator_connectable_shape_to_node(
  shape : ElkConnectableShape,
) -> ElkNode {
  match shape {
    NodeShape(node) => node
    PortShape(_) => abort("Expected node endpoint in topdown size approximator")
  }
}

///|
fn topdown_size_approximator_first_target_node(edge : ElkEdge) -> ElkNode {
  let targets = edge_targets(edge)
  if targets.is_empty() {
    abort("Edge without target in topdown size approximator")
  }
  topdown_size_approximator_connectable_shape_to_node(targets[0])
}

///|
fn topdown_size_approximator_layout_graph(layout_graph : ElkNode) -> Unit {
  let resolved = node_get_string_property(layout_graph, resolved_algorithm)
  let progress_monitor = new_null_elk_progress_monitor()

  if resolved == layered_algorithm_id {
    new_layered_layout_provider().layout(layout_graph, progress_monitor)
    return
  }
  if resolved == mrtree_algorithm_id {
    new_mrtree_tree_layout_provider().layout(layout_graph, progress_monitor)
    return
  }
  if resolved == topdownpacking_algorithm_id {
    new_topdownpacking_layout_provider().layout(layout_graph, progress_monitor)
    return
  }
  if resolved == force_algorithm_id {
    new_force_layout_provider().layout(layout_graph, progress_monitor)
    return
  }
  if resolved == stress_algorithm_id {
    new_stress_layout_provider().layout(layout_graph, progress_monitor)
    return
  }
  if resolved == rectpacking_algorithm_id {
    new_rectpacking_layout_provider().layout(layout_graph, progress_monitor)
    return
  }
  if resolved == radial_algorithm_id {
    new_radial_layout_provider().layout(layout_graph, progress_monitor)
    return
  }
  if resolved == vertiflex_algorithm_id {
    new_vertiflex_layout_provider().layout(layout_graph, progress_monitor)
    return
  }
  if resolved == spore_compaction_algorithm_id {
    new_spore_shrink_tree_layout_provider().layout(
      layout_graph, progress_monitor,
    )
    return
  }
  if resolved == spore_overlap_removal_algorithm_id {
    new_spore_overlap_removal_layout_provider().layout(
      layout_graph, progress_monitor,
    )
    return
  }
  if resolved == "org.eclipse.elk.disco" {
    new_dis_co_layout_provider().layout(layout_graph, progress_monitor)
    return
  }

  new_recursive_graph_layout_engine().layout(layout_graph, progress_monitor)
}

///|
fn topdown_size_approximator_count_children(node : ElkNode) -> KVector {
  let size = node_get_double_property(node, topdown_hierarchical_node_width) *
    node_children(node).length().to_double().sqrt()
  new_kvector_xy(
    size,
    size /
    node_get_double_property(node, topdown_hierarchical_node_aspect_ratio),
  )
}

///|
fn topdown_size_approximator_lookahead_layout(
  original_graph : ElkNode,
) -> KVector {
  let cloned_node = create_node(None)
  node_copy_properties(cloned_node, original_graph)

  let old_to_new_node_map : Map[ElkNode, ElkNode] = {}

  for child in node_children(original_graph) {
    let new_child = create_node(Some(cloned_node))
    node_copy_properties(new_child, child)
    let size = topdown_size_approximator_count_children(child)
    node_set_dimensions(
      new_child,
      if node_width(child) > size.x {
        node_width(child)
      } else {
        size.x
      },
      if node_height(child) > size.y {
        node_height(child)
      } else {
        size.y
      },
    )
    old_to_new_node_map[child] = new_child
  }

  for child in node_children(original_graph) {
    for edge in node_outgoing_edges(child) {
      let new_src = match old_to_new_node_map.get(child) {
        Some(value) => value
        None => abort("Missing source node clone in topdown size approximator")
      }
      let target = topdown_size_approximator_first_target_node(edge)
      let new_tar = match old_to_new_node_map.get(target) {
        Some(value) => value
        None => abort("Missing target node clone in topdown size approximator")
      }
      let new_edge = create_edge(Some(cloned_node))
      edge_add_source(new_edge, make_node_shape(new_src))
      edge_add_target(new_edge, make_node_shape(new_tar))
      edge_copy_properties(new_edge, edge)
    }
  }

  topdown_size_approximator_layout_graph(cloned_node)

  if !(node_has_double_property(cloned_node, child_area_width) ||
    node_has_double_property(cloned_node, child_area_height)) {
    compute_child_area_dimensions(cloned_node)
  }

  let child_area_desired_width = node_get_double_property(
    cloned_node, child_area_width,
  )
  let child_area_desired_height = node_get_double_property(
    cloned_node, child_area_height,
  )
  let child_area_desired_aspect_ratio = child_area_desired_width /
    child_area_desired_height

  let base_size = node_get_double_property(
      cloned_node, topdown_hierarchical_node_width,
    ) *
    node_children(cloned_node).length().to_double().sqrt()

  let padding_value = topdown_size_approximator_parse_padding(
    node_get_string_property(cloned_node, padding),
  )
  let min_width = padding_value.left + padding_value.right + 1.0
  let min_height = padding_value.top + padding_value.bottom + 1.0

  new_kvector_xy(
    if min_width > base_size {
      min_width
    } else {
      base_size
    },
    if min_height > base_size / child_area_desired_aspect_ratio {
      min_height
    } else {
      base_size / child_area_desired_aspect_ratio
    },
  )
}

///|
fn topdown_size_approximator_fixed_integer_ratio_boxes(
  original_graph : ElkNode,
) -> KVector {
  let base_width = node_get_double_property(
    original_graph, topdown_hierarchical_node_width,
  )
  let base_height = base_width /
    node_get_double_property(
      original_graph, topdown_hierarchical_node_aspect_ratio,
    )

  let multiplier = topdown_size_approximator_util_get_size_category_multiplier(
    original_graph,
  )

  let padding_value = topdown_size_approximator_parse_padding(
    node_get_string_property(original_graph, padding),
  )

  let mut node_node_spacing = spacing_node_node.get_default()
  if node_parent(original_graph) is Some(parent) {
    node_node_spacing = node_get_double_property(parent, spacing_node_node)
  }

  new_kvector_xy(base_width, base_height)
  .scale(multiplier)
  .add(
    new_kvector_xy(
      -(padding_value.left + padding_value.right) - node_node_spacing,
      -(padding_value.top + padding_value.bottom) - node_node_spacing,
    ),
  )
}

///|
fn topdown_size_approximator_layout_next_level(
  original_graph : ElkNode,
) -> KVector {
  for child_node in node_children(original_graph) {
    if node_children(child_node).length() > 0 {
      let approximator_value = node_get_string_property(
        child_node, topdown_size_approximator,
      )
      if topdown_size_approximator_from_string(approximator_value)
        is Some(approximator) {
        let size = approximator.get_size(child_node)
        let padding_value = topdown_size_approximator_parse_padding(
          node_get_string_property(child_node, padding),
        )
        node_set_dimensions(
          child_node,
          if node_width(child_node) >
            size.x + padding_value.left + padding_value.right {
            node_width(child_node)
          } else {
            size.x + padding_value.left + padding_value.right
          },
          if node_height(child_node) >
            size.y + padding_value.top + padding_value.bottom {
            node_height(child_node)
          } else {
            size.y + padding_value.top + padding_value.bottom
          },
        )
      } else {
        let padding_value = topdown_size_approximator_parse_padding(
          node_get_string_property(child_node, padding),
        )
        let size = new_kvector_xy(
          node_get_double_property(child_node, topdown_hierarchical_node_width),
          node_get_double_property(child_node, topdown_hierarchical_node_width) /
          node_get_double_property(
            child_node, topdown_hierarchical_node_aspect_ratio,
          ),
        )
        node_set_dimensions(
          child_node,
          if node_width(child_node) >
            size.x + padding_value.left + padding_value.right {
            node_width(child_node)
          } else {
            size.x + padding_value.left + padding_value.right
          },
          if node_height(child_node) >
            size.y + padding_value.top + padding_value.bottom {
            node_height(child_node)
          } else {
            size.y + padding_value.top + padding_value.bottom
          },
        )
      }
    }
  }

  topdown_size_approximator_layout_graph(original_graph)

  node_set_string_property(original_graph, algorithm, "org.eclipse.elk.fixed")
  apply_visitors(original_graph, [new_layout_algorithm_resolver().to_visitor()])

  compute_child_area_dimensions(original_graph)
  new_kvector_xy(
    node_get_double_property(original_graph, child_area_width),
    node_get_double_property(original_graph, child_area_height),
  )
}

///|
pub fn TopdownSizeApproximator::get_size(
  self : TopdownSizeApproximator,
  original_graph : ElkNode,
) -> KVector {
  match self {
    CountChildren => topdown_size_approximator_count_children(original_graph)
    LookaheadLayout =>
      topdown_size_approximator_lookahead_layout(original_graph)
    FixedIntegerRatioBoxes =>
      topdown_size_approximator_fixed_integer_ratio_boxes(original_graph)
    LayoutNextLevel =>
      topdown_size_approximator_layout_next_level(original_graph)
  }
}
