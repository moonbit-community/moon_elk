///|
pub struct ElkGraphIdeModule {
  base : AbstractElkGraphIdeModule
}

///|
pub fn new_elk_graph_ide_module() -> ElkGraphIdeModule {
  { base: new_abstract_elk_graph_ide_module() }
}

///|
pub fn ElkGraphIdeModule::get_base(
  self : ElkGraphIdeModule,
) -> AbstractElkGraphIdeModule {
  self.base
}

///|
pub fn ElkGraphIdeModule::bind_ide_content_proposal_provider(
  self : ElkGraphIdeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.ide.contentassist.ElkGraphProposalProvider"
}
