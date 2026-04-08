///|
pub struct GmfConnectorLayoutSettings {
  animate : Bool
  zoom_to_fit : Bool
  min_anim_time : Int
  max_anim_time : Int
  anim_time_factor : Int
}

///|
pub fn new_gmf_connector_layout_settings(
  animate? : Bool = false,
  zoom_to_fit? : Bool = false,
  min_anim_time? : Int = 0,
  max_anim_time? : Int = 0,
  anim_time_factor? : Int = 0,
) -> GmfConnectorLayoutSettings {
  { animate, zoom_to_fit, min_anim_time, max_anim_time, anim_time_factor }
}

///|
pub(all) enum GmfConnectorWorkbenchPart {
  DiagramEditorWorkbenchPart(GmfEditPart)
  AdaptableWorkbenchPart(GmfEditPart)
  OtherWorkbenchPart
} derive(Debug)

///|
pub(all) enum GmfConnectorDiagramPart {
  DirectEditPart(GmfEditPart)
  Selection(Array[GmfEditPart])
  NoDiagramPart
} derive(Debug)

///|
pub suberror GmfDiagramLayoutConnectorException {
  GmfDiagramLayoutConnectorException(String)
} derive(Debug, ToJson)

///|
fn gmf_diagram_layout_connector_raise_unit(
  message : String,
) -> Unit raise GmfDiagramLayoutConnectorException {
  raise GmfDiagramLayoutConnectorException(message)
}

///|
pub struct GmfLayoutMapping {
  workbench_part : GmfConnectorWorkbenchPart?
  parent_element : GmfEditPart?
  layout_graph : @graph.ElkNode
  node_map : Map[Int, GmfEditPart]
  port_map : Map[Int, GmfEditPart]
  edge_map : Map[Int, GmfEditPart]
  label_map : Map[Int, GmfEditPart]
  connections : Array[GmfEditPart]
  mut diagram_edit_part : GmfEditPart?
  mut layout_command : GmfLayoutCommand?
  mut command_stack : GmfCommandStack?
  mut coordinate_offset : GmfPoint?
  mut animation_time : Int
}

///|
fn new_gmf_layout_mapping(
  workbench_part : GmfConnectorWorkbenchPart?,
  parent_element : GmfEditPart?,
  layout_graph : @graph.ElkNode,
) -> GmfLayoutMapping {
  {
    workbench_part,
    parent_element,
    layout_graph,
    node_map: {},
    port_map: {},
    edge_map: {},
    label_map: {},
    connections: [],
    diagram_edit_part: None,
    layout_command: None,
    command_stack: None,
    coordinate_offset: None,
    animation_time: 0,
  }
}

///|
pub fn GmfLayoutMapping::graph_element_count(self : GmfLayoutMapping) -> Int {
  self.node_map.length() +
  self.port_map.length() +
  self.edge_map.length() +
  self.label_map.length()
}

///|
pub fn GmfLayoutMapping::set_command_stack(
  self : GmfLayoutMapping,
  command_stack : GmfCommandStack?,
) -> Unit {
  self.command_stack = command_stack
}

///|
pub fn GmfLayoutMapping::get_command_stack(
  self : GmfLayoutMapping,
) -> GmfCommandStack? {
  self.command_stack
}

///|
pub struct GmfDiagramLayoutConnector {
  edit_part_filter : IEditPartFilter
}

///|
pub fn new_gmf_diagram_layout_connector(
  edit_part_filter? : IEditPartFilter = new_i_edit_part_filter_default_impl(),
) -> GmfDiagramLayoutConnector {
  { edit_part_filter, }
}

///|
pub fn gmf_diagram_layout_connector_get_absolute_bounds(
  figure : GmfFigure,
) -> GmfRectangle {
  gmf_figure_absolute_bounds(figure)
}

///|
fn gmf_diagram_layout_connector_root_diagram_child(
  root_edit_part : GmfEditPart,
) -> GmfEditPart? {
  for child in gmf_edit_part_children(root_edit_part) {
    if gmf_edit_part_kind(child) == DiagramEditPart {
      return Some(child)
    }
  }
  None
}

