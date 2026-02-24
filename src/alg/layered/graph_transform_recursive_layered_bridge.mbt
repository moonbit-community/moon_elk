///|
fn max_positive(value : Double, fallback : Double) -> Double {
  if value > 0.0 {
    value
  } else {
    fallback
  }
}

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
fn has_placement_token(tokens : Array[String], expected : String) -> Bool {
  for token in tokens {
    if token == expected {
      return true
    }
  }
  false
}

///|
fn node_label_padding(node : @graph.ElkNode) -> @core.ElkPadding {
  let keys = [
    "nodeLabels.padding", "elk.nodeLabels.padding", "org.eclipse.elk.nodeLabels.padding",
  ]
  let padding_text = match
    node_individual_spacing_value_by_candidates(node, keys) {
    Some(value) => value
    None =>
      match node_layout_option_value_by_candidates_with_ancestors(node, keys) {
        Some(value) => value
        None => recursive_layered_node_labels_padding_property.get_default()
      }
  }
  let parsed = @core.new_elk_padding()
  parsed.parse(padding_text)
  parsed
}

///|
fn recursive_layout_node_has_size_constraint(
  node : @graph.ElkNode,
  constraint : String,
) -> Bool {
  for
    value in @graph.node_get_string_set_property(
      node, @core.node_size_constraints,
    ) {
    if value == constraint {
      return true
    }
  }
  false
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
        let parsed : Result[Double, @strconv.StrConvError] = try? @strconv.parse_double(
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
fn recursive_layout_node_labels(node : @graph.ElkNode) -> Unit {
  let keys = [
    "nodeLabels.placement", "elk.nodeLabels.placement", "org.eclipse.elk.nodeLabels.placement",
  ]
  let tokens = match node_layout_option_value_by_candidates(node, keys) {
    Some(value) => placement_tokens(value)
    None =>
      if @graph.node_has_string_set_property(node, @core.node_labels_placement) {
        @graph.node_get_string_set_property(node, @core.node_labels_placement)
      } else {
        return
      }
  }
  if !(has_placement_token(tokens, "INSIDE") &&
    has_placement_token(tokens, "V_TOP")) {
    return
  }
  let labels = @graph.node_labels(node)
  if labels.is_empty() {
    return
  }

  let padding_value = node_label_padding(node)
  let has_label_size_constraint = recursive_layout_node_has_size_constraint(
    node, "NODE_LABELS",
  )
  let horizontal_center = has_placement_token(tokens, "H_CENTER")

  if has_label_size_constraint {
    let mut max_label_width = 0.0
    let mut max_label_height = 0.0
    for label in labels {
      let width = @graph.label_width(label)
      let height = @graph.label_height(label)
      if width > max_label_width {
        max_label_width = width
      }
      if height > max_label_height {
        max_label_height = height
      }
    }

    let expected_width = padding_value.left +
      max_label_width +
      padding_value.right
    let expected_height = padding_value.top +
      max_label_height +
      padding_value.bottom
    let next_width = if @graph.node_width(node) < expected_width {
      expected_width
    } else {
      @graph.node_width(node)
    }
    let next_height = if @graph.node_height(node) < expected_height {
      expected_height
    } else {
      @graph.node_height(node)
    }
    @graph.node_set_dimensions(node, next_width, next_height)
  }

  let content_width = max_positive(
    @graph.node_width(node) - padding_value.left - padding_value.right,
    0.0,
  )
  for label in labels {
    let next_x = if horizontal_center {
      padding_value.left + (content_width - @graph.label_width(label)) / 2.0
    } else {
      @graph.label_x(label)
    }
    @graph.label_set_location(label, next_x, padding_value.top)
  }
}

///|
fn recursive_layout_label_top_reserve(node : @graph.ElkNode) -> Double {
  let mut reserve = 0.0
  for label in @graph.node_labels(node) {
    let bottom = @graph.label_y(label) + @graph.label_height(label)
    if bottom > reserve {
      reserve = bottom
    }
  }
  reserve
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
  edge_to_ledge : Map[@graph.ElkEdge, LEdge]
}

///|
let recursive_layered_transform_context_next_id : Ref[Int] = Ref::new(1)

///|
let recursive_layered_transform_context_store : Ref[
  Map[Int, (RecursiveLayeredContext, @graph.ElkNode)],
] = Ref::new({})

///|
let recursive_layered_transform_context_property : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.layered.recursive.contextId", -1,
)

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
  match recursive_layered_create_context(parent_node) {
    Some(context) =>
      Some(recursive_layered_transform_register_context(context, parent_node))
    None => None
  }
}

