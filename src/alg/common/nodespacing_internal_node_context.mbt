///|
let node_context_topdown_layout_property : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.topdownLayout", false,
)

///|
let node_context_node_size_constraints_property : @graph.IProperty[
  Array[String],
] = @graph.new_property("org.eclipse.elk.nodeSize.constraints", [])

///|
let node_context_node_size_options_property : @graph.IProperty[Array[String]] = @graph.new_property(
  "org.eclipse.elk.nodeSize.options",
  ["DEFAULT_MINIMUM_SIZE"],
)

///|
let node_context_port_labels_placement_property : @graph.IProperty[
  Array[String],
] = @graph.new_property("org.eclipse.elk.portLabels.placement", ["OUTSIDE"])

///|
let node_context_node_labels_placement_property : @graph.IProperty[
  Array[String],
] = @graph.new_property("org.eclipse.elk.nodeLabels.placement", [])

///|
let node_context_node_labels_padding_property : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.nodeLabels.padding", "[top=5,left=5,bottom=5,right=5]",
)

///|
let node_context_spacing_ports_surrounding_property : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.spacing.portsSurrounding", "[top=0,left=0,bottom=0,right=0]",
)

///|
let node_context_port_alignment_default_property : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.portAlignment.default", "DISTRIBUTED",
)

///|
let node_context_port_alignment_north_property : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.portAlignment.north", "",
)

///|
let node_context_port_alignment_south_property : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.portAlignment.south", "",
)

///|
let node_context_port_alignment_east_property : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.portAlignment.east", "",
)

///|
let node_context_port_alignment_west_property : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.portAlignment.west", "",
)

///|
fn node_context_parse_size_constraints(
  values : Array[String],
) -> Array[@core.SizeConstraint] {
  let parsed : Array[@core.SizeConstraint] = []
  for value in values {
    if value == "PORTS" {
      parsed.push(Ports)
    } else if value == "PORT_LABELS" {
      parsed.push(PortLabels)
    } else if value == "NODE_LABELS" {
      parsed.push(NodeLabels)
    } else if value == "MINIMUM_SIZE" {
      parsed.push(MinimumSize)
    } else if value == "MINIMUM_SIZE_WITH_PORTS" {
      parsed.push(Ports)
      parsed.push(MinimumSize)
    }
  }
  parsed
}

///|
fn node_context_parse_size_options(
  values : Array[String],
) -> Array[@core.SizeOptions] {
  let parsed : Array[@core.SizeOptions] = []
  for value in values {
    for option in @core.size_options_values() {
      if @core.size_options_to_string(option) == value {
        parsed.push(option)
      }
    }
  }
  parsed
}

///|
fn node_context_parse_port_label_placement(
  values : Array[String],
) -> Array[@core.PortLabelPlacement] {
  let parsed : Array[@core.PortLabelPlacement] = []
  for value in values {
    for option in @core.port_label_placement_values() {
      if @core.port_label_placement_to_string(option) == value {
        parsed.push(option)
      }
    }
  }
  parsed
}

///|
fn node_context_parse_node_label_placement(
  values : Array[String],
) -> Array[@core.NodeLabelPlacement] {
  let parsed : Array[@core.NodeLabelPlacement] = []
  for value in values {
    for option in @core.node_label_placement_values() {
      if @core.node_label_placement_to_string(option) == value {
        parsed.push(option)
      }
    }
  }
  parsed
}

///|
fn node_context_parse_port_constraints(value : String) -> @core.PortConstraints {
  for constraint in @core.port_constraints_values() {
    if @core.port_constraints_to_string(constraint) == value {
      return constraint
    }
  }
  Undefined
}

///|
fn node_context_parse_port_alignment(value : String) -> @core.PortAlignment {
  for alignment in [@core.Distributed, @core.Justified, Begin, Center, End] {
    if @core.port_alignment_to_string(alignment) == value {
      return alignment
    }
  }
  @core.Distributed
}

///|
fn node_context_contains_size_option(
  options : Array[@core.SizeOptions],
  target : @core.SizeOptions,
) -> Bool {
  let expected = @core.size_options_to_string(target)
  for option in options {
    if @core.size_options_to_string(option) == expected {
      return true
    }
  }
  false
}

///|
fn node_context_parse_padding(value : String) -> @core.ElkPadding {
  let parsed = @core.new_elk_padding()
  parsed.parse(value)
  parsed
}

///|
fn node_context_parse_margin(value : String) -> @core.ElkMargin {
  let parsed = @core.new_elk_margin()
  parsed.parse(value)
  parsed
}

///|
fn node_context_port_side_order(port_side : @core.PortSide) -> Int {
  match port_side {
    SideUndefined => 0
    North => 1
    East => 2
    South => 3
    West => 4
  }
}

///|
pub fn node_context_port_side_key(port_side : @core.PortSide) -> String {
  @core.port_side_to_string(port_side)
}

///|
pub fn node_context_node_label_location_key(
  location : NodeLabelLocation,
) -> String {
  node_label_location_to_string(location)
}