///|
pub fn gmf_diagram_layout_connector_get_diagram_edit_part(
  edit_part : GmfEditPart,
) -> GmfEditPart? {
  let mut current : GmfEditPart? = Some(edit_part)
  while current is Some(value) {
    let kind = gmf_edit_part_kind(value)
    if kind == DiagramEditPart {
      return Some(value)
    }
    if kind == RootEditPart {
      return gmf_diagram_layout_connector_root_diagram_child(value)
    }
    current = gmf_edit_part_parent(value)
  }
  None
}

///|
pub fn gmf_diagram_layout_connector_is_parent(
  parent : GmfEditPart,
  child : GmfEditPart,
) -> Bool {
  let mut current : GmfEditPart? = Some(child)
  while current is Some(value) {
    if value == parent {
      return true
    }
    current = gmf_edit_part_parent(value)
  }
  false
}

///|
pub fn gmf_diagram_layout_connector_common_parent(
  edit_part1 : GmfEditPart,
  edit_part2 : GmfEditPart,
) -> GmfEditPart? {
  let mut ep1 : GmfEditPart? = Some(edit_part1)
  let mut ep2 : GmfEditPart? = Some(edit_part2)
  while ep1 is Some(left) && ep2 is Some(right) {
    if gmf_diagram_layout_connector_is_parent(left, right) {
      return Some(left)
    }
    if gmf_diagram_layout_connector_is_parent(right, left) {
      return Some(right)
    }
    ep1 = gmf_edit_part_parent(left)
    ep2 = gmf_edit_part_parent(right)
  }
  None
}

///|
fn gmf_diagram_layout_connector_get_diagram_editor(
  workbench_part : GmfConnectorWorkbenchPart?,
) -> GmfEditPart? {
  match workbench_part {
    Some(DiagramEditorWorkbenchPart(diagram_edit_part)) =>
      Some(diagram_edit_part)
    Some(AdaptableWorkbenchPart(diagram_edit_part)) => Some(diagram_edit_part)
    _ => None
  }
}

///|
fn gmf_diagram_layout_connector_is_layout_root_candidate(
  edit_part : GmfEditPart,
) -> Bool {
  let kind = gmf_edit_part_kind(edit_part)
  kind == ShapeNodeEditPart || kind == DiagramEditPart
}

///|
fn gmf_diagram_layout_connector_collect_selection_roots(
  connector : GmfDiagramLayoutConnector,
  selection : Array[GmfEditPart],
  layout_root_part : GmfEditPart,
) -> Array[GmfEditPart] {
  let selected_parts : Array[GmfEditPart] = []
  for selected in selection {
    let mut candidate : GmfEditPart? = Some(selected)
    while candidate is Some(value) &&
          gmf_edit_part_parent(value) != Some(layout_root_part) {
      candidate = gmf_edit_part_parent(value)
    }
    match candidate {
      Some(value) =>
        if gmf_edit_part_kind(value) == ShapeNodeEditPart &&
          connector.edit_part_filter.filter(value) {
          let mut exists = false
          for entry in selected_parts {
            if entry == value {
              exists = true
            }
          }
          if !exists {
            selected_parts.push(value)
          }
        }
      None => ()
    }
  }
  selected_parts
}

///|
fn gmf_diagram_layout_connector_add_connections(
  connector : GmfDiagramLayoutConnector,
  mapping : GmfLayoutMapping,
  edit_part : GmfEditPart,
) -> Unit {
  for target_connection in gmf_edit_part_target_connections(edit_part) {
    if connector.edit_part_filter.filter(target_connection) {
      mapping.connections.push(target_connection)
      gmf_diagram_layout_connector_add_connections(
        connector, mapping, target_connection,
      )
    }
  }
}

