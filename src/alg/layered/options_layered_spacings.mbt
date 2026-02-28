///|
let layered_spacings_double_eq_epsilon = 0.0001

///|
pub let layered_spacings_base_spacing_option : @graph.IProperty[Double] = @core.spacing_node_node

///|
pub suberror LayeredSpacingsException {
  LayeredSpacingsException(String)
} derive(Show, ToJson)

///|
fn[T] layered_spacings_raise(
  message : String,
) -> T raise LayeredSpacingsException {
  raise LayeredSpacingsException(message)
}

///|
pub fn layered_spacings_exception_message(
  err : LayeredSpacingsException,
) -> String {
  match err {
    LayeredSpacingsException(message) => message
  }
}

///|
fn layered_spacings_dependent_spacing_options() -> Array[
  @graph.IProperty[Double],
] {
  [
    @core.spacing_component_component, @core.spacing_edge_edge, @core.spacing_edge_label,
    @core.spacing_edge_node, @core.spacing_label_label, @core.spacing_label_node,
    @core.spacing_label_port_horizontal, @core.spacing_label_port_vertical, @core.spacing_node_self_loop,
    @core.spacing_port_port, layered_options_spacing_edge_edge_between_layers, layered_options_spacing_edge_node_between_layers,
    layered_options_spacing_node_node_between_layers,
  ]
}

///|
fn layered_spacings_factor_index(
  factors : Array[(@graph.IProperty[Double], Double)],
  option : @graph.IProperty[Double],
) -> Int? {
  for i in 0..<factors.length() {
    let (current_option, _) = factors[i]
    if current_option.get_id() == option.get_id() {
      return Some(i)
    }
  }
  None
}

///|
fn layered_spacings_set_factor(
  factors : Array[(@graph.IProperty[Double], Double)],
  option : @graph.IProperty[Double],
  factor : Double,
) -> Unit raise LayeredSpacingsException {
  match layered_spacings_factor_index(factors, option) {
    Some(index) => factors[index] = (option, factor)
    None =>
      layered_spacings_raise(
        "'\{option.get_id()}' is not a configurable spacing option.",
      )
  }
}

///|
pub struct LayeredSpacingsBuilder {
  base_spacing : Double
  mut overwrite : Bool
  factors : Array[(@graph.IProperty[Double], Double)]
}

///|
pub fn layered_spacings_with_base_value(
  base_spacing : Double,
) -> LayeredSpacingsBuilder {
  let factors = [(layered_spacings_base_spacing_option, 1.0)]
  for option in layered_spacings_dependent_spacing_options() {
    let factor = option.get_default() /
      layered_spacings_base_spacing_option.get_default()
    factors.push((option, factor))
  }
  { base_spacing, overwrite: false, factors }
}

///|
pub fn LayeredSpacingsBuilder::factors(
  self : LayeredSpacingsBuilder,
) -> Array[(@graph.IProperty[Double], Double)] {
  self.factors.copy()
}

///|
pub fn LayeredSpacingsBuilder::factor_for(
  self : LayeredSpacingsBuilder,
  option : @graph.IProperty[Double],
) -> Double raise LayeredSpacingsException {
  match layered_spacings_factor_index(self.factors, option) {
    Some(index) => {
      let (_, factor) = self.factors[index]
      factor
    }
    None =>
      layered_spacings_raise(
        "'\{option.get_id()}' is not a configurable spacing option.",
      )
  }
}

///|
pub fn LayeredSpacingsBuilder::with_factor(
  self : LayeredSpacingsBuilder,
  spacing_option : @graph.IProperty[Double],
  factor : Double,
) -> LayeredSpacingsBuilder raise LayeredSpacingsException {
  if layered_spacings_factor_index(self.factors, spacing_option) is None {
    layered_spacings_raise(
      "'\{spacing_option.get_id()}' is not a configurable spacing option.",
    )
  }
  if factor < 0.0 {
    layered_spacings_raise(
      "The factor for '\{spacing_option.get_id()}' must not be negative (\{factor}).",
    )
  }
  if spacing_option.get_id() == layered_spacings_base_spacing_option.get_id() {
    layered_spacings_raise(
      "'\{spacing_option.get_id()}' is the base spacing option not allowed to use with 'with_factor'.",
    )
  }
  layered_spacings_set_factor(self.factors, spacing_option, factor)
  self
}

///|
pub fn LayeredSpacingsBuilder::with_value(
  self : LayeredSpacingsBuilder,
  spacing_option : @graph.IProperty[Double],
  value : Double,
) -> LayeredSpacingsBuilder raise LayeredSpacingsException {
  if layered_spacings_factor_index(self.factors, spacing_option) is None {
    layered_spacings_raise(
      "'\{spacing_option.get_id()}' is not a configurable spacing option.",
    )
  }
  if value < 0.0 {
    layered_spacings_raise(
      "The value for '\{spacing_option.get_id()}' must not be negative (\{value}).",
    )
  }
  if spacing_option.get_id() == layered_spacings_base_spacing_option.get_id() {
    layered_spacings_raise(
      "'\{spacing_option.get_id()}' is the base spacing option not allowed to use with 'with_value'.",
    )
  }
  layered_spacings_set_factor(
    self.factors,
    spacing_option,
    value / self.base_spacing,
  )
  self
}

///|
pub fn LayeredSpacingsBuilder::with_overwrite(
  self : LayeredSpacingsBuilder,
  shall_overwrite : Bool,
) -> LayeredSpacingsBuilder {
  self.overwrite = shall_overwrite
  self
}

///|
pub fn LayeredSpacingsBuilder::build(
  self : LayeredSpacingsBuilder,
) -> (LGraph) -> Unit {
  if !self.overwrite &&
    (self.base_spacing - layered_spacings_base_spacing_option.get_default()).abs() <=
    layered_spacings_double_eq_epsilon {
    return _ => ()
  }

  let overwrite = self.overwrite
  let base_spacing = self.base_spacing
  let factors = self.factors.copy()
  graph => {
    for entry in factors {
      let (property, factor) = entry
      if overwrite || !graph.has_property_double(property) {
        graph.set_property_double(property, factor * base_spacing)
      }
    }
  }
}

///|
pub fn LayeredSpacingsBuilder::apply(
  self : LayeredSpacingsBuilder,
  graph : LGraph,
) -> Unit {
  self.build()(graph)
}
