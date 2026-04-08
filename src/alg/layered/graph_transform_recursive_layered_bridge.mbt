///|
fn parse_node_padding(node : @graph.ElkNode) -> @core.ElkPadding {
  let parsed = @core.new_elk_padding()
  parsed.parse(@graph.node_get_string_property(node, @core.padding))
  parsed
}

///|
fn _parse_node_minimum_size(node : @graph.ElkNode) -> @core.KVector {
  let parsed = @core.new_kvector()
  parsed.parse(@graph.node_get_string_property(node, @core.node_size_minimum))
  parsed
}

///|
fn _has_minimum_size_constraint(node : @graph.ElkNode) -> Bool {
  for
    value in @graph.node_get_string_set_property(
      node, @core.node_size_constraints,
    ) {
    if value == "MINIMUM_SIZE" || value == "MINIMUM_SIZE_WITH_PORTS" {
      return true
    }
  }
  false
}

///|
fn recursive_layered_should_calculate_minimum_graph_size(
  node : @graph.ElkNode,
) -> Bool {
  !@graph.node_get_string_set_property(node, @core.node_size_constraints).is_empty()
}

///|
fn recursive_layered_calculate_minimum_graph_size(
  node : @graph.ElkNode,
  layered_graph : LGraph,
) -> Unit {
  let parent = match @graph.node_parent(node) {
    Some(value) => value
    None => return
  }

  let size_constraints = layered_graph.get_property_string_array(
    @core.node_size_constraints,
  )
  if size_constraints.is_empty() {
    return
  }

  if @graph.node_get_string_property(node, @core.port_constraints) ==
    "UNDEFINED" {
    @graph.node_set_string_property(node, @core.port_constraints, "FREE")
  }

  let min_size = @common.node_label_and_size_calculator_process_single_node(
    parent, node, false, true,
  )

  if !size_constraints.contains("MINIMUM_SIZE") {
    size_constraints.push("MINIMUM_SIZE")
    layered_graph.set_property_string_array(
      @core.node_size_constraints, size_constraints,
    )
  }

  let configured_min_size = @core.new_kvector()
  configured_min_size.parse(
    layered_graph.get_property_string(@core.node_size_minimum),
  )
  configured_min_size.x = @cmp.maximum(min_size.x, configured_min_size.x)
  configured_min_size.y = @cmp.maximum(min_size.y, configured_min_size.y)
  layered_graph.set_property_string(
    @core.node_size_minimum,
    configured_min_size.to_string(),
  )
}

