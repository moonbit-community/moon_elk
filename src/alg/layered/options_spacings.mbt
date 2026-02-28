///|
fn spacings_node_type_ordinal(node_type : NodeType) -> Int {
  match node_type {
    NodeType::Normal => 0
    NodeType::LongEdge => 1
    NodeType::ExternalPort => 2
    NodeType::NorthSouthPort => 3
    NodeType::LabelNode => 4
    NodeType::BreakingPoint => 5
    NodeType::Placeholder => 6
    NodeType::NonshiftingPlaceholder => 7
  }
}

///|
fn spacings_new_option_grid(
  size : Int,
) -> Array[Array[@graph.IProperty[Double]?]] {
  let grid : Array[Array[@graph.IProperty[Double]?]] = []
  for _ in 0..<size {
    let row : Array[@graph.IProperty[Double]?] = []
    for _ in 0..<size {
      row.push(None)
    }
    grid.push(row)
  }
  grid
}

///|
fn spacings_require_option(
  option : @graph.IProperty[Double]?,
) -> @graph.IProperty[Double] raise LayeredSpacingsException {
  match option {
    Some(value) => value
    None => layered_spacings_raise("Unspecified spacing for node types.")
  }
}

///|
pub fn layered_spacings_get_individual_or_default(
  node : LNode,
  property : @graph.IProperty[Double],
) -> Double {
  if node.has_property_double(property) {
    node.get_property_double(property)
  } else {
    node.get_graph().get_property_double(property)
  }
}

///|
pub struct Spacings {
  graph : LGraph
  node_type_spacing_options_horizontal : Array[Array[@graph.IProperty[Double]?]]
  node_type_spacing_options_vertical : Array[Array[@graph.IProperty[Double]?]]
}

///|
pub fn new_layered_spacings(graph : LGraph) -> Spacings {
  let size = 8
  let spacings = {
    graph,
    node_type_spacing_options_horizontal: spacings_new_option_grid(size),
    node_type_spacing_options_vertical: spacings_new_option_grid(size),
  }
  spacings.precalculate_node_type_spacings()
  spacings
}

///|
fn Spacings::set_same_type_spacing_vertical(
  self : Spacings,
  node_type : NodeType,
  spacing : @graph.IProperty[Double],
) -> Unit {
  let index = spacings_node_type_ordinal(node_type)
  self.node_type_spacing_options_vertical[index][index] = Some(spacing)
}

///|
fn Spacings::set_same_type_spacing(
  self : Spacings,
  node_type : NodeType,
  spacing_vertical : @graph.IProperty[Double],
  spacing_horizontal : @graph.IProperty[Double],
) -> Unit {
  let index = spacings_node_type_ordinal(node_type)
  self.node_type_spacing_options_vertical[index][index] = Some(spacing_vertical)
  self.node_type_spacing_options_horizontal[index][index] = Some(
    spacing_horizontal,
  )
}

///|
fn Spacings::set_pair_spacing_vertical(
  self : Spacings,
  first : NodeType,
  second : NodeType,
  spacing : @graph.IProperty[Double],
) -> Unit {
  let first_index = spacings_node_type_ordinal(first)
  let second_index = spacings_node_type_ordinal(second)
  self.node_type_spacing_options_vertical[first_index][second_index] = Some(
    spacing,
  )
  self.node_type_spacing_options_vertical[second_index][first_index] = Some(
    spacing,
  )
}

///|
fn Spacings::set_pair_spacing(
  self : Spacings,
  first : NodeType,
  second : NodeType,
  spacing_vertical : @graph.IProperty[Double],
  spacing_horizontal : @graph.IProperty[Double],
) -> Unit {
  let first_index = spacings_node_type_ordinal(first)
  let second_index = spacings_node_type_ordinal(second)

  self.node_type_spacing_options_vertical[first_index][second_index] = Some(
    spacing_vertical,
  )
  self.node_type_spacing_options_vertical[second_index][first_index] = Some(
    spacing_vertical,
  )

  self.node_type_spacing_options_horizontal[first_index][second_index] = Some(
    spacing_horizontal,
  )
  self.node_type_spacing_options_horizontal[second_index][first_index] = Some(
    spacing_horizontal,
  )
}

