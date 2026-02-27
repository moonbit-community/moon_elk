///|
let spacing_double_eq_epsilon = 0.0001

///|
pub(all) struct ElkCoreSpacingsBuilder {
  base_spacing : Double
  mut overwrite : Bool
  factors : Array[(@graph.IProperty[Double], Double)]
}

///|
pub suberror ElkSpacingsException {
  ElkSpacingsException(String)
} derive(Show, ToJson)

///|
fn[T] elk_spacings_raise(message : String) -> T raise ElkSpacingsException {
  raise ElkSpacingsException(message)
}

///|
pub fn elk_spacings_exception_message(err : ElkSpacingsException) -> String {
  match err {
    ElkSpacingsException(message) => message
  }
}

///|
fn elk_core_dependent_spacing_options() -> Array[@graph.IProperty[Double]] {
  [
    spacing_component_component, spacing_edge_edge, spacing_edge_label, spacing_edge_node,
    spacing_label_label, spacing_label_node, spacing_label_port_horizontal, spacing_label_port_vertical,
    spacing_node_self_loop, spacing_port_port,
  ]
}

///|
pub fn elk_spacings_with_base_value(
  base_spacing : Double,
) -> ElkCoreSpacingsBuilder {
  let factors = [(spacing_node_node, 1.0)]
  for option in elk_core_dependent_spacing_options() {
    let factor = option.get_default() / spacing_node_node.get_default()
    factors.push((option, factor))
  }
  { base_spacing, overwrite: false, factors }
}

///|
fn factor_index(
  factors : Array[(@graph.IProperty[Double], Double)],
  option : @graph.IProperty[Double],
) -> Int? {
  for i = 0; i < factors.length(); i = i + 1 {
    let (current_option, _) = factors[i]
    if current_option.get_id() == option.get_id() {
      return Some(i)
    }
  }
  None
}

///|
fn set_factor(
  factors : Array[(@graph.IProperty[Double], Double)],
  option : @graph.IProperty[Double],
  factor : Double,
) -> Unit raise ElkSpacingsException {
  match factor_index(factors, option) {
    Some(index) => factors[index] = (option, factor)
    None =>
      elk_spacings_raise(
        "'\{option.get_id()}' is not a configurable spacing option.",
      )
  }
}

///|
pub fn ElkCoreSpacingsBuilder::factors(
  self : ElkCoreSpacingsBuilder,
) -> Array[(@graph.IProperty[Double], Double)] {
  self.factors.copy()
}

///|
pub fn ElkCoreSpacingsBuilder::factor_for(
  self : ElkCoreSpacingsBuilder,
  option : @graph.IProperty[Double],
) -> Double raise ElkSpacingsException {
  match factor_index(self.factors, option) {
    Some(index) => {
      let (_, factor) = self.factors[index]
      factor
    }
    None =>
      elk_spacings_raise(
        "'\{option.get_id()}' is not a configurable spacing option.",
      )
  }
}

///|
pub fn ElkCoreSpacingsBuilder::with_factor(
  self : ElkCoreSpacingsBuilder,
  spacing_option : @graph.IProperty[Double],
  factor : Double,
) -> ElkCoreSpacingsBuilder raise ElkSpacingsException {
  if factor_index(self.factors, spacing_option) is None {
    elk_spacings_raise(
      "'\{spacing_option.get_id()}' is not a configurable spacing option.",
    )
  }
  if factor < 0.0 {
    elk_spacings_raise(
      "The factor for '\{spacing_option.get_id()}' must not be negative (\{factor}).",
    )
  }
  if spacing_option.get_id() == spacing_node_node.get_id() {
    elk_spacings_raise(
      "'\{spacing_option.get_id()}' is the base spacing option not allowed to use with 'with_factor'.",
    )
  }
  set_factor(self.factors, spacing_option, factor)
  self
}

///|
pub fn ElkCoreSpacingsBuilder::with_value(
  self : ElkCoreSpacingsBuilder,
  spacing_option : @graph.IProperty[Double],
  value : Double,
) -> ElkCoreSpacingsBuilder raise ElkSpacingsException {
  if factor_index(self.factors, spacing_option) is None {
    elk_spacings_raise(
      "'\{spacing_option.get_id()}' is not a configurable spacing option.",
    )
  }
  if value < 0.0 {
    elk_spacings_raise(
      "The value for '\{spacing_option.get_id()}' must not be negative (\{value}).",
    )
  }
  if spacing_option.get_id() == spacing_node_node.get_id() {
    elk_spacings_raise(
      "'\{spacing_option.get_id()}' is the base spacing option not allowed to use with 'with_value'.",
    )
  }
  set_factor(self.factors, spacing_option, value / self.base_spacing)
  self
}

///|
pub fn ElkCoreSpacingsBuilder::with_overwrite(
  self : ElkCoreSpacingsBuilder,
  shall_overwrite : Bool,
) -> ElkCoreSpacingsBuilder {
  self.overwrite = shall_overwrite
  self
}

///|
pub fn ElkCoreSpacingsBuilder::build(
  self : ElkCoreSpacingsBuilder,
) -> (@graph.ElkNode) -> Unit {
  if !self.overwrite &&
    (self.base_spacing - spacing_node_node.get_default()).abs() <=
    spacing_double_eq_epsilon {
    return _ => ()
  }
  let overwrite = self.overwrite
  let base_spacing = self.base_spacing
  let factors = self.factors.copy()
  element => {
    for entry in factors {
      let (property, factor) = entry
      if overwrite || !@graph.node_has_double_property(element, property) {
        @graph.node_set_double_property(
          element,
          property,
          factor * base_spacing,
        )
      }
    }
  }
}

///|
pub fn ElkCoreSpacingsBuilder::apply(
  self : ElkCoreSpacingsBuilder,
  holder : @graph.ElkNode,
) -> Unit {
  self.build()(holder)
}

///|
pub fn ElkCoreSpacingsBuilder::to_visitor(
  self : ElkCoreSpacingsBuilder,
) -> IGraphElementVisitor {
  let consumer = self.build()
  new_graph_element_visitor(element => consumer(element))
}
