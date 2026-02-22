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
fn recursive_layered_edge_endpoint_port(
  edge_shapes : Array[@graph.ElkConnectableShape],
  elk_to_lport : Map[@graph.ElkPort, LPort],
) -> LPort? {
  if edge_shapes.is_empty() {
    return None
  }
  match edge_shapes[0] {
    PortShape(port) => elk_to_lport.get(port)
    _ => None
  }
}

///|
fn recursive_layered_direct_child_for_endpoint(
  root_node : @graph.ElkNode,
  endpoint_node : @graph.ElkNode,
) -> @graph.ElkNode? {
  if endpoint_node == root_node {
    return None
  }

  let mut current = endpoint_node
  while true {
    match @graph.node_parent(current) {
      Some(parent) =>
        if parent == root_node {
          return Some(current)
        } else {
          current = parent
        }
      None => return None
    }
  }
  None
}

///|
fn recursive_layered_endpoint_lnode(
  root_node : @graph.ElkNode,
  endpoint_node : @graph.ElkNode,
  elk_to_lnode : Map[@graph.ElkNode, LNode],
) -> (LNode?, Bool) {
  match elk_to_lnode.get(endpoint_node) {
    Some(found) => (Some(found), false)
    None =>
      match
        recursive_layered_direct_child_for_endpoint(root_node, endpoint_node) {
        Some(child) => (elk_to_lnode.get(child), true)
        None => (None, false)
      }
  }
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
fn recursive_layered_align_edge_sections_to_port_anchors(
  root_node : @graph.ElkNode,
) -> Unit {
  for edge in recursive_layered_descendant_edges(root_node) {
    let sections = @graph.edge_sections(edge)
    if sections.is_empty() {
      continue
    }
    let section = sections[0]
    match
      @graph.connectable_shape_to_port(
        @graph.edge_section_incoming_shape(section),
      ) {
      Some(incoming_port) => {
        let start_anchor = recursive_layered_port_anchor_in_edge_coordinates(
          edge, incoming_port,
        )
        @graph.edge_section_set_start(section, start_anchor.x, start_anchor.y)
      }
      None => ()
    }
    match
      @graph.connectable_shape_to_port(
        @graph.edge_section_outgoing_shape(section),
      ) {
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
fn recursive_layered_new_edge_port(
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
fn recursive_layered_new_descendant_endpoint_port(
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
fn recursive_layered_shape_anchor_for_edge_section(
  edge : @graph.ElkEdge,
  shape : @graph.ElkConnectableShape,
) -> @core.KVector? {
  match @graph.connectable_shape_to_port(Some(shape)) {
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
fn recursive_layered_new_descendant_port_endpoint_port(
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
      1.0
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

  let nodes_to_import = @graph.node_children(node).copy()

  let mut node_model_order = 0
  for child in nodes_to_import {
    if @graph.node_get_bool_property(child, @core.no_layout) {
      continue
    }
    let lnode = new_l_node(graph=Some(layered_graph))
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
    if needs_model_order {
      lnode.set_property_int(internal_properties_model_order, node_model_order)
      node_model_order += 1
    }
    recursive_layered_copy_nodespacing_options(node, child, lnode)

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
        get_direction(layered_graph),
        explicit_anchor,
      )
      if recursive_layered_is_north_south_side(lport.get_side()) {
        recursive_layered_add_graph_property(
          layered_graph,
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

    node_label_pairs[child] = node_label_pairs_for_child
    layered_graph.get_layerless_nodes().push(lnode)
    elk_to_lnode[child] = lnode
    lnode_to_elk[lnode.get_handle()] = child
  }
  layered_graph.set_property_int(
    internal_properties_max_model_order_nodes, node_model_order,
  )

  let edges_to_import = @graph.node_contained_edges(node).copy()

  let mut edge_model_order = 0
  for edge in edges_to_import {
    let source_shapes = @graph.edge_sources(edge)
    if source_shapes.is_empty() {
      return None
    }
    let target_shapes = @graph.edge_targets(edge)
    if target_shapes.is_empty() {
      return None
    }

    let source_port = match
      recursive_layered_edge_endpoint_port(source_shapes, elk_to_lport) {
      Some(port) => port
      None =>
        match source_shapes[0] {
          PortShape(parent_port) =>
            match @graph.port_parent(parent_port) {
              Some(parent_of_port) =>
                if parent_of_port == node {
                  recursive_layered_parent_port_lport(
                    node, parent_port, direction_value, layered_graph, elk_to_lport,
                  )
                } else {
                  match
                    recursive_layered_endpoint_lnode(
                      node, parent_of_port, elk_to_lnode,
                    ) {
                    (Some(source_lnode), fix_owner_side) => {
                      if fix_owner_side {
                        recursive_layered_add_graph_property(
                          layered_graph,
                          GraphProperties::ExternalPorts,
                        )
                      }
                      if fix_owner_side {
                        match lnode_to_elk.get(source_lnode.get_handle()) {
                          Some(source_owner_elk) =>
                            recursive_layered_new_descendant_port_endpoint_port(
                              source_lnode,
                              source_owner_elk,
                              parent_port,
                              layered_graph,
                              PortType::Output,
                            )
                          None =>
                            recursive_layered_new_edge_port(
                              source_lnode,
                              @core.PortSide::East,
                              layered_graph,
                              PortType::Output,
                              fix_owner_side=fix_owner_side ||
                                hierarchical_layout,
                            )
                        }
                      } else {
                        let mut source_side = recursive_layered_port_side_from_string(
                          recursive_layered_port_side_option(parent_port),
                        )
                        match source_side {
                          @core.PortSide::SideUndefined =>
                            source_side = @core.PortSide::East
                          _ => ()
                        }
                        recursive_layered_new_edge_port(
                          source_lnode,
                          source_side,
                          layered_graph,
                          PortType::Output,
                          fix_owner_side=fix_owner_side || hierarchical_layout,
                        )
                      }
                    }
                    (None, _) => return None
                  }
                }
              None => return None
            }
          NodeShape(source_node) =>
            match
              recursive_layered_endpoint_lnode(node, source_node, elk_to_lnode) {
              (Some(source_lnode), fix_owner_side) =>
                if fix_owner_side {
                  recursive_layered_add_graph_property(
                    layered_graph,
                    GraphProperties::ExternalPorts,
                  )
                  recursive_layered_new_descendant_endpoint_port(
                    source_lnode,
                    source_node,
                    layered_graph,
                    PortType::Output,
                  )
                } else {
                  recursive_layered_new_edge_port(
                    source_lnode,
                    @core.PortSide::SideUndefined,
                    layered_graph,
                    PortType::Output,
                    fix_owner_side=fix_owner_side || hierarchical_layout,
                  )
                }
              (None, _) => return None
            }
        }
    }
    let target_port = match
      recursive_layered_edge_endpoint_port(target_shapes, elk_to_lport) {
      Some(port) => port
      None =>
        match target_shapes[0] {
          PortShape(parent_port) =>
            match @graph.port_parent(parent_port) {
              Some(parent_of_port) =>
                if parent_of_port == node {
                  recursive_layered_parent_port_lport(
                    node, parent_port, direction_value, layered_graph, elk_to_lport,
                  )
                } else {
                  match
                    recursive_layered_endpoint_lnode(
                      node, parent_of_port, elk_to_lnode,
                    ) {
                    (Some(target_lnode), fix_owner_side) => {
                      if fix_owner_side {
                        recursive_layered_add_graph_property(
                          layered_graph,
                          GraphProperties::ExternalPorts,
                        )
                      }
                      if fix_owner_side {
                        match lnode_to_elk.get(target_lnode.get_handle()) {
                          Some(target_owner_elk) =>
                            recursive_layered_new_descendant_port_endpoint_port(
                              target_lnode,
                              target_owner_elk,
                              parent_port,
                              layered_graph,
                              PortType::Input,
                            )
                          None =>
                            recursive_layered_new_edge_port(
                              target_lnode,
                              @core.PortSide::West,
                              layered_graph,
                              PortType::Input,
                              fix_owner_side=fix_owner_side ||
                                hierarchical_layout,
                            )
                        }
                      } else {
                        let mut target_side = recursive_layered_port_side_from_string(
                          recursive_layered_port_side_option(parent_port),
                        )
                        match target_side {
                          @core.PortSide::SideUndefined =>
                            target_side = @core.PortSide::West
                          _ => ()
                        }
                        recursive_layered_new_edge_port(
                          target_lnode,
                          target_side,
                          layered_graph,
                          PortType::Input,
                          fix_owner_side=fix_owner_side || hierarchical_layout,
                        )
                      }
                    }
                    (None, _) => return None
                  }
                }
              None => return None
            }
          NodeShape(target_node) =>
            match
              recursive_layered_endpoint_lnode(node, target_node, elk_to_lnode) {
              (Some(target_lnode), fix_owner_side) =>
                if fix_owner_side {
                  recursive_layered_add_graph_property(
                    layered_graph,
                    GraphProperties::ExternalPorts,
                  )
                  recursive_layered_new_descendant_endpoint_port(
                    target_lnode,
                    target_node,
                    layered_graph,
                    PortType::Input,
                  )
                } else {
                  recursive_layered_new_edge_port(
                    target_lnode,
                    @core.PortSide::SideUndefined,
                    layered_graph,
                    PortType::Input,
                    fix_owner_side=fix_owner_side || hierarchical_layout,
                  )
                }
              (None, _) => return None
            }
        }
    }

    let l_edge = new_l_edge()
    l_edge.set_source(Some(source_port))
    l_edge.set_target(Some(target_port))
    if recursive_layered_ports_have_same_owner(source_port, target_port) {
      recursive_layered_add_graph_property(
        layered_graph,
        GraphProperties::SelfLoops,
      )
    }
    if needs_model_order {
      l_edge.set_property_int(internal_properties_model_order, edge_model_order)
      edge_model_order += 1
    }
    l_edge.set_property_double(
      @core.edge_thickness,
      @core.edge_thickness.get_default(),
    )

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
          layered_graph,
          GraphProperties::CenterLabels,
        )
      } else {
        recursive_layered_add_graph_property(
          layered_graph,
          GraphProperties::EndLabels,
        )
      }
      l_edge.get_labels().push(llabel)
    }

    edge_to_ledge[edge] = l_edge
  }
  graph_configurator_configure_graph_properties(layered_graph)
  recursive_layered_normalize_port_constraints(layered_graph)

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
    let graph_x = position.x + owner_offset.x
    let graph_y = position.y + owner_offset.y
    let actual_x = graph_x + owner_padding.left
    let actual_y = graph_y + owner_padding.top
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
    let source_anchor = source_port.get_absolute_anchor()
    let target_anchor = target_port.get_absolute_anchor()
    let edge_graph = match source_port.get_node() {
      Some(node) => node.get_graph()
      None => context.layered_graph
    }
    let edge_graph_offset = edge_graph.get_offset()
    let edge_graph_padding = edge_graph.get_padding()
    let mut section_start_x = source_anchor.x +
      edge_graph_offset.x +
      edge_graph_padding.left
    let mut section_start_y = source_anchor.y +
      edge_graph_offset.y +
      edge_graph_padding.top
    let mut section_end_x = target_anchor.x +
      edge_graph_offset.x +
      edge_graph_padding.left
    let mut section_end_y = target_anchor.y +
      edge_graph_offset.y +
      edge_graph_padding.top

    let edge_sources = @graph.edge_sources(elk_edge)
    if edge_sources.length() == 1 {
      @graph.edge_section_set_incoming_shape(section, Some(edge_sources[0]))
      match
        recursive_layered_shape_anchor_for_edge_section(
          elk_edge,
          edge_sources[0],
        ) {
        Some(source_shape_anchor) => {
          section_start_x = source_shape_anchor.x
          section_start_y = source_shape_anchor.y
        }
        None => ()
      }
    }
    let edge_targets = @graph.edge_targets(elk_edge)
    if edge_targets.length() == 1 {
      @graph.edge_section_set_outgoing_shape(section, Some(edge_targets[0]))
      match
        recursive_layered_shape_anchor_for_edge_section(
          elk_edge,
          edge_targets[0],
        ) {
        Some(target_shape_anchor) => {
          section_end_x = target_shape_anchor.x
          section_end_y = target_shape_anchor.y
        }
        None => ()
      }
    }
    @graph.edge_section_set_start(section, section_start_x, section_start_y)
    @graph.edge_section_set_end(section, section_end_x, section_end_y)

    let edge_offset_x = edge_graph_offset.x + edge_graph_padding.left
    let edge_offset_y = edge_graph_offset.y + edge_graph_padding.top
    @graph.edge_section_clear_bend_points(section)
    for bend_point in layered_edge.get_bend_points().to_array() {
      @graph.edge_section_add_bend_point(
        section,
        @graph.new_elk_bend_point(
          x=edge_offset_x + bend_point.x,
          y=edge_offset_y + bend_point.y,
        ),
      )
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
        layered_label.get_position().x + edge_offset_x,
        layered_label.get_position().y + edge_offset_y,
      )
    }
  }

  let width = rightmost + padding_value.left + padding_value.right
  let height = max_bottom + padding_value.top + padding_value.bottom
  if recursive_layered_has_graph_property(
      context.layered_graph,
      GraphProperties::ExternalPorts,
    ) {
    @graph.node_set_string_property(
      parent_node, @core.port_constraints, "FIXED_POS",
    )
  }
  @graph.node_set_dimensions(parent_node, width, height)
  recursive_layered_align_edge_sections_to_port_anchors(parent_node)
}

///|
