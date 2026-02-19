///|
pub(all) enum TopdownSizeApproximator {
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
  shape : @graph.ElkConnectableShape,
) -> @graph.ElkNode {
  match shape {
    NodeShape(node) => node
    PortShape(_) => abort("Expected node endpoint in topdown size approximator")
  }
}

///|
fn topdown_size_approximator_first_target_node(
  edge : @graph.ElkEdge,
) -> @graph.ElkNode {
  let targets = @graph.edge_targets(edge)
  if targets.is_empty() {
    abort("Edge without target in topdown size approximator")
  }
  topdown_size_approximator_connectable_shape_to_node(targets[0])
}

///|
fn topdown_size_approximator_layout_graph(
  layout_graph : @graph.ElkNode,
) -> Unit {
  let progress_monitor = new_null_elk_progress_monitor()
  new_recursive_graph_layout_engine().layout(layout_graph, progress_monitor)
}

///|
fn topdown_size_approximator_count_children(node : @graph.ElkNode) -> KVector {
  let size = @graph.node_get_double_property(
      node, topdown_hierarchical_node_width,
    ) *
    @graph.node_children(node).length().to_double().sqrt()
  new_kvector_xy(
    size,
    size /
    @graph.node_get_double_property(
      node, topdown_hierarchical_node_aspect_ratio,
    ),
  )
}

///|
fn topdown_size_approximator_lookahead_layout(
  original_graph : @graph.ElkNode,
) -> KVector {
  let cloned_node = @graph.create_node(None)
  @graph.node_copy_properties(cloned_node, original_graph)

  let old_to_new_node_map : Map[@graph.ElkNode, @graph.ElkNode] = {}

  for child in @graph.node_children(original_graph) {
    let new_child = @graph.create_node(Some(cloned_node))
    @graph.node_copy_properties(new_child, child)
    let size = topdown_size_approximator_count_children(child)
    @graph.node_set_dimensions(
      new_child,
      if @graph.node_width(child) > size.x {
        @graph.node_width(child)
      } else {
        size.x
      },
      if @graph.node_height(child) > size.y {
        @graph.node_height(child)
      } else {
        size.y
      },
    )
    old_to_new_node_map[child] = new_child
  }

  for child in @graph.node_children(original_graph) {
    for edge in @graph.node_outgoing_edges(child) {
      let new_src = match old_to_new_node_map.get(child) {
        Some(value) => value
        None => abort("Missing source node clone in topdown size approximator")
      }
      let target = topdown_size_approximator_first_target_node(edge)
      let new_tar = match old_to_new_node_map.get(target) {
        Some(value) => value
        None => abort("Missing target node clone in topdown size approximator")
      }
      let new_edge = @graph.create_edge(Some(cloned_node))
      @graph.edge_add_source(new_edge, @graph.make_node_shape(new_src))
      @graph.edge_add_target(new_edge, @graph.make_node_shape(new_tar))
      @graph.edge_copy_properties(new_edge, edge)
    }
  }

  topdown_size_approximator_layout_graph(cloned_node)

  if !(@graph.node_has_double_property(cloned_node, child_area_width) ||
    @graph.node_has_double_property(cloned_node, child_area_height)) {
    compute_child_area_dimensions(cloned_node)
  }

  let child_area_desired_width = @graph.node_get_double_property(
    cloned_node, child_area_width,
  )
  let child_area_desired_height = @graph.node_get_double_property(
    cloned_node, child_area_height,
  )
  let child_area_desired_aspect_ratio = child_area_desired_width /
    child_area_desired_height

  let base_size = @graph.node_get_double_property(
      cloned_node, topdown_hierarchical_node_width,
    ) *
    @graph.node_children(cloned_node).length().to_double().sqrt()

  let padding_value = topdown_size_approximator_parse_padding(
    @graph.node_get_string_property(cloned_node, padding),
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
  original_graph : @graph.ElkNode,
) -> KVector {
  let base_width = @graph.node_get_double_property(
    original_graph, topdown_hierarchical_node_width,
  )
  let base_height = base_width /
    @graph.node_get_double_property(
      original_graph, topdown_hierarchical_node_aspect_ratio,
    )

  let multiplier = topdown_size_approximator_util_get_size_category_multiplier(
    original_graph,
  )

  let padding_value = topdown_size_approximator_parse_padding(
    @graph.node_get_string_property(original_graph, padding),
  )

  let mut node_node_spacing = spacing_node_node.get_default()
  if @graph.node_parent(original_graph) is Some(parent) {
    node_node_spacing = @graph.node_get_double_property(
      parent, spacing_node_node,
    )
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
  original_graph : @graph.ElkNode,
) -> KVector {
  for child_node in @graph.node_children(original_graph) {
    if @graph.node_children(child_node).length() > 0 {
      let approximator_value = @graph.node_get_string_property(
        child_node, topdown_size_approximator,
      )
      if topdown_size_approximator_from_string(approximator_value)
        is Some(approximator) {
        let size = approximator.get_size(child_node)
        let padding_value = topdown_size_approximator_parse_padding(
          @graph.node_get_string_property(child_node, padding),
        )
        @graph.node_set_dimensions(
          child_node,
          if @graph.node_width(child_node) >
            size.x + padding_value.left + padding_value.right {
            @graph.node_width(child_node)
          } else {
            size.x + padding_value.left + padding_value.right
          },
          if @graph.node_height(child_node) >
            size.y + padding_value.top + padding_value.bottom {
            @graph.node_height(child_node)
          } else {
            size.y + padding_value.top + padding_value.bottom
          },
        )
      } else {
        let padding_value = topdown_size_approximator_parse_padding(
          @graph.node_get_string_property(child_node, padding),
        )
        let size = new_kvector_xy(
          @graph.node_get_double_property(
            child_node, topdown_hierarchical_node_width,
          ),
          @graph.node_get_double_property(
            child_node, topdown_hierarchical_node_width,
          ) /
          @graph.node_get_double_property(
            child_node, topdown_hierarchical_node_aspect_ratio,
          ),
        )
        @graph.node_set_dimensions(
          child_node,
          if @graph.node_width(child_node) >
            size.x + padding_value.left + padding_value.right {
            @graph.node_width(child_node)
          } else {
            size.x + padding_value.left + padding_value.right
          },
          if @graph.node_height(child_node) >
            size.y + padding_value.top + padding_value.bottom {
            @graph.node_height(child_node)
          } else {
            size.y + padding_value.top + padding_value.bottom
          },
        )
      }
    }
  }

  topdown_size_approximator_layout_graph(original_graph)

  @graph.node_set_string_property(
    original_graph, algorithm, "org.eclipse.elk.fixed",
  )
  apply_visitors(original_graph, [new_layout_algorithm_resolver().to_visitor()])

  compute_child_area_dimensions(original_graph)
  new_kvector_xy(
    @graph.node_get_double_property(original_graph, child_area_width),
    @graph.node_get_double_property(original_graph, child_area_height),
  )
}

///|
pub fn TopdownSizeApproximator::get_size(
  self : TopdownSizeApproximator,
  original_graph : @graph.ElkNode,
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