///|
pub fn node_context_port_constraints_equals(
  left : @core.PortConstraints,
  right : @core.PortConstraints,
) -> Bool {
  @core.port_constraints_to_string(left) ==
  @core.port_constraints_to_string(right)
}

///|
pub fn node_context_port_alignment_equals(
  left : @core.PortAlignment,
  right : @core.PortAlignment,
) -> Bool {
  @core.port_alignment_to_string(left) == @core.port_alignment_to_string(right)
}

///|
pub fn node_context_compare_port_sides(
  port_side1 : @core.PortSide,
  port_side2 : @core.PortSide,
) -> Int {
  node_context_port_side_order(port_side1).compare(
    node_context_port_side_order(port_side2),
  )
}

///|
pub struct NodeContext {
  node : @core.ElkNodeAdapter
  node_size : @core.KVector
  treat_as_compound_node : Bool
  size_constraints : Array[@core.SizeConstraint]
  size_options : Array[@core.SizeOptions]
  port_constraints : @core.PortConstraints
  port_labels_placement : Array[@core.PortLabelPlacement]
  port_labels_treat_as_group : Bool
  node_label_placement : Array[@core.NodeLabelPlacement]
  node_labels_padding : @core.ElkPadding
  node_label_spacing : Double
  label_label_spacing : Double
  label_cell_spacing : Double
  port_port_spacing : Double
  port_label_spacing_horizontal : Double
  port_label_spacing_vertical : Double
  surrounding_port_margins : @core.ElkMargin
  topdown_layout : Bool
  port_contexts : Map[String, Array[PortContext]]
  node_container : StripContainerCell
  node_container_middle_row : StripContainerCell
  mut inside_node_label_container : GridContainerCell
  inside_port_label_cells : Map[String, AtomicCell]
  outside_node_label_containers : Map[String, StripContainerCell]
  node_label_cells : Map[String, LabelCell]
}

///|
pub fn new_node_context(node : @core.ElkNodeAdapter) -> NodeContext {
  let node_size = node.get_size().clone()

  let topdown_layout = node.get_property_bool(
    node_context_topdown_layout_property,
  )
  let treat_as_compound_node = node.is_compound_node() ||
    node.get_property_bool(@core.inside_self_loops_activate)

  let size_constraints = node_context_parse_size_constraints(
    node.get_property_string_array(node_context_node_size_constraints_property),
  )
  let size_options = node_context_parse_size_options(
    node.get_property_string_array(node_context_node_size_options_property),
  )
  let parsed_port_constraints = node_context_parse_port_constraints(
    node.get_property_string(@core.port_constraints),
  )
  let port_labels_placement = node_context_parse_port_label_placement(
    node.get_property_string_array(node_context_port_labels_placement_property),
  )
  if !@core.port_label_placement_is_valid(port_labels_placement) {
    abort("Invalid port label placement.")
  }
  let port_labels_treat_as_group = node.get_property_bool(
    @core.port_labels_treat_as_group,
  )
  let node_label_placement = node_context_parse_node_label_placement(
    node.get_property_string_array(node_context_node_labels_placement_property),
  )
  if !@core.node_label_placement_is_valid(node_label_placement) {
    abort("Invalid node label placement.")
  }

  let node_labels_padding = node_context_parse_padding(
    node.get_property_string(node_context_node_labels_padding_property),
  )
  let node_label_spacing = @core.individual_spacings_get_individual_or_inherited(
    node.get_node(),
    @core.spacing_label_node,
  )
  let label_label_spacing = @core.individual_spacings_get_individual_or_inherited(
    node.get_node(),
    @core.spacing_label_label,
  )
  let port_port_spacing = @core.individual_spacings_get_individual_or_inherited(
    node.get_node(),
    @core.spacing_port_port,
  )
  let port_label_spacing_horizontal = @core.individual_spacings_get_individual_or_inherited(
    node.get_node(),
    @core.spacing_label_port_horizontal,
  )
  let port_label_spacing_vertical = @core.individual_spacings_get_individual_or_inherited(
    node.get_node(),
    @core.spacing_label_port_vertical,
  )
  let surrounding_port_margins = node_context_parse_margin(
    node.get_property_string(node_context_spacing_ports_surrounding_property),
  )

  let symmetry = !node_context_contains_size_option(size_options, Asymmetrical)
  let node_container = new_strip_container_cell(Vertical, symmetry, 0.0)
  let node_container_middle_row = new_strip_container_cell(
    Horizontal,
    symmetry,
    0.0,
  )
  node_container.set_cell(Center, Some(node_container_middle_row))

  {
    node,
    node_size,
    treat_as_compound_node,
    size_constraints,
    size_options,
    port_constraints: parsed_port_constraints,
    port_labels_placement,
    port_labels_treat_as_group,
    node_label_placement,
    node_labels_padding,
    node_label_spacing,
    label_label_spacing,
    label_cell_spacing: 2.0 * label_label_spacing,
    port_port_spacing,
    port_label_spacing_horizontal,
    port_label_spacing_vertical,
    surrounding_port_margins,
    topdown_layout,
    port_contexts: {},
    node_container,
    node_container_middle_row,
    inside_node_label_container: new_grid_container_cell(false, symmetry, 0.0),
    inside_port_label_cells: {},
    outside_node_label_containers: {},
    node_label_cells: {},
  }
}

