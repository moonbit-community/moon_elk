///|
pub type ServiceWorkbenchPart = Int

///|
pub type ServiceDiagramElement = Int

///|
pub type ServiceGraphElement = Int

///|
pub enum LayoutMappingStatus {
  OkStatus
  WarningStatus(String)
  ErrorStatus(String)
  CanceledStatus
} derive(Eq, Show)

///|
pub struct LayoutMapping {
  graph_elem_map : Map[ServiceGraphElement, ServiceDiagramElement]
  diagram_elem_map : Map[ServiceDiagramElement, ServiceGraphElement]
  mut layout_graph : ElkNode?
  mut parent_element : ServiceDiagramElement?
  workbench_part : ServiceWorkbenchPart?
  mut status : LayoutMappingStatus?
  mut connector_id : String?
  properties : Map[String, String]
}

///|
pub fn new_layout_mapping(
  workbench_part? : ServiceWorkbenchPart? = None,
) -> LayoutMapping {
  {
    graph_elem_map: {},
    diagram_elem_map: {},
    layout_graph: None,
    parent_element: None,
    workbench_part,
    status: None,
    connector_id: None,
    properties: {},
  }
}

///|
pub fn new_layout_mapping_with_graph(
  workbench_part : ServiceWorkbenchPart?,
  parent_element : ServiceDiagramElement?,
  layout_graph : ElkNode,
) -> LayoutMapping {
  let mapping = new_layout_mapping(workbench_part~)
  mapping.parent_element = parent_element
  mapping.layout_graph = Some(layout_graph)
  mapping
}

///|
pub fn LayoutMapping::put_graph_mapping(
  self : LayoutMapping,
  graph_element : ServiceGraphElement,
  diagram_element : ServiceDiagramElement,
) -> Unit {
  self.graph_elem_map[graph_element] = diagram_element
  self.diagram_elem_map[diagram_element] = graph_element
}

///|
pub fn LayoutMapping::get_diagram_element(
  self : LayoutMapping,
  graph_element : ServiceGraphElement,
) -> ServiceDiagramElement? {
  self.graph_elem_map.get(graph_element)
}

///|
pub fn LayoutMapping::get_graph_element(
  self : LayoutMapping,
  diagram_element : ServiceDiagramElement,
) -> ServiceGraphElement? {
  self.diagram_elem_map.get(diagram_element)
}

///|
pub fn LayoutMapping::graph_map_entries(
  self : LayoutMapping,
) -> Array[(ServiceGraphElement, ServiceDiagramElement)] {
  self.graph_elem_map.to_array()
}

///|
pub fn LayoutMapping::graph_map_size(self : LayoutMapping) -> Int {
  self.graph_elem_map.length()
}

///|
pub fn LayoutMapping::set_layout_graph(
  self : LayoutMapping,
  layout_graph : ElkNode?,
) -> Unit {
  self.layout_graph = layout_graph
}

///|
pub fn LayoutMapping::get_layout_graph(self : LayoutMapping) -> ElkNode? {
  self.layout_graph
}

///|
pub fn LayoutMapping::set_parent_element(
  self : LayoutMapping,
  parent_element : ServiceDiagramElement?,
) -> Unit {
  self.parent_element = parent_element
}

///|
pub fn LayoutMapping::get_parent_element(
  self : LayoutMapping,
) -> ServiceDiagramElement? {
  self.parent_element
}

///|
pub fn LayoutMapping::get_workbench_part(
  self : LayoutMapping,
) -> ServiceWorkbenchPart? {
  self.workbench_part
}

///|
pub fn LayoutMapping::set_status(
  self : LayoutMapping,
  status : LayoutMappingStatus?,
) -> Unit {
  self.status = status
}

///|
pub fn LayoutMapping::get_status(self : LayoutMapping) -> LayoutMappingStatus? {
  self.status
}

///|
pub fn LayoutMapping::set_connector_id(
  self : LayoutMapping,
  connector_id : String?,
) -> Unit {
  self.connector_id = connector_id
}

///|
pub fn LayoutMapping::get_connector_id(self : LayoutMapping) -> String? {
  self.connector_id
}

///|
pub fn LayoutMapping::set_property(
  self : LayoutMapping,
  key : String,
  value : String,
) -> Unit {
  self.properties[key] = value
}

///|
pub fn LayoutMapping::get_property(
  self : LayoutMapping,
  key : String,
) -> String? {
  self.properties.get(key)
}