///|
fn gmf_diagram_layout_connector_create_node(
  connector : GmfDiagramLayoutConnector,
  mapping : GmfLayoutMapping,
  node_edit_part : GmfEditPart,
  parent_edit_part : GmfEditPart?,
  parent_layout_node : @graph.ElkNode?,
) -> @graph.ElkNode {
  ignore(parent_edit_part)
  let child_layout_node = @graph.create_node(parent_layout_node)
  let node_figure = gmf_edit_part_figure(node_edit_part)
  let child_bounds = gmf_figure_absolute_bounds(node_figure)
  let container_bounds = match gmf_figure_parent(node_figure) {
    Some(parent_figure) => gmf_figure_absolute_bounds(parent_figure)
    None => child_bounds
  }
  @graph.node_set_location(
    child_layout_node,
    (child_bounds.x - container_bounds.x).to_double(),
    (child_bounds.y - container_bounds.y).to_double(),
  )
  @graph.node_set_dimensions(
    child_layout_node,
    child_bounds.width.to_double(),
    child_bounds.height.to_double(),
  )
  let min_size = gmf_figure_minimum_size(node_figure)
  @graph.node_set_string_property(
    child_layout_node,
    @core.node_size_minimum,
    "(\{min_size.width.to_double()}, \{min_size.height.to_double()})",
  )
  mapping.node_map[child_layout_node] = node_edit_part
  gmf_diagram_layout_connector_add_connections(
    connector, mapping, node_edit_part,
  )
  child_layout_node
}

///|
fn gmf_diagram_layout_connector_create_port(
  connector : GmfDiagramLayoutConnector,
  mapping : GmfLayoutMapping,
  port_edit_part : GmfEditPart,
  node_edit_part : GmfEditPart,
  elk_node : @graph.ElkNode,
) -> @graph.ElkPort {
  ignore(connector)
  let port = @graph.create_port(Some(elk_node))
  let port_bounds = gmf_figure_absolute_bounds(
    gmf_edit_part_figure(port_edit_part),
  )
  let node_bounds = gmf_figure_absolute_bounds(
    gmf_edit_part_figure(node_edit_part),
  )
  @graph.port_set_location(
    port,
    (port_bounds.x - node_bounds.x).to_double(),
    (port_bounds.y - node_bounds.y).to_double(),
  )
  @graph.port_set_dimensions(
    port,
    port_bounds.width.to_double(),
    port_bounds.height.to_double(),
  )
  mapping.port_map[port] = port_edit_part
  gmf_diagram_layout_connector_add_connections(
    connector, mapping, port_edit_part,
  )
  port
}

///|
fn gmf_diagram_layout_connector_create_node_label(
  mapping : GmfLayoutMapping,
  label_edit_part : GmfEditPart,
  node_edit_part : GmfEditPart,
  elk_node : @graph.ElkNode,
) -> @graph.ElkLabel? {
  let label_figure = gmf_edit_part_figure(label_edit_part)
  let text = gmf_figure_text(label_figure)
  if text.is_empty() {
    return None
  }
  let label = @graph.create_label(Some(@graph.make_node_label_parent(elk_node)))
  @graph.label_set_text(label, text)
  let label_bounds = gmf_figure_absolute_bounds(label_figure)
  let node_bounds = gmf_figure_absolute_bounds(
    gmf_edit_part_figure(node_edit_part),
  )
  @graph.label_set_location(
    label,
    (label_bounds.x - node_bounds.x).to_double(),
    (label_bounds.y - node_bounds.y).to_double(),
  )
  let preferred = gmf_figure_preferred_size(label_figure)
  @graph.label_set_dimensions(
    label,
    preferred.width.to_double(),
    preferred.height.to_double(),
  )
  match gmf_figure_font_name(label_figure) {
    Some(font_name) =>
      if !gmf_figure_font_is_disposed(label_figure) {
        @graph.label_set_layout_option_string_by_id(
          label, "org.eclipse.elk.font.name", font_name,
        )
        @graph.label_set_layout_option_string_by_id(
          label,
          "org.eclipse.elk.font.size",
          gmf_figure_font_size(label_figure).to_string(),
        )
      }
    None => ()
  }
  mapping.label_map[label] = label_edit_part
  Some(label)
}

