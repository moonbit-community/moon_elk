///|
pub struct RecursiveGraphLayoutEngine {
  marker : Int
}

///|
pub fn new_recursive_graph_layout_engine() -> RecursiveGraphLayoutEngine {
  { marker: 0 }
}

///|
fn max_positive(value : Double, fallback : Double) -> Double {
  if value > 0.0 {
    value
  } else {
    fallback
  }
}

///|
fn parse_node_padding(node : ElkNode) -> ElkPadding {
  let parsed = new_elk_padding()
  parsed.parse(node_get_string_property(node, padding))
  parsed
}

///|
fn parse_node_minimum_size(node : ElkNode) -> KVector {
  let parsed = new_kvector()
  parsed.parse(node_get_string_property(node, node_size_minimum))
  parsed
}

///|
fn has_minimum_size_constraint(node : ElkNode) -> Bool {
  for value in node_get_string_set_property(node, node_size_constraints) {
    if value == "MINIMUM_SIZE" || value == "MINIMUM_SIZE_WITH_PORTS" {
      return true
    }
  }
  false
}

///|
fn node_layout_option_value_by_candidates(
  node : ElkNode,
  candidates : Array[String],
) -> String? {
  for candidate in candidates {
    match node_layout_option_string_value(node, candidate) {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn node_individual_spacing_value_by_candidates(
  node : ElkNode,
  candidates : Array[String],
) -> String? {
  for candidate in candidates {
    match node_individual_spacing_option_string_value(node, candidate) {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn node_layout_option_value_by_candidates_with_ancestors(
  node : ElkNode,
  candidates : Array[String],
) -> String? {
  match node_layout_option_value_by_candidates(node, candidates) {
    Some(option) => Some(option)
    None =>
      match node_parent(node) {
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
fn node_label_padding(node : ElkNode) -> ElkPadding {
  let keys = [
    "nodeLabels.padding", "elk.nodeLabels.padding", "org.eclipse.elk.nodeLabels.padding",
  ]
  let padding_text = match
    node_individual_spacing_value_by_candidates(node, keys) {
    Some(value) => value
    None =>
      match node_layout_option_value_by_candidates_with_ancestors(node, keys) {
        Some(value) => value
        None => return new_elk_padding()
      }
  }
  let parsed = new_elk_padding()
  parsed.parse(padding_text)
  parsed
}

///|
fn recursive_layout_node_has_size_constraint(
  node : ElkNode,
  constraint : String,
) -> Bool {
  for value in node_get_string_set_property(node, node_size_constraints) {
    if value == constraint {
      return true
    }
  }
  false
}

///|
let recursive_layered_node_labels_padding_property : IProperty[String] = new_property(
  "org.eclipse.elk.nodeLabels.padding", "[top=5,left=5,bottom=5,right=5]",
)

///|
fn recursive_layered_individual_spacing_options() -> Array[IProperty[Double]] {
  [
    spacing_node_node, spacing_component_component, spacing_edge_edge, spacing_edge_label,
    spacing_edge_node, spacing_label_label, spacing_label_node, spacing_label_port_horizontal,
    spacing_label_port_vertical, spacing_node_self_loop, spacing_port_port, layered_options_spacing_edge_edge_between_layers,
    layered_options_spacing_edge_node_between_layers, layered_options_spacing_node_node_between_layers,
  ]
}

///|
fn recursive_layered_copy_individual_spacing_options(
  source_node : ElkNode,
  target_node : LNode,
) -> Unit {
  for property in recursive_layered_individual_spacing_options() {
    match
      node_individual_spacing_option_string_value(
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
  graph_node : ElkNode,
  source_node : ElkNode,
  target_node : LNode,
) -> Unit {
  recursive_layered_copy_individual_spacing_options(source_node, target_node)

  if node_has_string_set_property(source_node, node_size_constraints) {
    target_node.set_property_string_array(
      node_size_constraints,
      node_get_string_set_property(source_node, node_size_constraints),
    )
  }
  if node_has_string_set_property(source_node, node_size_options) {
    target_node.set_property_string_array(
      node_size_options,
      node_get_string_set_property(source_node, node_size_options),
    )
  }
  if node_has_string_set_property(source_node, node_labels_placement) {
    target_node.set_property_string_array(
      node_labels_placement,
      node_get_string_set_property(source_node, node_labels_placement),
    )
  }
  if node_has_string_set_property(source_node, port_labels_placement) {
    target_node.set_property_string_array(
      port_labels_placement,
      node_get_string_set_property(source_node, port_labels_placement),
    )
  }

  let keys = [
    "nodeLabels.padding", "elk.nodeLabels.padding", "org.eclipse.elk.nodeLabels.padding",
  ]
  let node_labels_padding_value = match
    node_layout_option_value_by_candidates(source_node, keys) {
    Some(value) => value
    None =>
      match node_layout_option_value_by_candidates(graph_node, keys) {
        Some(value) => value
        None => recursive_layered_node_labels_padding_property.get_default()
      }
  }
  target_node.set_property_string(
    recursive_layered_node_labels_padding_property, node_labels_padding_value,
  )
}

///|
fn recursive_layout_node_labels(node : ElkNode) -> Unit {
  let keys = [
    "nodeLabels.placement", "elk.nodeLabels.placement", "org.eclipse.elk.nodeLabels.placement",
  ]
  let tokens = match node_layout_option_value_by_candidates(node, keys) {
    Some(value) => placement_tokens(value)
    None =>
      if node_has_string_set_property(node, node_labels_placement) {
        node_get_string_set_property(node, node_labels_placement)
      } else {
        return
      }
  }
  if !(has_placement_token(tokens, "INSIDE") &&
    has_placement_token(tokens, "V_TOP")) {
    return
  }
  let labels = node_labels(node)
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
      let width = label_width(label)
      let height = label_height(label)
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
    let next_width = if node_width(node) < expected_width {
      expected_width
    } else {
      node_width(node)
    }
    let next_height = if node_height(node) < expected_height {
      expected_height
    } else {
      node_height(node)
    }
    node_set_dimensions(node, next_width, next_height)
  }

  let content_width = max_positive(
    node_width(node) - padding_value.left - padding_value.right,
    0.0,
  )
  for label in labels {
    let next_x = if horizontal_center {
      padding_value.left + (content_width - label_width(label)) / 2.0
    } else {
      label_x(label)
    }
    label_set_location(label, next_x, padding_value.top)
  }
}

///|
fn recursive_layout_label_top_reserve(node : ElkNode) -> Double {
  let mut reserve = 0.0
  for label in node_labels(node) {
    let bottom = label_y(label) + label_height(label)
    if bottom > reserve {
      reserve = bottom
    }
  }
  reserve
}

///|
fn ensure_edge_section_for_edge(edge : ElkEdge) -> Unit {
  if !edge_sections(edge).is_empty() {
    return
  }
  if edge_sources(edge).length() != 1 || edge_targets(edge).length() != 1 {
    return
  }
  let source_shape = edge_sources(edge)[0]
  let target_shape = edge_targets(edge)[0]
  match source_shape {
    NodeShape(source_node) =>
      match target_shape {
        NodeShape(target_node) => {
          let section = create_edge_section(edge)
          let start_x = node_x(source_node) +
            max_positive(node_width(source_node), 10.0)
          let start_y = node_y(source_node) +
            max_positive(node_height(source_node), 10.0) / 2.0
          let end_x = node_x(target_node)
          let end_y = node_y(target_node) +
            max_positive(node_height(target_node), 10.0) / 2.0
          edge_section_set_start(section, start_x, start_y)
          edge_section_set_end(section, end_x, end_y)
          edge_section_set_incoming_shape(section, Some(source_shape))
          edge_section_set_outgoing_shape(section, Some(target_shape))
        }
        _ => ()
      }
    _ => ()
  }
}

///|
priv struct RecursiveLayeredContext {
  layered_graph : LGraph
  elk_to_lnode : Map[ElkNode, LNode]
  elk_to_lport : Map[ElkPort, LPort]
  lnode_to_elk : Map[Int, ElkNode]
  edge_to_ledge : Map[ElkEdge, LEdge]
}

///|
let recursive_layered_transform_context_next_id : Ref[Int] = Ref::new(1)

///|
let recursive_layered_transform_context_store : Ref[
  Map[Int, (RecursiveLayeredContext, ElkNode)],
] = Ref::new({})

///|
fn recursive_layered_transform_register_context(
  context : RecursiveLayeredContext,
  parent_node : ElkNode,
) -> LGraph {
  let context_id = recursive_layered_transform_context_next_id.val
  recursive_layered_transform_context_next_id.val = context_id + 1
  context.layered_graph.set_id(context_id)
  recursive_layered_transform_context_store.val[context_id] = (
    context, parent_node,
  )
  context.layered_graph
}

///|
pub fn recursive_layered_import_graph_for_transform(
  parent_node : ElkNode,
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
  match recursive_layered_transform_context_store.val.get(context_id) {
    Some((context, parent_node)) => {
      ignore(recursive_layered_transform_context_store.val.remove(context_id))
      recursive_layered_apply_layout(context, parent_node)
      true
    }
    None => false
  }
}

///|
fn recursive_layered_edge_endpoint_node(
  edge_shapes : Array[ElkConnectableShape],
) -> ElkNode? {
  if edge_shapes.is_empty() {
    return None
  }
  match edge_shapes[0] {
    NodeShape(node) => Some(node)
    PortShape(port) => port_parent(port)
  }
}

///|
fn recursive_layered_edge_endpoint_port(
  edge_shapes : Array[ElkConnectableShape],
  elk_to_lport : Map[ElkPort, LPort],
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
  root_node : ElkNode,
  endpoint_node : ElkNode,
) -> ElkNode? {
  if endpoint_node == root_node {
    return None
  }

  let mut current = endpoint_node
  while true {
    match node_parent(current) {
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
  root_node : ElkNode,
  endpoint_node : ElkNode,
  elk_to_lnode : Map[ElkNode, LNode],
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
fn recursive_layered_port_side_from_string(value : String) -> PortSide {
  match value {
    "NORTH" => PortSide::North
    "EAST" => PortSide::East
    "SOUTH" => PortSide::South
    "WEST" => PortSide::West
    _ => PortSide::SideUndefined
  }
}

///|
fn recursive_layered_port_side_option(port : ElkPort) -> String {
  let candidates = ["org.eclipse.elk.port.side", "elk.port.side", "port.side"]
  for candidate in candidates {
    match port_layout_option_string_value(port, candidate) {
      Some(value) => return value
      None => ()
    }
  }
  "UNDEFINED"
}

///|
fn recursive_layered_port_allow_non_flow_switch_sides(port : ElkPort) -> Bool {
  let candidates = [
    layered_options_allow_non_flow_ports_to_switch_sides.get_id(),
    "elk.layered.allowNonFlowPortsToSwitchSides",
    "layered.allowNonFlowPortsToSwitchSides",
  ]
  for candidate in candidates {
    match port_layout_option_string_value(port, candidate) {
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
let recursive_layered_ext_port_border_offset_property : IProperty[Double] = new_property(
  "recursive.layered.extPortBorderOffset", 0.0,
)

///|
fn recursive_layered_port_border_offset(port : ElkPort) -> Double {
  let candidates = [
    "org.eclipse.elk.port.borderOffset", "elk.port.borderOffset", "port.borderOffset",
  ]
  for candidate in candidates {
    match port_layout_option_string_value(port, candidate) {
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
fn recursive_layered_direction_to_port_side(
  direction_value : String,
) -> PortSide {
  match direction_value {
    "LEFT" => PortSide::West
    "DOWN" => PortSide::South
    "UP" => PortSide::North
    _ => PortSide::East
  }
}

///|
fn recursive_layered_opposed_port_side(side : PortSide) -> PortSide {
  match side {
    PortSide::North => PortSide::South
    PortSide::East => PortSide::West
    PortSide::South => PortSide::North
    PortSide::West => PortSide::East
    _ => PortSide::SideUndefined
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
fn recursive_layered_is_north_south_side(side : PortSide) -> Bool {
  match side {
    PortSide::North => true
    PortSide::South => true
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
fn recursive_layered_edge_label_placement(elk_label : ElkLabel) -> String {
  match
    label_layout_option_string_value(elk_label, edge_labels_placement.get_id()) {
    Some(value) => value
    None => edge_labels_placement.get_default()
  }
}

///|
fn recursive_layered_is_center_label_placement(value : String) -> Bool {
  value == "CENTER"
}

///|
fn recursive_layered_is_descendant(
  candidate : ElkNode,
  ancestor : ElkNode,
) -> Bool {
  let mut current = node_parent(candidate)
  while true {
    match current {
      Some(parent) =>
        if parent == ancestor {
          return true
        } else {
          current = node_parent(parent)
        }
      None => return false
    }
  }
  false
}

///|
fn recursive_layered_port_has_inside_connections(
  owner_node : ElkNode,
  elk_port : ElkPort,
) -> Bool {
  for outgoing_edge in port_outgoing_edges(elk_port) {
    match recursive_layered_edge_endpoint_node(edge_targets(outgoing_edge)) {
      Some(target_node) =>
        if recursive_layered_is_descendant(target_node, owner_node) {
          return true
        }
      None => ()
    }
  }

  for incoming_edge in port_incoming_edges(elk_port) {
    match recursive_layered_edge_endpoint_node(edge_sources(incoming_edge)) {
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
  owner_node : ElkNode,
  elk_port : ElkPort,
) -> Bool {
  for outgoing_edge in port_outgoing_edges(elk_port) {
    match recursive_layered_edge_endpoint_node(edge_targets(outgoing_edge)) {
      Some(target_node) =>
        if !recursive_layered_is_descendant(target_node, owner_node) {
          return true
        }
      None => ()
    }
  }

  for incoming_edge in port_incoming_edges(elk_port) {
    match recursive_layered_edge_endpoint_node(edge_sources(incoming_edge)) {
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
  parent_node : ElkNode,
  parent_port : ElkPort,
) -> Int {
  let mut output_vote = 0
  let mut input_vote = 0

  for outgoing_edge in port_outgoing_edges(parent_port) {
    let target_node = match
      recursive_layered_edge_endpoint_node(edge_targets(outgoing_edge)) {
      Some(value) => value
      None => continue
    }
    match node_parent(target_node) {
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

  for incoming_edge in port_incoming_edges(parent_port) {
    let source_node = match
      recursive_layered_edge_endpoint_node(edge_sources(incoming_edge)) {
      Some(value) => value
      None => continue
    }
    match node_parent(source_node) {
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
  parent_node : ElkNode,
  parent_port : ElkPort,
  direction_value : String,
  layered_graph : LGraph,
  elk_to_lport : Map[ElkPort, LPort],
) -> LPort {
  match elk_to_lport.get(parent_port) {
    Some(existing) => existing
    None => {
      let port_constraints_value = node_get_string_property(
        parent_node, port_constraints,
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
        port_set_layout_option_string_by_id(
          parent_port,
          "org.eclipse.elk.port.side",
          port_side_to_string(final_external_side),
        )
      }

      let dummy = new_l_node(graph=Some(layered_graph))
      dummy.set_type(NodeType::ExternalPort)
      dummy.set_property_string(port_constraints, "FIXED_POS")
      dummy.set_property_port_side(
        internal_properties_ext_port_side, final_external_side,
      )
      let port_size = new_kvector_xy(
        port_width(parent_port),
        port_height(parent_port),
      )
      dummy.set_property_kvector(
        internal_properties_ext_port_size,
        new_kvector_copy(port_size),
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
      let anchor = new_kvector_xy(port_size.x / 2.0, port_size.y / 2.0)
      let mut explicit_anchor = false
      match
        port_layout_option_string_value(
          parent_port,
          layered_options_port_anchor.get_id(),
        ) {
        Some(anchor_text) => {
          let parsed_anchor = new_kvector()
          parsed_anchor.parse(anchor_text)
          anchor.x = parsed_anchor.x
          anchor.y = parsed_anchor.y
          explicit_anchor = true
        }
        None => ()
      }

      match final_external_side {
        PortSide::West => {
          dummy.set_property_string(
            layered_options_layering_layer_constraint, "FIRST_SEPARATE",
          )
          dummy.get_size().y = port_size.y
          if border_offset < 0.0 {
            dummy.get_size().x = -border_offset
          }
          lport.set_side(PortSide::East)
          if !explicit_anchor {
            anchor.x = port_size.x
          }
          anchor.x = anchor.x - port_size.x
        }
        PortSide::East => {
          dummy.set_property_string(
            layered_options_layering_layer_constraint, "LAST_SEPARATE",
          )
          dummy.get_size().y = port_size.y
          if border_offset < 0.0 {
            dummy.get_size().x = -border_offset
          }
          lport.set_side(PortSide::West)
          anchor.x = 0.0
        }
        PortSide::North => {
          dummy.set_property_string(
            internal_properties_in_layer_constraint, "TOP",
          )
          dummy.get_size().x = port_size.x
          if border_offset < 0.0 {
            dummy.get_size().y = -border_offset
          }
          lport.set_side(PortSide::South)
          if !explicit_anchor {
            anchor.y = port_size.y
          }
          anchor.y = anchor.y - port_size.y
        }
        PortSide::South => {
          dummy.set_property_string(
            internal_properties_in_layer_constraint, "BOTTOM",
          )
          dummy.get_size().x = port_size.x
          if border_offset < 0.0 {
            dummy.get_size().y = -border_offset
          }
          lport.set_side(PortSide::North)
          anchor.y = 0.0
        }
        PortSide::SideUndefined => {
          lport.set_side(PortSide::West)
          anchor.x = 0.0
        }
      }
      lport.get_position().x = anchor.x
      lport.get_position().y = anchor.y
      dummy.set_property_kvector(
        layered_options_port_anchor,
        new_kvector_copy(anchor),
      )

      if recursive_layered_port_constraints_order_fixed(port_constraints_value) {
        let mut ratio_or_position = 0.0
        match final_external_side {
          PortSide::West => ratio_or_position = port_y(parent_port)
          PortSide::East => ratio_or_position = port_y(parent_port)
          PortSide::North => ratio_or_position = port_x(parent_port)
          PortSide::South => ratio_or_position = port_x(parent_port)
          PortSide::SideUndefined => ()
        }
        if port_constraints_value == "FIXED_RATIO" {
          match final_external_side {
            PortSide::West =>
              if node_height(parent_node) > 0.0 {
                ratio_or_position = ratio_or_position / node_height(parent_node)
              }
            PortSide::East =>
              if node_height(parent_node) > 0.0 {
                ratio_or_position = ratio_or_position / node_height(parent_node)
              }
            PortSide::North =>
              if node_width(parent_node) > 0.0 {
                ratio_or_position = ratio_or_position / node_width(parent_node)
              }
            PortSide::South =>
              if node_width(parent_node) > 0.0 {
                ratio_or_position = ratio_or_position / node_width(parent_node)
              }
            PortSide::SideUndefined => ()
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
  side : PortSide,
  fix_owner_side? : Bool = false,
) -> LPort {
  if fix_owner_side {
    owner.set_property_string(port_constraints, "FIXED_SIDE")
  }
  let port = new_l_port()
  port.set_node(Some(owner))
  port.set_side(side)
  ignore(port.get_size().set_xy(0.0, 0.0))
  port
}

///|
fn recursive_layered_parse_edge_routing(value : String) -> EdgeRouting {
  for routing in edge_routing_values() {
    if edge_routing_to_string(routing) == value {
      return routing
    }
  }
  RoutingUndefined
}

///|
fn recursive_layered_cycle_breaking_factory(
  strategy : String,
) -> ILayoutProcessorFactory[LayeredPhases, LGraph] {
  match strategy {
    "DEPTH_FIRST" =>
      new_layout_processor_factory(21001, 0, () => {
        new_depth_first_cycle_breaker_layout_phase()
      })
    "INTERACTIVE" =>
      new_layout_processor_factory(21002, 0, () => {
        new_interactive_cycle_breaker_layout_phase()
      })
    "MODEL_ORDER" =>
      new_layout_processor_factory(21003, 0, () => {
        new_model_order_cycle_breaker_layout_phase()
      })
    "GREEDY_MODEL_ORDER" =>
      new_layout_processor_factory(21004, 0, () => {
        new_greedy_model_order_cycle_breaker_layout_phase()
      })
    "SCC_CONNECTIVITY" =>
      new_layout_processor_factory(21005, 0, () => {
        new_sc_connectivity_cycle_breaker_layout_phase()
      })
    "SCC_NODE_TYPE" =>
      new_layout_processor_factory(21006, 0, () => {
        new_scc_node_type_cycle_breaker_layout_phase()
      })
    "DFS_NODE_ORDER" =>
      new_layout_processor_factory(21007, 0, () => {
        new_dfs_node_order_cycle_breaker_layout_phase()
      })
    "BFS_NODE_ORDER" =>
      new_layout_processor_factory(21008, 0, () => {
        new_bfs_node_order_cycle_breaker_layout_phase()
      })
    _ =>
      new_layout_processor_factory(21000, 0, () => {
        new_greedy_cycle_breaker_layout_phase()
      })
  }
}

///|
fn recursive_layered_layering_factory(
  strategy : String,
) -> ILayoutProcessorFactory[LayeredPhases, LGraph] {
  match strategy {
    "LONGEST_PATH" =>
      new_layout_processor_factory(22001, 1, () => {
        new_longest_path_layerer_layout_phase()
      })
    "LONGEST_PATH_SOURCE" =>
      new_layout_processor_factory(22002, 1, () => {
        new_longest_path_source_layerer_layout_phase()
      })
    "COFFMAN_GRAHAM" =>
      new_layout_processor_factory(22003, 1, () => {
        new_coffman_graham_layerer_layout_phase()
      })
    "INTERACTIVE" =>
      new_layout_processor_factory(22004, 1, () => {
        new_interactive_layerer_layout_phase()
      })
    "STRETCH_WIDTH" =>
      new_layout_processor_factory(22005, 1, () => {
        new_stretch_width_layerer_layout_phase()
      })
    "MIN_WIDTH" =>
      new_layout_processor_factory(22006, 1, () => {
        new_min_width_layerer_layout_phase()
      })
    "BF_MODEL_ORDER" =>
      new_layout_processor_factory(22007, 1, () => {
        new_breadth_first_model_order_layerer_layout_phase()
      })
    "DF_MODEL_ORDER" =>
      new_layout_processor_factory(22008, 1, () => {
        new_depth_first_model_order_layerer_layout_phase()
      })
    _ =>
      new_layout_processor_factory(22000, 1, () => {
        new_network_simplex_layerer_layout_phase()
      })
  }
}

///|
fn recursive_layered_crossing_factory(
  strategy : String,
) -> ILayoutProcessorFactory[LayeredPhases, LGraph] {
  match strategy {
    "NONE" =>
      new_layout_processor_factory(24002, 2, () => {
        new_no_crossing_minimizer_layout_phase()
      })
    "INTERACTIVE" =>
      new_layout_processor_factory(24003, 2, () => {
        new_interactive_crossing_minimizer_layout_phase()
      })
    "MEDIAN_LAYER_SWEEP" =>
      new_layout_processor_factory(24001, 2, () => {
        new_layer_sweep_crossing_minimizer_layout_phase(CrossMinType::Median)
      })
    _ =>
      new_layout_processor_factory(24000, 2, () => {
        new_layer_sweep_crossing_minimizer_layout_phase(
          CrossMinType::Barycenter,
        )
      })
  }
}

///|
fn recursive_layered_node_placement_factory(
  strategy : String,
) -> ILayoutProcessorFactory[LayeredPhases, LGraph] {
  match strategy {
    "SIMPLE" =>
      new_layout_processor_factory(24100, 3, () => {
        new_simple_node_placer_layout_phase()
      })
    "INTERACTIVE" =>
      new_layout_processor_factory(24101, 3, () => {
        new_interactive_node_placer_layout_phase()
      })
    "LINEAR_SEGMENTS" =>
      new_layout_processor_factory(24102, 3, () => {
        new_linear_segments_node_placer_layout_phase()
      })
    "BRANDES_KOEPF" =>
      new_layout_processor_factory(24103, 3, () => {
        new_bk_node_placer_layout_phase()
      })
    "NETWORK_SIMPLEX" =>
      new_layout_processor_factory(24104, 3, () => {
        new_network_simplex_placer_layout_phase()
      })
    _ =>
      new_layout_processor_factory(24103, 3, () => {
        new_bk_node_placer_layout_phase()
      })
  }
}

///|
fn recursive_layered_primary_option(
  node : ElkNode,
  key : String,
  fallback : String,
) -> String {
  match node_layout_option_string_value(node, key) {
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
fn recursive_layered_requires_direction_transform(
  direction_value : String,
) -> Bool {
  direction_value == "LEFT" ||
  direction_value == "DOWN" ||
  direction_value == "UP"
}

///|
fn recursive_layered_normalize_port_constraints(lgraph : LGraph) -> Unit {
  for node in lgraph.get_layerless_nodes() {
    if node.get_property_string(port_constraints) == "UNDEFINED" {
      node.set_property_string(port_constraints, "FREE")
    }
  }
  for layer in lgraph.get_layers() {
    for node in layer.get_nodes() {
      if node.get_property_string(port_constraints) == "UNDEFINED" {
        node.set_property_string(port_constraints, "FREE")
      }
    }
  }
}

///|
fn recursive_layered_create_context(node : ElkNode) -> RecursiveLayeredContext? {
  let layered_graph = new_l_graph()
  let elk_to_lnode : Map[ElkNode, LNode] = {}
  let elk_to_lport : Map[ElkPort, LPort] = {}
  let lnode_to_elk : Map[Int, ElkNode] = {}
  let edge_to_ledge : Map[ElkEdge, LEdge] = {}
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

  let spacing_node = node_get_double_property(node, spacing_node_node)
  let spacing_edge_edge_value = node_get_double_property(
    node, spacing_edge_edge,
  )
  let spacing_between_layers = node_get_double_property(
    node, layered_options_spacing_node_node_between_layers,
  )
  let spacing_edge_edge_between_layers = node_get_double_property(
    node, layered_options_spacing_edge_edge_between_layers,
  )
  let aspect_ratio_value = node_get_double_property(node, aspect_ratio)
  let consider_model_order = node_get_string_property(
    node, layered_options_consider_model_order_strategy,
  )
  let node_promotion_strategy = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.layered.nodePromotion.strategy",
    node_get_string_property(
      node, layered_options_layering_node_promotion_strategy,
    ),
  )
  let crossing_strategy = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.layered.crossingMinimization.strategy",
    node_get_string_property(
      node, layered_options_crossing_minimization_strategy,
    ),
  )
  let edge_routing_value = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.edgeRouting",
    node_get_string_property(node, edge_routing),
  )
  let direction_value = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.direction",
    node_get_string_property(node, direction),
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
  let random_seed_value = match
    recursive_layered_parse_int(
      recursive_layered_primary_option(
        node,
        "org.eclipse.elk.randomSeed",
        random_seed.get_default().to_string(),
      ),
    ) {
    Some(value) => value
    None => random_seed.get_default()
  }
  let graph_port_constraints = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.portConstraints",
    node_get_string_property(node, port_constraints),
  )
  let feedback_edges = node_get_bool_property(
    node, layered_options_feedback_edges,
  )
  let mut hierarchical_layout = false
  for child in node_children(node) {
    if !node_children(child).is_empty() {
      hierarchical_layout = true
      break
    }
  }
  let needs_model_order = recursive_layered_needs_model_order(
    cycle_breaking_strategy, layering_strategy, node_promotion_strategy, consider_model_order,
  )

  layered_graph.set_property_double(
    spacing_node_node,
    if spacing_node > 0.0 {
      spacing_node
    } else {
      spacing_node_node.get_default()
    },
  )
  layered_graph.set_property_double(
    spacing_edge_edge,
    if spacing_edge_edge_value > 0.0 {
      spacing_edge_edge_value
    } else {
      spacing_edge_edge.get_default()
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
    aspect_ratio,
    if aspect_ratio_value > 0.0 {
      aspect_ratio_value
    } else {
      1.0
    },
  )
  layered_graph.set_property_int(random_seed, random_seed_value)
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
    edge_routing,
    if edge_routing_value == "UNDEFINED" || edge_routing_value.is_empty() {
      "ORTHOGONAL"
    } else {
      edge_routing_value
    },
  )
  layered_graph.set_property_string(direction, direction_value)
  layered_graph.set_property_string(
    port_constraints,
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

  let mut node_model_order = 0
  for child in node_children(node) {
    if node_get_bool_property(child, no_layout) {
      continue
    }
    let lnode = new_l_node(graph=Some(layered_graph))
    lnode.get_size().x = max_positive(node_width(child), 10.0)
    lnode.get_size().y = max_positive(node_height(child), 10.0)
    let original_port_constraints = match
      node_layout_option_value_by_candidates(child, [
        port_constraints.get_id(),
        "org.eclipse.elk.portConstraints",
        "elk.portConstraints",
        "portConstraints",
      ]) {
      Some(value) => value
      None => node_get_string_property(child, port_constraints)
    }
    let resolved_port_constraints = if original_port_constraints == "UNDEFINED" {
      "FREE"
    } else {
      original_port_constraints
    }
    lnode.set_property_string(port_constraints, original_port_constraints)
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

    for elk_label in node_labels(child) {
      let text = label_text(elk_label)
      if text.is_empty() {
        continue
      }
      let llabel = new_l_label_text(text)
      llabel.get_size().x = label_width(elk_label)
      llabel.get_size().y = label_height(elk_label)
      llabel.get_position().x = label_x(elk_label)
      llabel.get_position().y = label_y(elk_label)
      lnode.get_labels().push(llabel)
    }

    let mut port_model_order = 0
    for elk_port in node_ports(child) {
      let lport = new_l_port()
      lport.set_node(Some(lnode))
      lport.get_size().x = port_width(elk_port)
      lport.get_size().y = port_height(elk_port)
      let port_border_offset = recursive_layered_port_border_offset(elk_port)
      lport.set_property_double(
        nodespacing_port_border_offset_property, port_border_offset,
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
      if recursive_layered_is_north_south_side(lport.get_side()) {
        recursive_layered_add_graph_property(
          layered_graph,
          GraphProperties::NorthSouthPorts,
        )
      }
      match
        port_layout_option_string_value(
          elk_port,
          layered_options_port_anchor.get_id(),
        ) {
        Some(anchor_text) => {
          let parsed_anchor = new_kvector()
          parsed_anchor.parse(anchor_text)
          lport.get_anchor().x = parsed_anchor.x
          lport.get_anchor().y = parsed_anchor.y
          lport.set_explicitly_supplied_port_anchor(true)
        }
        None => {
          let side_is_defined = match lport.get_side() {
            PortSide::SideUndefined => false
            _ => true
          }
          if recursive_layered_port_constraints_side_fixed(
              resolved_port_constraints,
            ) &&
            side_is_defined {
            match lport.get_side() {
              PortSide::North => {
                lport.get_anchor().x = lport.get_size().x / 2.0
                lport.get_anchor().y = 0.0
              }
              PortSide::East => {
                lport.get_anchor().x = lport.get_size().x
                lport.get_anchor().y = lport.get_size().y / 2.0
              }
              PortSide::South => {
                lport.get_anchor().x = lport.get_size().x / 2.0
                lport.get_anchor().y = lport.get_size().y
              }
              PortSide::West => {
                lport.get_anchor().x = 0.0
                lport.get_anchor().y = lport.get_size().y / 2.0
              }
              PortSide::SideUndefined => ()
            }
          } else {
            lport.get_anchor().x = lport.get_size().x / 2.0
            lport.get_anchor().y = lport.get_size().y / 2.0
          }
        }
      }
      lport.get_position().x = port_x(elk_port)
      lport.get_position().y = port_y(elk_port)
      if resolved_port_constraints == "FIXED_RATIO" {
        let mut ratio_or_position = 0.0
        match lport.get_side() {
          PortSide::North =>
            if node_width(child) > 0.0 {
              ratio_or_position = lport.get_position().x / node_width(child)
            }
          PortSide::South =>
            if node_width(child) > 0.0 {
              ratio_or_position = lport.get_position().x / node_width(child)
            }
          PortSide::East =>
            if node_height(child) > 0.0 {
              ratio_or_position = lport.get_position().y / node_height(child)
            }
          PortSide::West =>
            if node_height(child) > 0.0 {
              ratio_or_position = lport.get_position().y / node_height(child)
            }
          PortSide::SideUndefined => ()
        }
        lport.set_property_double(
          internal_properties_port_ratio_or_position, ratio_or_position,
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

    layered_graph.get_layerless_nodes().push(lnode)
    elk_to_lnode[child] = lnode
    lnode_to_elk[lnode.get_handle()] = child
  }
  layered_graph.set_property_int(
    internal_properties_max_model_order_nodes, node_model_order,
  )

  let mut edge_model_order = 0
  for edge in node_contained_edges(node) {
    let source_shapes = edge_sources(edge)
    if source_shapes.is_empty() {
      return None
    }
    let target_shapes = edge_targets(edge)
    if target_shapes.is_empty() {
      return None
    }

    let source_port = match
      recursive_layered_edge_endpoint_port(source_shapes, elk_to_lport) {
      Some(port) => port
      None =>
        match source_shapes[0] {
          PortShape(parent_port) =>
            match port_parent(parent_port) {
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
                      let mut source_side = recursive_layered_port_side_from_string(
                        recursive_layered_port_side_option(parent_port),
                      )
                      match source_side {
                        PortSide::SideUndefined => source_side = PortSide::East
                        _ => ()
                      }
                      recursive_layered_new_edge_port(
                        source_lnode,
                        source_side,
                        fix_owner_side=fix_owner_side || hierarchical_layout,
                      )
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
                recursive_layered_new_edge_port(
                  source_lnode,
                  PortSide::East,
                  fix_owner_side=fix_owner_side || hierarchical_layout,
                )
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
            match port_parent(parent_port) {
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
                      let mut target_side = recursive_layered_port_side_from_string(
                        recursive_layered_port_side_option(parent_port),
                      )
                      match target_side {
                        PortSide::SideUndefined => target_side = PortSide::West
                        _ => ()
                      }
                      recursive_layered_new_edge_port(
                        target_lnode,
                        target_side,
                        fix_owner_side=fix_owner_side || hierarchical_layout,
                      )
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
                recursive_layered_new_edge_port(
                  target_lnode,
                  PortSide::West,
                  fix_owner_side=fix_owner_side || hierarchical_layout,
                )
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
    l_edge.set_property_double(edge_thickness, edge_thickness.get_default())

    for elk_label in edge_labels(edge) {
      let text = label_text(elk_label)
      if text.is_empty() {
        continue
      }
      let llabel = new_l_label_text(text)
      llabel.get_size().x = label_width(elk_label)
      llabel.get_size().y = label_height(elk_label)
      llabel.get_position().x = label_x(elk_label)
      llabel.get_position().y = label_y(elk_label)
      let placement = recursive_layered_edge_label_placement(elk_label)
      llabel.set_property_string(edge_labels_placement, placement)
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
    lnode_to_elk,
    edge_to_ledge,
  })
}

///|
fn recursive_layered_apply_layout(
  context : RecursiveLayeredContext,
  parent_node : ElkNode,
) -> Unit {
  let mut rightmost = 0.0
  let mut max_bottom = 0.0
  let graph_offset = context.layered_graph.get_offset()
  let graph_size = context.layered_graph.get_size()
  let padding_value = context.layered_graph.get_padding()

  for entry in context.elk_to_lnode.to_array() {
    let (elk_node, layered_node) = entry
    let position = layered_node.get_position()
    let size = layered_node.get_size()
    let resolved_width = if size.x > 0.0 {
      size.x
    } else {
      node_width(elk_node)
    }
    let resolved_height = if size.y > 0.0 {
      size.y
    } else {
      node_height(elk_node)
    }
    let graph_x = position.x + graph_offset.x
    let graph_y = position.y + graph_offset.y
    let actual_x = graph_x + padding_value.left
    let actual_y = graph_y + padding_value.top
    node_set_location(elk_node, actual_x, actual_y)
    node_set_dimensions(elk_node, resolved_width, resolved_height)

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
    let is_parent_port = match port_parent(elk_port) {
      Some(owner) => owner == parent_node
      None => false
    }
    match context.lnode_to_elk.get(owner_lnode.get_handle()) {
      Some(owner_elk) =>
        if !is_parent_port && !node_children(owner_elk).is_empty() {
          continue
        }
      None => ()
    }
    if is_parent_port {
      let border_offset = recursive_layered_port_border_offset(elk_port)
      let mut ext_side = owner_lnode.get_property_port_side(
        internal_properties_ext_port_side,
      )
      match ext_side {
        PortSide::SideUndefined =>
          ext_side = recursive_layered_port_side_from_string(
            recursive_layered_port_side_option(elk_port),
          )
        _ => ()
      }
      let owner_position = owner_lnode.get_position()
      let owner_size = owner_lnode.get_size()
      let port_width_value = port_width(elk_port)
      let port_height_value = port_height(elk_port)
      resolved_port_x = owner_position.x + owner_size.x / 2.0
      resolved_port_y = owner_position.y + owner_size.y / 2.0

      match ext_side {
        PortSide::North => {
          resolved_port_x = resolved_port_x +
            padding_value.left +
            graph_offset.x -
            port_width_value / 2.0
          resolved_port_y = -port_height_value - border_offset
          owner_position.y = -(padding_value.top +
            border_offset +
            graph_offset.y)
        }
        PortSide::East => {
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
        PortSide::South => {
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
        PortSide::West => {
          resolved_port_x = -port_width_value - border_offset
          resolved_port_y = resolved_port_y +
            padding_value.top +
            graph_offset.y -
            port_height_value / 2.0
          owner_position.x = -(padding_value.left +
            border_offset +
            graph_offset.x)
        }
        PortSide::SideUndefined => {
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
            PortSide::SideUndefined =>
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
            PortSide::North => {
              resolved_port_x = resolved_port_x +
                padding_value.left +
                graph_offset.x -
                port_width_value / 2.0
              resolved_port_y = -port_height_value - border_offset
              owner_position.y = -(padding_value.top +
                border_offset +
                graph_offset.y)
            }
            PortSide::East => {
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
            PortSide::South => {
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
            PortSide::West => {
              resolved_port_x = -port_width_value - border_offset
              resolved_port_y = resolved_port_y +
                padding_value.top +
                graph_offset.y -
                port_height_value / 2.0
              owner_position.x = -(padding_value.left +
                border_offset +
                graph_offset.x)
            }
            PortSide::SideUndefined => {
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

    port_set_location(elk_port, resolved_port_x, resolved_port_y)
    let resolved_port_width = if is_parent_port {
      port_width(elk_port)
    } else {
      layered_port.get_size().x
    }
    let resolved_port_height = if is_parent_port {
      port_height(elk_port)
    } else {
      layered_port.get_size().y
    }
    port_set_dimensions(elk_port, resolved_port_width, resolved_port_height)
  }

  for entry in context.edge_to_ledge.to_array() {
    let (elk_edge, layered_edge) = entry
    ensure_edge_section_for_edge(elk_edge)
    if edge_sections(elk_edge).is_empty() {
      continue
    }
    let section = edge_sections(elk_edge)[0]
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
    edge_section_set_start(
      section,
      source_anchor.x + graph_offset.x + padding_value.left,
      source_anchor.y + graph_offset.y + padding_value.top,
    )
    edge_section_set_end(
      section,
      target_anchor.x + graph_offset.x + padding_value.left,
      target_anchor.y + graph_offset.y + padding_value.top,
    )

    let source_node = match source_port.get_node() {
      Some(value) => value
      None => continue
    }
    let target_node = match target_port.get_node() {
      Some(value) => value
      None => continue
    }
    match context.lnode_to_elk.get(source_node.get_handle()) {
      Some(elk_source) =>
        edge_section_set_incoming_shape(
          section,
          Some(make_node_shape(elk_source)),
        )
      None => ()
    }
    match context.lnode_to_elk.get(target_node.get_handle()) {
      Some(elk_target) =>
        edge_section_set_outgoing_shape(
          section,
          Some(make_node_shape(elk_target)),
        )
      None => ()
    }

    let edge_offset_x = graph_offset.x + padding_value.left
    let edge_offset_y = graph_offset.y + padding_value.top
    let layered_labels = layered_edge.get_labels()
    let mut layered_label_index = 0
    for elk_label in edge_labels(elk_edge) {
      if label_text(elk_label).is_empty() {
        continue
      }
      if layered_label_index >= layered_labels.length() {
        break
      }
      let layered_label = layered_labels[layered_label_index]
      layered_label_index += 1
      label_set_dimensions(
        elk_label,
        layered_label.get_size().x,
        layered_label.get_size().y,
      )
      label_set_location(
        elk_label,
        layered_label.get_position().x + edge_offset_x,
        layered_label.get_position().y + edge_offset_y,
      )
    }
  }

  let mut width = rightmost + padding_value.left + padding_value.right
  let mut height = max_bottom + padding_value.top + padding_value.bottom
  if width < 10.0 {
    width = 10.0
  }
  if height < 10.0 {
    height = 10.0
  }
  if recursive_layered_has_graph_property(
      context.layered_graph,
      GraphProperties::ExternalPorts,
    ) {
    node_set_string_property(parent_node, port_constraints, "FIXED_POS")
  }
  node_set_dimensions(parent_node, width, height)
}

///|
fn recursive_layered_try_layout(
  node : ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Bool {
  let context = match recursive_layered_create_context(node) {
    Some(value) => value
    None => return false
  }

  let layering_strategy = recursive_layered_primary_option(
    node, "org.eclipse.elk.layered.layering.strategy", "NETWORK_SIMPLEX",
  )
  let cycle_breaking_strategy = recursive_layered_primary_option(
    node, "org.eclipse.elk.layered.cycleBreaking.strategy", "GREEDY",
  )
  let crossing_strategy = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.layered.crossingMinimization.strategy",
    context.layered_graph.get_property_string(
      layered_options_crossing_minimization_strategy,
    ),
  )
  let node_promotion_strategy = recursive_layered_primary_option(
    node,
    "org.eclipse.elk.layered.nodePromotion.strategy",
    context.layered_graph.get_property_string(
      layered_options_layering_node_promotion_strategy,
    ),
  )
  let node_placement_strategy = recursive_layered_primary_option(
    node, "org.eclipse.elk.layered.nodePlacement.strategy", "BRANDES_KOEPF",
  )
  let direction_value = context.layered_graph.get_property_string(direction)
  let feedback_edges = context.layered_graph.get_property_bool(
    layered_options_feedback_edges,
  )
  let edge_routing_value = context.layered_graph.get_property_string(
    edge_routing,
  )

  let assembler = algorithm_assembler_create(layered_phase_descriptor)
  ignore(assembler.reset())
  ignore(
    assembler.set_phase(
      LayeredPhases::P1CycleBreaking,
      recursive_layered_cycle_breaking_factory(cycle_breaking_strategy),
    ),
  )
  ignore(
    assembler.set_phase(
      LayeredPhases::P2Layering,
      recursive_layered_layering_factory(layering_strategy),
    ),
  )
  ignore(
    assembler.set_phase(
      LayeredPhases::P3NodeOrdering,
      recursive_layered_crossing_factory(crossing_strategy),
    ),
  )
  ignore(
    assembler.set_phase(
      LayeredPhases::P4NodePlacement,
      recursive_layered_node_placement_factory(node_placement_strategy),
    ),
  )
  ignore(
    assembler.set_phase(
      LayeredPhases::P5EdgeRouting,
      edge_router_factory_factory_for(
        recursive_layered_parse_edge_routing(edge_routing_value),
      ),
    ),
  )
  ignore(
    assembler.add_processor_configuration(
      layout_processor_configuration_create(layered_phase_descriptor)
      .add_before(
        LayeredPhases::P4NodePlacement,
        new_layout_processor_factory(95024, 31, () => {
          new_innermost_node_margin_calculator_layout_processor()
        }),
      )
      .add_before(
        LayeredPhases::P4NodePlacement,
        new_layout_processor_factory(95025, 30, () => {
          new_label_and_node_size_processor_layout_processor()
        }),
      )
      .add_before(
        LayeredPhases::P5EdgeRouting,
        new_layout_processor_factory(95040, 40, () => {
          new_layer_size_and_graph_height_calculator_layout_processor()
        }),
      )
      .add_after(
        LayeredPhases::P5EdgeRouting,
        new_layout_processor_factory(95053, 53, () => {
          new_end_label_sorter_layout_processor()
        }),
      ),
    ),
  )
  if feedback_edges {
    ignore(
      assembler.add_processor_configuration(
        layout_processor_configuration_create(layered_phase_descriptor).add_before(
          LayeredPhases::P1CycleBreaking,
          new_layout_processor_factory(95030, 17, () => {
            new_port_side_processor_layout_processor()
          }),
        ),
      ),
    )
  } else {
    ignore(
      assembler.add_processor_configuration(
        layout_processor_configuration_create(layered_phase_descriptor).add_before(
          LayeredPhases::P3NodeOrdering,
          new_layout_processor_factory(95030, 17, () => {
            new_port_side_processor_layout_processor()
          }),
        ),
      ),
    )
  }

  if recursive_layered_requires_direction_transform(direction_value) &&
    recursive_layered_has_graph_property(
      context.layered_graph,
      GraphProperties::ExternalPorts,
    ) {
    ignore(
      assembler.add_processor_configuration(
        layout_processor_configuration_create(layered_phase_descriptor)
        .add_before(
          LayeredPhases::P1CycleBreaking,
          new_layout_processor_factory(95000, 0, () => {
            new_direction_preprocessor_layout_processor()
          }),
        )
        .add_after(
          LayeredPhases::P5EdgeRouting,
          new_layout_processor_factory(95056, 56, () => {
            new_direction_postprocessor_layout_processor()
          }),
        ),
      ),
    )
  }

  if node_promotion_strategy != "NONE" {
    ignore(
      assembler.add_processor_configuration(
        layout_processor_configuration_create(layered_phase_descriptor).add_before(
          LayeredPhases::P3NodeOrdering,
          new_layout_processor_factory(95026, 10, () => {
            new_node_promotion_layout_processor()
          }),
        ),
      ),
    )
  }

  if context.layered_graph.get_property_string(
      layered_options_consider_model_order_strategy,
    ) !=
    "NONE" {
    ignore(
      assembler.add_processor_configuration(
        layout_processor_configuration_create(layered_phase_descriptor).add_before(
          LayeredPhases::P3NodeOrdering,
          new_layout_processor_factory(95039, 20, () => {
            new_sort_by_input_model_processor_layout_processor()
          }),
        ),
      ),
    )
  }

  let algorithm = assembler.build(context.layered_graph)
  let algorithm_monitor = match progress_monitor.sub_task(1.0) {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(
    algorithm_monitor.begin("Layered layout", algorithm.length().to_double()),
  )
  for processor in algorithm {
    if algorithm_monitor.is_canceled() {
      algorithm_monitor.done()
      return false
    }
    processor.process(context.layered_graph, algorithm_monitor.sub_task(1.0))
  }
  algorithm_monitor.done()
  recursive_layered_apply_layout(context, node)
  true
}

///|
fn layout_node_recursively(
  node : ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  if node_get_bool_property(node, no_layout) {
    return
  }
  let children = node_children(node)
  for child in children {
    layout_node_recursively(child, progress_monitor)
  }
  if children.is_empty() {
    recursive_layout_node_labels(node)
    return
  }
  let resolved = node_get_string_property(node, resolved_algorithm)
  if resolved.is_empty() {
    abort("Resolved algorithm is not set")
  }
  if layout_meta_data_service_get_algorithm_data_by_suffix(resolved) is None {
    abort("Resolved algorithm is unknown")
  }
  if resolved == mrtree_algorithm_id {
    let provider = new_mrtree_tree_layout_provider()
    provider.layout(node, progress_monitor)
    return
  }
  if resolved == "org.eclipse.elk.layered" {
    if recursive_layered_try_layout(node, progress_monitor) {
      return
    }
  }
  let mut rightmost = 0.0
  let mut max_height = 0.0
  let mut cursor_x = 12.0
  for child in children {
    let child_width = max_positive(node_width(child), 10.0)
    let child_height = max_positive(node_height(child), 10.0)
    node_set_dimensions(child, child_width, child_height)
    node_set_location(child, cursor_x, 12.0)
    let child_right = cursor_x + child_width
    if child_right > rightmost {
      rightmost = child_right
    }
    cursor_x = child_right + 20.0
    if child_height > max_height {
      max_height = child_height
    }
  }
  for edge in node_contained_edges(node) {
    ensure_edge_section_for_edge(edge)
  }
  let padding_value = parse_node_padding(node)
  let label_top_reserve = recursive_layout_label_top_reserve(node)
  let top_reserved_for_single_child = if label_top_reserve > padding_value.top {
    label_top_reserve
  } else {
    padding_value.top
  }
  if children.length() == 1 {
    let child = children[0]
    let child_width = max_positive(node_width(child), 10.0)
    let child_height = max_positive(node_height(child), 10.0)
    let requested_width = child_width + padding_value.left + padding_value.right
    let requested_height = child_height +
      top_reserved_for_single_child +
      padding_value.bottom
    if requested_width > rightmost + 12.0 {
      rightmost = requested_width - 12.0
    }
    if requested_height > max_height + 24.0 {
      max_height = requested_height - 24.0
    }
  }
  let mut width = max_positive(rightmost + 12.0, 10.0)
  let mut height = max_positive(max_height + 24.0, 10.0)
  if has_minimum_size_constraint(node) {
    let min_size = parse_node_minimum_size(node)
    if width < min_size.x {
      width = min_size.x
    }
    if height < min_size.y {
      height = min_size.y
    }
  }
  node_set_dimensions(node, width, height)
  if children.length() == 1 {
    let child = children[0]
    let child_width = max_positive(
      node_width(node) - padding_value.left - padding_value.right,
      0.0,
    )
    let child_height = max_positive(
      node_height(node) - top_reserved_for_single_child - padding_value.bottom,
      0.0,
    )
    node_set_location(child, padding_value.left, top_reserved_for_single_child)
    node_set_dimensions(child, child_width, child_height)
  }
  recursive_layout_node_labels(node)
}

///|
pub fn RecursiveGraphLayoutEngine::layout(
  self : RecursiveGraphLayoutEngine,
  layout_graph : ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  ignore(self)
  ignore(progress_monitor.begin("Recursive Graph Layout", 1.0))
  if node_get_string_property(layout_graph, resolved_algorithm).is_empty() {
    let resolver = new_layout_algorithm_resolver()
    apply_visitors(layout_graph, [resolver.to_visitor()])
  }
  layout_node_recursively(layout_graph, progress_monitor)
  progress_monitor.done()
}
