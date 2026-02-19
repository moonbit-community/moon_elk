///|
pub type RecursiveGraphLayoutHandler = (@graph.ElkNode, IElkProgressMonitor) -> Unit

///|
let recursive_graph_layout_engine_handlers : Ref[
  Map[String, RecursiveGraphLayoutHandler],
] = Ref::new({})

///|
let recursive_graph_layout_engine_hierarchy_handling_property : @graph.IProperty[
  String,
] = @graph.new_property("org.eclipse.elk.hierarchyHandling", "INHERIT")

///|
let recursive_graph_layout_engine_inside_self_loops_yo_option_id = "org.eclipse.elk.insideSelfLoops.yo"

///|
pub fn recursive_graph_layout_engine_register_handler(
  algorithm_id : String,
  handler : RecursiveGraphLayoutHandler,
) -> Unit {
  recursive_graph_layout_engine_handlers.val[algorithm_id] = handler
}

///|
pub fn recursive_graph_layout_engine_clear_handlers_for_test() -> Unit {
  recursive_graph_layout_engine_handlers.val.clear()
}

///|
fn recursive_graph_layout_engine_get_handler(
  algorithm_id : String,
) -> RecursiveGraphLayoutHandler? {
  recursive_graph_layout_engine_handlers.val.get(algorithm_id)
}

///|
pub(all) struct RecursiveGraphLayoutEngine {
  marker : Int
}

///|
pub fn new_recursive_graph_layout_engine() -> RecursiveGraphLayoutEngine {
  { marker: 0 }
}

///|
fn recursive_graph_layout_engine_parse_bool(value : String) -> Bool {
  let normalized = value.trim().to_string().to_lower()
  normalized == "true" || normalized == "1"
}

///|
fn recursive_graph_layout_engine_has_explicit_algorithm(node : @graph.ElkNode) -> Bool {
  @graph.node_has_string_property(node, algorithm) ||
  @graph.node_layout_option_string_value(node, algorithm.get_id()) is Some(_)
}

///|
fn recursive_graph_layout_engine_resolved_algorithm_id(node : @graph.ElkNode) -> String {
  @graph.node_get_string_property(node, resolved_algorithm)
}

///|
fn recursive_graph_layout_engine_hierarchy_handling(
  node : @graph.ElkNode,
) -> String {
  match
    @graph.node_layout_option_string_value(
      node,
      recursive_graph_layout_engine_hierarchy_handling_property.get_id(),
    ) {
    Some(value) => value
    None =>
      if @graph.node_has_string_property(
          node, recursive_graph_layout_engine_hierarchy_handling_property,
        ) {
        @graph.node_get_string_property(
          node, recursive_graph_layout_engine_hierarchy_handling_property,
        )
      } else {
        recursive_graph_layout_engine_hierarchy_handling_property.get_default()
      }
  }
}

///|
fn recursive_graph_layout_engine_set_hierarchy_handling(
  node : @graph.ElkNode,
  value : String,
) -> Unit {
  @graph.node_set_string_property(
    node,
    recursive_graph_layout_engine_hierarchy_handling_property,
    value,
  )
  @graph.node_set_layout_option_string_by_id(
    node,
    recursive_graph_layout_engine_hierarchy_handling_property.get_id(),
    value,
  )
}

///|
fn recursive_graph_layout_engine_evaluate_hierarchy_handling_inheritance(
  layout_node : @graph.ElkNode,
) -> Unit {
  if recursive_graph_layout_engine_hierarchy_handling(layout_node) != "INHERIT" {
    return
  }
  if @graph.node_parent(layout_node) is None {
    recursive_graph_layout_engine_set_hierarchy_handling(
      layout_node, "SEPARATE_CHILDREN",
    )
  } else if @graph.node_parent(layout_node) is Some(parent_node) {
    recursive_graph_layout_engine_set_hierarchy_handling(
      layout_node,
      recursive_graph_layout_engine_hierarchy_handling(parent_node),
    )
  }
}

///|
fn recursive_graph_layout_engine_count_nodes_recursively(
  layout_node : @graph.ElkNode,
  count_ancestors : Bool,
) -> Int {
  let mut count = @graph.node_children(layout_node).length()
  for child_node in @graph.node_children(layout_node) {
    if !@graph.node_children(child_node).is_empty() {
      count = count + recursive_graph_layout_engine_count_nodes_recursively(
        child_node,
        false,
      )
    }
  }
  if count_ancestors {
    let mut parent = @graph.node_parent(layout_node)
    while parent is Some(parent_node) {
      count = count + @graph.node_children(parent_node).length()
      parent = @graph.node_parent(parent_node)
    }
  }
  count
}

