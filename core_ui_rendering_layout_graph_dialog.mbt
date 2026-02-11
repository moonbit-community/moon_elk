///|
pub struct LayoutGraphDialog {
  graph : ElkNode
  resource_file_name : String?
  configurator : GraphRenderingConfigurator
  mut graph_canvas : GraphRenderingCanvas?
  mut shell_text : String
}

///|
pub fn new_layout_graph_dialog(
  graph : ElkNode,
  resource_file_name : String?,
  configurator : GraphRenderingConfigurator,
) -> LayoutGraphDialog {
  {
    graph,
    resource_file_name,
    configurator,
    graph_canvas: None,
    shell_text: "",
  }
}

///|
pub fn LayoutGraphDialog::is_resizable(self : LayoutGraphDialog) -> Bool {
  ignore(self)
  true
}

///|
pub fn LayoutGraphDialog::configure_shell(self : LayoutGraphDialog) -> Unit {
  self.shell_text = match self.resource_file_name {
    Some(file_name) =>
      if file_name.is_empty() {
        "Layout Graph"
      } else {
        file_name
      }
    None => "Layout Graph"
  }
}

///|
pub fn LayoutGraphDialog::get_shell_text(self : LayoutGraphDialog) -> String {
  self.shell_text
}

///|
pub fn LayoutGraphDialog::create_contents(
  self : LayoutGraphDialog,
  display : CoreUiDisplay,
) -> GraphRenderingCanvas {
  let canvas = new_graph_rendering_canvas_with_configurator(
    display,
    self.configurator,
  )
  canvas.setup_mouse_interaction()
  canvas.set_layout_graph(Some(self.graph))
  self.graph_canvas = Some(canvas)
  canvas
}

///|
pub fn LayoutGraphDialog::get_graph_canvas(
  self : LayoutGraphDialog,
) -> GraphRenderingCanvas? {
  self.graph_canvas
}