///|
fn gmf_diagram_layout_connector_build_layout_graph_recursively(
  connector : GmfDiagramLayoutConnector,
  mapping : GmfLayoutMapping,
  parent_edit_part : GmfEditPart,
  parent_layout_node : @graph.ElkNode,
  current_edit_part : GmfEditPart,
) -> Unit {
  for child in gmf_edit_part_children(current_edit_part) {
    if !gmf_figure_is_visible(gmf_edit_part_figure(child)) {
      continue
    }
    let child_kind = gmf_edit_part_kind(child)
    if child_kind == AbstractBorderItemEditPart {
      if connector.edit_part_filter.filter(child) {
        ignore(
          gmf_diagram_layout_connector_create_port(
            connector, mapping, child, parent_edit_part, parent_layout_node,
          ),
        )
      }
    } else if child_kind == ResizableCompartmentEditPart &&
      !gmf_edit_part_children(child).is_empty() {
      if connector.edit_part_filter.filter(child) &&
        gmf_figure_is_expanded(gmf_edit_part_figure(child)) {
        gmf_diagram_layout_connector_build_layout_graph_recursively(
          connector, mapping, parent_edit_part, parent_layout_node, child,
        )
      }
    } else if child_kind == ShapeNodeEditPart {
      if connector.edit_part_filter.filter(child) {
        let node = gmf_diagram_layout_connector_create_node(
          connector,
          mapping,
          child,
          Some(parent_edit_part),
          Some(parent_layout_node),
        )
        gmf_diagram_layout_connector_build_layout_graph_recursively(
          connector, mapping, child, node, child,
        )
      }
    } else if connector.edit_part_filter.filter(child) {
      ignore(
        gmf_diagram_layout_connector_create_node_label(
          mapping, child, parent_edit_part, parent_layout_node,
        ),
      )
    }
  }
}

///|
fn gmf_diagram_layout_connector_shape_by_edit_part(
  mapping : GmfLayoutMapping,
  edit_part : GmfEditPart,
) -> @graph.ElkConnectableShape? {
  for entry in mapping.node_map.to_array() {
    if entry.1 == edit_part {
      return Some(@graph.make_node_shape(entry.0))
    }
  }
  for entry in mapping.port_map.to_array() {
    if entry.1 == edit_part {
      return Some(@graph.make_port_shape(entry.0))
    }
  }
  None
}

///|
fn gmf_diagram_layout_connector_set_edge_layout(
  edge : @graph.ElkEdge,
  connection_edit_part : GmfEditPart,
  offset_x : Double,
  offset_y : Double,
) -> Unit {
  let point_list = gmf_figure_points(gmf_edit_part_figure(connection_edit_part))
  if point_list.size() < 2 {
    return
  }
  let edge_section = @graph.create_edge_section(edge)
  let first_point = point_list.get_first_point()
  @graph.edge_section_set_start(
    edge_section,
    first_point.x.to_double() - offset_x,
    first_point.y.to_double() - offset_y,
  )
  let last_point = point_list.get_last_point()
  @graph.edge_section_set_end(
    edge_section,
    last_point.x.to_double() - offset_x,
    last_point.y.to_double() - offset_y,
  )
}

