///|
pub type LayoutConfiguratorElementClass = String

///|
pub let class_graph_element : LayoutConfiguratorElementClass = "graph"

///|
pub let class_node_element : LayoutConfiguratorElementClass = "node"

///|
pub type LayoutConfiguratorFilter = (ElkNode, IProperty[Double]) -> Bool

///|
type DoublePropertyAssignment = (IProperty[Double], Double)

///|
pub struct LayoutConfigurator {
  element_option_map : Map[ElkNode, Map[String, DoublePropertyAssignment]]
  class_option_map : Map[String, Map[String, DoublePropertyAssignment]]
  option_filters : Array[LayoutConfiguratorFilter]
}

///|
pub fn new_layout_configurator() -> LayoutConfigurator {
  { element_option_map: {}, class_option_map: {}, option_filters: [] }
}

///|
fn upsert_option(
  options : Map[String, DoublePropertyAssignment],
  property : IProperty[Double],
  value : Double,
) -> Unit {
  options[property.get_id()] = (property, value)
}

///|
fn class_key(element_class : LayoutConfiguratorElementClass) -> String {
  element_class
}

///|
pub fn LayoutConfigurator::configure_node_property(
  self : LayoutConfigurator,
  node : ElkNode,
  property : IProperty[Double],
  value : Double,
) -> Unit {
  let options = match self.element_option_map.get(node) {
    Some(existing) => existing
    None => {}
  }
  upsert_option(options, property, value)
  self.element_option_map[node] = options
}

///|
pub fn LayoutConfigurator::configure_class_property(
  self : LayoutConfigurator,
  element_class : LayoutConfiguratorElementClass,
  property : IProperty[Double],
  value : Double,
) -> Unit {
  let options = match self.class_option_map.get(class_key(element_class)) {
    Some(existing) => existing
    None => {}
  }
  upsert_option(options, property, value)
  self.class_option_map[class_key(element_class)] = options
}

///|
pub fn LayoutConfigurator::add_filter(
  self : LayoutConfigurator,
  filter : LayoutConfiguratorFilter,
) -> Unit {
  self.option_filters.push(filter)
}

///|
pub fn layout_configurator_no_overwrite_filter() -> LayoutConfiguratorFilter {
  (node, property) => !node_has_double_property(node, property)
}

///|
fn merge_assignments(
  target : Map[String, DoublePropertyAssignment],
  source : Map[String, DoublePropertyAssignment]?,
) -> Unit {
  if source is Some(source_options) {
    source_options.each((id, assignment) => target[id] = assignment)
  }
}

///|
fn find_class_options(
  configurator : LayoutConfigurator,
  node : ElkNode,
) -> Map[String, DoublePropertyAssignment] {
  let combined : Map[String, DoublePropertyAssignment] = {}
  merge_assignments(
    combined,
    configurator.class_option_map.get(class_graph_element),
  )
  merge_assignments(
    combined,
    configurator.class_option_map.get(class_node_element),
  )
  merge_assignments(combined, configurator.element_option_map.get(node))
  combined
}

///|
pub fn LayoutConfigurator::visit(
  self : LayoutConfigurator,
  node : ElkNode,
) -> Unit {
  let combined = find_class_options(self, node)
  combined.each((_, assignment) => {
    let (property, value) = assignment
    let mut accept = true
    for filter in self.option_filters {
      if !filter(node, property) {
        accept = false
        break
      }
    }
    if accept {
      node_set_double_property(node, property, value)
    }
  })
}

///|
pub fn LayoutConfigurator::to_visitor(
  self : LayoutConfigurator,
) -> IGraphElementVisitor {
  new_graph_element_visitor(node => self.visit(node))
}