///|
fn recursive_graph_layout_engine_count_nodes_with_hierarchy(
  parent_node : @graph.ElkNode,
) -> Int {
  let mut count = @graph.node_children(parent_node).length()
  let parent_resolved = recursive_graph_layout_engine_resolved_algorithm_id(
    parent_node,
  )
  for child_node in @graph.node_children(parent_node) {
    recursive_graph_layout_engine_evaluate_hierarchy_handling_inheritance(
      child_node,
    )
    if recursive_graph_layout_engine_hierarchy_handling(child_node) ==
      "SEPARATE_CHILDREN" {
      continue
    }
    let child_resolved = recursive_graph_layout_engine_resolved_algorithm_id(
      child_node,
    )
    if parent_resolved == child_resolved && !@graph.node_children(child_node).is_empty() {
      count = count + recursive_graph_layout_engine_count_nodes_with_hierarchy(
        child_node,
      )
    }
  }
  count
}

///|
fn recursive_graph_layout_engine_sub_monitor(
  progress_monitor : IElkProgressMonitor,
  work : Double,
) -> IElkProgressMonitor {
  match progress_monitor.sub_task(work) {
    Some(monitor) => monitor
    None => new_null_elk_progress_monitor()
  }
}

///|
fn recursive_graph_layout_engine_edge_is_self_loop(edge : @graph.ElkEdge) -> Bool {
  let sources = @graph.edge_sources(edge)
  let targets = @graph.edge_targets(edge)
  if sources.length() != 1 || targets.length() != 1 {
    return false
  }
  let source_node = @graph.connectable_shape_to_node(Some(sources[0]))
  let target_node = @graph.connectable_shape_to_node(Some(targets[0]))
  source_node == target_node
}

///|
fn recursive_graph_layout_engine_edge_inside_self_loops_yo(
  edge : @graph.ElkEdge,
) -> Bool {
  match @graph.edge_layout_option_string_value(
    edge,
    recursive_graph_layout_engine_inside_self_loops_yo_option_id,
  ) {
    Some(value) => recursive_graph_layout_engine_parse_bool(value)
    None => false
  }
}

///|
fn recursive_graph_layout_engine_gather_inside_self_loops(
  node : @graph.ElkNode,
) -> Array[@graph.ElkEdge] {
  if !@graph.node_get_bool_property(node, inside_self_loops_activate) {
    return []
  }
  let loops = []
  for edge in @graph.all_outgoing_edges(node) {
    if recursive_graph_layout_engine_edge_is_self_loop(edge) &&
      recursive_graph_layout_engine_edge_inside_self_loops_yo(edge) {
      loops.push(edge)
    }
  }
  loops
}

///|
fn recursive_graph_layout_engine_post_process_inside_self_loops(
  inside_self_loops : Array[@graph.ElkEdge],
) -> Unit {
  for self_loop in inside_self_loops {
    let sources = @graph.edge_sources(self_loop)
    if sources.is_empty() {
      continue
    }
    let node = @graph.connectable_shape_to_node(Some(sources[0]))
    let x_offset = @graph.node_x(node)
    let y_offset = @graph.node_y(node)
    if @graph.edge_sections(self_loop).is_empty() {
      continue
    }
    let section = @graph.edge_sections(self_loop)[0]
    @graph.edge_section_set_start(
      section,
      @graph.edge_section_start_x(section) + x_offset,
      @graph.edge_section_start_y(section) + y_offset,
    )
    @graph.edge_section_set_end(
      section,
      @graph.edge_section_end_x(section) + x_offset,
      @graph.edge_section_end_y(section) + y_offset,
    )
  }
}

///|
fn recursive_graph_layout_engine_work_from_node_count(node_count : Int) -> Double {
  if node_count > 0 {
    node_count.to_double()
  } else {
    1.0
  }
}

///|
fn recursive_graph_layout_engine_execute_algorithm(
  layout_node : @graph.ElkNode,
  resolved_algorithm_id : String,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  if resolved_algorithm_id == "org.eclipse.elk.box" {
    new_box_layout_provider().layout(layout_node, progress_monitor)
    return
  }
  if resolved_algorithm_id == "org.eclipse.elk.fixed" {
    new_fixed_layout_provider().layout(layout_node, progress_monitor)
    return
  }
  if resolved_algorithm_id == "org.eclipse.elk.random" {
    new_random_layout_provider().layout(layout_node, progress_monitor)
    return
  }

  match recursive_graph_layout_engine_get_handler(resolved_algorithm_id) {
    Some(handler) => handler(layout_node, progress_monitor)
    None =>
      abort(
        "No recursive layout handler registered for " + resolved_algorithm_id,
      )
  }
}

///|
fn recursive_graph_layout_engine_supports_hierarchy(
  algorithm_data : LayoutAlgorithmData,
) -> Bool {
  algorithm_data.supports_feature(@graph.GraphFeature::Compound) ||
  algorithm_data.supports_feature(@graph.GraphFeature::Clusters)
}