///|
fn gmf_diagram_layout_connector_process_edge_labels(
  mapping : GmfLayoutMapping,
  connection_edit_part : GmfEditPart,
  edge : @graph.ElkEdge,
  offset_x : Double,
  offset_y : Double,
) -> Unit {
  for child in gmf_edit_part_children(connection_edit_part) {
    if gmf_edit_part_kind(child) != LabelEditPart {
      continue
    }
    let label_figure = gmf_edit_part_figure(child)
    if !gmf_figure_is_visible(label_figure) {
      continue
    }
    let text = gmf_figure_text(label_figure)
    if text.is_empty() {
      let label = @graph.create_label(None)
      mapping.label_map[label] = child
      continue
    }
    let label = @graph.create_label(Some(@graph.make_edge_label_parent(edge)))
    match gmf_edit_part_key_point(child) {
      0 =>
        @graph.label_set_layout_option_string_by_id(
          label, "org.eclipse.elk.edgeLabels.placement", "CENTER",
        )
      1 =>
        @graph.label_set_layout_option_string_by_id(
          label, "org.eclipse.elk.edgeLabels.placement", "HEAD",
        )
      2 =>
        @graph.label_set_layout_option_string_by_id(
          label, "org.eclipse.elk.edgeLabels.placement", "TAIL",
        )
      _ => ()
    }
    let bounds = gmf_figure_absolute_bounds(label_figure)
    @graph.label_set_location(
      label,
      bounds.x.to_double() - offset_x,
      bounds.y.to_double() - offset_y,
    )
    @graph.label_set_dimensions(
      label,
      bounds.width.to_double(),
      bounds.height.to_double(),
    )
    @graph.label_set_text(label, text)
    mapping.label_map[label] = child
  }
}

///|
fn gmf_diagram_layout_connector_process_connections(
  mapping : GmfLayoutMapping,
) -> Unit {
  for connection in mapping.connections {
    let source_edit_part = match gmf_edit_part_source(connection) {
      Some(source) =>
        if gmf_edit_part_kind(source) == ConnectionEditPart {
          match gmf_edit_part_source(source) {
            Some(source_source) => source_source
            None => source
          }
        } else {
          source
        }
      None => continue
    }
    let source_shape = match
      gmf_diagram_layout_connector_shape_by_edit_part(mapping, source_edit_part) {
      Some(shape) => shape
      None => continue
    }

    let target_edit_part = match gmf_edit_part_target(connection) {
      Some(target) =>
        if gmf_edit_part_kind(target) == ConnectionEditPart {
          match gmf_edit_part_target(target) {
            Some(target_target) => target_target
            None => target
          }
        } else {
          target
        }
      None => continue
    }
    let target_shape = match
      gmf_diagram_layout_connector_shape_by_edit_part(mapping, target_edit_part) {
      Some(shape) => shape
      None => continue
    }

    let source_node = try
      @graph.connectable_shape_to_node(Some(source_shape))
    catch {
      _ => continue
    } noraise {
      value => value
    }
    let target_node = try
      @graph.connectable_shape_to_node(Some(target_shape))
    catch {
      _ => continue
    } noraise {
      value => value
    }
    let edge_containment = match
      @graph.find_lowest_common_ancestor(source_node, target_node) {
      Some(node) => node
      None => continue
    }
    let edge = @graph.create_edge(Some(edge_containment))
    @graph.edge_add_source(edge, source_shape)
    @graph.edge_add_target(edge, target_shape)
    mapping.edge_map[edge] = connection

    let offset_x = @graph.node_x(edge_containment)
    let offset_y = @graph.node_y(edge_containment)
    gmf_diagram_layout_connector_set_edge_layout(
      edge, connection, offset_x, offset_y,
    )
    gmf_diagram_layout_connector_process_edge_labels(
      mapping, connection, edge, offset_x, offset_y,
    )
  }
}

