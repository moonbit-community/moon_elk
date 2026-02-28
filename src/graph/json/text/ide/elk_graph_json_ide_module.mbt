///|
pub struct ElkGraphJsonIdeModule {
  base : AbstractElkGraphJsonIdeModule
}

///|
pub fn new_elk_graph_json_ide_module() -> ElkGraphJsonIdeModule {
  { base: new_abstract_elk_graph_json_ide_module() }
}

///|
pub fn ElkGraphJsonIdeModule::get_base(
  self : ElkGraphJsonIdeModule,
) -> AbstractElkGraphJsonIdeModule {
  self.base
}

///|
pub fn ElkGraphJsonIdeModule::bind_ide_content_proposal_provider(
  self : ElkGraphJsonIdeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.ide.contentassist.ElkGraphJsonProposalProvider"
}
