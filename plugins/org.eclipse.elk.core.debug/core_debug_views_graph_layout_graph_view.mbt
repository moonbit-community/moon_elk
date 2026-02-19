///|
pub let layout_graph_view_id : String = "org.eclipse.elk.debug.graphView"

///|
fn layout_graph_view_filter(info : ExecutionInfo) -> Bool {
  execution_info_has_logged_graphs(info) ||
  execution_info_has_descendants_with_logged_graphs(info)
}

///|
pub struct LayoutGraphView {
  base : AbstractLayoutDebugView
  graph_list_label_provider : GraphListLabelProvider
  mut logged_graphs : Array[LoggedGraph]
  mut selected_logged_graph : LoggedGraph?
  mut visual_graph : ElkNode?
  mut textual_graph : String
  mut showing_visual_graph : Bool
}

///|
pub fn new_layout_graph_view() -> LayoutGraphView {
  {
    base: new_abstract_layout_debug_view(
      layout_graph_view_id, core_debug_pref_debug_logging, layout_graph_view_filter,
    ),
    graph_list_label_provider: new_graph_list_label_provider(),
    logged_graphs: [],
    selected_logged_graph: None,
    visual_graph: None,
    textual_graph: "",
    showing_visual_graph: false,
  }
}

///|
pub fn LayoutGraphView::get_base(
  self : LayoutGraphView,
) -> AbstractLayoutDebugView {
  self.base
}

///|
pub fn LayoutGraphView::get_selected_execution_infos(
  self : LayoutGraphView,
) -> Array[ExecutionInfo] {
  self.base.get_selected_execution_infos()
}

///|
pub fn LayoutGraphView::set_selected_execution_infos(
  self : LayoutGraphView,
  infos : Array[ExecutionInfo],
) -> Unit {
  self.base.set_selected_execution_infos(infos)
  self.tree_selection_changed()
}

///|
pub fn LayoutGraphView::tree_selection_changed(self : LayoutGraphView) -> Unit {
  let collected : Array[LoggedGraph] = []
  for info in self.base.get_selected_execution_infos() {
    for graph in execution_info_get_logged_graphs(info) {
      collected.push(graph)
    }
  }
  self.logged_graphs = collected
  if self.logged_graphs.is_empty() {
    self.selected_logged_graph = None
    self.visual_graph = None
    self.textual_graph = ""
    self.showing_visual_graph = false
  } else {
    self.selected_logged_graph = Some(self.logged_graphs[0])
    self.list_selection_changed()
  }
}

///|
pub fn LayoutGraphView::get_logged_graphs_for_test(
  self : LayoutGraphView,
) -> Array[LoggedGraph] {
  self.logged_graphs.copy()
}

///|
pub fn LayoutGraphView::select_logged_graph_for_test(
  self : LayoutGraphView,
  index : Int,
) -> Unit {
  if index < 0 || index >= self.logged_graphs.length() {
    self.selected_logged_graph = None
  } else {
    self.selected_logged_graph = Some(self.logged_graphs[index])
  }
  self.list_selection_changed()
}

///|
pub fn LayoutGraphView::list_selection_changed(self : LayoutGraphView) -> Unit {
  match self.selected_logged_graph {
    Some(graph) => self.show_logged_graph(graph)
    None => {
      self.visual_graph = None
      self.textual_graph = ""
      self.showing_visual_graph = false
    }
  }
}

///|
fn LayoutGraphView::show_graph_on_canvas(
  self : LayoutGraphView,
  graph : ElkNode?,
) -> Unit {
  self.showing_visual_graph = true
  self.visual_graph = graph
  self.textual_graph = ""
}

///|
fn LayoutGraphView::show_text_on_canvas(
  self : LayoutGraphView,
  text : String,
) -> Unit {
  self.showing_visual_graph = false
  self.textual_graph = text
  self.visual_graph = None
}

///|
pub fn LayoutGraphView::show_logged_graph(
  self : LayoutGraphView,
  graph_info : LoggedGraph,
) -> Unit {
  match graph_info.graph_type {
    ElkGraph =>
      if self.visual_graph is None {
        self.show_graph_on_canvas(Some(create_graph()))
      } else {
        self.show_graph_on_canvas(self.visual_graph)
      }
    _ => self.show_text_on_canvas(graph_info.tag)
  }
}

///|
pub fn LayoutGraphView::get_canvas_graph_for_test(
  self : LayoutGraphView,
) -> ElkNode? {
  if self.showing_visual_graph {
    self.visual_graph
  } else {
    None
  }
}

///|
pub fn LayoutGraphView::set_canvas_graph_for_test(
  self : LayoutGraphView,
  graph : ElkNode?,
) -> Unit {
  self.visual_graph = graph
}

///|
pub fn LayoutGraphView::get_textual_graph_for_test(
  self : LayoutGraphView,
) -> String {
  self.textual_graph
}

///|
pub fn LayoutGraphView::is_showing_visual_graph_for_test(
  self : LayoutGraphView,
) -> Bool {
  self.showing_visual_graph
}