///|
fn node_layout_option_value_by_candidates(
  node : @graph.ElkNode,
  candidates : Array[String],
) -> String? {
  for candidate in candidates {
    match @graph.node_layout_option_string_value(node, candidate) {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn node_individual_spacing_value_by_candidates(
  node : @graph.ElkNode,
  candidates : Array[String],
) -> String? {
  for candidate in candidates {
    match @graph.node_individual_spacing_option_string_value(node, candidate) {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn node_string_property_value_by_candidates(
  node : @graph.ElkNode,
  candidates : Array[String],
) -> String? {
  for candidate in candidates {
    let property : @graph.IProperty[String] = @graph.new_property(candidate, "")
    if @graph.node_has_string_property(node, property) {
      return Some(@graph.node_get_string_property(node, property))
    }
  }
  None
}

///|
fn node_layout_option_value_by_candidates_with_ancestors(
  node : @graph.ElkNode,
  candidates : Array[String],
) -> String? {
  match node_layout_option_value_by_candidates(node, candidates) {
    Some(option) => Some(option)
    None =>
      match @graph.node_parent(node) {
        Some(parent) =>
          node_layout_option_value_by_candidates_with_ancestors(
            parent, candidates,
          )
        None => None
      }
  }
}

///|
fn node_string_property_value_by_candidates_with_ancestors(
  node : @graph.ElkNode,
  candidates : Array[String],
) -> String? {
  match node_string_property_value_by_candidates(node, candidates) {
    Some(value) => Some(value)
    None =>
      match @graph.node_parent(node) {
        Some(parent) =>
          node_string_property_value_by_candidates_with_ancestors(
            parent, candidates,
          )
        None => None
      }
  }
}

///|
fn placement_tokens(value : String) -> Array[String] {
  let normalized = value
    .replace_all(old="[", new="")
    .replace_all(old="]", new="")
  let tokens = []
  for token_view in normalized.split(",") {
    let token = token_view.trim().to_string()
    if !token.is_empty() {
      tokens.push(token)
    }
  }
  tokens
}

///|
fn option_value_tokens(value : String) -> Array[String] {
  let normalized = value
    .replace_all(old="[", new=" ")
    .replace_all(old="]", new=" ")
    .replace_all(old=",", new=" ")
  let tokens = []
  for token_view in normalized.split(" ") {
    let token = token_view.trim().to_string()
    if !token.is_empty() && !tokens.contains(token) {
      tokens.push(token)
    }
  }
  tokens
}

///|
let recursive_layered_node_labels_padding_property : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.nodeLabels.padding", "[top=5,left=5,bottom=5,right=5]",
)

///|
fn recursive_layered_individual_spacing_options() -> Array[
  @graph.IProperty[Double],
] {
  [
    @core.spacing_node_node, @core.spacing_component_component, @core.spacing_edge_edge,
    @core.spacing_edge_label, @core.spacing_edge_node, @core.spacing_label_label,
    @core.spacing_label_node, @core.spacing_label_port_horizontal, @core.spacing_label_port_vertical,
    @core.spacing_node_self_loop, @core.spacing_port_port, layered_options_spacing_edge_edge_between_layers,
    layered_options_spacing_edge_node_between_layers, layered_options_spacing_node_node_between_layers,
  ]
}

///|
fn recursive_layered_copy_individual_spacing_options(
  source_node : @graph.ElkNode,
  target_node : LNode,
) -> Unit {
  for property in recursive_layered_individual_spacing_options() {
    match
      @graph.node_individual_spacing_option_string_value(
        source_node,
        property.get_id(),
      ) {
      Some(raw_value) => {
        let parsed : Result[Double, Error] = try? @string.parse_double(
          raw_value.trim().to_string(),
        )
        match parsed {
          Ok(value) => target_node.set_property_double(property, value)
          Err(_) => ()
        }
      }
      None => ()
    }
  }
}

///|
fn recursive_layered_copy_nodespacing_options(
  graph_node : @graph.ElkNode,
  source_node : @graph.ElkNode,
  target_node : LNode,
) -> Unit {
  recursive_layered_copy_individual_spacing_options(source_node, target_node)

  if @graph.node_has_string_set_property(
      source_node, @core.node_size_constraints,
    ) {
    target_node.set_property_string_array(
      @core.node_size_constraints,
      @graph.node_get_string_set_property(
        source_node, @core.node_size_constraints,
      ),
    )
  }
  if @graph.node_has_string_set_property(source_node, @core.node_size_options) {
    target_node.set_property_string_array(
      @core.node_size_options,
      @graph.node_get_string_set_property(source_node, @core.node_size_options),
    )
  }
  if @graph.node_has_string_set_property(
      source_node, @core.node_labels_placement,
    ) {
    target_node.set_property_string_array(
      @core.node_labels_placement,
      @graph.node_get_string_set_property(
        source_node, @core.node_labels_placement,
      ),
    )
  } else {
    let node_label_placement_keys = [
      "nodeLabels.placement", "elk.nodeLabels.placement", "org.eclipse.elk.nodeLabels.placement",
    ]
    match
      node_layout_option_value_by_candidates(
        source_node, node_label_placement_keys,
      ) {
      Some(value) =>
        target_node.set_property_string_array(
          @core.node_labels_placement,
          placement_tokens(value),
        )
      None => ()
    }
  }
  if @graph.node_has_string_set_property(
      source_node, @core.port_labels_placement,
    ) {
    target_node.set_property_string_array(
      @core.port_labels_placement,
      @graph.node_get_string_set_property(
        source_node, @core.port_labels_placement,
      ),
    )
  } else {
    let port_label_placement_keys = [
      "portLabels.placement", "elk.portLabels.placement", "org.eclipse.elk.portLabels.placement",
    ]
    match
      node_layout_option_value_by_candidates(
        source_node, port_label_placement_keys,
      ) {
      Some(value) =>
        target_node.set_property_string_array(
          @core.port_labels_placement,
          placement_tokens(value),
        )
      None => ()
    }
  }

  let keys = [
    "nodeLabels.padding", "elk.nodeLabels.padding", "org.eclipse.elk.nodeLabels.padding",
  ]
  let node_labels_padding_value = match
    node_individual_spacing_value_by_candidates(source_node, keys) {
    Some(value) => value
    None =>
      match node_layout_option_value_by_candidates(source_node, keys) {
        Some(value) => value
        None =>
          match node_individual_spacing_value_by_candidates(graph_node, keys) {
            Some(value) => value
            None =>
              match node_layout_option_value_by_candidates(graph_node, keys) {
                Some(value) => value
                None =>
                  recursive_layered_node_labels_padding_property.get_default()
              }
          }
      }
  }
  target_node.set_property_string(
    recursive_layered_node_labels_padding_property, node_labels_padding_value,
  )
}

///|
fn recursive_layered_copy_elk_node_properties(
  source_node : @graph.ElkNode,
  target_node : LNode,
) -> Unit {
  for entry in @graph.node_int_property_entries(source_node) {
    target_node.set_property_int(@graph.new_property(entry.0, 0), entry.1)
  }
  for entry in @graph.node_bool_property_entries(source_node) {
    target_node.set_property_bool(@graph.new_property(entry.0, false), entry.1)
  }
  for entry in @graph.node_double_property_entries(source_node) {
    target_node.set_property_double(@graph.new_property(entry.0, 0.0), entry.1)
  }
  for entry in @graph.node_string_property_entries(source_node) {
    target_node.set_property_string(@graph.new_property(entry.0, ""), entry.1)
  }
  for entry in @graph.node_string_set_property_entries(source_node) {
    target_node.set_property_string_array(
      @graph.new_property(entry.0, ([] : Array[String])),
      entry.1,
    )
  }
  for entry in @graph.node_kvector_property_entries(source_node) {
    let parsed = @core.new_kvector()
    parsed.parse(entry.1)
    target_node.set_property_kvector(
      @graph.new_property(entry.0, @core.new_kvector()),
      parsed,
    )
  }
  for entry in @graph.node_layout_option_string_entries(source_node) {
    for option_id in recursive_layered_option_key_aliases(entry.0) {
      target_node.set_property_string(
        @graph.new_property(option_id, ""),
        entry.1,
      )

      let parsed_bool = recursive_layered_parse_bool(entry.1)
      if parsed_bool is Some(value) {
        target_node.set_property_bool(
          @graph.new_property(option_id, false),
          value,
        )
      }

      let parsed_int : Result[Int, Error] = try? @string.parse_int(
        entry.1.trim().to_string(),
      )
      if parsed_int is Ok(value) {
        target_node.set_property_int(@graph.new_property(option_id, 0), value)
      }

      let parsed_double : Result[Double, Error] = try? @string.parse_double(
        entry.1.trim().to_string(),
      )
      if parsed_double is Ok(value) {
        target_node.set_property_double(
          @graph.new_property(option_id, 0.0),
          value,
        )
      }
    }
  }
  for entry in @graph.node_individual_spacing_option_string_entries(source_node) {
    for option_id in recursive_layered_option_key_aliases(entry.0) {
      target_node.set_property_string(
        @graph.new_property(option_id, ""),
        entry.1,
      )
      let parsed : Result[Double, Error] = try? @string.parse_double(
        entry.1.trim().to_string(),
      )
      if parsed is Ok(value) {
        target_node.set_property_double(
          @graph.new_property(option_id, 0.0),
          value,
        )
      }
    }
  }
}

///|
fn recursive_layered_copy_elk_port_layout_options(
  source_port : @graph.ElkPort,
  target_port : LPort,
) -> Unit {
  for entry in @graph.port_layout_option_string_entries(source_port) {
    for option_id in recursive_layered_option_key_aliases(entry.0) {
      let parsed_bool = recursive_layered_parse_bool(entry.1)
      if parsed_bool is Some(value) {
        target_port.set_property_bool(
          @graph.new_property(option_id, false),
          value,
        )
      }

      let parsed_int : Result[Int, Error] = try? @string.parse_int(
        entry.1.trim().to_string(),
      )
      if parsed_int is Ok(value) {
        target_port.set_property_int(@graph.new_property(option_id, 0), value)
      }

      let parsed_double : Result[Double, Error] = try? @string.parse_double(
        entry.1.trim().to_string(),
      )
      if parsed_double is Ok(value) {
        target_port.set_property_double(
          @graph.new_property(option_id, 0.0),
          value,
        )
      }
    }
  }
}

///|
fn recursive_layered_copy_elk_edge_layout_options(
  source_edge : @graph.ElkEdge,
  target_edge : LEdge,
) -> Unit {
  for entry in @graph.edge_layout_option_string_entries(source_edge) {
    for option_id in recursive_layered_option_key_aliases(entry.0) {
      let parsed_bool = recursive_layered_parse_bool(entry.1)
      if parsed_bool is Some(value) {
        target_edge.set_property_bool(
          @graph.new_property(option_id, false),
          value,
        )
      }

      let parsed_int : Result[Int, Error] = try? @string.parse_int(
        entry.1.trim().to_string(),
      )
      if parsed_int is Ok(value) {
        target_edge.set_property_int(@graph.new_property(option_id, 0), value)
      }

      let parsed_double : Result[Double, Error] = try? @string.parse_double(
        entry.1.trim().to_string(),
      )
      if parsed_double is Ok(value) {
        target_edge.set_property_double(
          @graph.new_property(option_id, 0.0),
          value,
        )
      }
    }
  }
}

///|
fn recursive_layered_copy_elk_label_layout_options(
  source_label : @graph.ElkLabel,
  target_label : LLabel,
) -> Unit {
  for entry in @graph.label_layout_option_string_entries(source_label) {
    for option_id in recursive_layered_option_key_aliases(entry.0) {
      target_label.set_property_string(
        @graph.new_property(option_id, ""),
        entry.1,
      )

      let parsed_bool = recursive_layered_parse_bool(entry.1)
      if parsed_bool is Some(value) {
        target_label.set_property_bool(
          @graph.new_property(option_id, false),
          value,
        )
      }
    }
  }
}

///|
fn recursive_layered_option_key_aliases(option_id : String) -> Array[String] {
  let aliases : Array[String] = [option_id]
  match option_id {
    "layerConstraint" => {
      aliases.push("layering.layerConstraint")
      aliases.push("elk.layered.layering.layerConstraint")
      aliases.push("org.eclipse.elk.layered.layering.layerConstraint")
    }
    _ => ()
  }
  match option_id.strip_prefix("elk.") {
    Some(without_elk_view) => {
      aliases.push("org.eclipse." + option_id)
      aliases.push(without_elk_view.to_string())
    }
    None =>
      match option_id.strip_prefix("org.eclipse.elk.") {
        Some(without_full_view) => {
          aliases.push("elk." + without_full_view.to_string())
          aliases.push(without_full_view.to_string())
        }
        None => ()
      }
  }
  let deduped : Array[String] = []
  for key in aliases {
    if !deduped.contains(key) {
      deduped.push(key)
    }
  }
  deduped
}

///|
fn ensure_edge_section_for_edge(edge : @graph.ElkEdge) -> Unit {
  if !@graph.edge_sections(edge).is_empty() {
    return
  }
  let sources = @graph.edge_sources(edge)
  let targets = @graph.edge_targets(edge)
  if sources.length() != 1 || targets.length() != 1 {
    return
  }
  let source_shape = sources[0]
  let target_shape = targets[0]
  let section = @graph.create_edge_section(edge)
  @graph.edge_section_set_incoming_shape(section, Some(source_shape))
  @graph.edge_section_set_outgoing_shape(section, Some(target_shape))
  match source_shape {
    NodeShape(source_node) =>
      match target_shape {
        NodeShape(target_node) => {
          let start_x = @graph.node_x(source_node) +
            @graph.node_width(source_node)
          let start_y = @graph.node_y(source_node) +
            @graph.node_height(source_node) / 2.0
          let end_x = @graph.node_x(target_node)
          let end_y = @graph.node_y(target_node) +
            @graph.node_height(target_node) / 2.0
          @graph.edge_section_set_start(section, start_x, start_y)
          @graph.edge_section_set_end(section, end_x, end_y)
        }
        _ => ()
      }
    _ => ()
  }
}

///|
priv struct RecursiveLayeredContext {
  layered_graph : LGraph
  elk_to_lnode : Map[@graph.ElkNode, LNode]
  elk_to_lport : Map[@graph.ElkPort, LPort]
  node_label_pairs : Map[@graph.ElkNode, Array[(LLabel, @graph.ElkLabel)]]
  lnode_to_elk : Map[Int, @graph.ElkNode]
}

///|
let recursive_layered_transform_context_next_id : Ref[Int] = Ref::new(1)

///|
let recursive_layered_model_order_node_assignments : Ref[
  Map[@graph.ElkNode, Int],
] = Ref::new({})

///|
let recursive_layered_model_order_edge_assignments : Ref[
  Map[@graph.ElkEdge, Int],
] = Ref::new({})

///|
let recursive_layered_model_order_max_nodes : Ref[Int] = Ref::new(0)

///|
let recursive_layered_model_order_cb_group_count : Ref[Int] = Ref::new(0)

///|
let recursive_layered_transform_context_store : Ref[
  Map[Int, (RecursiveLayeredContext, @graph.ElkNode)],
] = Ref::new({})

///|
let recursive_layered_global_elk_to_lnode : Ref[Map[@graph.ElkNode, LNode]] = Ref::new({},
)

///|
let recursive_layered_global_elk_to_lport : Ref[Map[@graph.ElkPort, LPort]] = Ref::new({},
)

///|
let recursive_layered_global_ledge_to_elk_edge : Ref[Map[Int, @graph.ElkEdge]] = Ref::new({},
)

///|
let recursive_layered_transform_context_property : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.layered.recursive.contextId", -1,
)

///|
let recursive_layered_origin_elk_edge_handle_property : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.layered.recursive.originElkEdgeHandle", -1,
)

///|
fn recursive_layered_node_consider_model_order_no_model_order(
  node : @graph.ElkNode,
) -> Bool {
  match
    recursive_layered_parse_bool(
      recursive_layered_primary_option(
        node, "org.eclipse.elk.layered.considerModelOrder.noModelOrder", "false",
      ),
    ) {
    Some(value) => value
    None => false
  }
}

///|
fn recursive_layered_node_cb_group_model_order_cycle_breaking_id(
  node : @graph.ElkNode,
) -> Int? {
  let keys = [
    layered_options_consider_model_order_group_model_order_cycle_breaking_id.get_id(),
    "elk.layered.considerModelOrder.groupModelOrder.cycleBreakingId",
    "layered.considerModelOrder.groupModelOrder.cycleBreakingId",
    "considerModelOrder.groupModelOrder.cycleBreakingId",
  ]
  match node_layout_option_value_by_candidates(node, keys) {
    Some(raw_value) =>
      match recursive_layered_parse_int(raw_value) {
        Some(value) => Some(value)
        None => None
      }
    None => None
  }
}

///|
fn recursive_layered_needs_model_order_based_on_parent_node(
  parent_node : @graph.ElkNode,
) -> Bool {
  let cycle_breaking_strategy = recursive_layered_primary_option(
    parent_node,
    layered_options_cycle_breaking_strategy.get_id(),
    @graph.node_get_string_property(
      parent_node, layered_options_cycle_breaking_strategy,
    ),
  )
  let layering_strategy = recursive_layered_primary_option(
    parent_node,
    layered_options_layering_strategy.get_id(),
    @graph.node_get_string_property(
      parent_node, layered_options_layering_strategy,
    ),
  )
  let node_promotion_strategy = recursive_layered_primary_option(
    parent_node,
    layered_options_layering_node_promotion_strategy.get_id(),
    @graph.node_get_string_property(
      parent_node, layered_options_layering_node_promotion_strategy,
    ),
  )
  let consider_model_order_strategy = recursive_layered_primary_option(
    parent_node,
    layered_options_consider_model_order_strategy.get_id(),
    @graph.node_get_string_property(
      parent_node, layered_options_consider_model_order_strategy,
    ),
  )
  let force_node_model_order = match
    recursive_layered_parse_bool(
      recursive_layered_primary_option(
        parent_node,
        layered_options_crossing_minimization_force_node_model_order.get_id(),
        @graph.node_get_bool_property(
          parent_node, layered_options_crossing_minimization_force_node_model_order,
        ).to_string(),
      ),
    ) {
    Some(value) => value
    None =>
      layered_options_crossing_minimization_force_node_model_order.get_default()
  }
  let consider_model_order_components = recursive_layered_primary_option(
    parent_node,
    layered_options_consider_model_order_components.get_id(),
    "NONE",
  )
  let crossing_counter_node_influence = match
    recursive_layered_parse_double(
      recursive_layered_primary_option(
        parent_node,
        layered_options_consider_model_order_crossing_counter_node_influence.get_id(),
        @graph.node_get_double_property(
          parent_node, layered_options_consider_model_order_crossing_counter_node_influence,
        ).to_string(),
      ),
    ) {
    Some(value) => value
    None => 0.0
  }
  let crossing_counter_port_influence = match
    recursive_layered_parse_double(
      recursive_layered_primary_option(
        parent_node,
        layered_options_consider_model_order_crossing_counter_port_influence.get_id(),
        @graph.node_get_double_property(
          parent_node, layered_options_consider_model_order_crossing_counter_port_influence,
        ).to_string(),
      ),
    ) {
    Some(value) => value
    None => 0.0
  }

  let model_order_cycle_breaking = recursive_layered_model_order_cycle_breaking(
    cycle_breaking_strategy,
  )
  let model_order_layering = recursive_layered_model_order_layering(
    layering_strategy, node_promotion_strategy,
  )
  let model_order_crossing_minimization = consider_model_order_strategy !=
    "NONE" ||
    force_node_model_order ||
    consider_model_order_components != "NONE" ||
    crossing_counter_node_influence != 0.0 ||
    crossing_counter_port_influence != 0.0

  model_order_cycle_breaking ||
  model_order_layering ||
  model_order_crossing_minimization
}

///|
fn recursive_layered_prepare_model_order_assignments(
  root_node : @graph.ElkNode,
) -> Unit {
  let node_assignments : Map[@graph.ElkNode, Int] = {}
  let edge_assignments : Map[@graph.ElkEdge, Int] = {}
  let cb_group_model_orders : Array[Int] = []
  let node_order_enabled = recursive_layered_needs_model_order_based_on_parent_node(
    root_node,
  )

  let node_queue = @graph.node_children(root_node).copy()
  let mut node_queue_index = 0
  let mut node_index = 0
  while node_queue_index < node_queue.length() {
    let current = node_queue[node_queue_index]
    node_queue_index += 1

    if node_order_enabled &&
      !recursive_layered_node_consider_model_order_no_model_order(current) {
      node_assignments[current] = node_index
      node_index += 1
      match
        recursive_layered_node_cb_group_model_order_cycle_breaking_id(current) {
        Some(group_id) =>
          if !cb_group_model_orders.contains(group_id) {
            cb_group_model_orders.push(group_id)
          }
        None => ()
      }
    }

    let is_node_to_be_laid_out = !@graph.node_get_bool_property(
      current, @core.no_layout,
    )
    if !is_node_to_be_laid_out {
      continue
    }
    let has_children = !@graph.node_children(current).is_empty()
    let has_inside_self_loops = recursive_layered_has_inside_self_loops(current)
    let has_hierarchy_handling_enabled = recursive_layered_node_hierarchy_include_children(
      current,
    )
    let uses_layered = recursive_layered_node_uses_layered(current)
    if uses_layered &&
      has_hierarchy_handling_enabled &&
      (has_children || has_inside_self_loops) {
      for child in @graph.node_children(current) {
        node_queue.push(child)
      }
    }
  }

  let edge_order_enabled = recursive_layered_needs_model_order_based_on_parent_node(
    root_node,
  )
  let edge_queue : Array[@graph.ElkNode] = [root_node]
  let mut edge_queue_index = 0
  let mut edge_index = 0
  while edge_queue_index < edge_queue.length() {
    let current = edge_queue[edge_queue_index]
    edge_queue_index += 1

    for edge in @graph.node_contained_edges(current) {
      if edge_order_enabled {
        edge_assignments[edge] = edge_index
        edge_index += 1
      }
    }

    if recursive_layered_node_hierarchy_include_children(current) {
      for child in @graph.node_children(current) {
        let uses_layered = recursive_layered_node_uses_layered(child)
        let part_of_same_layout_run = recursive_layered_node_hierarchy_include_children(
          child,
        )
        if uses_layered && part_of_same_layout_run {
          edge_queue.push(child)
        }
      }
    }
  }

  recursive_layered_model_order_node_assignments.val = node_assignments
  recursive_layered_model_order_edge_assignments.val = edge_assignments
  recursive_layered_model_order_max_nodes.val = node_index
  recursive_layered_model_order_cb_group_count.val = cb_group_model_orders.length()
}

///|
fn recursive_layered_transform_register_context(
  context : RecursiveLayeredContext,
  parent_node : @graph.ElkNode,
) -> LGraph {
  let context_id = recursive_layered_transform_context_next_id.val
  recursive_layered_transform_context_next_id.val = context_id + 1
  context.layered_graph.set_id(context_id)
  context.layered_graph.set_property_int(
    recursive_layered_transform_context_property, context_id,
  )
  recursive_layered_transform_context_store.val[context_id] = (
    context, parent_node,
  )
  context.layered_graph
}

///|
pub fn recursive_layered_import_graph_for_transform(
  parent_node : @graph.ElkNode,
) -> LGraph? {
  recursive_layered_transform_context_store.val.clear()
  recursive_layered_transform_context_next_id.val = 1
  recursive_layered_global_elk_to_lnode.val.clear()
  recursive_layered_global_elk_to_lport.val.clear()
  recursive_layered_global_ledge_to_elk_edge.val.clear()
  recursive_layered_model_order_node_assignments.val.clear()
  recursive_layered_model_order_edge_assignments.val.clear()
  recursive_layered_model_order_max_nodes.val = 0
  recursive_layered_model_order_cb_group_count.val = 0
  recursive_layered_prepare_model_order_assignments(parent_node)
  match recursive_layered_create_context(parent_node, None, import_edges=true) {
    Some(context) => {
      context.layered_graph.set_property_int(
        internal_properties_max_model_order_nodes,
        recursive_layered_model_order_max_nodes.val,
      )
      context.layered_graph.set_property_int(
        internal_properties_cb_num_model_order_groups,
        recursive_layered_model_order_cb_group_count.val,
      )
      Some(recursive_layered_transform_register_context(context, parent_node))
    }
    None => None
  }
}

///|
pub fn recursive_layered_apply_transformed_graph(
  layered_graph : LGraph,
) -> Bool {
  let context_id = layered_graph.get_id()
  let fallback_context_id = layered_graph.get_property_int(
    recursive_layered_transform_context_property,
  )
  let use_fallback_context = recursive_layered_transform_context_store.val.contains(
    fallback_context_id,
  )
  let use_primary_context = recursive_layered_transform_context_store.val.contains(
    context_id,
  )
  let resolved_context_id = if use_fallback_context {
    fallback_context_id
  } else if use_primary_context {
    context_id
  } else {
    fallback_context_id
  }
  match recursive_layered_transform_context_store.val.get(resolved_context_id) {
    Some((context, parent_node)) => {
      ignore(
        recursive_layered_transform_context_store.val.remove(
          resolved_context_id,
        ),
      )
      recursive_layered_apply_layout(context, parent_node)
      true
    }
    None => false
  }
}

///|
fn recursive_layered_edge_endpoint_node(
  edge_shapes : Array[@graph.ElkConnectableShape],
) -> @graph.ElkNode? {
  if edge_shapes.is_empty() {
    return None
  }
  match edge_shapes[0] {
    NodeShape(node) => Some(node)
    PortShape(port) => @graph.port_parent(port)
  }
}

///|
fn recursive_layered_edge_endpoint_port(
  edge_shapes : Array[@graph.ElkConnectableShape],
  elk_to_lport : Map[@graph.ElkPort, LPort],
) -> LPort? {
  if edge_shapes.is_empty() {
    return None
  }
  match edge_shapes[0] {
    PortShape(port) =>
      match elk_to_lport.get(port) {
        Some(found) => Some(found)
        None => recursive_layered_global_elk_to_lport.val.get(port)
      }
    _ => None
  }
}

///|
fn recursive_layered_endpoint_lnode(
  root_node : @graph.ElkNode,
  endpoint_node : @graph.ElkNode,
  elk_to_lnode : Map[@graph.ElkNode, LNode],
) -> (LNode?, Bool) {
  ignore(root_node)
  match elk_to_lnode.get(endpoint_node) {
    Some(found) => (Some(found), false)
    None =>
      match recursive_layered_global_elk_to_lnode.val.get(endpoint_node) {
        Some(found) => (Some(found), false)
        None => (None, false)
      }
  }
}

///|
fn recursive_layered_convert_edge_section_point_to_parent_coordinates(
  edge : @graph.ElkEdge,
  parent_node : @graph.ElkNode,
  point_x : Double,
  point_y : Double,
) -> @core.KVector {
  let mut absolute_x = point_x
  let mut absolute_y = point_y
  match @graph.edge_containing_node(edge) {
    Some(containing_node) => {
      absolute_x = absolute_x +
        recursive_layered_absolute_node_x(containing_node)
      absolute_y = absolute_y +
        recursive_layered_absolute_node_y(containing_node)
    }
    None => ()
  }
  @core.new_kvector_xy(
    absolute_x - recursive_layered_absolute_node_x(parent_node),
    absolute_y - recursive_layered_absolute_node_y(parent_node),
  )
}

///|
fn recursive_layered_descendant_edges(
  root_node : @graph.ElkNode,
) -> Array[@graph.ElkEdge] {
  let edges : Array[@graph.ElkEdge] = []
  let queue : Array[@graph.ElkNode] = [root_node]
  let mut index = 0
  while index < queue.length() {
    let current = queue[index]
    index += 1
    for edge in @graph.node_contained_edges(current) {
      edges.push(edge)
    }
    for child in @graph.node_children(current) {
      queue.push(child)
    }
  }
  edges
}

///|
fn recursive_layered_layout_run_graph_nodes(
  root_node : @graph.ElkNode,
) -> Array[@graph.ElkNode] {
  let queue : Array[@graph.ElkNode] = [root_node]
  let mut index = 0
  while index < queue.length() {
    let current = queue[index]
    index += 1
    if recursive_layered_node_hierarchy_include_children(current) {
      for child in @graph.node_children(current) {
        let uses_layered = recursive_layered_node_uses_layered(child)
        let part_of_same_layout_run = recursive_layered_node_hierarchy_include_children(
          child,
        )
        if uses_layered && part_of_same_layout_run {
          queue.push(child)
        }
      }
    }
  }
  queue
}

///|
fn recursive_layered_layout_run_edges(
  root_node : @graph.ElkNode,
) -> Array[@graph.ElkEdge] {
  let edges : Array[@graph.ElkEdge] = []
  for graph_node in recursive_layered_layout_run_graph_nodes(root_node) {
    for edge in @graph.node_contained_edges(graph_node) {
      edges.push(edge)
    }
  }
  edges
}

///|
fn recursive_layered_port_anchor_in_edge_coordinates(
  edge : @graph.ElkEdge,
  port : @graph.ElkPort,
) -> @core.KVector {
  let absolute_anchor = recursive_layered_absolute_port_anchor(port)
  match @graph.edge_containing_node(edge) {
    Some(containing_node) =>
      @core.new_kvector_xy(
        absolute_anchor.x - recursive_layered_absolute_node_x(containing_node),
        absolute_anchor.y - recursive_layered_absolute_node_y(containing_node),
      )
    None => absolute_anchor
  }
}

///|
fn _recursive_layered_align_edge_sections_to_port_anchors(
  root_node : @graph.ElkNode,
) -> Unit {
  for edge in recursive_layered_descendant_edges(root_node) {
    let sections = @graph.edge_sections(edge)
    if sections.is_empty() {
      continue
    }
    let section = sections[0]
    let incoming_port = try
      @graph.connectable_shape_to_port(
        @graph.edge_section_incoming_shape(section),
      )
    catch {
      _ => None
    } noraise {
      value => value
    }
    match incoming_port {
      Some(incoming_port) => {
        let start_anchor = recursive_layered_port_anchor_in_edge_coordinates(
          edge, incoming_port,
        )
        @graph.edge_section_set_start(section, start_anchor.x, start_anchor.y)
      }
      None => ()
    }
    let outgoing_port = try
      @graph.connectable_shape_to_port(
        @graph.edge_section_outgoing_shape(section),
      )
    catch {
      _ => None
    } noraise {
      value => value
    }
    match outgoing_port {
      Some(outgoing_port) => {
        let end_anchor = recursive_layered_port_anchor_in_edge_coordinates(
          edge, outgoing_port,
        )
        @graph.edge_section_set_end(section, end_anchor.x, end_anchor.y)
      }
      None => ()
    }
  }
}

///|
fn recursive_layered_port_side_from_string(value : String) -> @core.PortSide {
  match value {
    "NORTH" => @core.PortSide::North
    "EAST" => @core.PortSide::East
    "SOUTH" => @core.PortSide::South
    "WEST" => @core.PortSide::West
    _ => @core.PortSide::SideUndefined
  }
}

///|
fn recursive_layered_port_side_option(port : @graph.ElkPort) -> String {
  let candidates = ["org.eclipse.elk.port.side", "elk.port.side", "port.side"]
  for candidate in candidates {
    match @graph.port_layout_option_string_value(port, candidate) {
      Some(value) => return value
      None => ()
    }
  }
  "UNDEFINED"
}

///|
fn recursive_layered_port_allow_non_flow_switch_sides(
  port : @graph.ElkPort,
) -> Bool {
  let candidates = [
    layered_options_allow_non_flow_ports_to_switch_sides.get_id(),
    "elk.layered.allowNonFlowPortsToSwitchSides",
    "layered.allowNonFlowPortsToSwitchSides",
  ]
  for candidate in candidates {
    match @graph.port_layout_option_string_value(port, candidate) {
      Some(raw_value) =>
        match recursive_layered_parse_bool(raw_value) {
          Some(value) => return value
          None => ()
        }
      None => ()
    }
  }
  layered_options_allow_non_flow_ports_to_switch_sides.get_default()
}

///|
let recursive_layered_ext_port_border_offset_property : @graph.IProperty[Double] = @graph.new_property(
  "recursive.layered.extPortBorderOffset", 0.0,
)

///|
fn recursive_layered_port_border_offset(port : @graph.ElkPort) -> Double {
  let candidates = [
    "org.eclipse.elk.port.borderOffset", "elk.port.borderOffset", "port.borderOffset",
  ]
  for candidate in candidates {
    match @graph.port_layout_option_string_value(port, candidate) {
      Some(raw_value) => {
        let parsed : Result[Double, Error] = try? @string.parse_double(
          raw_value,
        )
        match parsed {
          Ok(value) => return value
          Err(_) => ()
        }
      }
      None => ()
    }
  }
  0.0
}

///|
fn recursive_layered_port_constraints_side_fixed(value : String) -> Bool {
  value == "FIXED_SIDE" ||
  value == "FIXED_ORDER" ||
  value == "FIXED_RATIO" ||
  value == "FIXED_POS"
}

///|
fn recursive_layered_port_constraints_order_fixed(value : String) -> Bool {
  value == "FIXED_ORDER" || value == "FIXED_RATIO" || value == "FIXED_POS"
}

///|
fn recursive_layered_parse_port_constraints(
  value : String,
) -> @core.PortConstraints {
  for constraint in @core.port_constraints_values() {
    if @core.port_constraints_to_string(constraint) == value {
      return constraint
    }
  }
  @core.PortConstraints::Undefined
}

///|
fn recursive_layered_direction_to_port_side(
  direction_value : String,
) -> @core.PortSide {
  match direction_value {
    "LEFT" => @core.PortSide::West
    "DOWN" => @core.PortSide::South
    "UP" => @core.PortSide::North
    _ => @core.PortSide::East
  }
}

///|
fn recursive_layered_opposed_port_side(side : @core.PortSide) -> @core.PortSide {
  match side {
    @core.PortSide::North => @core.PortSide::South
    @core.PortSide::East => @core.PortSide::West
    @core.PortSide::South => @core.PortSide::North
    @core.PortSide::West => @core.PortSide::East
    _ => @core.PortSide::SideUndefined
  }
}

///|
fn recursive_layered_graph_property_equals(
  left : GraphProperties,
  right : GraphProperties,
) -> Bool {
  match (left, right) {
    (Comments, Comments) => true
    (ExternalPorts, ExternalPorts) => true
    (Hyperedges, Hyperedges) => true
    (Hypernodes, Hypernodes) => true
    (NonFreePorts, NonFreePorts) => true
    (NorthSouthPorts, NorthSouthPorts) => true
    (SelfLoops, SelfLoops) => true
    (CenterLabels, CenterLabels) => true
    (EndLabels, EndLabels) => true
    (Partitions, Partitions) => true
    _ => false
  }
}

///|
fn recursive_layered_add_graph_property(
  layered_graph : LGraph,
  property : GraphProperties,
) -> Unit {
  let properties = layered_graph.get_property_graph_properties_array(
    internal_properties_graph_properties,
  )
  for current in properties {
    if recursive_layered_graph_property_equals(current, property) {
      return
    }
  }
  properties.push(property)
  layered_graph.set_property_graph_properties_array(
    internal_properties_graph_properties, properties,
  )
}

///|
fn recursive_layered_has_graph_property(
  layered_graph : LGraph,
  expected : GraphProperties,
) -> Bool {
  for
    property in layered_graph.get_property_graph_properties_array(
      internal_properties_graph_properties,
    ) {
    if recursive_layered_graph_property_equals(property, expected) {
      return true
    }
  }
  false
}

///|
fn recursive_layered_is_north_south_side(side : @core.PortSide) -> Bool {
  match side {
    @core.PortSide::North => true
    @core.PortSide::South => true
    _ => false
  }
}

///|
fn recursive_layered_is_north_south_port_for_direction(
  side : @core.PortSide,
  direction_value : String,
) -> Bool {
  if direction_value == "UP" || direction_value == "DOWN" {
    match side {
      @core.PortSide::East => true
      @core.PortSide::West => true
      _ => false
    }
  } else {
    recursive_layered_is_north_south_side(side)
  }
}

///|
fn recursive_layered_ports_have_same_owner(left : LPort, right : LPort) -> Bool {
  match left.get_node() {
    Some(left_node) =>
      match right.get_node() {
        Some(right_node) => left_node.get_handle() == right_node.get_handle()
        None => false
      }
    None => false
  }
}

///|
fn recursive_layered_edge_label_placement(
  elk_label : @graph.ElkLabel,
) -> String {
  let candidates = [
    @core.edge_labels_placement.get_id(),
    "elk.edgeLabels.placement",
    "edgeLabels.placement",
  ]
  for candidate in candidates {
    match @graph.label_layout_option_string_value(elk_label, candidate) {
      Some(value) => return value
      None => ()
    }
  }
  @core.edge_labels_placement.get_default()
}

///|
fn recursive_layered_edge_label_inline(elk_label : @graph.ElkLabel) -> Bool? {
  let candidates = [
    @core.edge_labels_inline.get_id(),
    "elk.edgeLabels.inline",
    "edgeLabels.inline",
  ]
  for candidate in candidates {
    match @graph.label_layout_option_string_value(elk_label, candidate) {
      Some(raw) => return recursive_layered_parse_bool(raw)
      None => ()
    }
  }
  None
}

///|
fn recursive_layered_is_center_label_placement(value : String) -> Bool {
  value == "CENTER"
}

///|
fn recursive_layered_is_descendant(
  candidate : @graph.ElkNode,
  ancestor : @graph.ElkNode,
) -> Bool {
  let mut current = @graph.node_parent(candidate)
  while true {
    match current {
      Some(parent) =>
        if parent == ancestor {
          return true
        } else {
          current = @graph.node_parent(parent)
        }
      None => return false
    }
  }
  false
}

///|
fn recursive_layered_find_coordinate_system_origin(
  edge : @graph.ElkEdge,
  top_level_elk_graph : @graph.ElkNode,
  top_level_lgraph : LGraph,
  elk_to_lnode : Map[@graph.ElkNode, LNode],
) -> LGraph? {
  let sources = @graph.edge_sources(edge)
  let targets = @graph.edge_targets(edge)
  if sources.is_empty() || targets.is_empty() {
    return None
  }
  let source = try @graph.connectable_shape_to_node(Some(sources[0])) catch {
    _ => return None
  } noraise {
    value => value
  }
  let target = try @graph.connectable_shape_to_node(Some(targets[0])) catch {
    _ => return None
  } noraise {
    value => value
  }

  if @graph.node_parent(source) == @graph.node_parent(target) {
    return None
  }
  if recursive_layered_is_descendant(target, source) {
    return None
  }

  let origin = match @graph.edge_containing_node(edge) {
    Some(value) => value
    None => return None
  }
  if origin == top_level_elk_graph {
    return Some(top_level_lgraph)
  }

  match
    recursive_layered_endpoint_lnode(top_level_elk_graph, origin, elk_to_lnode) {
    (Some(origin_lnode), _) => origin_lnode.get_nested_graph()
    (None, _) => None
  }
}

///|
fn recursive_layered_port_has_inside_connections(
  owner_node : @graph.ElkNode,
  elk_port : @graph.ElkPort,
) -> Bool {
  for outgoing_edge in @graph.port_outgoing_edges(elk_port) {
    match
      recursive_layered_edge_endpoint_node(@graph.edge_targets(outgoing_edge)) {
      Some(target_node) =>
        if recursive_layered_is_descendant(target_node, owner_node) {
          return true
        }
      None => ()
    }
  }

  for incoming_edge in @graph.port_incoming_edges(elk_port) {
    match
      recursive_layered_edge_endpoint_node(@graph.edge_sources(incoming_edge)) {
      Some(source_node) =>
        if recursive_layered_is_descendant(source_node, owner_node) {
          return true
        }
      None => ()
    }
  }

  false
}

///|
fn recursive_layered_port_connected_to_external_nodes(
  owner_node : @graph.ElkNode,
  elk_port : @graph.ElkPort,
) -> Bool {
  for outgoing_edge in @graph.port_outgoing_edges(elk_port) {
    match
      recursive_layered_edge_endpoint_node(@graph.edge_targets(outgoing_edge)) {
      Some(target_node) =>
        if !recursive_layered_is_descendant(target_node, owner_node) {
          return true
        }
      None => ()
    }
  }

  for incoming_edge in @graph.port_incoming_edges(elk_port) {
    match
      recursive_layered_edge_endpoint_node(@graph.edge_sources(incoming_edge)) {
      Some(source_node) =>
        if !recursive_layered_is_descendant(source_node, owner_node) {
          return true
        }
      None => ()
    }
  }

  false
}

///|
fn recursive_layered_external_port_net_flow(
  parent_node : @graph.ElkNode,
  parent_port : @graph.ElkPort,
) -> Int {
  let mut output_vote = 0
  let mut input_vote = 0

  for outgoing_edge in @graph.port_outgoing_edges(parent_port) {
    let target_node = match
      recursive_layered_edge_endpoint_node(@graph.edge_targets(outgoing_edge)) {
      Some(value) => value
      None => continue
    }
    match @graph.node_parent(target_node) {
      Some(target_parent) =>
        if target_parent == parent_node || target_node == parent_node {
          input_vote += 1
        } else {
          output_vote += 1
        }
      None =>
        if target_node == parent_node {
          input_vote += 1
        } else {
          output_vote += 1
        }
    }
  }

  for incoming_edge in @graph.port_incoming_edges(parent_port) {
    let source_node = match
      recursive_layered_edge_endpoint_node(@graph.edge_sources(incoming_edge)) {
      Some(value) => value
      None => continue
    }
    match @graph.node_parent(source_node) {
      Some(source_parent) =>
        if source_parent == parent_node || source_node == parent_node {
          output_vote += 1
        } else {
          input_vote += 1
        }
      None =>
        if source_node == parent_node {
          output_vote += 1
        } else {
          input_vote += 1
        }
    }
  }

  output_vote - input_vote
}

///|
fn recursive_layered_parent_port_lport(
  parent_node : @graph.ElkNode,
  parent_port : @graph.ElkPort,
  direction_value : String,
  layered_graph : LGraph,
  elk_to_lport : Map[@graph.ElkPort, LPort],
) -> LPort {
  match elk_to_lport.get(parent_port) {
    Some(existing) => existing
    None => {
      let port_constraints_value = @graph.node_get_string_property(
        parent_node, @core.port_constraints,
      )
      let border_offset = recursive_layered_port_border_offset(parent_port)
      let net_flow = recursive_layered_external_port_net_flow(
        parent_node, parent_port,
      )

      let mut final_external_side = recursive_layered_port_side_from_string(
        recursive_layered_port_side_option(parent_port),
      )
      if !recursive_layered_port_constraints_side_fixed(port_constraints_value) {
        final_external_side = recursive_layered_direction_to_port_side(
          direction_value,
        )
        if net_flow < 0 {
          final_external_side = recursive_layered_opposed_port_side(
            final_external_side,
          )
        }
        @graph.port_set_layout_option_string_by_id(
          parent_port,
          "org.eclipse.elk.port.side",
          @core.port_side_to_string(final_external_side),
        )
      }

      let dummy = new_l_node(graph=Some(layered_graph))
      dummy.set_type(NodeType::ExternalPort)
      dummy.set_property_string(@core.port_constraints, "FIXED_POS")
      dummy.set_property_port_side(
        internal_properties_ext_port_side, final_external_side,
      )
      let port_size = @core.new_kvector_xy(
        @graph.port_width(parent_port),
        @graph.port_height(parent_port),
      )
      dummy.set_property_kvector(
        internal_properties_ext_port_size,
        @core.new_kvector_copy(port_size),
      )
      dummy.set_property_double(
        recursive_layered_ext_port_border_offset_property, border_offset,
      )
      dummy.set_property_double(
        layered_options_port_border_offset, border_offset,
      )

      let lport = new_l_port()
      lport.set_node(Some(dummy))
      lport.set_connected_to_external_nodes(
        recursive_layered_port_connected_to_external_nodes(
          parent_node, parent_port,
        ),
      )
      let anchor = @core.new_kvector_xy(port_size.x / 2.0, port_size.y / 2.0)
      let mut explicit_anchor = false
      match
        @graph.port_layout_option_string_value(
          parent_port,
          layered_options_port_anchor.get_id(),
        ) {
        Some(anchor_text) => {
          let parsed_anchor = @core.new_kvector()
          parsed_anchor.parse(anchor_text)
          anchor.x = parsed_anchor.x
          anchor.y = parsed_anchor.y
          explicit_anchor = true
        }
        None => ()
      }

      match final_external_side {
        @core.PortSide::West => {
          dummy.set_property_string(
            layered_options_layering_layer_constraint, "FIRST_SEPARATE",
          )
          dummy.set_property_string(
            internal_properties_edge_constraint, "OUTGOING_ONLY",
          )
          dummy.get_size().y = port_size.y
          if border_offset < 0.0 {
            dummy.get_size().x = -border_offset
          }
          lport.set_side(@core.PortSide::East)
          if !explicit_anchor {
            anchor.x = port_size.x
          }
          anchor.x = anchor.x - port_size.x
        }
        @core.PortSide::East => {
          dummy.set_property_string(
            layered_options_layering_layer_constraint, "LAST_SEPARATE",
          )
          dummy.set_property_string(
            internal_properties_edge_constraint, "INCOMING_ONLY",
          )
          dummy.get_size().y = port_size.y
          if border_offset < 0.0 {
            dummy.get_size().x = -border_offset
          }
          lport.set_side(@core.PortSide::West)
          if !explicit_anchor {
            anchor.x = 0.0
          }
        }
        @core.PortSide::North => {
          dummy.set_property_string(
            internal_properties_in_layer_constraint, "TOP",
          )
          dummy.get_size().x = port_size.x
          if border_offset < 0.0 {
            dummy.get_size().y = -border_offset
          }
          lport.set_side(@core.PortSide::South)
          if !explicit_anchor {
            anchor.y = port_size.y
          }
          anchor.y = anchor.y - port_size.y
        }
        @core.PortSide::South => {
          dummy.set_property_string(
            internal_properties_in_layer_constraint, "BOTTOM",
          )
          dummy.get_size().x = port_size.x
          if border_offset < 0.0 {
            dummy.get_size().y = -border_offset
          }
          lport.set_side(@core.PortSide::North)
          if !explicit_anchor {
            anchor.y = 0.0
          }
        }
        @core.PortSide::SideUndefined => {
          lport.set_side(@core.PortSide::West)
          anchor.x = 0.0
        }
      }
      lport.get_position().x = anchor.x
      lport.get_position().y = anchor.y
      dummy.set_property_kvector(
        layered_options_port_anchor,
        @core.new_kvector_copy(anchor),
      )

      if recursive_layered_port_constraints_order_fixed(port_constraints_value) {
        let mut ratio_or_position = 0.0
        match final_external_side {
          @core.PortSide::West => ratio_or_position = @graph.port_y(parent_port)
          @core.PortSide::East => ratio_or_position = @graph.port_y(parent_port)
          @core.PortSide::North =>
            ratio_or_position = @graph.port_x(parent_port)
          @core.PortSide::South =>
            ratio_or_position = @graph.port_x(parent_port)
          @core.PortSide::SideUndefined => ()
        }
        if port_constraints_value == "FIXED_RATIO" {
          match final_external_side {
            @core.PortSide::West =>
              if @graph.node_height(parent_node) > 0.0 {
                ratio_or_position = ratio_or_position /
                  @graph.node_height(parent_node)
              }
            @core.PortSide::East =>
              if @graph.node_height(parent_node) > 0.0 {
                ratio_or_position = ratio_or_position /
                  @graph.node_height(parent_node)
              }
            @core.PortSide::North =>
              if @graph.node_width(parent_node) > 0.0 {
                ratio_or_position = ratio_or_position /
                  @graph.node_width(parent_node)
              }
            @core.PortSide::South =>
              if @graph.node_width(parent_node) > 0.0 {
                ratio_or_position = ratio_or_position /
                  @graph.node_width(parent_node)
              }
            @core.PortSide::SideUndefined => ()
          }
        }
        dummy.set_property_double(
          internal_properties_port_ratio_or_position, ratio_or_position,
        )
      }

      dummy.set_property_l_port(internal_properties_origin_l_port, Some(lport))
      layered_graph.get_layerless_nodes().push(dummy)
      recursive_layered_add_graph_property(
        layered_graph,
        GraphProperties::ExternalPorts,
      )
      if recursive_layered_is_north_south_side(final_external_side) {
        recursive_layered_add_graph_property(
          layered_graph,
          GraphProperties::NorthSouthPorts,
        )
      }
      elk_to_lport[parent_port] = lport
      recursive_layered_global_elk_to_lport.val[parent_port] = lport
      lport
    }
  }
}

///|
fn recursive_layered_model_order_cycle_breaking(
  cycle_breaking_strategy : String,
) -> Bool {
  cycle_breaking_strategy == "MODEL_ORDER" ||
  cycle_breaking_strategy == "BFS_NODE_ORDER" ||
  cycle_breaking_strategy == "DFS_NODE_ORDER" ||
  cycle_breaking_strategy == "GREEDY_MODEL_ORDER" ||
  cycle_breaking_strategy == "SCC_CONNECTIVITY" ||
  cycle_breaking_strategy == "SCC_NODE_TYPE"
}

///|
fn recursive_layered_model_order_layering(
  layering_strategy : String,
  node_promotion_strategy : String,
) -> Bool {
  layering_strategy == "BF_MODEL_ORDER" ||
  layering_strategy == "DF_MODEL_ORDER" ||
  node_promotion_strategy == "MODEL_ORDER_LEFT_TO_RIGHT" ||
  node_promotion_strategy == "MODEL_ORDER_RIGHT_TO_LEFT"
}

///|
fn _recursive_layered_needs_model_order(
  cycle_breaking_strategy : String,
  layering_strategy : String,
  node_promotion_strategy : String,
  consider_model_order_strategy : String,
) -> Bool {
  recursive_layered_model_order_cycle_breaking(cycle_breaking_strategy) ||
  recursive_layered_model_order_layering(
    layering_strategy, node_promotion_strategy,
  ) ||
  consider_model_order_strategy != "NONE"
}

///|
fn _recursive_layered_new_edge_port(
  owner : LNode,
  side : @core.PortSide,
  layered_graph : LGraph,
  port_type : PortType,
  fix_owner_side? : Bool = false,
) -> LPort {
  if fix_owner_side {
    owner.set_property_string(@core.port_constraints, "FIXED_SIDE")
  }
  let port = create_port_for_edge(owner, None, port_type, layered_graph)
  if !(side is @core.PortSide::SideUndefined) &&
    owner.get_property_string(@core.port_constraints) == "FIXED_SIDE" {
    port.set_side(side)
  }
  port
}

///|
fn _recursive_layered_new_descendant_endpoint_port(
  owner : LNode,
  endpoint_node : @graph.ElkNode,
  layered_graph : LGraph,
  port_type : PortType,
) -> LPort {
  owner.set_property_string(@core.port_constraints, "FIXED_POS")
  let port = new_l_port()
  port.set_node(Some(owner))
  let point = port.get_position()
  point.x = @graph.node_x(endpoint_node) +
    @graph.node_width(endpoint_node) / 2.0
  point.y = @graph.node_y(endpoint_node) +
    @graph.node_height(endpoint_node) / 2.0
  ignore(point.bound(0.0, 0.0, owner.get_size().x, owner.get_size().y))
  let default_side = @core.port_side_from_direction(
    get_direction(layered_graph),
  )
  port.set_side(
    match port_type {
      PortType::Output => default_side
      PortType::Input => default_side.opposed()
      PortType::Undefined => default_side
    },
  )
  port
}

///|
fn recursive_layered_absolute_node_x(node : @graph.ElkNode) -> Double {
  match @graph.node_parent(node) {
    Some(parent) =>
      @graph.node_x(node) + recursive_layered_absolute_node_x(parent)
    None => @graph.node_x(node)
  }
}

///|
fn recursive_layered_absolute_node_y(node : @graph.ElkNode) -> Double {
  match @graph.node_parent(node) {
    Some(parent) =>
      @graph.node_y(node) + recursive_layered_absolute_node_y(parent)
    None => @graph.node_y(node)
  }
}

///|
fn recursive_layered_descendant_port_anchor(
  port : @graph.ElkPort,
) -> @core.KVector {
  let port_width = @graph.port_width(port)
  let port_height = @graph.port_height(port)
  let anchor = @core.new_kvector_xy(port_width / 2.0, port_height / 2.0)
  let mut side = recursive_layered_port_side_from_string(
    recursive_layered_port_side_option(port),
  )
  if side is @core.PortSide::SideUndefined {
    match @graph.port_parent(port) {
      Some(parent_node) => {
        let port_x = @graph.port_x(port)
        let port_y = @graph.port_y(port)
        let node_width = @graph.node_width(parent_node)
        let node_height = @graph.node_height(parent_node)
        if port_x < 0.0 {
          side = @core.PortSide::West
        } else if port_x + port_width > node_width {
          side = @core.PortSide::East
        } else if port_y < 0.0 {
          side = @core.PortSide::North
        } else if port_y + port_height > node_height {
          side = @core.PortSide::South
        }
      }
      None => ()
    }
  }
  match side {
    @core.PortSide::East => {
      anchor.x = port_width
      anchor.y = port_height / 2.0
    }
    @core.PortSide::West => {
      anchor.x = 0.0
      anchor.y = port_height / 2.0
    }
    @core.PortSide::North => {
      anchor.x = port_width / 2.0
      anchor.y = 0.0
    }
    @core.PortSide::South => {
      anchor.x = port_width / 2.0
      anchor.y = port_height
    }
    @core.PortSide::SideUndefined => ()
  }
  match
    @graph.port_layout_option_string_value(
      port,
      layered_options_port_anchor.get_id(),
    ) {
    Some(anchor_text) => {
      let parsed_anchor = @core.new_kvector()
      parsed_anchor.parse(anchor_text)
      anchor.x = parsed_anchor.x
      anchor.y = parsed_anchor.y
    }
    None => ()
  }
  anchor
}

///|
fn recursive_layered_absolute_port_anchor(
  port : @graph.ElkPort,
) -> @core.KVector {
  let anchor = recursive_layered_descendant_port_anchor(port)
  match @graph.port_parent(port) {
    Some(parent_node) =>
      @core.new_kvector_xy(
        recursive_layered_absolute_node_x(parent_node) +
        @graph.port_x(port) +
        anchor.x,
        recursive_layered_absolute_node_y(parent_node) +
        @graph.port_y(port) +
        anchor.y,
      )
    None =>
      @core.new_kvector_xy(
        @graph.port_x(port) + anchor.x,
        @graph.port_y(port) + anchor.y,
      )
  }
}

///|
fn _recursive_layered_shape_anchor_for_edge_section(
  edge : @graph.ElkEdge,
  shape : @graph.ElkConnectableShape,
) -> @core.KVector? {
  let shape_port = try @graph.connectable_shape_to_port(Some(shape)) catch {
    _ => None
  } noraise {
    value => value
  }
  match shape_port {
    Some(port) =>
      match @graph.edge_containing_node(edge) {
        Some(containing_node) =>
          match @graph.port_parent(port) {
            Some(port_parent) =>
              if recursive_layered_is_descendant(port_parent, containing_node) {
                let absolute_anchor = recursive_layered_absolute_port_anchor(
                  port,
                )
                Some(
                  @core.new_kvector_xy(
                    absolute_anchor.x -
                    recursive_layered_absolute_node_x(containing_node),
                    absolute_anchor.y -
                    recursive_layered_absolute_node_y(containing_node),
                  ),
                )
              } else {
                None
              }
            None => None
          }
        None => None
      }
    None => None
  }
}

///|
fn _recursive_layered_new_descendant_port_endpoint_port(
  owner : LNode,
  owner_node : @graph.ElkNode,
  endpoint_port : @graph.ElkPort,
  layered_graph : LGraph,
  port_type : PortType,
) -> LPort {
  owner.set_property_string(@core.port_constraints, "FIXED_POS")
  let port = new_l_port()
  port.set_node(Some(owner))
  let point = port.get_position()
  let anchor = recursive_layered_descendant_port_anchor(endpoint_port)
  match @graph.port_parent(endpoint_port) {
    Some(endpoint_parent) => {
      let absolute_anchor_x = recursive_layered_absolute_node_x(endpoint_parent) +
        @graph.port_x(endpoint_port) +
        anchor.x
      let absolute_anchor_y = recursive_layered_absolute_node_y(endpoint_parent) +
        @graph.port_y(endpoint_port) +
        anchor.y
      point.x = absolute_anchor_x -
        recursive_layered_absolute_node_x(owner_node)
      point.y = absolute_anchor_y -
        recursive_layered_absolute_node_y(owner_node)
    }
    None => {
      point.x = @graph.port_x(endpoint_port) + anchor.x
      point.y = @graph.port_y(endpoint_port) + anchor.y
    }
  }
  ignore(point.bound(0.0, 0.0, owner.get_size().x, owner.get_size().y))
  let default_side = @core.port_side_from_direction(
    get_direction(layered_graph),
  )
  port.set_side(
    match port_type {
      PortType::Output => default_side
      PortType::Input => default_side.opposed()
      PortType::Undefined => default_side
    },
  )
  port
}

///|
fn recursive_layered_primary_option(
  node : @graph.ElkNode,
  key : String,
  fallback : String,
) -> String {
  let candidates = [key]
  let mut maybe_layered_suffix : String? = None
  match key.strip_prefix("org.eclipse.") {
    Some(without_org_view) => {
      let without_org = without_org_view.to_string()
      candidates.push(without_org)
      match without_org.strip_prefix("elk.") {
        Some(without_elk_view) => {
          let without_elk = without_elk_view.to_string()
          candidates.push(without_elk)
          match without_elk.strip_prefix("layered.") {
            Some(without_layered_view) =>
              maybe_layered_suffix = Some(without_layered_view.to_string())
            None => ()
          }
        }
        None => ()
      }
    }
    None => {
      match key.strip_prefix("elk.") {
        Some(without_elk_view) => {
          candidates.push("org.eclipse." + key)
          let without_elk = without_elk_view.to_string()
          candidates.push(without_elk)
          match without_elk.strip_prefix("layered.") {
            Some(without_layered_view) =>
              maybe_layered_suffix = Some(without_layered_view.to_string())
            None => ()
          }
        }
        None => ()
      }
      match key.strip_prefix("layered.") {
        Some(without_layered_view) =>
          maybe_layered_suffix = Some(without_layered_view.to_string())
        None => ()
      }
    }
  }
  match maybe_layered_suffix {
    Some(layered_suffix) => candidates.push(layered_suffix)
    None => ()
  }

  let mut matched_fallback_value : String? = None
  for candidate in candidates {
    let value_at_candidate = match
      node_layout_option_value_by_candidates(node, [candidate]) {
      Some(value) => Some(value)
      None => node_string_property_value_by_candidates(node, [candidate])
    }
    match value_at_candidate {
      Some(value) =>
        if value != fallback {
          return value
        } else if matched_fallback_value is None {
          matched_fallback_value = Some(value)
        }
      None => ()
    }
  }
  match matched_fallback_value {
    Some(value) => value
    None => fallback
  }
}

///|
fn recursive_layered_direction_option(node : @graph.ElkNode) -> String {
  let keys = [
    @core.direction.get_id(),
    "org.eclipse.elk.direction",
    "elk.direction",
    "direction",
  ]
  match node_layout_option_value_by_candidates_with_ancestors(node, keys) {
    Some(value) => value
    None =>
      match
        node_string_property_value_by_candidates_with_ancestors(node, keys) {
        Some(value) => value
        None => @graph.node_get_string_property(node, @core.direction)
      }
  }
}

///|
fn recursive_layered_parse_bool(value : String) -> Bool? {
  if value == "true" {
    Some(true)
  } else if value == "false" {
    Some(false)
  } else {
    None
  }
}

///|
fn recursive_layered_parse_int(value : String) -> Int? {
  let parsed : Result[Int, Error] = try? @string.parse_int(
    value.trim().to_string(),
  )
  match parsed {
    Ok(result) => Some(result)
    Err(_) => None
  }
}

///|
fn recursive_layered_parse_double(value : String) -> Double? {
  let parsed : Result[Double, Error] = try? @string.parse_double(
    value.trim().to_string(),
  )
  match parsed {
    Ok(result) => Some(result)
    Err(_) => None
  }
}

///|
fn recursive_layered_edge_no_layout(edge : @graph.ElkEdge) -> Bool {
  let candidates = [
    @core.no_layout.get_id(),
    "org.eclipse.elk.noLayout",
    "elk.noLayout",
    "noLayout",
  ]
  for candidate in candidates {
    match @graph.edge_layout_option_string_value(edge, candidate) {
      Some(raw_value) =>
        match recursive_layered_parse_bool(raw_value) {
          Some(value) => return value
          None => ()
        }
      None => ()
    }
  }
  false
}

///|
fn recursive_layered_edge_inside_self_loops_yo(edge : @graph.ElkEdge) -> Bool {
  let candidates = [
    "org.eclipse.elk.insideSelfLoops.yo", "elk.insideSelfLoops.yo", "insideSelfLoops.yo",
  ]
  for candidate in candidates {
    match @graph.edge_layout_option_string_value(edge, candidate) {
      Some(raw_value) =>
        match recursive_layered_parse_bool(raw_value) {
          Some(value) => return value
          None => ()
        }
      None => ()
    }
  }
  false
}

///|
fn recursive_layered_has_inside_self_loops(node : @graph.ElkNode) -> Bool {
  if !@graph.node_get_bool_property(node, @core.inside_self_loops_activate) {
    return false
  }
  for edge in @graph.all_outgoing_edges(node) {
    let source_node = match
      recursive_layered_edge_endpoint_node(@graph.edge_sources(edge)) {
      Some(value) => value
      None => continue
    }
    let target_node = match
      recursive_layered_edge_endpoint_node(@graph.edge_targets(edge)) {
      Some(value) => value
      None => continue
    }
    if source_node == node &&
      target_node == node &&
      recursive_layered_edge_inside_self_loops_yo(edge) {
      return true
    }
  }
  false
}

///|
fn recursive_layered_normalize_port_constraints(lgraph : LGraph) -> Unit {
  for node in lgraph.get_layerless_nodes() {
    if node.get_property_string(@core.port_constraints) == "UNDEFINED" {
      node.set_property_string(@core.port_constraints, "FREE")
    }
  }
  for layer in lgraph.get_layers() {
    for node in layer.get_nodes() {
      if node.get_property_string(@core.port_constraints) == "UNDEFINED" {
        node.set_property_string(@core.port_constraints, "FREE")
      }
    }
  }
}

///|
fn recursive_layered_node_algorithm_option(node : @graph.ElkNode) -> String? {
  let candidates = [
    @core.algorithm.get_id(),
    "org.eclipse.elk.algorithm",
    "elk.algorithm",
    "algorithm",
  ]
  match node_layout_option_value_by_candidates(node, candidates) {
    Some(value) => Some(value)
    None => node_string_property_value_by_candidates(node, candidates)
  }
}

///|
fn recursive_layered_node_uses_layered(node : @graph.ElkNode) -> Bool {
  match recursive_layered_node_algorithm_option(node) {
    Some(value) =>
      value == "layered" ||
      value == "elk.layered" ||
      value == layered_algorithm_id ||
      value.has_suffix(".layered")
    None => true
  }
}

///|
fn recursive_layered_node_hierarchy_include_children(
  node : @graph.ElkNode,
) -> Bool {
  recursive_layered_primary_option(
    node,
    "org.eclipse.elk.hierarchyHandling",
    @graph.node_get_string_property(node, layered_options_hierarchy_handling),
  ) ==
  "INCLUDE_CHILDREN"
}

///|
fn recursive_layered_create_context(
  node : @graph.ElkNode,
  inherited_direction : String?,
  import_edges? : Bool = true,
) -> RecursiveLayeredContext? {
  let layered_graph = new_l_graph()
  let elk_to_lnode : Map[@graph.ElkNode, LNode] = {}
  let elk_to_lport : Map[@graph.ElkPort, LPort] = {}
  let node_label_pairs : Map[@graph.ElkNode, Array[(LLabel, @graph.ElkLabel)]] = {}
  let lnode_to_elk : Map[Int, @graph.ElkNode] = {}
  let node_padding = parse_node_padding(node)
  let node_label_padding = @common.node_label_and_size_calculator_compute_inside_node_label_padding(
    node,
    @core.Direction::Rightward,
  )
  let graph_padding = layered_graph.get_padding()
  ignore(graph_padding.add(node_padding))
  ignore(graph_padding.add(node_label_padding))

  let spacing_node = match
    recursive_layered_parse_double(
      recursive_layered_primary_option(
        node,
        @core.spacing_node_node.get_id(),
        @graph.node_get_double_property(node, @core.spacing_node_node).to_string(),
      ),
    ) {
    Some(value) => value
    None => @core.spacing_node_node.get_default()
  }
  let spacing_edge_edge_value = match
    recursive_layered_parse_double(
      recursive_layered_primary_option(
        node,
        @core.spacing_edge_edge.get_id(),
        @graph.node_get_double_property(node, @core.spacing_edge_edge).to_string(),
      ),
    ) {
    Some(value) => value
    None => @core.spacing_edge_edge.get_default()
  }
  let spacing_edge_node_value = match
    recursive_layered_parse_double(
      recursive_layered_primary_option(
        node,
        @core.spacing_edge_node.get_id(),
        @graph.node_get_double_property(node, @core.spacing_edge_node).to_string(),
      ),
    ) {
    Some(value) => value
    None => @core.spacing_edge_node.get_default()
  }
  let spacing_node_self_loop_value = match
    recursive_layered_parse_double(
      recursive_layered_primary_option(
        node,
        @core.spacing_node_self_loop.get_id(),
        @graph.node_get_double_property(node, @core.spacing_node_self_loop).to_string(),
      ),
    ) {
    Some(value) => value
    None => @core.spacing_node_self_loop.get_default()
  }
  let spacing_between_layers = match
    recursive_layered_parse_double(
      recursive_layered_primary_option(
        node,
        layered_options_spacing_node_node_between_layers.get_id(),
        @graph.node_get_double_property(
          node, layered_options_spacing_node_node_between_layers,
        ).to_string(),
      ),
    ) {
    Some(value) => value
    None => layered_options_spacing_node_node_between_layers.get_default()
  }
  let spacing_edge_node_between_layers = match
    recursive_layered_parse_double(
      recursive_layered_primary_option(
        node,
        layered_options_spacing_edge_node_between_layers.get_id(),
        @graph.node_get_double_property(
          node, layered_options_spacing_edge_node_between_layers,
        ).to_string(),
      ),
    ) {
    Some(value) => value
    None => layered_options_spacing_edge_node_between_layers.get_default()
  }
  let spacing_edge_edge_between_layers = match
    recursive_layered_parse_double(
      recursive_layered_primary_option(
        node,
        layered_options_spacing_edge_edge_between_layers.get_id(),
        @graph.node_get_double_property(
          node, layered_options_spacing_edge_edge_between_layers,
        ).to_string(),
      ),
    ) {
    Some(value) => value
    None => layered_options_spacing_edge_edge_between_layers.get_default()
  }
  let aspect_ratio_value = @graph.node_get_double_property(
    node, layered_options_aspect_ratio,
  )
  let consider_model_order = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.layered.considerModelOrder.strategy",
    @graph.node_get_string_property(
      node, layered_options_consider_model_order_strategy,
    ),
  )
  let node_promotion_strategy = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.layered.nodePromotion.strategy",
    @graph.node_get_string_property(
      node, layered_options_layering_node_promotion_strategy,
    ),
  )
  let crossing_strategy = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.layered.crossingMinimization.strategy",
    @graph.node_get_string_property(
      node, layered_options_crossing_minimization_strategy,
    ),
  )
  let node_placement_strategy = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.layered.nodePlacement.strategy",
    @graph.node_get_string_property(
      node, layered_options_node_placement_strategy,
    ),
  )
  let greedy_switch_type = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.layered.crossingMinimization.greedySwitch.type",
    @graph.node_get_string_property(
      node, layered_options_crossing_minimization_greedy_switch_type,
    ),
  )
  let greedy_switch_hierarchical_type = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.layered.crossingMinimization.greedySwitchHierarchical.type",
    @graph.node_get_string_property(
      node, layered_options_crossing_minimization_greedy_switch_hierarchical_type,
    ),
  )
  let greedy_switch_activation_threshold = match
    recursive_layered_parse_int(
      recursive_layered_primary_option(
        node,
        "org.eclipse.elk.layered.crossingMinimization.greedySwitch.activationThreshold",
        @graph.node_get_int_property(
          node, layered_options_crossing_minimization_greedy_switch_activation_threshold,
        ).to_string(),
      ),
    ) {
    Some(value) => value
    None =>
      layered_options_crossing_minimization_greedy_switch_activation_threshold.get_default()
  }
  let crossing_semi_interactive = match
    recursive_layered_parse_bool(
      recursive_layered_primary_option(
        node,
        "org.eclipse.elk.layered.crossingMinimization.semiInteractive",
        @graph.node_get_bool_property(
          node, layered_options_crossing_minimization_semi_interactive,
        ).to_string(),
      ),
    ) {
    Some(value) => value
    None => layered_options_crossing_minimization_semi_interactive.get_default()
  }
  let crossing_force_node_model_order = match
    recursive_layered_parse_bool(
      recursive_layered_primary_option(
        node,
        "org.eclipse.elk.layered.crossingMinimization.forceNodeModelOrder",
        @graph.node_get_bool_property(
          node, layered_options_crossing_minimization_force_node_model_order,
        ).to_string(),
      ),
    ) {
    Some(value) => value
    None =>
      layered_options_crossing_minimization_force_node_model_order.get_default()
  }
  let edge_routing_value = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.edgeRouting",
    @graph.node_get_string_property(node, @core.edge_routing),
  )
  let mut direction_value = match inherited_direction {
    Some(value) => value
    None => recursive_layered_direction_option(node)
  }
  let fixed_alignment_value = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.layered.nodePlacement.bk.fixedAlignment",
    layered_options_node_placement_bk_fixed_alignment.get_default(),
  )
  let favor_straight_edges_value = recursive_layered_primary_option(
    node, "org.eclipse.elk.layered.nodePlacement.favorStraightEdges", "",
  )
  let cycle_breaking_strategy = recursive_layered_primary_option(
    node, "org.eclipse.elk.layered.cycleBreaking.strategy", "GREEDY",
  )
  let merge_edges = match
    recursive_layered_parse_bool(
      recursive_layered_primary_option(
        node,
        layered_options_merge_edges.get_id(),
        @graph.node_get_bool_property(node, layered_options_merge_edges).to_string(),
      ),
    ) {
    Some(value) => value
    None => layered_options_merge_edges.get_default()
  }
  let thoroughness_value = match
    recursive_layered_parse_int(
      recursive_layered_primary_option(
        node,
        layered_options_thoroughness.get_id(),
        @graph.node_get_int_property(node, layered_options_thoroughness).to_string(),
      ),
    ) {
    Some(value) => value
    None => layered_options_thoroughness.get_default()
  }
  let layering_strategy = recursive_layered_primary_option(
    node, "org.eclipse.elk.layered.layering.strategy", "NETWORK_SIMPLEX",
  )
  let hierarchy_handling = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.hierarchyHandling",
    @graph.node_get_string_property(node, layered_options_hierarchy_handling),
  )
  let high_degree_nodes_treatment = match
    recursive_layered_parse_bool(
      recursive_layered_primary_option(
        node,
        "org.eclipse.elk.alg.layered.highDegreeNodes.treatment",
        @graph.node_get_bool_property(
          node, layered_options_high_degree_nodes_treatment,
        ).to_string(),
      ),
    ) {
    Some(value) => value
    None => layered_options_high_degree_nodes_treatment.get_default()
  }
  let compaction_post_strategy = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.layered.compaction.postCompaction.strategy",
    @graph.node_get_string_property(
      node, layered_options_compaction_post_compaction_strategy,
    ),
  )
  let layer_unzipping_strategy = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.layered.layerUnzipping.strategy",
    @graph.node_get_string_property(
      node, layered_options_layer_unzipping_strategy,
    ),
  )
  let wrapping_strategy = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.layered.wrapping.strategy",
    @graph.node_get_string_property(node, layered_options_wrapping_strategy),
  )
  let generate_position_and_layer_ids = match
    recursive_layered_parse_bool(
      recursive_layered_primary_option(
        node,
        "org.eclipse.elk.layered.generatePositionAndLayerIds",
        @graph.node_get_bool_property(
          node, layered_options_generate_position_and_layer_ids,
        ).to_string(),
      ),
    ) {
    Some(value) => value
    None => layered_options_generate_position_and_layer_ids.get_default()
  }
  let interactive_layout = match
    recursive_layered_parse_bool(
      recursive_layered_primary_option(
        node,
        "org.eclipse.elk.interactive",
        @graph.node_get_bool_property(node, @core.interactive).to_string(),
      ),
    ) {
    Some(value) => value
    None => @core.interactive.get_default()
  }
  let random_seed_value = match
    recursive_layered_parse_int(
      recursive_layered_primary_option(
        node,
        "org.eclipse.elk.randomSeed",
        @core.random_seed.get_default().to_string(),
      ),
    ) {
    Some(value) => value
    None => @core.random_seed.get_default()
  }
  let graph_port_constraints = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.portConstraints",
    @graph.node_get_string_property(node, @core.port_constraints),
  )
  let content_alignment_value = recursive_layered_primary_option(
    node,
    @core.content_alignment.get_id(),
    @graph.node_get_string_set_property(node, @core.content_alignment).join(","),
  )
  let node_size_constraints_value = recursive_layered_primary_option(
    node,
    @core.node_size_constraints.get_id(),
    @graph.node_get_string_set_property(node, @core.node_size_constraints).join(
      ",",
    ),
  )
  let node_size_options_value = recursive_layered_primary_option(
    node,
    @core.node_size_options.get_id(),
    @graph.node_get_string_set_property(node, @core.node_size_options).join(","),
  )
  let node_size_minimum_value = recursive_layered_primary_option(
    node,
    @core.node_size_minimum.get_id(),
    @graph.node_get_string_property(node, @core.node_size_minimum),
  )
  let feedback_edges = match
    recursive_layered_parse_bool(
      recursive_layered_primary_option(
        node,
        "org.eclipse.elk.layered.feedbackEdges",
        @graph.node_get_bool_property(node, layered_options_feedback_edges).to_string(),
      ),
    ) {
    Some(value) => value
    None => layered_options_feedback_edges.get_default()
  }

  layered_graph.set_property_double(
    @core.spacing_node_node,
    if spacing_node > 0.0 {
      spacing_node
    } else {
      @core.spacing_node_node.get_default()
    },
  )
  layered_graph.set_property_double(
    @core.spacing_edge_edge,
    if spacing_edge_edge_value > 0.0 {
      spacing_edge_edge_value
    } else {
      @core.spacing_edge_edge.get_default()
    },
  )
  layered_graph.set_property_double(
    @core.spacing_edge_node,
    if spacing_edge_node_value > 0.0 {
      spacing_edge_node_value
    } else {
      @core.spacing_edge_node.get_default()
    },
  )
  layered_graph.set_property_double(
    @core.spacing_node_self_loop,
    if spacing_node_self_loop_value > 0.0 {
      spacing_node_self_loop_value
    } else {
      @core.spacing_node_self_loop.get_default()
    },
  )
  layered_graph.set_property_double(
    layered_options_spacing_node_node_between_layers,
    if spacing_between_layers > 0.0 {
      spacing_between_layers
    } else {
      layered_options_spacing_node_node_between_layers.get_default()
    },
  )
  layered_graph.set_property_double(
    layered_options_spacing_edge_node_between_layers,
    if spacing_edge_node_between_layers > 0.0 {
      spacing_edge_node_between_layers
    } else {
      layered_options_spacing_edge_node_between_layers.get_default()
    },
  )
  layered_graph.set_property_double(
    layered_options_spacing_edge_edge_between_layers,
    if spacing_edge_edge_between_layers > 0.0 {
      spacing_edge_edge_between_layers
    } else {
      layered_options_spacing_edge_edge_between_layers.get_default()
    },
  )
  layered_graph.set_property_double(
    layered_options_aspect_ratio,
    if aspect_ratio_value > 0.0 {
      aspect_ratio_value
    } else {
      layered_options_aspect_ratio.get_default()
    },
  )
  layered_graph.set_property_int(@core.random_seed, random_seed_value)
  layered_graph.set_property_string(
    layered_options_cycle_breaking_strategy, cycle_breaking_strategy,
  )
  layered_graph.set_property_bool(layered_options_merge_edges, merge_edges)
  layered_graph.set_property_int(
    layered_options_thoroughness,
    if thoroughness_value > 0 {
      thoroughness_value
    } else {
      layered_options_thoroughness.get_default()
    },
  )
  layered_graph.set_property_string(
    layered_options_layering_strategy, layering_strategy,
  )
  layered_graph.set_property_string(
    layered_options_consider_model_order_strategy, consider_model_order,
  )
  layered_graph.set_property_string(
    layered_options_layering_node_promotion_strategy, node_promotion_strategy,
  )
  layered_graph.set_property_string(
    layered_options_crossing_minimization_strategy, crossing_strategy,
  )
  layered_graph.set_property_string(
    layered_options_node_placement_strategy, node_placement_strategy,
  )
  layered_graph.set_property_string(
    layered_options_crossing_minimization_greedy_switch_type, greedy_switch_type,
  )
  layered_graph.set_property_string(
    layered_options_crossing_minimization_greedy_switch_hierarchical_type, greedy_switch_hierarchical_type,
  )
  layered_graph.set_property_int(
    layered_options_crossing_minimization_greedy_switch_activation_threshold, greedy_switch_activation_threshold,
  )
  layered_graph.set_property_bool(
    layered_options_crossing_minimization_semi_interactive, crossing_semi_interactive,
  )
  layered_graph.set_property_bool(
    layered_options_crossing_minimization_force_node_model_order, crossing_force_node_model_order,
  )
  layered_graph.set_property_string(
    @core.edge_routing,
    if edge_routing_value == "UNDEFINED" || edge_routing_value.is_empty() {
      "ORTHOGONAL"
    } else {
      edge_routing_value
    },
  )
  layered_graph.set_property_string(@core.direction, direction_value)
  direction_value = @core.direction_to_string(get_direction(layered_graph))
  layered_graph.set_property_string(@core.direction, direction_value)
  layered_graph.set_property_string(
    @core.port_constraints,
    if graph_port_constraints == "UNDEFINED" {
      "FREE"
    } else {
      graph_port_constraints
    },
  )
  layered_graph.set_property_bool(
    layered_options_feedback_edges, feedback_edges,
  )
  layered_graph.set_property_string(
    layered_options_hierarchy_handling, hierarchy_handling,
  )
  layered_graph.set_property_bool(
    layered_options_high_degree_nodes_treatment, high_degree_nodes_treatment,
  )
  layered_graph.set_property_string(
    layered_options_compaction_post_compaction_strategy, compaction_post_strategy,
  )
  layered_graph.set_property_string(
    layered_options_layer_unzipping_strategy, layer_unzipping_strategy,
  )
  layered_graph.set_property_string(
    layered_options_wrapping_strategy, wrapping_strategy,
  )
  layered_graph.set_property_bool(
    layered_options_generate_position_and_layer_ids, generate_position_and_layer_ids,
  )
  layered_graph.set_property_bool(@core.interactive, interactive_layout)
  layered_graph.set_property_string(
    layered_options_node_placement_bk_fixed_alignment, fixed_alignment_value,
  )
  let content_alignment_tokens = option_value_tokens(content_alignment_value)
  if !content_alignment_tokens.is_empty() {
    layered_graph.set_property_string_array(
      @core.content_alignment, content_alignment_tokens,
    )
  }
  layered_graph.set_property_string_array(
    @core.node_size_constraints,
    option_value_tokens(node_size_constraints_value),
  )
  layered_graph.set_property_string_array(
    @core.node_size_options,
    option_value_tokens(node_size_options_value),
  )
  layered_graph.set_property_string(
    @core.node_size_minimum, node_size_minimum_value,
  )
  if recursive_layered_should_calculate_minimum_graph_size(node) {
    recursive_layered_calculate_minimum_graph_size(node, layered_graph)
  }
  match recursive_layered_parse_bool(favor_straight_edges_value) {
    Some(value) =>
      layered_graph.set_property_bool(
        layered_options_node_placement_favor_straight_edges, value,
      )
    None => ()
  }
  layered_graph.set_property_graph_properties_array(
    internal_properties_graph_properties,
    [],
  )
  layered_graph.set_property_int(
    internal_properties_cb_num_model_order_groups, 0,
  )
  if graph_port_constraints != "UNDEFINED" && graph_port_constraints != "FREE" {
    recursive_layered_add_graph_property(
      layered_graph,
      GraphProperties::NonFreePorts,
    )
  }

  let nodes_to_import = @graph.node_children(node).copy()

  for child in nodes_to_import {
    if @graph.node_get_bool_property(child, @core.no_layout) {
      continue
    }
    let lnode = new_l_node(graph=Some(layered_graph))
    recursive_layered_copy_elk_node_properties(child, lnode)
    lnode.get_size().x = @graph.node_width(child)
    lnode.get_size().y = @graph.node_height(child)
    lnode.get_position().x = @graph.node_x(child)
    lnode.get_position().y = @graph.node_y(child)
    let original_port_constraints = match
      node_layout_option_value_by_candidates(child, [
        @core.port_constraints.get_id(),
        "org.eclipse.elk.portConstraints",
        "elk.portConstraints",
        "portConstraints",
      ]) {
      Some(value) => value
      None => @graph.node_get_string_property(child, @core.port_constraints)
    }
    let resolved_port_constraints = if original_port_constraints == "UNDEFINED" {
      "FREE"
    } else {
      original_port_constraints
    }
    lnode.set_property_string(@core.port_constraints, original_port_constraints)
    if original_port_constraints != "UNDEFINED" &&
      original_port_constraints != "FREE" {
      recursive_layered_add_graph_property(
        layered_graph,
        GraphProperties::NonFreePorts,
      )
    }
    match recursive_layered_model_order_node_assignments.val.get(child) {
      Some(model_order) =>
        lnode.set_property_int(internal_properties_model_order, model_order)
      None => ()
    }
    recursive_layered_copy_nodespacing_options(node, child, lnode)

    let node_label_pairs_for_child : Array[(LLabel, @graph.ElkLabel)] = []
    for elk_label in @graph.node_labels(child) {
      let text = @graph.label_text(elk_label)
      if text.is_empty() {
        continue
      }
      let llabel = new_l_label_text(text)
      recursive_layered_copy_elk_label_layout_options(elk_label, llabel)
      llabel.get_size().x = @graph.label_width(elk_label)
      llabel.get_size().y = @graph.label_height(elk_label)
      llabel.get_position().x = @graph.label_x(elk_label)
      llabel.get_position().y = @graph.label_y(elk_label)
      lnode.get_labels().push(llabel)
      node_label_pairs_for_child.push((llabel, elk_label))
    }

    node_label_pairs[child] = node_label_pairs_for_child
    layered_graph.get_layerless_nodes().push(lnode)
    elk_to_lnode[child] = lnode
    recursive_layered_global_elk_to_lnode.val[child] = lnode
    lnode_to_elk[lnode.get_handle()] = child

    for elk_port in @graph.node_ports(child) {
      let lport = new_l_port()
      lport.set_node(Some(lnode))
      recursive_layered_copy_elk_port_layout_options(elk_port, lport)
      lport.get_size().x = @graph.port_width(elk_port)
      lport.get_size().y = @graph.port_height(elk_port)
      let port_border_offset = recursive_layered_port_border_offset(elk_port)
      lport.set_property_double(
        @common.nodespacing_port_border_offset_property, port_border_offset,
      )
      lport.set_property_double(
        layered_options_port_border_offset, port_border_offset,
      )
      lport.set_property_bool(
        internal_properties_inside_connections,
        recursive_layered_port_has_inside_connections(child, elk_port),
      )
      let allow_non_flow_switch = if resolved_port_constraints == "FIXED_POS" {
        false
      } else {
        recursive_layered_port_allow_non_flow_switch_sides(elk_port)
      }
      lport.set_property_bool(
        layered_options_allow_non_flow_ports_to_switch_sides, allow_non_flow_switch,
      )
      lport.set_side(
        recursive_layered_port_side_from_string(
          recursive_layered_port_side_option(elk_port),
        ),
      )
      let port_index_candidates = [
        layered_options_port_index.get_id(),
        "elk.port.index",
        "port.index",
      ]
      for candidate in port_index_candidates {
        match @graph.port_layout_option_string_value(elk_port, candidate) {
          Some(raw_port_index) => {
            let parsed_port_index : Result[Int, Error] = try? @string.parse_int(
              raw_port_index.trim().to_string(),
            )
            if parsed_port_index is Ok(port_index) {
              lport.set_property_int(layered_options_port_index, port_index)
              break
            }
          }
          None => ()
        }
      }
      lport.get_position().x = @graph.port_x(elk_port)
      lport.get_position().y = @graph.port_y(elk_port)
      let explicit_anchor = match
        @graph.port_layout_option_string_value(
          elk_port,
          layered_options_port_anchor.get_id(),
        ) {
        Some(anchor_text) => {
          let parsed_anchor = @core.new_kvector()
          parsed_anchor.parse(anchor_text)
          Some(parsed_anchor)
        }
        None => None
      }
      initialize_port(
        lport,
        recursive_layered_parse_port_constraints(resolved_port_constraints),
        get_direction(layered_graph),
        explicit_anchor,
      )
      if recursive_layered_is_north_south_port_for_direction(
          lport.get_side(),
          direction_value,
        ) {
        recursive_layered_add_graph_property(
          layered_graph,
          GraphProperties::NorthSouthPorts,
        )
      }
      elk_to_lport[elk_port] = lport
      recursive_layered_global_elk_to_lport.val[elk_port] = lport
    }

    let has_children = !@graph.node_children(child).is_empty()
    let has_inside_self_loops = recursive_layered_has_inside_self_loops(child)
    if has_children ||
      @graph.node_get_bool_property(child, @core.inside_self_loops_activate) {
      lnode.set_property_bool(internal_properties_compound_node, true)
    }
    if (has_children || has_inside_self_loops) &&
      recursive_layered_node_uses_layered(child) &&
      recursive_layered_node_hierarchy_include_children(child) {
      match
        recursive_layered_create_context(
          child,
          Some(layered_graph.get_property_string(@core.direction)),
          import_edges=false,
        ) {
        Some(nested_context) => {
          let nested_graph = recursive_layered_transform_register_context(
            nested_context, child,
          )
          nested_graph.set_property_string(
            @core.direction,
            layered_graph.get_property_string(@core.direction),
          )
          lnode.set_nested_graph(Some(nested_graph))
          nested_graph.set_parent_node(Some(lnode))
        }
        None => ()
      }
    }
  }

  let edges_to_import = if import_edges {
    recursive_layered_layout_run_edges(node)
  } else {
    []
  }
  let include_children_layout_run = hierarchy_handling == "INCLUDE_CHILDREN"

  for edge in edges_to_import {
    let source_shapes = @graph.edge_sources(edge)
    if source_shapes.is_empty() {
      return None
    }
    let target_shapes = @graph.edge_targets(edge)
    if target_shapes.is_empty() {
      return None
    }

    let source_node = match
      recursive_layered_edge_endpoint_node(source_shapes) {
      Some(found) => found
      None => return None
    }
    let target_node = match
      recursive_layered_edge_endpoint_node(target_shapes) {
      Some(found) => found
      None => return None
    }
    if recursive_layered_edge_no_layout(edge) ||
      @graph.node_get_bool_property(source_node, @core.no_layout) ||
      @graph.node_get_bool_property(target_node, @core.no_layout) {
      continue
    }

    let is_inside_self_loop = source_node == target_node &&
      @graph.node_get_bool_property(
        source_node, @core.inside_self_loops_activate,
      ) &&
      recursive_layered_edge_inside_self_loops_yo(edge)
    let mut edge_parent_node = match @graph.edge_containing_node(edge) {
      Some(value) => value
      None => node
    }
    if is_inside_self_loop ||
      recursive_layered_is_descendant(target_node, source_node) {
      edge_parent_node = source_node
    } else if recursive_layered_is_descendant(source_node, target_node) {
      edge_parent_node = target_node
    }

    let edge_parent_lgraph = if edge_parent_node == node {
      layered_graph
    } else {
      let edge_parent_lnode = match elk_to_lnode.get(edge_parent_node) {
        Some(found) => Some(found)
        None => recursive_layered_global_elk_to_lnode.val.get(edge_parent_node)
      }
      match edge_parent_lnode {
        Some(parent_lnode) =>
          match parent_lnode.get_nested_graph() {
            Some(nested_graph) => nested_graph
            None => layered_graph
          }
        None => layered_graph
      }
    }
    let edge_direction_value = edge_parent_lgraph.get_property_string(
      @core.direction,
    )

    if !include_children_layout_run {
      let source_parent = @graph.node_parent(source_node)
      let target_parent = @graph.node_parent(target_node)
      let source_at_current_level = source_parent == Some(node)
      let target_at_current_level = target_parent == Some(node)
      let connects_siblings = source_at_current_level &&
        source_parent == target_parent
      let connects_to_graph = (source_at_current_level && target_node == node) ||
        (target_at_current_level && source_node == node)
      if (!connects_siblings && !connects_to_graph) || is_inside_self_loop {
        continue
      }
    }

    let source_lnode = match
      recursive_layered_endpoint_lnode(node, source_node, elk_to_lnode) {
      (Some(found), _) => Some(found)
      (None, _) => None
    }
    let target_lnode = match
      recursive_layered_endpoint_lnode(node, target_node, elk_to_lnode) {
      (Some(found), _) => Some(found)
      (None, _) => None
    }
    let edge_section = if @graph.edge_sections(edge).is_empty() {
      None
    } else {
      Some(@graph.edge_sections(edge)[0])
    }
    let source_port = match
      recursive_layered_edge_endpoint_port(source_shapes, elk_to_lport) {
      Some(found) => found
      None => {
        let source_parent_port = match source_shapes[0] {
          PortShape(parent_port) =>
            match @graph.port_parent(parent_port) {
              Some(parent_of_port) =>
                if parent_of_port == edge_parent_node {
                  Some(
                    recursive_layered_parent_port_lport(
                      edge_parent_node, parent_port, edge_direction_value, edge_parent_lgraph,
                      elk_to_lport,
                    ),
                  )
                } else {
                  None
                }
              None => None
            }
          _ => None
        }
        match source_parent_port {
          Some(found) => found
          None => {
            let source_lnode = match source_lnode {
              Some(found) => found
              None => return None
            }
            let mut source_point : @core.KVector? = None
            let mut source_port_type = PortType::Output
            match edge_section {
              Some(section) =>
                if recursive_layered_port_constraints_side_fixed(
                    source_lnode.get_property_string(@core.port_constraints),
                  ) {
                  source_point = Some(
                    recursive_layered_convert_edge_section_point_to_parent_coordinates(
                      edge,
                      edge_parent_node,
                      @graph.edge_section_start_x(section),
                      @graph.edge_section_start_y(section),
                    ),
                  )
                  if recursive_layered_is_descendant(target_node, source_node) {
                    source_port_type = PortType::Input
                    match source_point {
                      Some(point) => {
                        point.x = point.x + source_lnode.get_position().x
                        point.y = point.y + source_lnode.get_position().y
                      }
                      None => ()
                    }
                  }
                }
              None => ()
            }
            create_port_for_edge(
              source_lnode, source_point, source_port_type, edge_parent_lgraph,
            )
          }
        }
      }
    }
    let target_port = match
      recursive_layered_edge_endpoint_port(target_shapes, elk_to_lport) {
      Some(found) => found
      None => {
        let target_parent_port = match target_shapes[0] {
          PortShape(parent_port) =>
            match @graph.port_parent(parent_port) {
              Some(parent_of_port) =>
                if parent_of_port == edge_parent_node {
                  Some(
                    recursive_layered_parent_port_lport(
                      edge_parent_node, parent_port, edge_direction_value, edge_parent_lgraph,
                      elk_to_lport,
                    ),
                  )
                } else {
                  None
                }
              None => None
            }
          _ => None
        }
        match target_parent_port {
          Some(found) => found
          None => {
            let target_lnode = match target_lnode {
              Some(found) => found
              None => return None
            }
            let mut target_point : @core.KVector? = None
            match edge_section {
              Some(section) =>
                if recursive_layered_port_constraints_side_fixed(
                    target_lnode.get_property_string(@core.port_constraints),
                  ) {
                  target_point = Some(
                    recursive_layered_convert_edge_section_point_to_parent_coordinates(
                      edge,
                      edge_parent_node,
                      @graph.edge_section_end_x(section),
                      @graph.edge_section_end_y(section),
                    ),
                  )
                }
              None => ()
            }
            create_port_for_edge(
              target_lnode,
              target_point,
              PortType::Input,
              target_lnode.get_graph(),
            )
          }
        }
      }
    }

    let l_edge = new_l_edge()
    recursive_layered_copy_elk_edge_layout_options(edge, l_edge)
    match recursive_layered_model_order_edge_assignments.val.get(edge) {
      Some(model_order) =>
        l_edge.set_property_int(internal_properties_model_order, model_order)
      None => ()
    }
    l_edge.set_source(Some(source_port))
    l_edge.set_target(Some(target_port))
    if recursive_layered_ports_have_same_owner(source_port, target_port) {
      recursive_layered_add_graph_property(
        edge_parent_lgraph,
        GraphProperties::SelfLoops,
      )
    }
    if source_port.get_incoming_edges().length() > 1 ||
      source_port.get_outgoing_edges().length() > 1 ||
      target_port.get_incoming_edges().length() > 1 ||
      target_port.get_outgoing_edges().length() > 1 {
      recursive_layered_add_graph_property(
        edge_parent_lgraph,
        GraphProperties::Hyperedges,
      )
    }
    l_edge.set_property_l_graph(
      internal_properties_coordinate_system_origin,
      recursive_layered_find_coordinate_system_origin(
        edge, node, layered_graph, elk_to_lnode,
      ),
    )
    l_edge.set_property_int(
      recursive_layered_origin_elk_edge_handle_property, edge,
    )
    recursive_layered_global_ledge_to_elk_edge.val[l_edge.get_handle()] = edge

    for elk_label in @graph.edge_labels(edge) {
      let text = @graph.label_text(elk_label)
      if text.is_empty() {
        continue
      }
      let llabel = new_l_label_text(text)
      recursive_layered_copy_elk_label_layout_options(elk_label, llabel)
      llabel.get_size().x = @graph.label_width(elk_label)
      llabel.get_size().y = @graph.label_height(elk_label)
      llabel.get_position().x = @graph.label_x(elk_label)
      llabel.get_position().y = @graph.label_y(elk_label)
      let placement = recursive_layered_edge_label_placement(elk_label)
      llabel.set_property_string(@core.edge_labels_placement, placement)
      if recursive_layered_edge_label_inline(elk_label) is Some(inline) {
        llabel.set_property_bool(@core.edge_labels_inline, inline)
      }
      if recursive_layered_is_center_label_placement(placement) {
        recursive_layered_add_graph_property(
          edge_parent_lgraph,
          GraphProperties::CenterLabels,
        )
      } else {
        recursive_layered_add_graph_property(
          edge_parent_lgraph,
          GraphProperties::EndLabels,
        )
      }
      l_edge.get_labels().push(llabel)
    }
  }
  graph_configurator_configure_graph_properties(layered_graph)
  recursive_layered_normalize_port_constraints(layered_graph)

  Some({
    layered_graph,
    elk_to_lnode,
    elk_to_lport,
    node_label_pairs,
    lnode_to_elk,
  })
}