///|
fn Spacings::precalculate_node_type_spacings(self : Spacings) -> Unit {
  self.set_same_type_spacing(
    NodeType::Normal,
    @core.spacing_node_node,
    layered_options_spacing_node_node_between_layers,
  )
  self.set_pair_spacing(
    NodeType::Normal,
    NodeType::LongEdge,
    @core.spacing_edge_node,
    layered_options_spacing_edge_node_between_layers,
  )
  self.set_pair_spacing_vertical(
    NodeType::Normal,
    NodeType::NorthSouthPort,
    @core.spacing_edge_node,
  )
  self.set_pair_spacing_vertical(
    NodeType::Normal,
    NodeType::ExternalPort,
    @core.spacing_edge_node,
  )
  self.set_pair_spacing(
    NodeType::Normal,
    NodeType::LabelNode,
    @core.spacing_node_node,
    layered_options_spacing_node_node_between_layers,
  )

  self.set_same_type_spacing(
    NodeType::LongEdge,
    @core.spacing_edge_edge,
    layered_options_spacing_edge_edge_between_layers,
  )
  self.set_pair_spacing_vertical(
    NodeType::LongEdge,
    NodeType::NorthSouthPort,
    @core.spacing_edge_edge,
  )
  self.set_pair_spacing_vertical(
    NodeType::LongEdge,
    NodeType::ExternalPort,
    @core.spacing_edge_edge,
  )
  self.set_pair_spacing(
    NodeType::LongEdge,
    NodeType::LabelNode,
    @core.spacing_edge_node,
    layered_options_spacing_edge_node_between_layers,
  )

  self.set_same_type_spacing_vertical(
    NodeType::NorthSouthPort,
    @core.spacing_edge_edge,
  )
  self.set_pair_spacing_vertical(
    NodeType::NorthSouthPort,
    NodeType::ExternalPort,
    @core.spacing_edge_edge,
  )
  self.set_pair_spacing_vertical(
    NodeType::NorthSouthPort,
    NodeType::LabelNode,
    @core.spacing_label_node,
  )

  self.set_same_type_spacing_vertical(
    NodeType::ExternalPort,
    @core.spacing_port_port,
  )
  self.set_pair_spacing(
    NodeType::ExternalPort,
    NodeType::LabelNode,
    @core.spacing_label_port_vertical,
    @core.spacing_label_port_horizontal,
  )

  self.set_same_type_spacing(
    NodeType::LabelNode,
    @core.spacing_edge_edge,
    @core.spacing_edge_edge,
  )

  self.set_same_type_spacing(
    NodeType::BreakingPoint,
    @core.spacing_edge_edge,
    layered_options_spacing_edge_edge_between_layers,
  )
  self.set_pair_spacing(
    NodeType::BreakingPoint,
    NodeType::Normal,
    @core.spacing_edge_node,
    layered_options_spacing_edge_node_between_layers,
  )
  self.set_pair_spacing(
    NodeType::BreakingPoint,
    NodeType::LabelNode,
    @core.spacing_edge_node,
    layered_options_spacing_edge_node_between_layers,
  )
  self.set_pair_spacing(
    NodeType::BreakingPoint,
    NodeType::LongEdge,
    @core.spacing_edge_node,
    layered_options_spacing_edge_node_between_layers,
  )
}

///|
fn Spacings::get_local_spacing(
  _self : Spacings,
  first : LNode,
  second : LNode,
  mapping : Array[Array[@graph.IProperty[Double]?]],
) -> Double raise LayeredSpacingsException {
  let first_type = first.get_type()
  let second_type = second.get_type()
  let layout_option = spacings_require_option(
    mapping[spacings_node_type_ordinal(first_type)][spacings_node_type_ordinal(
      second_type,
    )],
  )
  let first_spacing = layered_spacings_get_individual_or_default(
    first, layout_option,
  )
  let second_spacing = layered_spacings_get_individual_or_default(
    second, layout_option,
  )
  if first_spacing >= second_spacing {
    first_spacing
  } else {
    second_spacing
  }
}

///|
fn Spacings::get_local_spacing_for_node_types(
  self : Spacings,
  first_type : NodeType,
  second_type : NodeType,
  mapping : Array[Array[@graph.IProperty[Double]?]],
) -> Double raise LayeredSpacingsException {
  let layout_option = spacings_require_option(
    mapping[spacings_node_type_ordinal(first_type)][spacings_node_type_ordinal(
      second_type,
    )],
  )
  self.graph.get_property_double(layout_option)
}

///|
pub fn Spacings::get_horizontal_spacing(
  self : Spacings,
  first : LNode,
  second : LNode,
) -> Double raise LayeredSpacingsException {
  self.get_local_spacing(
    first,
    second,
    self.node_type_spacing_options_horizontal,
  )
}

///|
pub fn Spacings::get_horizontal_spacing_for_node_type(
  self : Spacings,
  first_type : NodeType,
  second_type : NodeType,
) -> Double raise LayeredSpacingsException {
  self.get_local_spacing_for_node_types(
    first_type,
    second_type,
    self.node_type_spacing_options_horizontal,
  )
}

///|
pub fn Spacings::get_vertical_spacing(
  self : Spacings,
  first : LNode,
  second : LNode,
) -> Double raise LayeredSpacingsException {
  self.get_local_spacing(first, second, self.node_type_spacing_options_vertical)
}

///|
pub fn Spacings::get_vertical_spacing_for_node_type(
  self : Spacings,
  first_type : NodeType,
  second_type : NodeType,
) -> Double raise LayeredSpacingsException {
  self.get_local_spacing_for_node_types(
    first_type,
    second_type,
    self.node_type_spacing_options_vertical,
  )
}