///|
fn gmf_diagram_layout_connector_build_layout_graph_for_root(
  connector : GmfDiagramLayoutConnector,
  layout_root_part : GmfEditPart,
  selection : Array[GmfEditPart]?,
  workbench_part : GmfConnectorWorkbenchPart?,
) -> GmfLayoutMapping {
  let top_node = if gmf_edit_part_kind(layout_root_part) == ShapeNodeEditPart {
    @graph.create_graph()
  } else {
    @graph.create_graph()
  }
  let mapping = new_gmf_layout_mapping(
    workbench_part,
    Some(layout_root_part),
    top_node,
  )
  mapping.diagram_edit_part = gmf_diagram_layout_connector_get_diagram_edit_part(
    layout_root_part,
  )

  if gmf_edit_part_kind(layout_root_part) == ShapeNodeEditPart {
    let root_node = gmf_diagram_layout_connector_create_node(
      connector,
      mapping,
      layout_root_part,
      None,
      Some(top_node),
    )
    @graph.node_set_location(
      top_node,
      @graph.node_x(root_node),
      @graph.node_y(root_node),
    )
    @graph.node_set_dimensions(
      top_node,
      @graph.node_width(root_node),
      @graph.node_height(root_node),
    )
  } else {
    let root_bounds = gmf_figure_bounds(gmf_edit_part_figure(layout_root_part))
    @graph.node_set_location(
      top_node,
      root_bounds.x.to_double(),
      root_bounds.y.to_double(),
    )
    @graph.node_set_dimensions(
      top_node,
      root_bounds.width.to_double(),
      root_bounds.height.to_double(),
    )
    mapping.node_map[top_node] = layout_root_part
    if gmf_edit_part_kind(layout_root_part) == DiagramEditPart {
      match gmf_edit_part_notation_view(layout_root_part) {
        Some(view) => {
          let label_text = gmf_view_name(view)
          if !label_text.is_empty() {
            let label = @graph.create_label(
              Some(@graph.make_node_label_parent(top_node)),
            )
            @graph.label_set_text(label, label_text)
            mapping.label_map[label] = layout_root_part
          }
        }
        None => ()
      }
    }
  }

  match selection {
    Some(selected_parts) =>
      if !selected_parts.is_empty() {
        let mut minx = @double.max_value
        let mut miny = @double.max_value
        for selected in selected_parts {
          let node = gmf_diagram_layout_connector_create_node(
            connector,
            mapping,
            selected,
            Some(layout_root_part),
            Some(top_node),
          )
          if @graph.node_x(node) < minx {
            minx = @graph.node_x(node)
          }
          if @graph.node_y(node) < miny {
            miny = @graph.node_y(node)
          }
          gmf_diagram_layout_connector_build_layout_graph_recursively(
            connector, mapping, selected, node, selected,
          )
        }
        mapping.coordinate_offset = Some(
          new_gmf_point(minx.to_int(), miny.to_int()),
        )
      } else {
        gmf_diagram_layout_connector_build_layout_graph_recursively(
          connector, mapping, layout_root_part, top_node, layout_root_part,
        )
      }
    None =>
      gmf_diagram_layout_connector_build_layout_graph_recursively(
        connector, mapping, layout_root_part, top_node, layout_root_part,
      )
  }

  gmf_diagram_layout_connector_process_connections(mapping)
  mapping
}

///|
pub fn GmfDiagramLayoutConnector::build_layout_graph(
  self : GmfDiagramLayoutConnector,
  workbench_part : GmfConnectorWorkbenchPart?,
  diagram_part : GmfConnectorDiagramPart,
) -> GmfLayoutMapping {
  let diagram_editor = gmf_diagram_layout_connector_get_diagram_editor(
    workbench_part,
  )
  let mut layout_root_part : GmfEditPart? = None
  let mut selected_parts : Array[GmfEditPart]? = None

  match diagram_part {
    DirectEditPart(edit_part) =>
      if gmf_diagram_layout_connector_is_layout_root_candidate(edit_part) {
        layout_root_part = Some(edit_part)
      } else {
        match gmf_edit_part_top_graphic_edit_part(edit_part) {
          Some(top_graphic) =>
            if gmf_edit_part_kind(top_graphic) == ShapeNodeEditPart {
              layout_root_part = Some(top_graphic)
            }
          None => ()
        }
      }
    Selection(selection) => {
      for selected in selection {
        if layout_root_part is Some(root_part) {
          match
            gmf_diagram_layout_connector_common_parent(root_part, selected) {
            Some(parent) =>
              if gmf_edit_part_kind(parent) != RootEditPart {
                layout_root_part = Some(parent)
              }
            None => ()
          }
        } else if gmf_edit_part_kind(selected) != ConnectionEditPart {
          layout_root_part = Some(selected)
        }
      }
      match layout_root_part {
        Some(root_part) =>
          selected_parts = Some(
            gmf_diagram_layout_connector_collect_selection_roots(
              self, selection, root_part,
            ),
          )
        None => ()
      }
    }
    NoDiagramPart => ()
  }

  if layout_root_part is None {
    layout_root_part = diagram_editor
  }
  match layout_root_part {
    Some(root_part) =>
      gmf_diagram_layout_connector_build_layout_graph_for_root(
        self, root_part, selected_parts, workbench_part,
      )
    None => {
      try
        gmf_diagram_layout_connector_raise_unit(
          "Not supported by this layout connector",
        )
      catch {
        GmfDiagramLayoutConnectorException(message) =>
          @core.layout_runtime_report_unsupported_configuration(
            "org.eclipse.elk.conn.gmf.GmfDiagramLayoutConnector: " + message,
          )
      } noraise {
        _ => ()
      }
      new_gmf_layout_mapping(workbench_part, None, @graph.create_node(None))
    }
  }
}