///|
pub fn NodeContext::apply_node_size(self : NodeContext) -> Unit {
  self.node.set_size(self.node_size)
}

///|
fn node_context_port_contexts_of_side(
  node_context : NodeContext,
  port_side : @core.PortSide,
) -> Array[PortContext] {
  let side_key = node_context_port_side_key(port_side)
  match node_context.port_contexts.get(side_key) {
    Some(value) => value
    None => {
      let contexts : Array[PortContext] = []
      node_context.port_contexts[side_key] = contexts
      contexts
    }
  }
}

///|
fn node_context_compare_port_contexts(
  port_context1 : PortContext,
  port_context2 : PortContext,
) -> Int {
  let port_side_comparison = node_context_compare_port_sides(
    port_context1.port.get_side(),
    port_context2.port.get_side(),
  )
  if port_side_comparison != 0 {
    return port_side_comparison
  }

  match port_context1.port.get_side() {
    North => port_context1.volatile_id.compare(port_context2.volatile_id)
    East => port_context1.volatile_id.compare(port_context2.volatile_id)
    South => port_context2.volatile_id.compare(port_context1.volatile_id)
    West => port_context2.volatile_id.compare(port_context1.volatile_id)
    SideUndefined => 0
  }
}

///|
fn node_context_sort_port_contexts(port_contexts : Array[PortContext]) -> Unit {
  let length = port_contexts.length()
  if length <= 1 {
    return
  }

  for i in 1..<length {
    let key = port_contexts[i]
    let mut j = i
    while j > 0 &&
          node_context_compare_port_contexts(port_contexts[j - 1], key) > 0 {
      port_contexts[j] = port_contexts[j - 1]
      j = j - 1
    }
    port_contexts[j] = key
  }
}

///|
pub fn node_context_add_port_context(
  node_context : NodeContext,
  port_side : @core.PortSide,
  port_context : PortContext,
) -> Unit {
  let port_contexts = node_context_port_contexts_of_side(
    node_context, port_side,
  )
  port_contexts.push(port_context)
  node_context_sort_port_contexts(port_contexts)
}

///|
pub fn node_context_get_port_contexts(
  node_context : NodeContext,
  port_side : @core.PortSide,
) -> Array[PortContext] {
  node_context_port_contexts_of_side(node_context, port_side)
}

///|
pub fn node_context_get_all_port_contexts(
  node_context : NodeContext,
) -> Array[PortContext] {
  let contexts : Array[PortContext] = []
  for
    side in [
      @core.PortSide::North,
      @core.PortSide::East,
      @core.PortSide::South,
      @core.PortSide::West,
    ] {
    for port_context in node_context_get_port_contexts(node_context, side) {
      contexts.push(port_context)
    }
  }
  contexts
}

///|
pub fn NodeContext::has_size_constraint(
  self : NodeContext,
  constraint : @core.SizeConstraint,
) -> Bool {
  let expected = @core.size_constraint_to_string(constraint)
  for current in self.size_constraints {
    if @core.size_constraint_to_string(current) == expected {
      return true
    }
  }
  false
}

///|
pub fn NodeContext::has_size_option(
  self : NodeContext,
  option : @core.SizeOptions,
) -> Bool {
  node_context_contains_size_option(self.size_options, option)
}

///|
pub fn NodeContext::has_port_label_placement(
  self : NodeContext,
  placement : @core.PortLabelPlacement,
) -> Bool {
  let expected = @core.port_label_placement_to_string(placement)
  for current in self.port_labels_placement {
    if @core.port_label_placement_to_string(current) == expected {
      return true
    }
  }
  false
}

///|
pub fn NodeContext::get_port_alignment(
  self : NodeContext,
  port_side : @core.PortSide,
) -> @core.PortAlignment {
  let alignment_text = match port_side {
    North =>
      if self.node.has_property_string(
          node_context_port_alignment_north_property,
        ) {
        self.node.get_property_string(
          node_context_port_alignment_north_property,
        )
      } else {
        self.node.get_property_string(
          node_context_port_alignment_default_property,
        )
      }
    South =>
      if self.node.has_property_string(
          node_context_port_alignment_south_property,
        ) {
        self.node.get_property_string(
          node_context_port_alignment_south_property,
        )
      } else {
        self.node.get_property_string(
          node_context_port_alignment_default_property,
        )
      }
    East =>
      if self.node.has_property_string(
          node_context_port_alignment_east_property,
        ) {
        self.node.get_property_string(node_context_port_alignment_east_property)
      } else {
        self.node.get_property_string(
          node_context_port_alignment_default_property,
        )
      }
    West =>
      if self.node.has_property_string(
          node_context_port_alignment_west_property,
        ) {
        self.node.get_property_string(node_context_port_alignment_west_property)
      } else {
        self.node.get_property_string(
          node_context_port_alignment_default_property,
        )
      }
    SideUndefined =>
      self.node.get_property_string(
        node_context_port_alignment_default_property,
      )
  }
  node_context_parse_port_alignment(alignment_text)
}
