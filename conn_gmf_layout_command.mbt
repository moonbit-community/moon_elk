///|
pub let junction_points_style_name : String = "junctionPoints"

///|
pub struct GmfShapeLayoutData {
  view : GmfView
  location : GmfPoint?
  size : GmfDimension?
}

///|
pub struct GmfEdgeLayoutData {
  edge_view : GmfView
  bends : GmfPointList?
  junction_points : String?
  source_terminal : String?
  target_terminal : String?
}

///|
pub struct GmfLayoutCommand {
  label : String
  diagram_view : GmfView?
  mut shape_layouts : Array[GmfShapeLayoutData]
  mut edge_layouts : Array[GmfEdgeLayoutData]
  mut oblique_routing : Bool
}

///|
pub fn new_gmf_layout_command(
  label? : String = "Automatic Layout",
  diagram_view? : GmfView? = None,
) -> GmfLayoutCommand {
  {
    label,
    diagram_view,
    shape_layouts: [],
    edge_layouts: [],
    oblique_routing: false,
  }
}

///|
pub fn GmfLayoutCommand::get_label(self : GmfLayoutCommand) -> String {
  self.label
}

///|
pub fn GmfLayoutCommand::add_shape_layout(
  self : GmfLayoutCommand,
  view : GmfView,
  location : GmfPoint?,
  size : GmfDimension?,
) -> Unit {
  self.shape_layouts.push({ view, location, size })
}

///|
pub fn GmfLayoutCommand::add_edge_layout(
  self : GmfLayoutCommand,
  edge_view : GmfView,
  bends : GmfPointList?,
  source_terminal : String?,
  target_terminal : String?,
  junction_points : String?,
) -> Unit {
  self.edge_layouts.push({
    edge_view,
    bends,
    junction_points,
    source_terminal,
    target_terminal,
  })
}

///|
pub fn GmfLayoutCommand::set_oblique_routing(
  self : GmfLayoutCommand,
  oblique_routing : Bool,
) -> Unit {
  self.oblique_routing = oblique_routing
}

///|
pub fn GmfLayoutCommand::execute(self : GmfLayoutCommand) -> Unit {
  for shape_layout in self.shape_layouts {
    match shape_layout.location {
      Some(location) =>
        gmf_view_set_location(shape_layout.view, location.x, location.y)
      None => ()
    }
    match shape_layout.size {
      Some(size) =>
        gmf_view_set_size(shape_layout.view, size.width, size.height)
      None => ()
    }
  }
  self.shape_layouts = []

  for edge_layout in self.edge_layouts {
    match edge_layout.bends {
      Some(bends) => gmf_view_set_bendpoints(edge_layout.edge_view, bends)
      None => ()
    }

    match edge_layout.source_terminal {
      Some(value) =>
        gmf_view_set_source_terminal(edge_layout.edge_view, Some(value))
      None => ()
    }

    match edge_layout.target_terminal {
      Some(value) =>
        gmf_view_set_target_terminal(edge_layout.edge_view, Some(value))
      None => ()
    }

    match edge_layout.junction_points {
      Some(value) =>
        gmf_view_set_style(
          edge_layout.edge_view,
          junction_points_style_name,
          value,
        )
      None =>
        gmf_view_remove_style(edge_layout.edge_view, junction_points_style_name)
    }

    if self.oblique_routing {
      gmf_view_set_routing_manual(edge_layout.edge_view, true)
      gmf_view_set_smoothness_none(edge_layout.edge_view, true)
    }
  }
  self.edge_layouts = []
}

///|
pub fn GmfLayoutCommand::get_affected_files(
  self : GmfLayoutCommand,
) -> Array[String] {
  match self.diagram_view {
    Some(view) => [gmf_view_name(view)]
    None => []
  }
}
