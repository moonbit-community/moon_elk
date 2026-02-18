///|
pub type DotModelAdapter = Unit

///|
pub struct DotAdapterFactory {
  model_package : DotPackage
}

///|
pub fn new_dot_adapter_factory() -> DotAdapterFactory {
  { model_package: dot_package_instance }
}

///|
pub fn DotAdapterFactory::is_factory_for_type(
  self : DotAdapterFactory,
  package_id : DotPackage,
) -> Bool {
  package_id == self.model_package
}

///|
pub fn DotAdapterFactory::create_graphviz_model_adapter(
  self : DotAdapterFactory,
) -> DotModelAdapter? {
  ignore(self)
  None
}

///|
pub fn DotAdapterFactory::create_graph_adapter(
  self : DotAdapterFactory,
) -> DotModelAdapter? {
  ignore(self)
  None
}

///|
pub fn DotAdapterFactory::create_statement_adapter(
  self : DotAdapterFactory,
) -> DotModelAdapter? {
  ignore(self)
  None
}

///|
pub fn DotAdapterFactory::create_attribute_adapter(
  self : DotAdapterFactory,
) -> DotModelAdapter? {
  ignore(self)
  None
}

///|
pub fn DotAdapterFactory::create_node_statement_adapter(
  self : DotAdapterFactory,
) -> DotModelAdapter? {
  ignore(self)
  None
}

///|
pub fn DotAdapterFactory::create_node_adapter(
  self : DotAdapterFactory,
) -> DotModelAdapter? {
  ignore(self)
  None
}

///|
pub fn DotAdapterFactory::create_edge_statement_adapter(
  self : DotAdapterFactory,
) -> DotModelAdapter? {
  ignore(self)
  None
}

///|
pub fn DotAdapterFactory::create_edge_target_adapter(
  self : DotAdapterFactory,
) -> DotModelAdapter? {
  ignore(self)
  None
}

///|
pub fn DotAdapterFactory::create_attribute_statement_adapter(
  self : DotAdapterFactory,
) -> DotModelAdapter? {
  ignore(self)
  None
}

///|
pub fn DotAdapterFactory::create_subgraph_adapter(
  self : DotAdapterFactory,
) -> DotModelAdapter? {
  ignore(self)
  None
}

///|
pub fn DotAdapterFactory::create_port_adapter(
  self : DotAdapterFactory,
) -> DotModelAdapter? {
  ignore(self)
  None
}

///|
pub fn DotAdapterFactory::create_e_object_adapter(
  self : DotAdapterFactory,
) -> DotModelAdapter? {
  ignore(self)
  None
}

///|
pub fn DotAdapterFactory::create_adapter(
  self : DotAdapterFactory,
  target : DotSwitchTarget,
) -> DotModelAdapter? {
  new_dot_switch(
    case_graphviz_model=_ => self.create_graphviz_model_adapter(),
    case_graph=_ => self.create_graph_adapter(),
    case_statement=_ => self.create_statement_adapter(),
    case_attribute=_ => self.create_attribute_adapter(),
    case_node_statement=_ => self.create_node_statement_adapter(),
    case_node=_ => self.create_node_adapter(),
    case_edge_statement=_ => self.create_edge_statement_adapter(),
    case_edge_target=_ => self.create_edge_target_adapter(),
    case_attribute_statement=_ => self.create_attribute_statement_adapter(),
    case_subgraph=_ => self.create_subgraph_adapter(),
    case_port=_ => self.create_port_adapter(),
    default_case=() => self.create_e_object_adapter(),
  ).do_switch(target)
}