///|
pub fn recursive_layered_apply_transformed_graph(
  layered_graph : LGraph,
) -> Bool {
  let context_id = layered_graph.get_id()
  let use_primary_context = recursive_layered_transform_context_store.val.contains(
    context_id,
  )
  let fallback_context_id = layered_graph.get_property_int(
    recursive_layered_transform_context_property,
  )
  let resolved_context_id = if use_primary_context {
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
        let parsed : Result[Double, @strconv.StrConvError] = try? @strconv.parse_double(
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
  match
    @graph.label_layout_option_string_value(
      elk_label,
      @core.edge_labels_placement.get_id(),
    ) {
    Some(value) => value
    None => @core.edge_labels_placement.get_default()
  }
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
fn recursive_layered_nodes_share_parent(
  source : @graph.ElkNode,
  target : @graph.ElkNode,
) -> Bool {
  match (@graph.node_parent(source), @graph.node_parent(target)) {
    (Some(source_parent), Some(target_parent)) => source_parent == target_parent
    (None, None) => true
    _ => false
  }
}

///|
fn recursive_layered_find_coordinate_system_origin(
  edge : @graph.ElkEdge,
  top_level_elk_graph : @graph.ElkNode,
  top_level_l_graph : LGraph,
  elk_to_lnode : Map[@graph.ElkNode, LNode],
) -> LGraph? {
  let source_shapes = @graph.edge_sources(edge)
  if source_shapes.is_empty() {
    return None
  }
  let target_shapes = @graph.edge_targets(edge)
  if target_shapes.is_empty() {
    return None
  }
  let source = match recursive_layered_edge_endpoint_node(source_shapes) {
    Some(value) => value
    None => return None
  }
  let target = match recursive_layered_edge_endpoint_node(target_shapes) {
    Some(value) => value
    None => return None
  }

  if recursive_layered_nodes_share_parent(source, target) {
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
    return Some(top_level_l_graph)
  }
  match elk_to_lnode.get(origin) {
    Some(origin_lnode) => origin_lnode.get_nested_graph()
    None => None
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
          dummy.get_size().y = port_size.y
          if border_offset < 0.0 {
            dummy.get_size().x = -border_offset
          }
          lport.set_side(@core.PortSide::West)
          anchor.x = 0.0
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
          anchor.y = 0.0
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
fn recursive_layered_needs_model_order(
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

  let allow_ancestor_lookup = key == "org.eclipse.elk.hierarchyHandling" ||
    key == "elk.hierarchyHandling" ||
    key == "hierarchyHandling"

  let mut matched_fallback_value : String? = None
  for candidate in candidates {
    let value_at_candidate = if allow_ancestor_lookup {
      node_layout_option_value_by_candidates_with_ancestors(node, [candidate])
    } else {
      @graph.node_layout_option_string_value(node, candidate)
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
  let parsed : Result[Int, @strconv.StrConvError] = try? @strconv.parse_int(
    value.trim().to_string(),
  )
  match parsed {
    Ok(result) => Some(result)
    Err(_) => None
  }
}

///|
fn recursive_layered_parse_double(value : String) -> Double? {
  let parsed : Result[Double, @strconv.StrConvError] = try? @strconv.parse_double(
    value.trim().to_string(),
  )
  match parsed {
    Ok(result) => Some(result)
    Err(_) => None
  }
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
fn recursive_layered_node_hierarchy_handling_value(
  node : @graph.ElkNode,
) -> String {
  recursive_layered_primary_option(
    node,
    "org.eclipse.elk.hierarchyHandling",
    @graph.node_get_string_property(node, layered_options_hierarchy_handling),
  )
}

///|
fn recursive_layered_node_uses_elk_layered(node : @graph.ElkNode) -> Bool {
  let configured_algorithm = match
    @graph.node_layout_option_string_value(node, @core.algorithm.get_id()) {
    Some(value) => value
    None =>
      if @graph.node_has_string_property(node, @core.algorithm) {
        @graph.node_get_string_property(node, @core.algorithm)
      } else {
        ""
      }
  }
  configured_algorithm.is_empty() ||
  layered_algorithm_id.has_suffix(configured_algorithm)
}

///|
fn recursive_layered_edge_is_self_loop(edge : @graph.ElkEdge) -> Bool {
  let source_shapes = @graph.edge_sources(edge)
  if source_shapes.length() != 1 {
    return false
  }
  let target_shapes = @graph.edge_targets(edge)
  if target_shapes.length() != 1 {
    return false
  }
  match recursive_layered_edge_endpoint_node(source_shapes) {
    Some(source_node) =>
      match recursive_layered_edge_endpoint_node(target_shapes) {
        Some(target_node) => source_node == target_node
        None => false
      }
    None => false
  }
}

///|
fn recursive_layered_edge_inside_self_loops_yo(edge : @graph.ElkEdge) -> Bool {
  match
    @graph.edge_layout_option_string_value(
      edge, "org.eclipse.elk.insideSelfLoops.yo",
    ) {
    Some(raw_value) =>
      match recursive_layered_parse_bool(raw_value.trim().to_string()) {
        Some(value) => value
        None => false
      }
    None => false
  }
}

///|
fn recursive_layered_edge_no_layout(edge : @graph.ElkEdge) -> Bool {
  match @graph.edge_layout_option_string_value(edge, @core.no_layout.get_id()) {
    Some(raw_value) =>
      match recursive_layered_parse_bool(raw_value.trim().to_string()) {
        Some(value) => value
        None => false
      }
    None => false
  }
}

///|
fn recursive_layered_node_has_inside_self_loops(node : @graph.ElkNode) -> Bool {
  if !@graph.node_get_bool_property(node, @core.inside_self_loops_activate) {
    return false
  }
  for edge in @graph.all_outgoing_edges(node) {
    if recursive_layered_edge_is_self_loop(edge) &&
      recursive_layered_edge_inside_self_loops_yo(edge) {
      return true
    }
  }
  false
}

///|
fn recursive_layered_edge_section_point_relative_to_parent(
  edge : @graph.ElkEdge,
  parent_node : @graph.ElkNode,
  edge_section : @graph.ElkEdgeSection,
  source? : Bool = true,
) -> @core.KVector {
  let point = if source {
    @core.new_kvector_xy(
      @graph.edge_section_start_x(edge_section),
      @graph.edge_section_start_y(edge_section),
    )
  } else {
    @core.new_kvector_xy(
      @graph.edge_section_end_x(edge_section),
      @graph.edge_section_end_y(edge_section),
    )
  }
  match @graph.edge_containing_node(edge) {
    Some(containing_node) => {
      point.x = point.x +
        recursive_layered_absolute_node_x(containing_node) -
        recursive_layered_absolute_node_x(parent_node)
      point.y = point.y +
        recursive_layered_absolute_node_y(containing_node) -
        recursive_layered_absolute_node_y(parent_node)
    }
    None => ()
  }
  point
}

///|
fn recursive_layered_collect_all_graphs(root : LGraph) -> Array[LGraph] {
  let graphs : Array[LGraph] = [root]
  let mut graph_index = 0
  while graph_index < graphs.length() {
    let graph = graphs[graph_index]
    graph_index += 1
    for node in graph.get_layerless_nodes() {
      match node.get_nested_graph() {
        Some(nested_graph) => graphs.push(nested_graph)
        None => ()
      }
    }
  }
  graphs
}

///|
fn recursive_layered_create_context(
  node : @graph.ElkNode,
) -> RecursiveLayeredContext? {
  let layered_graph = new_l_graph()
  let elk_to_lnode : Map[@graph.ElkNode, LNode] = {}
  let elk_to_lport : Map[@graph.ElkPort, LPort] = {}
  let node_label_pairs : Map[@graph.ElkNode, Array[(LLabel, @graph.ElkLabel)]] = {}
  let lnode_to_elk : Map[Int, @graph.ElkNode] = {}
  let edge_to_ledge : Map[@graph.ElkEdge, LEdge] = {}
  recursive_layout_node_labels(node)
  let node_padding = parse_node_padding(node)
  let label_top_reserve = recursive_layout_label_top_reserve(node)
  let graph_padding = layered_graph.get_padding()
  graph_padding.left = node_padding.left
  graph_padding.right = node_padding.right
  graph_padding.bottom = node_padding.bottom
  graph_padding.top = if label_top_reserve > node_padding.top {
    label_top_reserve
  } else {
    node_padding.top
  }

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
    node, @core.aspect_ratio,
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
  let edge_routing_value = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.edgeRouting",
    @graph.node_get_string_property(node, @core.edge_routing),
  )
  let direction_value = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.direction",
    @graph.node_get_string_property(node, @core.direction),
  )
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
  let hierarchical_layout = hierarchy_handling == "INCLUDE_CHILDREN"
  let needs_model_order = recursive_layered_needs_model_order(
    cycle_breaking_strategy, layering_strategy, node_promotion_strategy, consider_model_order,
  )

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
    layered_options_spacing_node_node_between_layers,
    if spacing_between_layers > 0.0 {
      spacing_between_layers
    } else {
      layered_options_spacing_node_node_between_layers.get_default()
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
    @core.aspect_ratio,
    if aspect_ratio_value > 0.0 {
      aspect_ratio_value
    } else {
      1.6
    },
  )
  layered_graph.set_property_int(@core.random_seed, random_seed_value)
  layered_graph.set_property_string(
    layered_options_cycle_breaking_strategy, cycle_breaking_strategy,
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
  layered_graph.set_property_string(
    @core.edge_routing,
    if edge_routing_value == "UNDEFINED" || edge_routing_value.is_empty() {
      "ORTHOGONAL"
    } else {
      edge_routing_value
    },
  )
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

  layered_graph.set_property_int(internal_properties_max_model_order_nodes, 0)
  let node_queue = @graph.node_children(node).copy()
  let mut node_queue_index = 0
  while node_queue_index < node_queue.length() {
    let child = node_queue[node_queue_index]
    node_queue_index += 1
    if @graph.node_get_bool_property(child, @core.no_layout) {
      continue
    }

    let mut parent_lgraph = layered_graph
    match @graph.node_parent(child) {
      Some(parent_node) =>
        match elk_to_lnode.get(parent_node) {
          Some(parent_lnode) =>
            match parent_lnode.get_nested_graph() {
              Some(nested_parent_graph) => parent_lgraph = nested_parent_graph
              None => ()
            }
          None => ()
        }
      None => ()
    }

    let has_children = !@graph.node_children(child).is_empty()
    let has_inside_self_loops = recursive_layered_node_has_inside_self_loops(
      child,
    )
    let child_hierarchy_handling = recursive_layered_node_hierarchy_handling_value(
      child,
    )
    let child_uses_elk_layered = recursive_layered_node_uses_elk_layered(child)

    let mut nested_graph : LGraph? = None
    if child_uses_elk_layered &&
      child_hierarchy_handling == "INCLUDE_CHILDREN" &&
      (has_children || has_inside_self_loops) {
      let created_nested_graph = new_l_graph()
      created_nested_graph.copy_properties(layered_graph)
      created_nested_graph.set_property_string(@core.direction, direction_value)
      created_nested_graph.set_property_graph_properties_array(
        internal_properties_graph_properties,
        [],
      )
      created_nested_graph.set_property_int(
        internal_properties_cb_num_model_order_groups, 0,
      )
      created_nested_graph.set_property_int(
        internal_properties_max_model_order_nodes, 0,
      )
      let child_padding = parse_node_padding(child)
      let child_label_top_reserve = recursive_layout_label_top_reserve(child)
      let nested_padding = created_nested_graph.get_padding()
      nested_padding.left = child_padding.left
      nested_padding.right = child_padding.right
      nested_padding.bottom = child_padding.bottom
      nested_padding.top = if child_label_top_reserve > child_padding.top {
        child_label_top_reserve
      } else {
        child_padding.top
      }
      nested_graph = Some(created_nested_graph)
    }

    let lnode = new_l_node(graph=Some(parent_lgraph))
    lnode.get_size().x = @graph.node_width(child)
    lnode.get_size().y = @graph.node_height(child)
    lnode.get_position().x = @graph.node_x(child)
    lnode.get_position().y = @graph.node_y(child)
    if has_children ||
      @graph.node_get_bool_property(child, @core.inside_self_loops_activate) {
      lnode.set_property_bool(internal_properties_compound_node, true)
    }

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
        parent_lgraph,
        GraphProperties::NonFreePorts,
      )
    }
    if needs_model_order {
      let current_model_order = parent_lgraph.get_property_int(
        internal_properties_max_model_order_nodes,
      )
      lnode.set_property_int(
        internal_properties_model_order, current_model_order,
      )
      parent_lgraph.set_property_int(
        internal_properties_max_model_order_nodes,
        current_model_order + 1,
      )
    }

    let graph_node = match @graph.node_parent(child) {
      Some(parent) => parent
      None => node
    }
    recursive_layered_copy_nodespacing_options(graph_node, child, lnode)

    let node_label_pairs_for_child : Array[(LLabel, @graph.ElkLabel)] = []
    for elk_label in @graph.node_labels(child) {
      let text = @graph.label_text(elk_label)
      if text.is_empty() {
        continue
      }
      let llabel = new_l_label_text(text)
      llabel.get_size().x = @graph.label_width(elk_label)
      llabel.get_size().y = @graph.label_height(elk_label)
      llabel.get_position().x = @graph.label_x(elk_label)
      llabel.get_position().y = @graph.label_y(elk_label)
      lnode.get_labels().push(llabel)
      node_label_pairs_for_child.push((llabel, elk_label))
    }

    let mut port_model_order = 0
    for elk_port in @graph.node_ports(child) {
      let lport = new_l_port()
      lport.set_node(Some(lnode))
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
            let parsed_port_index : Result[Int, @strconv.StrConvError] = try? @strconv.parse_int(
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
        get_direction(parent_lgraph),
        explicit_anchor,
      )
      if recursive_layered_is_north_south_side(lport.get_side()) {
        recursive_layered_add_graph_property(
          parent_lgraph,
          GraphProperties::NorthSouthPorts,
        )
      }
      if needs_model_order {
        lport.set_property_int(
          internal_properties_model_order, port_model_order,
        )
        port_model_order += 1
      }
      elk_to_lport[elk_port] = lport
    }

    if nested_graph is Some(created_nested_graph) {
      lnode.set_nested_graph(Some(created_nested_graph))
      created_nested_graph.set_parent_node(Some(lnode))
      for nested_child in @graph.node_children(child) {
        node_queue.push(nested_child)
      }
    }

    node_label_pairs[child] = node_label_pairs_for_child
    parent_lgraph.get_layerless_nodes().push(lnode)
    elk_to_lnode[child] = lnode
    lnode_to_elk[lnode.get_handle()] = child
  }

  let edge_graph_queue : Array[@graph.ElkNode] = [node]
  let mut edge_graph_queue_index = 0
  let mut edge_model_order = 0
  while edge_graph_queue_index < edge_graph_queue.length() {
    let edge_graph_node = edge_graph_queue[edge_graph_queue_index]
    edge_graph_queue_index += 1

    for edge in @graph.node_contained_edges(edge_graph_node) {
      let source_shapes = @graph.edge_sources(edge)
      if source_shapes.is_empty() {
        continue
      }
      let target_shapes = @graph.edge_targets(edge)
      if target_shapes.is_empty() {
        continue
      }
      let source_node = match
        recursive_layered_edge_endpoint_node(source_shapes) {
        Some(value) => value
        None => continue
      }
      let target_node = match
        recursive_layered_edge_endpoint_node(target_shapes) {
        Some(value) => value
        None => continue
      }
      if recursive_layered_edge_no_layout(edge) ||
        @graph.node_get_bool_property(source_node, @core.no_layout) ||
        @graph.node_get_bool_property(target_node, @core.no_layout) {
        continue
      }

      let is_inside_self_loop = recursive_layered_edge_is_self_loop(edge) &&
        @graph.node_get_bool_property(
          source_node, @core.inside_self_loops_activate,
        ) &&
        recursive_layered_edge_inside_self_loops_yo(edge)

      let mut parent_elk_graph = edge_graph_node
      if is_inside_self_loop ||
        recursive_layered_is_descendant(target_node, source_node) {
        parent_elk_graph = source_node
      } else if recursive_layered_is_descendant(source_node, target_node) {
        parent_elk_graph = target_node
      }

      let mut parent_lgraph = layered_graph
      match elk_to_lnode.get(parent_elk_graph) {
        Some(parent_lnode) =>
          match parent_lnode.get_nested_graph() {
            Some(nested_graph) => parent_lgraph = nested_graph
            None => ()
          }
        None => ()
      }

      let source_lnode = match elk_to_lnode.get(source_node) {
        Some(value) => value
        None => continue
      }
      let target_lnode = match elk_to_lnode.get(target_node) {
        Some(value) => value
        None => continue
      }

      let mut source_port : LPort? = None
      match source_shapes[0] {
        PortShape(elk_source_port) =>
          match elk_to_lport.get(elk_source_port) {
            Some(mapped_source_port) => source_port = Some(mapped_source_port)
            None =>
              match @graph.port_parent(elk_source_port) {
                Some(source_port_parent) =>
                  if source_port_parent == parent_elk_graph {
                    source_port = Some(
                      recursive_layered_parent_port_lport(
                        parent_elk_graph, elk_source_port, direction_value, parent_lgraph,
                        elk_to_lport,
                      ),
                    )
                  }
                None => ()
              }
          }
        _ => ()
      }
      if source_port is None {
        let mut port_type = PortType::Output
        let mut source_point : @core.KVector? = None
        let edge_sections = @graph.edge_sections(edge)
        if !edge_sections.is_empty() &&
          recursive_layered_port_constraints_side_fixed(
            source_lnode.get_property_string(@core.port_constraints),
          ) {
          let point = recursive_layered_edge_section_point_relative_to_parent(
            edge,
            parent_elk_graph,
            edge_sections[0],
          )
          if recursive_layered_is_descendant(target_node, source_node) {
            port_type = PortType::Input
            point.x = point.x + source_lnode.get_position().x
            point.y = point.y + source_lnode.get_position().y
          }
          source_point = Some(point)
        }
        source_port = Some(
          create_port_for_edge(
            source_lnode, source_point, port_type, parent_lgraph,
          ),
        )
      }

      let mut target_port : LPort? = None
      match target_shapes[0] {
        PortShape(elk_target_port) =>
          match elk_to_lport.get(elk_target_port) {
            Some(mapped_target_port) => target_port = Some(mapped_target_port)
            None =>
              match @graph.port_parent(elk_target_port) {
                Some(target_port_parent) =>
                  if target_port_parent == parent_elk_graph {
                    target_port = Some(
                      recursive_layered_parent_port_lport(
                        parent_elk_graph, elk_target_port, direction_value, parent_lgraph,
                        elk_to_lport,
                      ),
                    )
                  }
                None => ()
              }
          }
        _ => ()
      }
      if target_port is None {
        let mut target_point : @core.KVector? = None
        let edge_sections = @graph.edge_sections(edge)
        if !edge_sections.is_empty() &&
          recursive_layered_port_constraints_side_fixed(
            target_lnode.get_property_string(@core.port_constraints),
          ) {
          target_point = Some(
            recursive_layered_edge_section_point_relative_to_parent(
              edge,
              parent_elk_graph,
              edge_sections[0],
              source=false,
            ),
          )
        }
        target_port = Some(
          create_port_for_edge(
            target_lnode,
            target_point,
            PortType::Input,
            target_lnode.get_graph(),
          ),
        )
      }

      let source_port = match source_port {
        Some(value) => value
        None => continue
      }
      let target_port = match target_port {
        Some(value) => value
        None => continue
      }

      let l_edge = new_l_edge()
      l_edge.set_source(Some(source_port))
      l_edge.set_target(Some(target_port))
      if recursive_layered_ports_have_same_owner(source_port, target_port) {
        recursive_layered_add_graph_property(
          parent_lgraph,
          GraphProperties::SelfLoops,
        )
      }
      if needs_model_order {
        l_edge.set_property_int(
          internal_properties_model_order, edge_model_order,
        )
        edge_model_order += 1
      }
      l_edge.set_property_double(
        @core.edge_thickness,
        @core.edge_thickness.get_default(),
      )

      if source_port.get_incoming_edges().length() > 1 ||
        source_port.get_outgoing_edges().length() > 1 ||
        target_port.get_incoming_edges().length() > 1 ||
        target_port.get_outgoing_edges().length() > 1 {
        recursive_layered_add_graph_property(
          parent_lgraph,
          GraphProperties::Hyperedges,
        )
      }

      for elk_label in @graph.edge_labels(edge) {
        let text = @graph.label_text(elk_label)
        if text.is_empty() {
          continue
        }
        let llabel = new_l_label_text(text)
        llabel.get_size().x = @graph.label_width(elk_label)
        llabel.get_size().y = @graph.label_height(elk_label)
        llabel.get_position().x = @graph.label_x(elk_label)
        llabel.get_position().y = @graph.label_y(elk_label)
        let placement = recursive_layered_edge_label_placement(elk_label)
        llabel.set_property_string(@core.edge_labels_placement, placement)
        if recursive_layered_is_center_label_placement(placement) {
          recursive_layered_add_graph_property(
            parent_lgraph,
            GraphProperties::CenterLabels,
          )
        } else {
          recursive_layered_add_graph_property(
            parent_lgraph,
            GraphProperties::EndLabels,
          )
        }
        l_edge.get_labels().push(llabel)
      }

      match
        recursive_layered_find_coordinate_system_origin(
          edge, node, layered_graph, elk_to_lnode,
        ) {
        Some(origin_graph) =>
          l_edge.set_property_l_graph(
            internal_properties_coordinate_system_origin,
            Some(origin_graph),
          )
        None => ()
      }

      edge_to_ledge[edge] = l_edge
    }

    if hierarchical_layout &&
      recursive_layered_node_hierarchy_handling_value(edge_graph_node) ==
      "INCLUDE_CHILDREN" {
      for child_graph_node in @graph.node_children(edge_graph_node) {
        if recursive_layered_node_uses_elk_layered(child_graph_node) &&
          recursive_layered_node_hierarchy_handling_value(child_graph_node) ==
          "INCLUDE_CHILDREN" {
          edge_graph_queue.push(child_graph_node)
        }
      }
    }
  }

  for imported_graph in recursive_layered_collect_all_graphs(layered_graph) {
    recursive_layered_normalize_port_constraints(imported_graph)
  }

  Some({
    layered_graph,
    elk_to_lnode,
    elk_to_lport,
    node_label_pairs,
    lnode_to_elk,
    edge_to_ledge,
  })
}

///|
fn recursive_layered_graph_signature(graph : LGraph) -> Array[Int] {
  let path : Array[Int] = []
  let mut current_graph = graph
  while true {
    match current_graph.get_parent_node() {
      Some(parent_node) => {
        path.push(parent_node.get_handle())
        current_graph = parent_node.get_graph()
      }
      None => break
    }
  }
  let signature : Array[Int] = []
  for i in 0..<path.length() {
    signature.push(path[path.length() - 1 - i])
  }
  signature
}

///|
fn recursive_layered_graph_signature_equals(
  left : Array[Int],
  right : Array[Int],
) -> Bool {
  if left.length() != right.length() {
    return false
  }
  for i in 0..<left.length() {
    if left[i] != right[i] {
      return false
    }
  }
  true
}

///|
fn recursive_layered_calculate_hierarchical_offset(
  layered_edge : LEdge,
) -> @core.KVector {
  match
    layered_edge.get_property_l_graph(
      internal_properties_coordinate_system_origin,
    ) {
    Some(target_coordinate_system) => {
      let result = @core.new_kvector()
      let source_port = match layered_edge.get_source() {
        Some(value) => value
        None => return result
      }
      let source_node = match source_port.get_node() {
        Some(value) => value
        None => return result
      }
      let target_signature = recursive_layered_graph_signature(
        target_coordinate_system,
      )

      let mut current_graph = source_node.get_graph()
      while true {
        let current_signature = recursive_layered_graph_signature(current_graph)
        if recursive_layered_graph_signature_equals(
            current_signature, target_signature,
          ) {
          break
        }
        let representing_node = match current_graph.get_parent_node() {
          Some(value) => value
          None => break
        }
        let upper_graph = representing_node.get_graph()
        ignore(result.add(representing_node.get_position()))
        ignore(result.add(upper_graph.get_offset()))
        ignore(
          result.add_xy(
            upper_graph.get_padding().left,
            upper_graph.get_padding().top,
          ),
        )
        current_graph = upper_graph
      }

      result
    }
    None => @core.new_kvector()
  }
}

///|
fn recursive_layered_apply_vector_chain_to_edge(
  vector_chain : @core.KVectorChain,
  edge : @graph.ElkEdge,
) -> Unit {
  if vector_chain.size() < 2 {
    return
  }

  ensure_edge_section_for_edge(edge)
  if @graph.edge_sections(edge).is_empty() {
    return
  }
  let section = @graph.edge_sections(edge)[0]

  let first_point = vector_chain.get(0)
  @graph.edge_section_set_start(section, first_point.x, first_point.y)
  let last_point = vector_chain.get(vector_chain.size() - 1)
  @graph.edge_section_set_end(section, last_point.x, last_point.y)

  @graph.edge_section_clear_bend_points(section)
  for i in 1..<(vector_chain.size() - 1) {
    let middle_point = vector_chain.get(i)
    @graph.edge_section_add_bend_point(
      section,
      @graph.new_elk_bend_point(x=middle_point.x, y=middle_point.y),
    )
  }
}

///|
fn recursive_layered_apply_layout(
  context : RecursiveLayeredContext,
  parent_node : @graph.ElkNode,
) -> Unit {
  let mut rightmost = 0.0
  let mut max_bottom = 0.0
  let graph_offset = context.layered_graph.get_offset()
  let graph_size = context.layered_graph.get_size()
  let padding_value = context.layered_graph.get_padding()
  let is_top_level_context = @graph.node_parent(parent_node) is None

  for entry in context.elk_to_lnode.to_array() {
    let (elk_node, layered_node) = entry
    let owner_graph = layered_node.get_graph()
    let owner_offset = owner_graph.get_offset()
    let owner_padding = owner_graph.get_padding()
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
    let owner_padding_x = owner_padding.left
    let owner_padding_y = owner_padding.top
    let graph_x = position.x + owner_offset.x
    let graph_y = position.y + owner_offset.y
    let actual_x = graph_x + owner_padding_x
    let actual_y = graph_y + owner_padding_y
    @graph.node_set_location(elk_node, actual_x, actual_y)
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

    if graph_x + resolved_width > rightmost {
      rightmost = graph_x + resolved_width
    }
    if graph_y + resolved_height > max_bottom {
      max_bottom = graph_y + resolved_height
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

  for entry in context.edge_to_ledge.to_array() {
    let (elk_edge, layered_edge) = entry
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
    let edge_graph = source_node.get_graph()
    let edge_padding = edge_graph.get_padding()
    let edge_offset = @core.new_kvector_xy(
      edge_graph.get_offset().x + edge_padding.left,
      edge_graph.get_offset().y + edge_padding.top,
    )
    ignore(
      edge_offset.add(
        recursive_layered_calculate_hierarchical_offset(layered_edge),
      ),
    )

    let source_point = if is_descendant_l_node(target_node, source_node) {
      let point = @core.new_kvector_copy(source_port.get_position())
      ignore(point.add(source_port.get_anchor()))
      ignore(point.sub(edge_offset))
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

    let edge_path = @core.new_kvector_chain()
    edge_path.add_last_vector(source_point)
    for bend_point in layered_edge.get_bend_points().to_array() {
      edge_path.add_last_vector(@core.new_kvector_copy(bend_point))
    }
    edge_path.add_last_vector(target_point)
    ignore(edge_path.offset(edge_offset))

    recursive_layered_apply_vector_chain_to_edge(edge_path, elk_edge)
    if @graph.edge_sections(elk_edge).is_empty() {
      continue
    }
    let section = @graph.edge_sections(elk_edge)[0]
    let edge_sources = @graph.edge_sources(elk_edge)
    if edge_sources.length() == 1 {
      @graph.edge_section_set_incoming_shape(section, Some(edge_sources[0]))
    }
    let edge_targets = @graph.edge_targets(elk_edge)
    if edge_targets.length() == 1 {
      @graph.edge_section_set_outgoing_shape(section, Some(edge_targets[0]))
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

  let computed_width = rightmost + padding_value.left + padding_value.right
  let computed_height = max_bottom + padding_value.top + padding_value.bottom
  let actual_size = context.layered_graph.get_actual_size()
  let width = if actual_size.x > 0.0 { actual_size.x } else { computed_width }
  let height = if actual_size.y > 0.0 { actual_size.y } else { computed_height }
  if recursive_layered_has_graph_property(
      context.layered_graph,
      GraphProperties::ExternalPorts,
    ) {
    @graph.node_set_string_property(
      parent_node, @core.port_constraints, "FIXED_POS",
    )
  }
  @graph.node_set_dimensions(parent_node, width, height)
}

///|
