///|
pub struct GmfLayoutEditPolicy {
  point_list_map : Map[Int, GmfPointList]
}

///|
pub fn new_gmf_layout_edit_policy() -> GmfLayoutEditPolicy {
  { point_list_map: {} }
}

///|
pub fn GmfLayoutEditPolicy::understands_request(
  _self : GmfLayoutEditPolicy,
  req_type : String,
) -> Bool {
  req_type == req_apply_layout
}

///|
fn gmf_layout_edit_policy_scaled_int(value : Double, scale : Double) -> Int {
  (value * scale).to_int()
}

///|
fn gmf_layout_edit_policy_add_shape_layout(
  command : GmfLayoutCommand,
  element : GmfElkGraphElement,
  edit_part : GmfEditPart,
  scale : Double,
) -> Unit {
  let view = match gmf_edit_part_notation_view(edit_part) {
    Some(view) => view
    None => return
  }
  let shape_layout = match gmf_get_layout_element_shape(element) {
    Some(layout) => layout
    None => return
  }

  let new_x = gmf_layout_edit_policy_scaled_int(shape_layout.x, scale)
  let new_y = gmf_layout_edit_policy_scaled_int(shape_layout.y, scale)
  let location = if gmf_view_location_x(view) == new_x &&
    gmf_view_location_y(view) == new_y {
    None
  } else {
    Some(new_gmf_point(new_x, new_y))
  }

  let new_width = gmf_layout_edit_policy_scaled_int(shape_layout.width, scale)
  let new_height = gmf_layout_edit_policy_scaled_int(shape_layout.height, scale)
  let size = if gmf_view_width(view) == new_width &&
    gmf_view_height(view) == new_height {
    None
  } else {
    Some(new_gmf_dimension(new_width, new_height))
  }

  if location is Some(_) || size is Some(_) {
    command.add_shape_layout(view, location, size)
  }
}

///|
fn gmf_layout_edit_policy_scaled_bend_points(
  bend_points : GmfPointList,
  scale : Double,
) -> GmfPointList {
  let scaled = new_gmf_point_list()
  for point in bend_points.points {
    scaled.add_point(
      new_gmf_point(
        gmf_layout_edit_policy_scaled_int(point.x.to_double(), scale),
        gmf_layout_edit_policy_scaled_int(point.y.to_double(), scale),
      ),
    )
  }
  scaled
}

///|
fn gmf_layout_edit_policy_is_connection_attachment(
  connection_edit_part : GmfEditPart,
) -> Bool {
  let source_is_connection = match gmf_edit_part_source(connection_edit_part) {
    Some(source) => gmf_edit_part_kind(source) == ConnectionEditPart
    None => false
  }
  let target_is_connection = match gmf_edit_part_target(connection_edit_part) {
    Some(target) => gmf_edit_part_kind(target) == ConnectionEditPart
    None => false
  }
  source_is_connection || target_is_connection
}

///|
fn gmf_layout_edit_policy_add_edge_layout(
  command : GmfLayoutCommand,
  element : GmfElkGraphElement,
  connection_edit_part : GmfEditPart,
  scale : Double,
) -> Unit {
  let edge_view = match gmf_edit_part_notation_view(connection_edit_part) {
    Some(view) => view
    None => return
  }
  let edge_layout = match gmf_get_layout_element_edge(element) {
    Some(layout) => layout
    None => return
  }
  let bend_points = gmf_layout_edit_policy_scaled_bend_points(
    edge_layout.bends,
    scale,
  )
  if gmf_layout_edit_policy_is_connection_attachment(connection_edit_part) {
    while bend_points.size() > 2 {
      bend_points.remove_point(1)
    }
  }
  command.add_edge_layout(
    edge_view,
    Some(bend_points),
    edge_layout.source_terminal,
    edge_layout.target_terminal,
    edge_layout.junction_points,
  )
}

///|
pub fn GmfLayoutEditPolicy::get_command(
  self : GmfLayoutEditPolicy,
  request : ApplyLayoutRequest,
  host_edit_part : GmfEditPart,
) -> GmfLayoutCommand? {
  if !self.understands_request(request.get_type()) {
    return None
  }
  let command = new_gmf_layout_command(
    diagram_view=gmf_edit_part_notation_view(host_edit_part),
  )
  let scale = request.get_scale()

  for pair in request.get_elements() {
    let element = match pair.get_first() {
      Some(value) => value
      None => continue
    }
    let edit_part = match pair.get_second() {
      Some(value) => value
      None => continue
    }
    let kind = gmf_edit_part_kind(edit_part)
    if kind == ConnectionEditPart {
      gmf_layout_edit_policy_add_edge_layout(command, element, edit_part, scale)
    } else {
      gmf_layout_edit_policy_add_shape_layout(
        command, element, edit_part, scale,
      )
    }
  }

  command.set_oblique_routing(true)
  self.point_list_map.clear()
  Some(command)
}