///|
fn recursive_graph_layout_engine_layout_recursively(
  layout_node : @graph.ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Array[@graph.ElkEdge] {
  if progress_monitor.is_canceled() {
    return []
  }
  if @graph.node_get_bool_property(layout_node, no_layout) {
    return []
  }

  let has_children = !@graph.node_children(layout_node).is_empty()
  let inside_self_loops = recursive_graph_layout_engine_gather_inside_self_loops(
    layout_node,
  )
  let has_inside_self_loops = !inside_self_loops.is_empty()

  if !has_children && !has_inside_self_loops {
    return []
  }

  let resolved_algorithm_id = recursive_graph_layout_engine_resolved_algorithm_id(
    layout_node,
  )
  if resolved_algorithm_id.is_empty() {
    abort(
      "Resolved algorithm is not set; apply a LayoutAlgorithmResolver before computing layout.",
    )
  }
  let algorithm_data = match layout_meta_data_service_get_algorithm_data_by_suffix(
    resolved_algorithm_id,
  ) {
    Some(data) => data
    None => abort("Resolved algorithm is unknown.")
  }
  let supports_inside_self_loops = algorithm_data.supports_feature(
    @graph.GraphFeature::InsideSelfLoops,
  )

  recursive_graph_layout_engine_evaluate_hierarchy_handling_inheritance(layout_node)

  if !has_children && has_inside_self_loops && !supports_inside_self_loops {
    return []
  }

  let children_inside_self_loops : Array[@graph.ElkEdge] = []
  let mut node_count = @graph.node_children(layout_node).length()

  if recursive_graph_layout_engine_hierarchy_handling(layout_node) ==
    "INCLUDE_CHILDREN" &&
    recursive_graph_layout_engine_supports_hierarchy(algorithm_data) {
    node_count = recursive_graph_layout_engine_count_nodes_with_hierarchy(
      layout_node,
    )
    let node_queue = @graph.node_children(layout_node)
    let mut queue_index = 0
    while queue_index < node_queue.length() {
      let node = node_queue[queue_index]
      queue_index = queue_index + 1

      recursive_graph_layout_engine_evaluate_hierarchy_handling_inheritance(node)
      let stop_hierarchy = recursive_graph_layout_engine_hierarchy_handling(node) ==
        "SEPARATE_CHILDREN"
      let switch_algorithm = if
        recursive_graph_layout_engine_has_explicit_algorithm(node) {
        recursive_graph_layout_engine_resolved_algorithm_id(node) !=
        resolved_algorithm_id
      } else {
        false
      }

      if stop_hierarchy || switch_algorithm {
        let child_layout_self_loops = recursive_graph_layout_engine_layout_recursively(
          node,
          progress_monitor,
        )
        for child_self_loop in child_layout_self_loops {
          children_inside_self_loops.push(child_self_loop)
        }
        recursive_graph_layout_engine_set_hierarchy_handling(
          node, "SEPARATE_CHILDREN",
        )
      } else {
        for child in @graph.node_children(node) {
          node_queue.push(child)
        }
      }
    }
  } else {
    for child in @graph.node_children(layout_node) {
      let child_layout_self_loops = recursive_graph_layout_engine_layout_recursively(
        child,
        progress_monitor,
      )
      for child_self_loop in child_layout_self_loops {
        children_inside_self_loops.push(child_self_loop)
      }
    }
  }

  if progress_monitor.is_canceled() {
    return []
  }

  for self_loop in children_inside_self_loops {
    @graph.edge_set_layout_option_string_by_id(
      self_loop,
      no_layout.get_id(),
      "true",
    )
  }

  recursive_graph_layout_engine_execute_algorithm(
    layout_node,
    resolved_algorithm_id,
    recursive_graph_layout_engine_sub_monitor(
      progress_monitor,
      recursive_graph_layout_engine_work_from_node_count(node_count),
    ),
  )

  recursive_graph_layout_engine_post_process_inside_self_loops(
    children_inside_self_loops,
  )

  if has_inside_self_loops && supports_inside_self_loops {
    inside_self_loops
  } else {
    []
  }
}

///|
pub fn RecursiveGraphLayoutEngine::layout(
  self : RecursiveGraphLayoutEngine,
  layout_graph : @graph.ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  ignore(self)

  let node_count = recursive_graph_layout_engine_count_nodes_recursively(
    layout_graph,
    true,
  )
  ignore(
    progress_monitor.begin(
      "Recursive Graph Layout",
      recursive_graph_layout_engine_work_from_node_count(node_count),
    ),
  )

  let replacer = new_deprecated_layout_option_replacer()
  apply_visitors(layout_graph, [
    new_graph_element_visitor(node => replacer.visit(node)),
  ])

  if recursive_graph_layout_engine_resolved_algorithm_id(layout_graph).is_empty() {
    let resolver = new_layout_algorithm_resolver()
    apply_visitors(layout_graph, [resolver.to_visitor()])
  }

  ignore(
    recursive_graph_layout_engine_layout_recursively(
      layout_graph,
      progress_monitor,
    ),
  )
  progress_monitor.done()
}