///|
pub fn GmfDiagramLayoutConnector::count_nodes(
  self : GmfDiagramLayoutConnector,
  node : @graph.ElkNode,
) -> Int {
  let mut count = 0
  for child in @graph.node_children(node) {
    count = count + self.count_nodes(child) + 1
  }
  count
}

///|
pub fn GmfDiagramLayoutConnector::calc_animation_time(
  self : GmfDiagramLayoutConnector,
  mapping : GmfLayoutMapping,
  settings : GmfConnectorLayoutSettings,
  viewer_not_visible : Bool,
) -> Int {
  ignore(viewer_not_visible)
  if !settings.animate {
    return 0
  }
  let min_time = if settings.min_anim_time < 0 {
    0
  } else {
    settings.min_anim_time
  }
  let max_time = if settings.max_anim_time < min_time {
    min_time
  } else {
    settings.max_anim_time
  }
  if settings.anim_time_factor > 0 {
    let graph_size = self.count_nodes(mapping.layout_graph)
    let time = min_time +
      (settings.anim_time_factor.to_double() * graph_size.to_double().sqrt()).to_int()
    if time <= max_time {
      time
    } else {
      max_time
    }
  } else {
    min_time
  }
}

///|
pub fn gmf_diagram_layout_connector_add_offset(
  parent_node : @graph.ElkNode,
  offset : GmfPoint,
) -> Unit {
  let children = @graph.node_children(parent_node)
  if children.is_empty() {
    return
  }
  let mut minx = @double.max_value
  let mut miny = @double.max_value
  for child in children {
    if @graph.node_x(child) < minx {
      minx = @graph.node_x(child)
    }
    if @graph.node_y(child) < miny {
      miny = @graph.node_y(child)
    }
  }
  @core.translate_xy(
    parent_node,
    offset.x.to_double() - minx,
    offset.y.to_double() - miny,
  )
}

///|
fn gmf_diagram_layout_connector_transfer_shape(
  request : ApplyLayoutRequest,
  edit_part : GmfEditPart,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  element_id : Int,
) -> Unit {
  gmf_set_layout_element_shape(element_id, x, y, width, height)
  request.add_element(element_id, edit_part)
}

///|
fn gmf_diagram_layout_connector_transfer_edge(
  request : ApplyLayoutRequest,
  edit_part : GmfEditPart,
  element_id : Int,
  edge : @graph.ElkEdge,
) -> Unit {
  let bends = new_gmf_point_list()
  let sections = @graph.edge_sections(edge)
  if !sections.is_empty() {
    let section = sections[0]
    bends.add_point(
      new_gmf_point(
        @graph.edge_section_start_x(section).to_int(),
        @graph.edge_section_start_y(section).to_int(),
      ),
    )
    bends.add_point(
      new_gmf_point(
        @graph.edge_section_end_x(section).to_int(),
        @graph.edge_section_end_y(section).to_int(),
      ),
    )
  }
  let view = gmf_edit_part_notation_view(edit_part)
  let source_terminal = match view {
    Some(v) => gmf_view_source_terminal(v)
    None => None
  }
  let target_terminal = match view {
    Some(v) => gmf_view_target_terminal(v)
    None => None
  }
  let junction_points = match view {
    Some(v) => gmf_view_get_style(v, junction_points_style_name)
    None => None
  }
  gmf_set_layout_element_edge(
    element_id, bends, source_terminal, target_terminal, junction_points,
  )
  request.add_element(element_id, edit_part)
}