///|
fn recursive_layered_calculate_hierarchical_offset(
  edge : LEdge,
) -> @core.KVector {
  match
    edge.get_property_l_graph(internal_properties_coordinate_system_origin) {
    Some(target_coordinate_system) => {
      let source_port = match edge.get_source() {
        Some(value) => value
        None => return @core.new_kvector()
      }
      let source_node = match source_port.get_node() {
        Some(value) => value
        None => return @core.new_kvector()
      }
      let result = @core.new_kvector()
      let mut current_graph = source_node.get_graph()
      while current_graph.get_handle() != target_coordinate_system.get_handle() {
        let representing_node = match current_graph.get_parent_node() {
          Some(value) => value
          None => break
        }
        current_graph = representing_node.get_graph()
        let current_padding = current_graph.get_padding()
        ignore(result.add(representing_node.get_position()))
        ignore(result.add(current_graph.get_offset()))
        ignore(result.add_xy(current_padding.left, current_padding.top))
      }
      result
    }
    None => @core.new_kvector()
  }
}

///|
fn recursive_layered_apply_layout(
  context : RecursiveLayeredContext,
  parent_node : @graph.ElkNode,
) -> Unit {
  let graph_offset = context.layered_graph.get_offset()
  let graph_size = context.layered_graph.get_size()
  let padding_value = context.layered_graph.get_padding()
  let offset = @core.new_kvector_copy(graph_offset)
  ignore(offset.add_xy(padding_value.left, padding_value.top))
  let is_top_level_context = context.layered_graph.get_parent_node() is None

  for entry in context.elk_to_lnode.to_array() {
    let (elk_node, layered_node) = entry
    let position = layered_node.get_position()
    let size = layered_node.get_size()
    let resolved_width = if size.x > 0.0 {
      size.x
    } else {
      @graph.node_width(elk_node)
    }
    let resolved_height = if size.y > 0.0 {
      size.y
    } else {
      @graph.node_height(elk_node)
    }
    @graph.node_set_location(
      elk_node,
      position.x + offset.x,
      position.y + offset.y,
    )
    @graph.node_set_dimensions(elk_node, resolved_width, resolved_height)

    let node_has_label_placement = !layered_node
      .get_property_string_array(@core.node_labels_placement)
      .is_empty()
    match context.node_label_pairs.get(elk_node) {
      Some(mapped_labels) =>
        for mapped_label in mapped_labels {
          let (layered_label, elk_label) = mapped_label
          if node_has_label_placement ||
            !layered_label
            .get_property_string_array(@core.node_labels_placement)
            .is_empty() {
            @graph.label_set_dimensions(
              elk_label,
              layered_label.get_size().x,
              layered_label.get_size().y,
            )
            @graph.label_set_location(
              elk_label,
              layered_label.get_position().x,
              layered_label.get_position().y,
            )
          }
        }
      None => ()
    }
  }

  for entry in context.elk_to_lport.to_array() {
    let (elk_port, layered_port) = entry
    let owner_lnode = match layered_port.get_node() {
      Some(value) => value
      None => continue
    }

    let mut resolved_port_x = layered_port.get_position().x
    let mut resolved_port_y = layered_port.get_position().y
    let is_parent_port = match @graph.port_parent(elk_port) {
      Some(owner) => owner == parent_node
      None => false
    }
    if is_parent_port && !is_top_level_context {
      continue
    }
    if is_parent_port {
      let border_offset = recursive_layered_port_border_offset(elk_port)
      let mut ext_side = owner_lnode.get_property_port_side(
        internal_properties_ext_port_side,
      )
      match ext_side {
        @core.PortSide::SideUndefined =>
          ext_side = recursive_layered_port_side_from_string(
            recursive_layered_port_side_option(elk_port),
          )
        _ => ()
      }
      let owner_position = owner_lnode.get_position()
      let owner_size = owner_lnode.get_size()
      let port_width_value = @graph.port_width(elk_port)
      let port_height_value = @graph.port_height(elk_port)
      resolved_port_x = owner_position.x + owner_size.x / 2.0
      resolved_port_y = owner_position.y + owner_size.y / 2.0

      match ext_side {
        @core.PortSide::North => {
          resolved_port_x = resolved_port_x +
            padding_value.left +
            graph_offset.x -
            port_width_value / 2.0
          resolved_port_y = -port_height_value - border_offset
          owner_position.y = -(padding_value.top +
            border_offset +
            graph_offset.y)
        }
        @core.PortSide::East => {
          resolved_port_x = graph_size.x +
            padding_value.left +
            padding_value.right +
            border_offset
          resolved_port_y = resolved_port_y +
            padding_value.top +
            graph_offset.y -
            port_height_value / 2.0
          owner_position.x = graph_size.x +
            padding_value.right +
            border_offset -
            graph_offset.x
        }
        @core.PortSide::South => {
          resolved_port_x = resolved_port_x +
            padding_value.left +
            graph_offset.x -
            port_width_value / 2.0
          resolved_port_y = graph_size.y +
            padding_value.top +
            padding_value.bottom +
            border_offset
          owner_position.y = graph_size.y +
            padding_value.bottom +
            border_offset -
            graph_offset.y
        }
        @core.PortSide::West => {
          resolved_port_x = -port_width_value - border_offset
          resolved_port_y = resolved_port_y +
            padding_value.top +
            graph_offset.y -
            port_height_value / 2.0
          owner_position.x = -(padding_value.left +
            border_offset +
            graph_offset.x)
        }
        @core.PortSide::SideUndefined => {
          resolved_port_x = resolved_port_x + graph_offset.x
          resolved_port_y = resolved_port_y + graph_offset.y
        }
      }
    } else {
      match context.lnode_to_elk.get(owner_lnode.get_handle()) {
        Some(_) => ()
        None => {
          let owner_position = owner_lnode.get_position()
          let owner_size = owner_lnode.get_size()
          let border_offset = owner_lnode.get_property_double(
            recursive_layered_ext_port_border_offset_property,
          )
          let mut ext_side = owner_lnode.get_property_port_side(
            internal_properties_ext_port_side,
          )
          match ext_side {
            @core.PortSide::SideUndefined =>
              ext_side = recursive_layered_port_side_from_string(
                recursive_layered_port_side_option(elk_port),
              )
            _ => ()
          }
          let port_width_value = layered_port.get_size().x
          let port_height_value = layered_port.get_size().y

          resolved_port_x = owner_position.x + owner_size.x / 2.0
          resolved_port_y = owner_position.y + owner_size.y / 2.0

          match ext_side {
            @core.PortSide::North => {
              resolved_port_x = resolved_port_x +
                padding_value.left +
                graph_offset.x -
                port_width_value / 2.0
              resolved_port_y = -port_height_value - border_offset
              owner_position.y = -(padding_value.top +
                border_offset +
                graph_offset.y)
            }
            @core.PortSide::East => {
              resolved_port_x = graph_size.x +
                padding_value.left +
                padding_value.right +
                border_offset
              resolved_port_y = resolved_port_y +
                padding_value.top +
                graph_offset.y -
                port_height_value / 2.0
              owner_position.x = graph_size.x +
                padding_value.right +
                border_offset -
                graph_offset.x
            }
            @core.PortSide::South => {
              resolved_port_x = resolved_port_x +
                padding_value.left +
                graph_offset.x -
                port_width_value / 2.0
              resolved_port_y = graph_size.y +
                padding_value.top +
                padding_value.bottom +
                border_offset
              owner_position.y = graph_size.y +
                padding_value.bottom +
                border_offset -
                graph_offset.y
            }
            @core.PortSide::West => {
              resolved_port_x = -port_width_value - border_offset
              resolved_port_y = resolved_port_y +
                padding_value.top +
                graph_offset.y -
                port_height_value / 2.0
              owner_position.x = -(padding_value.left +
                border_offset +
                graph_offset.x)
            }
            @core.PortSide::SideUndefined => {
              resolved_port_x = owner_position.x +
                resolved_port_x +
                graph_offset.x
              resolved_port_y = owner_position.y +
                resolved_port_y +
                graph_offset.y
            }
          }
        }
      }
    }

    @graph.port_set_location(elk_port, resolved_port_x, resolved_port_y)
    let resolved_port_width = if is_parent_port {
      @graph.port_width(elk_port)
    } else {
      layered_port.get_size().x
    }
    let resolved_port_height = if is_parent_port {
      @graph.port_height(elk_port)
    } else {
      layered_port.get_size().y
    }
    @graph.port_set_dimensions(
      elk_port, resolved_port_width, resolved_port_height,
    )
  }

  let edge_list : Array[LEdge] = []
  let collected_edges : Map[Int, Bool] = {}
  for layered_node in context.layered_graph.get_layerless_nodes() {
    for port in layered_node.get_ports() {
      for layered_edge in port.get_outgoing_edges() {
        let target_port = match layered_edge.get_target() {
          Some(value) => value
          None => continue
        }
        let target_node = match target_port.get_node() {
          Some(value) => value
          None => continue
        }
        if !is_descendant_l_node(target_node, layered_node) {
          let edge_handle = layered_edge.get_handle()
          if !collected_edges.contains(edge_handle) {
            collected_edges[edge_handle] = true
            edge_list.push(layered_edge)
          }
        }
      }
    }
  }
  match context.layered_graph.get_parent_node() {
    Some(parent_lnode) =>
      for port in parent_lnode.get_ports() {
        for layered_edge in port.get_outgoing_edges() {
          let target_port = match layered_edge.get_target() {
            Some(value) => value
            None => continue
          }
          let target_node = match target_port.get_node() {
            Some(value) => value
            None => continue
          }
          if is_descendant_l_node(target_node, parent_lnode) {
            let edge_handle = layered_edge.get_handle()
            if !collected_edges.contains(edge_handle) {
              collected_edges[edge_handle] = true
              edge_list.push(layered_edge)
            }
          }
        }
      }
    None => ()
  }

  for layered_edge in edge_list {
    let elk_edge = if layered_edge.has_property_int(
        recursive_layered_origin_elk_edge_handle_property,
      ) {
      layered_edge.get_property_int(
        recursive_layered_origin_elk_edge_handle_property,
      )
    } else {
      match
        recursive_layered_global_ledge_to_elk_edge.val.get(
          layered_edge.get_handle(),
        ) {
        Some(value) => value
        None => continue
      }
    }
    ensure_edge_section_for_edge(elk_edge)
    if @graph.edge_sections(elk_edge).is_empty() {
      continue
    }
    let section = @graph.edge_sections(elk_edge)[0]
    let source_port = match layered_edge.get_source() {
      Some(value) => value
      None => continue
    }
    let target_port = match layered_edge.get_target() {
      Some(value) => value
      None => continue
    }
    let source_node = match source_port.get_node() {
      Some(value) => value
      None => continue
    }
    let target_node = match target_port.get_node() {
      Some(value) => value
      None => continue
    }
    let hierarchical_offset = recursive_layered_calculate_hierarchical_offset(
      layered_edge,
    )
    let offset_for_edge = @core.new_kvector_copy(offset)
    let edge_offset = @core.new_kvector_copy(offset_for_edge)
    ignore(edge_offset.add(hierarchical_offset))
    @graph.edge_clear_junction_points(elk_edge)
    if layered_edge.has_property_kvector_chain(layered_options_junction_points) {
      let junction_points = layered_edge.get_property_kvector_chain(
        layered_options_junction_points,
      )
      for junction_point in junction_points.to_array() {
        let transformed = @core.new_kvector_copy(junction_point)
        ignore(transformed.add(edge_offset))
        @graph.edge_add_junction_point(
          elk_edge,
          @graph.new_elk_bend_point(x=transformed.x, y=transformed.y),
        )
      }
    }

    let source_point = if is_descendant_l_node(target_node, source_node) {
      let point = @core.new_kvector_copy(source_port.get_position())
      ignore(point.add(source_port.get_anchor()))
      ignore(point.sub(offset))
      point
    } else {
      source_port.get_absolute_anchor()
    }
    let target_point = target_port.get_absolute_anchor()
    if layered_edge.has_property_kvector(internal_properties_target_offset) {
      ignore(
        target_point.add(
          layered_edge.get_property_kvector(internal_properties_target_offset),
        ),
      )
    }
    let bend_points = @core.new_kvector_chain_copy(
      layered_edge.get_bend_points(),
    )
    bend_points.add_first_vector(source_point)
    bend_points.add_last_vector(target_point)
    ignore(bend_points.offset(edge_offset))

    let edge_sources = @graph.edge_sources(elk_edge)
    if edge_sources.length() == 1 {
      @graph.edge_section_set_incoming_shape(section, Some(edge_sources[0]))
    }
    let edge_targets = @graph.edge_targets(elk_edge)
    if edge_targets.length() == 1 {
      @graph.edge_section_set_outgoing_shape(section, Some(edge_targets[0]))
    }
    let bend_points_array = bend_points.to_array()
    if bend_points_array.length() < 2 {
      continue
    }
    @graph.edge_section_set_start(
      section,
      bend_points_array[0].x,
      bend_points_array[0].y,
    )
    @graph.edge_section_set_end(
      section,
      bend_points_array[bend_points_array.length() - 1].x,
      bend_points_array[bend_points_array.length() - 1].y,
    )
    @graph.edge_section_clear_bend_points(section)
    let mut bend_index = 1
    while bend_index + 1 < bend_points_array.length() {
      let bend_point = bend_points_array[bend_index]
      @graph.edge_section_add_bend_point(
        section,
        @graph.new_elk_bend_point(x=bend_point.x, y=bend_point.y),
      )
      bend_index += 1
    }
    let layered_labels = layered_edge.get_labels()
    let mut layered_label_index = 0
    for elk_label in @graph.edge_labels(elk_edge) {
      if @graph.label_text(elk_label).is_empty() {
        continue
      }
      if layered_label_index >= layered_labels.length() {
        break
      }
      let layered_label = layered_labels[layered_label_index]
      layered_label_index += 1
      @graph.label_set_dimensions(
        elk_label,
        layered_label.get_size().x,
        layered_label.get_size().y,
      )
      @graph.label_set_location(
        elk_label,
        layered_label.get_position().x + edge_offset.x,
        layered_label.get_position().y + edge_offset.y,
      )
    }
  }

  if is_top_level_context {
    let actual_graph_size = context.layered_graph.get_actual_size()
    let has_external_ports = recursive_layered_has_graph_property(
      context.layered_graph,
      GraphProperties::ExternalPorts,
    )
    if has_external_ports {
      @graph.node_set_string_property(
        parent_node, @core.port_constraints, "FIXED_POS",
      )
      @graph.node_set_dimensions(
        parent_node,
        actual_graph_size.x,
        actual_graph_size.y,
      )
    } else if !@graph.node_get_bool_property(
        parent_node, @core.node_size_fixed_graph_size,
      ) {
      @graph.node_set_dimensions(
        parent_node,
        actual_graph_size.x,
        actual_graph_size.y,
      )
    }
  }
  let mut size_constraints_include_port_labels = false
  for
    constraint in @graph.node_get_string_set_property(
      parent_node, @core.node_size_constraints,
    ) {
    if constraint == "PORT_LABELS" {
      size_constraints_include_port_labels = true
      break
    }
  }
  if size_constraints_include_port_labels {
    @graph.node_set_string_set_property(
      parent_node,
      @core.node_size_constraints,
      ["PORT_LABELS"],
    )
  } else {
    @graph.node_set_string_set_property(
      parent_node,
      @core.node_size_constraints,
      [],
    )
  }

  for entry in context.elk_to_lnode.to_array() {
    let (_, layered_node) = entry
    match layered_node.get_nested_graph() {
      Some(nested_graph) =>
        ignore(recursive_layered_apply_transformed_graph(nested_graph))
      None => ()
    }
  }
}

///|
