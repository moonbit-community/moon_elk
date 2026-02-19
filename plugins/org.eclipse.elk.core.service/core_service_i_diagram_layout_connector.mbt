///|
pub type LayoutApplySettings = Map[String, String]

///|
pub struct IDiagramLayoutConnector {
  id : String
  build_layout_graph_fn : (ServiceWorkbenchPart?, ServiceDiagramElement?) -> LayoutMapping?
  apply_layout_fn : (LayoutMapping, LayoutApplySettings) -> Unit
}

///|
pub fn new_diagram_layout_connector(
  build_layout_graph_fn? : (ServiceWorkbenchPart?, ServiceDiagramElement?) -> LayoutMapping? = (
    _,
    _,
  ) => None,
  apply_layout_fn? : (LayoutMapping, LayoutApplySettings) -> Unit = (_, _) => (),
  id? : String = "IDiagramLayoutConnector",
) -> IDiagramLayoutConnector {
  { id, build_layout_graph_fn, apply_layout_fn }
}

///|
pub fn IDiagramLayoutConnector::build_layout_graph(
  self : IDiagramLayoutConnector,
  workbench_part : ServiceWorkbenchPart?,
  diagram_part : ServiceDiagramElement?,
) -> LayoutMapping? {
  (self.build_layout_graph_fn)(workbench_part, diagram_part)
}

///|
pub fn IDiagramLayoutConnector::apply_layout(
  self : IDiagramLayoutConnector,
  mapping : LayoutMapping,
  settings : LayoutApplySettings,
) -> Unit {
  (self.apply_layout_fn)(mapping, settings)
}