///|
pub fn GmfDiagramLayoutConnector::transfer_layout(
  _self : GmfDiagramLayoutConnector,
  mapping : GmfLayoutMapping,
) -> Unit {
  let request = new_apply_layout_request()
  let mut element_id = 1

  for entry in mapping.node_map.to_array() {
    if gmf_edit_part_kind(entry.1) != DiagramEditPart {
      gmf_diagram_layout_connector_transfer_shape(
        request,
        entry.1,
        @graph.node_x(entry.0),
        @graph.node_y(entry.0),
        @graph.node_width(entry.0),
        @graph.node_height(entry.0),
        element_id,
      )
      element_id = element_id + 1
    }
  }
  for entry in mapping.port_map.to_array() {
    gmf_diagram_layout_connector_transfer_shape(
      request,
      entry.1,
      @graph.port_x(entry.0),
      @graph.port_y(entry.0),
      @graph.port_width(entry.0),
      @graph.port_height(entry.0),
      element_id,
    )
    element_id = element_id + 1
  }
  for entry in mapping.label_map.to_array() {
    gmf_diagram_layout_connector_transfer_shape(
      request,
      entry.1,
      @graph.label_x(entry.0),
      @graph.label_y(entry.0),
      @graph.label_width(entry.0),
      @graph.label_height(entry.0),
      element_id,
    )
    element_id = element_id + 1
  }
  for entry in mapping.edge_map.to_array() {
    gmf_diagram_layout_connector_transfer_edge(
      request,
      entry.1,
      element_id,
      entry.0,
    )
    element_id = element_id + 1
  }

  request.set_upper_bound(
    @graph.node_width(mapping.layout_graph),
    @graph.node_height(mapping.layout_graph),
  )
  match mapping.coordinate_offset {
    Some(offset) =>
      gmf_diagram_layout_connector_add_offset(mapping.layout_graph, offset)
    None => ()
  }
  match mapping.diagram_edit_part {
    Some(diagram_edit_part) =>
      mapping.layout_command = new_gmf_layout_edit_policy().get_command(
        request, diagram_edit_part,
      )
    None => ()
  }
}

///|
pub fn GmfDiagramLayoutConnector::apply_transferred_layout(
  _self : GmfDiagramLayoutConnector,
  mapping : GmfLayoutMapping,
) -> Unit {
  match mapping.layout_command {
    Some(command) =>
      match mapping.command_stack {
        Some(stack) => stack.execute(command)
        None => {
          let stack = new_gmf_command_stack()
          stack.execute(command)
          mapping.command_stack = Some(stack)
        }
      }
    None => ()
  }
}

///|
pub fn GmfDiagramLayoutConnector::apply_layout_internal(
  self : GmfDiagramLayoutConnector,
  mapping : GmfLayoutMapping,
  animation_time : Int,
) -> Unit {
  self.transfer_layout(mapping)
  ignore(animation_time)
  self.apply_transferred_layout(mapping)
}

///|
pub fn GmfDiagramLayoutConnector::apply_layout(
  self : GmfDiagramLayoutConnector,
  mapping : GmfLayoutMapping,
  settings : GmfConnectorLayoutSettings,
  viewer_not_visible? : Bool = false,
) -> Unit {
  mapping.animation_time = self.calc_animation_time(
    mapping, settings, viewer_not_visible,
  )
  self.apply_layout_internal(mapping, mapping.animation_time)
}
